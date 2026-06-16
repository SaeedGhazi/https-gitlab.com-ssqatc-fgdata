#!/usr/bin/env python3
# -*- coding: utf-8 -*-
APT="/home/user/navdata_build/out/apt.dat"
COMM={
 "OICC":[(54,122.450,"Kermanshah Tower"),(50,126.800,"Kermanshah ATIS")],
 "OIIE":[(54,118.700,"IKA Tower"),(53,121.600,"IKA Ground"),(50,127.200,"IKA ATIS")],
 "OIII":[(54,118.100,"Mehrabad Tower"),(53,121.900,"Mehrabad Ground"),(55,125.100,"Mehrabad Approach")],
 "OIMM":[(54,118.100,"Mashhad Tower"),(53,121.900,"Mashhad Ground"),(55,127.300,"Mashhad Approach")],
 "OISS":[(54,118.100,"Shiraz Tower"),(53,121.900,"Shiraz Ground"),(55,119.000,"Shiraz Approach")],
}
with open(APT) as f: lines=f.read().split("\n")
out=[]; cur=None
def comm_lines(cur):
    return [f"{c} {int(round(fr*100)):5d} {nm}" for c,fr,nm in COMM.get(cur,[])]
for ln in lines:
    # پایان بلوک = خط خالی: قبل از آن فرکانس‌ها را بریز
    if ln.strip()=="" and cur:
        out += comm_lines(cur); cur=None
    if ln.startswith("1 ") and len(ln.split())>=5:
        cur=ln.split()[4]
    out.append(ln)
with open(APT,"w") as f: f.write("\n".join(out))
print("OK")
