# راهنمای شروع نشست جدید — پروژه ATC Tower Trainer (FlightGear)

این فایل برای این نوشته شده که در یک **نشست جدید** (با ۴ ریپو از همان ابتدا)
به‌سرعت context کامل پروژه بازسازی شود. اول این فایل را بخوان، بعد برای
جزئیات فنی کامل به `PC2/README.md` و `PC2/research-notes/ATC_TOWER_TRAINER_NOTES1.md`
مراجعه کن.

## هدف پروژه

ساخت یک **شبیه‌ساز برج مراقبت ترافیک هوایی (ATC Tower Trainer)** مبتنی بر
FlightGear برای آموزش کنترلرهای ترافیک هوایی:
- یک انسان (متدرّب کنترلر) در نقش ناظر، با aircraft از نوع `ufo` در موقعیت
  برج (Tower View) قرار می‌گیرد.
- چند هواپیمای AI ("بلیپ") از طریق یک AI scenario سفارشی (`SSQ`) لود می‌شوند.
- کنترلر باید بتواند به این بلیپ‌ها دستور بدهد (هدینگ/ارتفاع/سرعت/...) — این
  دستورها از طریق **Property Tree** فلایت‌گیر (Telnet/HTTP JSON/Generic UDP)
  به نودهای استاندارد `/ai/models/aircraft[n]/controls/flight/*` نوشته
  می‌شوند.
- هدف از دسترسی به سورس‌های FlightGear/SimGear/TerraGear **فقط مطالعه‌ی
  منطق، متغیرها، روابط و پروتکل‌ها** است، نه تغییر این سورس‌ها. سیستم نهایی
  (GUI کنترلر + اسکریپت‌های Nasal + داده‌های سناریو) یک لایه‌ی **خارجی** است
  که با FlightGear از طریق Property Tree حرف می‌زند.

## ریپوهای پروژه (۴ ریپو)

| ریپو | نقش | نسخه/وضعیت |
|------|-----|------------|
| `https-gitlab.com-ssqatc-flightgear` | سورس اصلی FlightGear (مرجع منطق AIModel/ATC/Network) | اسنپ‌شات ~آوریل ۲۰۲۰، فایل `version` = `2019.2.0` |
| `https-gitlab.com-ssqatc-fgdata` | داده‌های FlightGear + آرشیو پروژه (`PC2/`) | فایل `version` = `2024.2.0` |
| `https-gitlab.com-ssqatc-simgear` | کتابخانه‌ی پایه (SGPropertyNode/property tree, props_io, کد پایه‌ی پروتکل‌ها) | تازه اضافه شده — هنوز بررسی نشده |
| `https-gitlab.com-ssqatc-terragear` | ابزار ساخت/ویرایش سینری (برای `Scenery_OIII`) | قرار است اضافه شود |

> ⚠️ نکته: اختلاف نسخه‌ی flightgear (~۲۰۲۰) و fgdata (۲۰۲۴.۲) باعث می‌شود برخی
> property/feature‌ها بین این دو ممکن است کمی فرق داشته باشند — همیشه در صورت
> شک، با `PC2/scenario-data/property_tree_snapshot.json` (دیتای واقعی از یک
> اجرای زنده) کراس‌چک شود.

## کارهایی که تا الان انجام شده

1. یادداشت‌های تحقیقاتی اولیه (`ATC_TOWER_TRAINER_NOTES1.md`) با snapshot واقعی
   property tree کراس‌چک شد — نودهای
   `controls/flight/{lateral-mode,target-hdg,target-roll,vertical-mode,
   target-alt,target-pitch,target-spd}` دقیقاً مطابق یادداشت‌ها تایید شدند.
2. مسیر `FGTowerController` در سورس flightgear پیدا و تایید شد:
   `src/ATC/trafficcontrol.{hxx,cxx}` (نه یک فایل جدای `TowerController.*` —
   این اصلاح نسبت به فرضیات قبلی است).
3. تمام فایل‌های مرجعی که کاربر فرستاده بود (مشخصات سخت‌افزار PC2، اسکریپت‌های
   اجرا/رندر، snapshot واقعی property tree، dump کامل ساختار پوشه‌ی fg-root،
   و ۵ اسکریپت Nasal سفارشی) در پوشه‌ی `PC2/` داخل ریپوی `fgdata` ذخیره،
   دسته‌بندی و کامیت/پوش شدند (branch: `claude/continuing-previous-discussion-6tpgsr`).
