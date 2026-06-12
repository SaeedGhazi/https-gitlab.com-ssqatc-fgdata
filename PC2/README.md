# PC2 — مرجع محیط اجرا و سناریوی فعلی (شبیه‌ساز برج مراقبت OIII)

این پوشه آرشیوی از فایل‌های مرجع ارسال‌شده توسط کاربر در نشست‌های قبلی است که برای
ادامه‌ی کار روی **شبیه‌ساز برج مراقبت ترافیک هوایی مبتنی بر FlightGear** نگه‌داری
می‌شود (تا با reset شدن کانتینر از بین نروند). PC2 = کامپیوتر فعلی پروژه. یک
PC1 قوی‌تر هم بعداً اضافه می‌شود.

## ساختار

```
PC2/
├── research-notes/   یادداشت‌های تحقیقاتی اولیه (بررسی سورس FlightGear/SimGear)
├── system-info/      مشخصات سخت‌افزاری/سیستم PC2
├── runtime-config/   اسکریپت اجرا + پیکربندی رندر/دوربین چندمانیتوره
├── scenario-data/     خروجی واقعی از یک نشست در حال اجرا (ground truth)
└── nasal-scripts/    اسکریپت‌های Nasal سفارشی پروژه (پیشوند SSQ_)
```

## خلاصه‌ی محیط (PC2)
- ASUS PRIME B660M-A D4, Intel i5-12400 (6C/12T), 64GB DDR4-2133, RTX 3050 8GB, Arch Linux.
- نمایش: `Screen 0` = 7680x1080 (۴ مانیتور 1920x1080: DP-1@0,0 / DP-3@1920,0 /
  DP-5@3840,0 / HDMI-0@5760,0).

## راه‌اندازی شبیه‌ساز (`runtime-config/3d_OIII_xdotool.sh`)
- `aircraft=ufo` در موقعیت برج فرودگاه **OIII** (مهرآباد، lat=35.690221،
  lon=51.322259)، `--ai-scenario=SSQ`، `--telnet=5000`، رندر سبک‌شده برای FPS.
- `runtime-config/oiii-camera.xml`: ۱۵ دوربین با FOV~17.3° (هر کدام -17.3°
  نسبت به قبلی) روی ۴ پنجره‌ی `OIII_1..4` → پوشش ~260° دید جلوی برج.
- `runtime-config/defaults.xml`: نسخه‌ی سفارشی‌شده‌ی fgdata/defaults.xml این
  پروژه (include کردن oiii-camera.xml، تنظیمات `<sim><tower>`، رندر سبک).

## سناریوی فعلی SSQ — یافته‌های Property Tree (ground truth)
فایل `scenario-data/property_tree_snapshot.json` یک dump واقعی از httpd JSON
هنگام اجرای سناریوی `SSQ` است (`/sim/ai/scenario=SSQ`, 6 بلیپ AI):

| index | callsign  |
|-------|-----------|
| 0 | A320 |
| 1 | MD80 |
| 2 | IRA-A346 |
| 3 | IRC-A346 |
| 4 | IRM-A346 |
| 5 | F50 |

- نودهای استاندارد `controls/flight/{lateral-mode,target-hdg,target-roll,
  vertical-mode,target-alt,target-pitch,target-spd}` دقیقاً مطابق یادداشت‌های
  تحقیقاتی (`research-notes/ATC_TOWER_TRAINER_NOTES1.md`) موجودند. ✅
- `/sim/tower`: `lat=35.690221, lon=51.322259, alt-ft=4136, airport-id=OIII,
  auto-position=true` (نکته: مقدار alt با `--altitude=7000` در launch script
  فرق دارد — احتمالاً auto-position آن را override کرده).
- `/instructor` در tree وجود ندارد (چون `SSQ_Weather.nas--` غیرفعال است).

`scenario-data/project_folder_files.txt`: dump کامل ساختار پوشه‌ی fg-root شامل
aircraft سفارشی `SSQ-IRAN-AIRLINES/A346` (لیوری‌های IRA/IRC/IRM)، سناریوهای
`AI/Traffic/SSQ*.xml`, `AI/FlightPlans/SSQ_FPL.xml.bk`, و `Scenery_OIII/`
(groundnet/ILS/threshold/twr + مدل سفارشی `SignalsSquare`).

## اسکریپت‌های Nasal سفارشی (`nasal-scripts/`)
- **`SSQ_set_primary_parameters_and_remain_on_the_GND.nas` (فعال، 5Hz)**:
  روی همه‌ی `/ai/models/aircraft[n]` بر اساس نودهای سفارشی string
  (`on-ground`, `gear-down`, `flaps-down` در ریشه‌ی هر aircraft) ارتفاع را به
  زمین قفل می‌کند، gear را جمع/باز می‌کند و وضعیت فلپ را تنظیم می‌کند، و در
  on-ground=true با سرعت >140kt حالت takeoff (`on-ground=false`,
  `target-alt=6000`) را فعال می‌کند.
  > ⚠️ **باگ شناخته‌شده**: این اسکریپت دنبال `surface-positions/flaps-pos-norm`
  > می‌گردد، اما property واقعی (طبق snapshot) `surface-positions/flap-pos-norm`
  > است (بدون "s") → بخش مدیریت فلپ عملاً اجرا نمی‌شود. باید فیکس شود.
- **`SSQ_Weather.nas--` (غیرفعال)**: کانال فرمان `/instructor/command` با
  فرمت `WEATHER;STORM;HEAVY` / `WEATHER;FOG;...` — الگوی پیشنهادی برای کانال
  فرمان instructor/کنترلر؛ می‌تواند پایه‌ی پروتکل فرمان‌دهی کلی شود.
- **`SSQ_stg_loader.nas--` (غیرفعال)**: ابزار توسعه برای تیون موقعیت مدل‌های
  استاتیک از فایل `.stg`.
- **`SSQ_CTRL_SHIFT_CLICK_coor_alt_to_file.nas`**: ابزار استخراج lat/lon/elev
  با کلیک یا گرید برای ساخت داده‌ی سناریو/scenery.
- **`SSQ_smoke.nas.orig`**: افکت آتش با کلیک ماوس (`geo.click_position` +
  `fgcommand("add-model", ...)`).

> یادآوری: `Aircraft/ufo/Nasal/SSQ_remote_control.nas---` (غیرفعال) در آرشیو
> Nasal.zip ارسالی نبود (zip فقط ریشه‌ی `fgdata/Nasal/` را داشت). اگر محتوای
> آن لازم شد، باید جدا ارسال شود.

## موارد باز / نکات برای ادامه
1. فیکس باگ `flap-pos-norm` در `SSQ_set_primary_parameters_and_remain_on_the_GND.nas`.
2. فعال‌سازی و تکمیل کانال فرمان instructor (الگوبرداری از `SSQ_Weather.nas--`).
3. سوالات باز فاز قبل (در `research-notes/ATC_TOWER_TRAINER_NOTES1.md`، بخش ۵)
   هنوز پابرجاست: نقش `ATC/trafficcontrol.cxx`/`TowerController`، فرمت AI
   scenario بدون flight-plan، و کانال داده برای N بلیپ متغیر.
4. مشخصات PC1 (قوی‌تر) بعداً اضافه می‌شود — پیشنهاد: یک پوشه‌ی موازی `PC1/`
   با همین ساختار.
