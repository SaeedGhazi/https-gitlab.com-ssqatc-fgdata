#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""تولید فایل‌های NavData/Navaids فلایت‌گیر از داده‌ی واقعی Iran FIR (AIP)."""
import csv, re, os
from openpyxl import load_workbook

SRC="/root/.claude/uploads/72981597-461f-52bc-8d4d-8d695de372be"
OUT="/home/user/navdata_build/out"
os.makedirs(OUT, exist_ok=True)

import math
def dms2dec(s):
    """'354144.03N' یا '0511853E' -> اعشاری"""
    if not s: return None
    s=s.strip()
    m=re.match(r'^(\d{2,3})(\d{2})(\d{2}(?:\.\d+)?)([NSEW])$', s)
    if not m: return None
    d,mi,se,h=m.groups()
    val=int(d)+int(mi)/60+float(se)/3600
    if h in ('S','W'): val=-val
    return round(val,8)

def parse_latlon(cell):
    """سلولِ 'LATdms LONdms' -> (lat,lon)"""
    if not cell: return (None,None)
    lat=lon=None
    for t in re.findall(r'\d{6,7}(?:\.\d+)?[NSEW]', cell):
        if t[-1] in 'NS': lat=dms2dec(t)
        else: lon=dms2dec(t)
    return (lat,lon)

def project(lat,lon,brg_deg,dist_m):
    """نقطه‌ی جدید در فاصله/بیرینگ داده‌شده (تقریب کروی) برای سرِ مقابل باند"""
    R=6371000.0; br=math.radians(brg_deg); d=dist_m/R
    la=math.radians(lat); lo=math.radians(lon)
    la2=math.asin(math.sin(la)*math.cos(d)+math.cos(la)*math.sin(d)*math.cos(br))
    lo2=lo+math.atan2(math.sin(br)*math.sin(d)*math.cos(la),
                      math.cos(d)-math.sin(la)*math.sin(la2))
    return (round(math.degrees(la2),8), round(math.degrees(lo2),8))

def parse_var(name):
    """استخراج واریاسیون مغناطیسی از نام مثل '(4° E)' یا '(3°30 ʹ E)'"""
    if not name: return 0.0
    m=re.search(r'\((\d+)°\s*(\d+)?\s*[ʹ\']?\s*([EW])', name)
    if not m: return 0.0
    deg=int(m.group(1)); mn=int(m.group(2)) if m.group(2) else 0
    v=deg+mn/60.0
    return v if m.group(3)=='E' else -v

def parse_freq_mhz(s):
    """اولین فرکانس MHz را به ده‌هزارم MHz تبدیل کن: '115.100 MHZ'->11510"""
    m=re.search(r'(\d{3}\.\d+|\d{3})\s*MHZ', s, re.I)
    if not m: return None
    return int(round(float(m.group(1))*100))

def parse_freq_khz(s):
    m=re.search(r'(\d{2,3})\s*KHZ', s, re.I)
    return int(m.group(1)) if m else None

# ---------- 1) POINTS.xlsx -> fix.dat (DR) + nav.dat (navaids) ----------
wb=load_workbook(os.path.join(SRC,"a0fecc7d-POINTS.xlsx"), read_only=True, data_only=True)
ws=wb.active
prows=[r for r in ws.iter_rows(values_only=True)][1:]

fixes={}     # ident -> (lat,lon)
nav_lines=[] # nav.dat رکوردها
navaids_count={'VOR':0,'NDB':0,'DME':0,'TACAN':0}

for r in prows:
    ident=(r[0] or "").strip()
    if not ident: continue
    typ=(r[1] or "").strip()
    lat=r[5]; lon=r[6]
    if lat is None or lon is None: continue
    lat=round(float(lat),8); lon=round(float(lon),8)
    name=(r[11] or ident).strip()
    freq=(r[9] or "")
    alt=r[10]
    try: elev=int(float(alt)) if alt not in (None,"") else 0
    except: elev=0

    if typ=="DR" or not freq:
        fixes[ident]=(lat,lon)
        continue
    # navaid
    var=parse_var(name)
    mhz=parse_freq_mhz(freq); khz=parse_freq_khz(freq)
    cleanname=re.sub(r'\s*\([^)]*\)','',name).strip()
    # حذف توکن نوع از انتهای نام تا تکرار نشود (مثل 'ABADAN DVOR/DME' -> 'ABADAN')
    cleanname=re.sub(r'\s*(D?VOR(TAC)?(/DME)?|NDB(/DME)?|DME|TACAN)\s*$','',cleanname,flags=re.I).strip() or ident
    if "NDB" in typ:
        if khz:
            nav_lines.append(f"2  {lat:11.8f} {lon:13.8f} {elev:6d} {khz:5d}  50    0.0 {ident:4s} {cleanname} NDB")
            navaids_count['NDB']+=1
        if "DME" in typ and mhz:
            nav_lines.append(f"12 {lat:11.8f} {lon:13.8f} {elev:6d} {mhz:5d}  25    0.0 {ident:4s} {cleanname} DME")
            navaids_count['DME']+=1
    else:  # VOR / DVOR / VORTAC (+DME)
        if mhz:
            nav_lines.append(f"3  {lat:11.8f} {lon:13.8f} {elev:6d} {mhz:5d} 130  {var:5.1f} {ident:4s} {cleanname} VOR")
            navaids_count['VOR']+=1
            if "TAC" in typ:
                nav_lines.append(f"13 {lat:11.8f} {lon:13.8f} {elev:6d} {mhz:5d} 130    0.0 {ident:4s} {cleanname} VORTAC")
                navaids_count['TACAN']+=1
            elif "DME" in typ:
                nav_lines.append(f"12 {lat:11.8f} {lon:13.8f} {elev:6d} {mhz:5d}  25    0.0 {ident:4s} {cleanname} DME")
                navaids_count['DME']+=1

