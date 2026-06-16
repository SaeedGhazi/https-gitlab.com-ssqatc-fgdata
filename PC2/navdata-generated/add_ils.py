#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""افزودن رکوردهای ILS (LOC/GS/DME) از AIP به nav.dat موجود."""
import re, math
NAV="/home/user/navdata_build/out/nav.dat"

def dms2dec(s):
    m=re.match(r'^(\d{2,3})(\d{2})(\d{2}(?:\.\d+)?)([NSEW])$', s.strip())
    d,mi,se,h=m.groups(); v=int(d)+int(mi)/60+float(se)/3600
    return -v if h in 'SW' else round(v,8)
def project(lat,lon,brg,dist_m):
    R=6371000.0; br=math.radians(brg); d=dist_m/R
    la=math.radians(lat); lo=math.radians(lon)
    la2=math.asin(math.sin(la)*math.cos(d)+math.cos(la)*math.sin(d)*math.cos(br))
    lo2=lo+math.atan2(math.sin(br)*math.sin(d)*math.cos(la),math.cos(d)-math.sin(la)*math.sin(la2))
    return (round(math.degrees(la2),8),round(math.degrees(lo2),8))

# هر ILS: (icao, rwy, loc_ident, loc_freq, thr_dms, true_brg, length_m, var_E, gs_angle, dme_ident, dme_elev, cat)
ILS=[
 ("OICC","29","IKMS",11110,"342020.75N 0471029.39E",296.09,3220,3.5,3.0,"IKMS",4297,"ILS-cat-I"),
 ("OIIE","29R","IIKA",11030,"352447.33N 0510957.43E",288.86,4198,5.0,3.0,"IIKA",3275,"ILS-cat-II"),
 ("OIII","29L","ITHL",10990,"354056.69N 0512001.06E",289.68,4035,5.0,3.3,"ITHL",3981,"ILS-cat-I"),
 ("OIII","29R","ITRN",11070,"354104.28N 0512001.38E",289.65,3646,5.0,3.3,"ITRN",3858,"ILS-cat-I"),
 ("OIMM","31R","IMSD",10990,"361326.45N 0593925.71E",313.60,3810,4.0,3.0,"IMSD",3262,"ILS-cat-I"),
 ("OISS","29L","ISYZ",10990,"293145.09N 0523633.08E",294.48,4271,3.0,3.0,"ISYZ",4866,"ILS-cat-I"),
]

lines=[]
for icao,rwy,lid,freq,thr,tbrg,length,var,gs,did,delev,cat in ILS:
    la=dms2dec(thr.split()[0]); lo=dms2dec(thr.split()[1])
    magbrg=round(tbrg-var,3)                      # کورس مغناطیسی localizer
    # آنتن LOC در سرِ دور باند: از آستانه‌ی فرود در امتداد heading فرود به‌اندازه‌ی طول
    locla,loclo=project(la,lo,tbrg,length)
    gscode=int(round(gs*100))                     # زاویه‌ی GS ×100
    # کد 4 = LOC ؛ کد 6 = GS ؛ کد 12 = ILS-DME
    lines.append(f"4  {locla:11.8f} {loclo:13.8f} {delev:6d} {freq:5d}  18  {magbrg:11.3f} {lid:4s} {icao} {rwy:3s} {cat}")
    lines.append(f"6  {la:11.8f} {lo:13.8f} {delev:6d} {freq:5d}  10  {gscode*1000+magbrg:11.3f} {lid:4s} {icao} {rwy:3s} GS")
    lines.append(f"12 {la:11.8f} {lo:13.8f} {delev:6d} {freq:5d}  25     0.000 {did:4s} {icao} {rwy:3s} DME-ILS")

# درج پیش از خط پایانی 99
with open(NAV) as f: content=f.read().rstrip()
content=content[:-2].rstrip() if content.endswith("99") else content
with open(NAV,"w") as f:
    f.write(content+"\n# --- ILS records added from AIP (OICC/OIIE/OIII/OIMM/OISS) ---\n")
    f.write("\n".join(lines)+"\n99\n")
print(f"افزوده شد: {len(lines)} رکورد ILS برای {len(ILS)} باند")
for l in lines: print(" ", l)