4. ساختار فعلی `PC2/`:
   ```
   PC2/
   ├── README.md                  ← خلاصه کامل فنی پروژه (مرجع اصلی جزئیات)
   ├── SESSION_HANDOFF.md          ← همین فایل
   ├── research-notes/             یادداشت تحقیقاتی اولیه
   ├── system-info/                مشخصات سخت‌افزار/سیستم PC2
   ├── runtime-config/              اسکریپت اجرا + پیکربندی رندر/دوربین
   ├── scenario-data/               dump واقعی property tree + لیست فایل‌های fg-root
   └── nasal-scripts/               اسکریپت‌های Nasal سفارشی پروژه (SSQ_*)
   ```
5. سناریوی فعلی `SSQ` (فرودگاه OIII/مهرآباد) با ۶ بلیپ AI تایید شد:
   A320, MD80, IRA-A346, IRC-A346, IRM-A346, F50.
6. یک باگ واقعی در کد پروژه پیدا شد (هنوز فیکس نشده):
   در `nasal-scripts/SSQ_set_primary_parameters_and_remain_on_the_GND.nas`
   اسکریپت دنبال `surface-positions/flaps-pos-norm` می‌گردد، اما property
   واقعی `surface-positions/flap-pos-norm` (بدون "s") است → منطق فلپ عملاً
   اجرا نمی‌شود.

## PC1 و PC2 چیستند؟

- **PC2** = کامپیوتر فعلی پروژه که سناریو روی آن اجرا می‌شود (ASUS PRIME
  B660M-A D4, i5-12400, 64GB RAM, RTX 3050 8GB, Arch Linux، ۴ مانیتور
  7680x1080). مشخصات کامل در `PC2/system-info/`.
- **PC1** = یک کامپیوتر قوی‌تر که **بعداً** به پروژه اضافه می‌شود؛ کاربر
  مشخصاتش را در یک نشست بعدی می‌فرستد. وقتی رسید، باید یک پوشه‌ی موازی
  `PC1/` با همان ساختار `PC2/` (system-info, runtime-config, ...) ساخته شود.

## موارد باز / کارهای بعدی (برای نشست جدید)

1. بررسی ریپوهای تازه‌اضافه‌شده `simgear` (اولویت بالا — هسته‌ی property tree
   و پروتکل‌ها) و `terragear` (اولویت پایین‌تر — فقط اگر کار روی
   `Scenery_OIII` لازم شد).
2. فیکس باگ `flap-pos-norm` در `SSQ_set_primary_parameters_and_remain_on_the_GND.nas`.
3. فعال‌سازی/تکمیل کانال فرمان instructor (الگوبرداری از
   `nasal-scripts/SSQ_Weather.nas--` که فعلاً غیرفعال است، روی property
   `/instructor/command`).
4. سوالات باز بخش ۵ یادداشت‌های تحقیقاتی (`research-notes/ATC_TOWER_TRAINER_NOTES1.md`):
   نقش دقیق `FGTowerController`/`trafficcontrol.cxx`، فرمت AI scenario برای
   بلیپ‌های بدون flight-plan، و طراحی کانال داده برای N بلیپ متغیر.
5. ایجاد پوشه‌ی `PC1/` وقتی مشخصات PC1 رسید.
6. محتوای `Aircraft/ufo/Nasal/SSQ_remote_control.nas---` (در آرشیو فعلی موجود
   نبود) — اگر کانال فرمان کنترلر گسترش داده شود، احتمالاً نقطه‌ی شروع است.

## دستور سریع برای شروع نشست جدید

بعد از این‌که ۴ ریپو به نشست اضافه شد:
1. این فایل (`PC2/SESSION_HANDOFF.md` در ریپوی `fgdata`، branch
   `claude/continuing-previous-discussion-6tpgsr`) را بخوان.
2. سپس `PC2/README.md` را برای جزئیات کامل فنی بخوان.
3. در صورت نیاز به جزئیات property tree زنده، `PC2/scenario-data/property_tree_snapshot.json`
   را چک کن.
4. سپس از بند «موارد باز / کارهای بعدی» بالا ادامه بده.