# ---------- 2) IRANFIRROUTES.csv -> awy.dat (+ افزودن waypointهای مسیر به fix) ----------
routes={}
with open(os.path.join(SRC,"aa9d4230-IRANFIRROUTES.csv"), encoding='utf-8-sig') as f:
    rd=csv.reader(f)
    hdr=next(rd)
    for row in rd:
        if len(row)<8 or not row[0].strip(): continue
        rid=row[0].strip()
        order=row[1].strip()
        wp=(row[2] or "").strip()
        latdd=row[6]; londd=row[7]
        mnm=row[11] if len(row)>11 else ""
        if not order or not wp: continue
        try:
            lat=round(float(latdd),8); lon=round(float(londd),8)
        except: continue
        # شناسه‌ی تمیز waypoint: اگر داخل پرانتز کد دارد بردار، وگرنه کلمه‌ی اول
        m=re.search(r'\(([A-Z0-9]{2,5})\)', wp)
        ident=m.group(1) if m else re.split(r'[\s,;]+', wp)[0][:5].upper()
        ident=re.sub(r'[^A-Z0-9]','',ident) or "WPT"
        routes.setdefault(rid,[]).append((int(order) if order.isdigit() else len(routes.get(rid,[]))+1, ident, lat, lon, mnm))
        if ident not in fixes:
            fixes[ident]=(lat,lon)

def fl(s, default):
    m=re.search(r'FL?\s*(\d{2,3})', s or "")
    return int(m.group(1)) if m else default

awy_lines=[]
for rid, pts in routes.items():
    pts.sort(key=lambda x:x[0])
    for i in range(len(pts)-1):
        _,id1,la1,lo1,mnm1=pts[i]
        _,id2,la2,lo2,mnm2=pts[i+1]
        base=fl(mnm1,50); 
        top=600 if (mnm1 and 'UNL' in mnm1.upper()) else fl(mnm1,460)
        if top<=base: top=base+10
        awy_lines.append(f"{id1:5s} {la1:10.6f} {lo1:11.6f} {id2:5s} {la2:10.6f} {lo2:11.6f} 1 {base:03d} {top:03d} {rid}")

# ---------- 3) IRANFIRAIRPORTS.csv -> apt.dat ----------
SURF={'asphalt':1,'concrete':2,'turf':3,'grass':3,'dirt':4,'gravel':5,'water':13}
apts={}  # icao -> {name,elev,arp,var,rwys:{rwyid:row}}
with open(os.path.join(SRC,"064a82cd-IRANFIRAIRPORTS.csv"), encoding='utf-8-sig') as f:
    rd=csv.DictReader(f)
    for row in rd:
        icao=(row.get('ICAO-name') or "").strip()
        if not icao: continue
        a=apts.setdefault(icao, {'name':(row.get('NAME') or icao).strip().title(),
                                 'elev':row.get('AD Elevation'),'arp':row.get('ARP Coordinates'),
                                 'var':row.get('Variation'),'rwys':{}})
        rwy=(row.get('RWY') or "").strip()
        if rwy:
            a['rwys'][rwy]=row

def recip(rwy):
    m=re.match(r'^(\d{1,2})([LRC]?)$', rwy)
    if not m: return None
    num=int(m.group(1)); suf=m.group(2)
    rnum=(num+18-1)%36+1
    rsuf={'L':'R','R':'L','C':'C','':''}[suf]
    return f"{rnum:02d}{rsuf}"

def num_or(v, default=0):
    try: return int(float(re.sub(r'[^0-9.]','',v or "")))
    except: return default

