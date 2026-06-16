# راهنمای استقرار و جایگزینی داده‌ی ناوبری Iran FIR

این بسته از روی داده‌ی واقعی AIP (فایل‌های `POINTS.xlsx`, `IRANFIRROUTES.csv`,
`IRANFIRAIRPORTS.csv`, `OIII_stands.csv`) ساخته شده و شامل کل Iran FIR است.

## محتوای تولیدشده
| فایل | تعداد رکورد | منبع |
|------|-------------|------|
| `apt.dat` | **88 فرودگاه** (+ ۵۴ پارکینگ OIII) | IRANFIRAIRPORTS + OIII_stands |
| `nav.dat` | **125 رکورد** (54 VOR، 11 NDB، 59 DME، 1 TACAN) | POINTS (navaidها) |
| `fix.dat` | **521 فیکس** | POINTS (DR) + waypointهای مسیرها |
| `awy.dat` | **997 قطعه** از 149 مسیر | IRANFIRROUTES |
| `poi.dat` | حداقلی | — |

دو شکل ارائه شده:
- `Scenery_OIII/NavData/{apt,awy,fix,nav,poi}/*.dat` → روش **scenery override** (امن)
- `global/Airports/*.gz` و `global/Navaids/*.gz` → روش **جایگزینی سراسری** (سبک‌سازی)

---

## ⚠️ قبل از هر کاری: پشتیبان بگیر
```bash
cd $FG_ROOT
cp Airports/apt.dat.gz Airports/apt.dat.gz.BAK
cp -r Navaids Navaids.BAK
```

---

## روش A — Scenery Override (توصیه‌شده؛ بازگشت‌پذیر، بدون حذف داده‌ی جهانی)

داده‌ی جهانی دست‌نخورده می‌ماند؛ داده‌ی Iran شما **قبل از** آن لود می‌شود (اولویت).

```bash
# داخل پوشه‌ی scenery پروژه (که در --fg-scenery ثبت است)
cp -r Scenery_OIII/NavData  <scenery_path>/Scenery_OIII/
```
ساختار نهایی:
```
Scenery_OIII/
└── NavData/
    ├── apt/apt.dat
    ├── awy/awy.dat
    ├── fix/fix.dat
    ├── nav/nav.dat
    └── poi/poi.dat
```
> چون NavDataCache فایل‌های scenery را اول می‌خواند، رکوردهای شما اولویت دارند.
> برای جلوگیری از دوگانگی فرودگاه (مثل OIII در هر دو)، یا روش B را بگیر یا OIII را
> از apt.dat جهانی حذف کن.

---

## روش B — جایگزینی سراسری (برای محدودسازی واقعی حجم و سبک‌سازی)

کل داده‌ی جهانی را با داده‌ی Iran جایگزین می‌کند → فقط ۸۸ فرودگاه ایران، navaid و
مسیرهای ایران باقی می‌مانند. کش navdata کوچک و سریع می‌شود.

```bash
cd $FG_ROOT
# جایگزینی (بعد از پشتیبان!)
cp global/Airports/apt.dat.gz   Airports/apt.dat.gz
cp global/Navaids/nav.dat.gz    Navaids/nav.dat.gz
cp global/Navaids/fix.dat.gz    Navaids/fix.dat.gz
cp global/Navaids/awy.dat.gz    Navaids/awy.dat.gz
# poi اختیاری (فقط برچسب نقشه):
cp global/Navaids/poi.dat.gz    Navaids/poi.dat.gz
```

> ⚠️ با این کار همه‌ی فرودگاه‌های خارج از ایران از شبیه‌ساز حذف می‌شوند. اگر فقط
> برای پروژه‌ی برج OIII است، این دقیقاً همان «محدودسازی» موردنظر است.

---

## بازسازی کش (الزامی بعد از هر دو روش)

کش navdata با تغییر فایل‌ها **خودکار** بازسازی می‌شود. اگر نشد، دستی پاک کن:
```bash
rm -f $FG_HOME/navdata.cache  $FG_HOME/navdata_*.cache
```
اجرای بعدی FlightGear پیام «Rebuilding navigation database» را نشان می‌دهد (طبیعی).

---

## تست صحت
1. در launcher یا `--airport=OIII` بالا بیا.
2. منوی **Equipment → Radio**: VOR `TRN 115.30`، `RUS 116.95` باید قابل تنظیم باشند.
3. **Map (F10 یا منوی Map)**: فرودگاه‌های ایران، VOR/NDBها و airwayها باید دیده شوند.
4. `--telnet=5000` → `get /airports/OIII` یا property browser برای تایید باندها.

---

## به‌روزرسانی AIP (نسخه‌ی ۲)
از روی AIP رسمی ۵ فرودگاه (OICC، OIIE، OIII، OIMM، OISS) موارد زیر اضافه شد:
- **ILS کامل** (LOC کد 4 + GS کد 6 + ILS-DME کد 12) برای ۶ باند:
  OICC 29، OIIE 29R (CAT II)، OIII 29L و 29R، OIMM 31R، OISS 29L.
  کورس localizer مغناطیسی = بیرینگ true منهای واریاسیون؛ زاویه‌ی GS از AIP.
- **فرکانس‌های ATC** (TWR/GND/APP/ATIS، کدهای 50/53/54/55) برای همین ۵ فرودگاه.

## ⚠️ محدودیت‌های شناخته‌شده (صادقانه)
- **ILS فقط برای ۵ فرودگاهِ دارای AIP** اضافه شد؛ بقیه‌ی فرودگاه‌ها ILS ندارند
  (داده‌اش در منبع نبود). با AIP فرودگاه‌های دیگر قابل تکمیل است.
- آنتن LOC در سرِ دور باند با projection (بیرینگ+طول) جای‌گذاری شده؛ کورس دقیق و
  جهت درست است، ولی موقعیت آنتن نسبت به مختصات دقیق AIP چند ده متر تفاوت دارد.
- **سرِ مقابل باندهای جفت‌نشده** با projection از بیرینگ+طول ساخته شده (تقریبی).
- **ارتفاع فرودگاه**: اگر AD Elevation در CSV خالی بود، از میانگین THR استفاده شد.
- **تجزیه‌ی نام waypoint** در مسیرها heuristic است؛ چند ident ممکن است نیاز به
  اصلاح دستی داشته باشند.
- داده‌ی بصری (`.btg`) با این تغییر عوض نمی‌شود (بخش ۱۷ مانوال) — فقط لایه‌ی منطقی.

---

## بازگردانی (Undo)
```bash
cd $FG_ROOT
mv Airports/apt.dat.gz.BAK Airports/apt.dat.gz
rm -rf Navaids && mv Navaids.BAK Navaids
rm -f $FG_HOME/navdata*.cache
```