apt_blocks=[]
for icao,a in sorted(apts.items()):
    # ارتفاع میدان: اول AD Elevation، اگر خالی بود میانگین THR
    elev=num_or(a['elev'], None)
    if elev is None:
        tes=[num_or(r.get('THR elevation(FT)'),None) for r in a['rwys'].values()]
        tes=[x for x in tes if x is not None]
        elev=int(sum(tes)/len(tes)) if tes else 0
    lines=[f"1 {elev:8d} 0 0 {icao} {a['name']}"]
    done=set()
    for rwy,row in a['rwys'].items():
        if rwy in done: continue
        rr0=recip(rwy)
        done.add(rwy)
        dim=(row.get('Dimensions(Meter)') or "").lower()
        wm=re.search(r'x\s*(\d+)', dim); width=float(wm.group(1)) if wm else 45.0
        lm=re.search(r'(\d+)\s*x', dim);  length=float(lm.group(1)) if lm else 2500.0
        surf=2
        for k,v in SURF.items():
            if k in (row.get('surface') or "").lower(): surf=v; break
        la1,lo1=parse_latlon(row.get('THR coordinates'))
        if la1 is None or lo1 is None: continue
        row2=a['rwys'].get(rr0)
        if row2:
            done.add(rr0); rr=rr0
            la2,lo2=parse_latlon(row2.get('THR coordinates'))
        else:
            rr=rr0 or "XX"
            # سرِ مقابل را از روی بیرینگ و طول باند بساز
            brg=num_or(row.get('TRUE BRG'),0)
            la2,lo2=project(la1,lo1,brg,length)
        if la2 is None or lo2 is None: continue
        lines.append(f"100 {width:6.2f} {surf} 0 0.25 1 2 1 "
                     f"{rwy:3s} {la1:12.8f} {lo1:13.8f} 0.00 0.00 2 6 1 1 "
                     f"{rr:3s} {la2:12.8f} {lo2:13.8f} 0.00 0.00 2 6 1 1")
    apt_blocks.append((icao,"\n".join(lines)))

# ---------- 4) OIII_stands.csv -> پارکینگ به بلوک OIII اضافه کن ----------
stands=[]
with open(os.path.join(SRC,"19262067-OIII_stands.csv"), encoding='utf-8-sig') as f:
    rd=csv.DictReader(f)
    for row in rd:
        nr=(row.get('NR') or "").strip()
        coord=(row.get('Stand Coordinates') or "").strip()
        if not nr or 'not AVBL' in coord: continue
        la=dms2dec(coord.split()[0]) if coord.split() else None
        lo=dms2dec(coord.split()[1]) if len(coord.split())>1 else None
        if la is None or lo is None: continue
        stands.append(f"1300 {la:12.8f} {lo:13.8f} 0.0 misc jets|turboprops Gate_{nr}")
# تزریق به بلوک OIII
for i,(icao,blk) in enumerate(apt_blocks):
    if icao=="OIII" and stands:
        apt_blocks[i]=(icao, blk+"\n"+"\n".join(stands))

# ---------- نوشتن خروجی‌ها ----------
HDR_FIX="I\n610 Version - Iran FIR custom (from AIP, generated)\n"
HDR_NAV="I\n810 Version - Iran FIR custom navaids (from AIP, generated)\n"
HDR_AWY="I\n640 Version - Iran FIR custom airways (from AIP, generated)\n"
HDR_APT="I\n1000 Version - Iran FIR custom airports (from AIP, generated)\n"

with open(f"{OUT}/fix.dat","w",encoding='utf-8') as f:
    f.write(HDR_FIX)
    for ident,(la,lo) in sorted(fixes.items()):
        f.write(f" {la:10.6f} {lo:11.6f} {ident}\n")
    f.write("99\n")

with open(f"{OUT}/nav.dat","w",encoding='utf-8') as f:
    f.write(HDR_NAV)
    for ln in nav_lines: f.write(ln+"\n")
    f.write("99\n")

with open(f"{OUT}/awy.dat","w",encoding='utf-8') as f:
    f.write(HDR_AWY)
    for ln in awy_lines: f.write(ln+"\n")
    f.write("99\n")

with open(f"{OUT}/apt.dat","w",encoding='utf-8') as f:
    f.write(HDR_APT)
    for icao,blk in apt_blocks: f.write(blk+"\n\n")
    f.write("99\n")

# poi.dat حداقلی
with open(f"{OUT}/poi.dat","w",encoding='utf-8') as f:
    f.write("# poi.dat v1.02 - Iran FIR custom (minimal)\n10 35.6892 51.3890 Iran\n")

# ---------- گزارش ----------
print("=== خلاصه‌ی تولید ===")
print(f"fix.dat : {len(fixes)} فیکس")
print(f"nav.dat : {len(nav_lines)} رکورد  (VOR={navaids_count['VOR']}, NDB={navaids_count['NDB']}, DME={navaids_count['DME']}, TACAN={navaids_count['TACAN']})")
print(f"awy.dat : {len(awy_lines)} قطعه از {len(routes)} مسیر")
print(f"apt.dat : {len(apt_blocks)} فرودگاه، {len(stands)} پارکینگ OIII")
