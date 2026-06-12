# یادداشت‌های تحقیقاتی: شبیه‌ساز برج مراقبت با FlightGear

این سند خلاصه‌ی یافته‌های بررسی سورس FlightGear (نسخه‌ی فعلی شاخه‌ی `next` در
`gitlab.com/flightgear/flightgear` و `gitlab.com/flightgear/simgear`) برای
پروژه‌ی شبیه‌ساز آموزش کنترلرهای ترافیک هوایی است. ناظر/کنترلر در قالب
هواپیمای UFO در موقعیت برج قرار می‌گیرد و هواپیماهای AI (بلیپ‌ها) از طریق
Property Tree فرمان می‌گیرند.

## 1) فرمان‌دهی به بلیپ‌ها (Controller -> FlightGear)

### کانال: سرور Telnet (Property Server)
- فایل منبع: `src/Network/propsProtocol.cxx` / `propsProtocol.hxx`
- پورت پیش‌فرض: `5501` (با `--telnet=socket,bi,...,<port>,...` یا `--telnet=<port>` فعال می‌شود)
- دستورات پشتیبانی‌شده: `ls`, `ls2`, `cd`, `pwd`, `get`/`show`, `set`, `setb`,
  `seti`, `setd`/`setf`, `del`, `dump`, `run`, `reinit`, `quit`/`exit`

### پیش‌نیاز: بلیپ باید بدون Flight-Plan لود شود
طبق `src/AIModel/AIAircraft.cxx` (تابع `updatePrimaryTargetValues`, خط
~1206-1268)، اگر شیء AI **flight-plan معتبر نداشته باشد**، رفتارش کاملاً از
روی نودهای زیر `controls/flight/` کنترل می‌شود (در غیر این صورت AI خودش از
flight-plan پیروی می‌کند و این نودها نادیده گرفته می‌شوند).

### نودهای کنترلی هر بلیپ (زیر `/ai/models/aircraft[n]/`)

| Property | نوع | توضیح |
|---|---|---|
| `controls/flight/lateral-mode` | string | اگر `"roll"` باشد از `target-roll` پیروی می‌کند، در غیر این صورت از `target-hdg` (heading-hold) |
| `controls/flight/target-hdg` | double (deg) | heading هدف؛ گردش با نرخ واقع‌گرایانه بر اساس PerformanceData انجام می‌شود (`TurnTo`) |
| `controls/flight/target-roll` | double (deg) | بانک هدف (`RollTo`) |
| `controls/flight/vertical-mode` | string | اگر `"alt"` باشد از `target-alt` پیروی می‌کند (`ClimbTo`)، در غیر این صورت از `target-pitch` (`PitchTo`) |
| `controls/flight/target-alt` | double (ft) | ارتفاع هدف |
| `controls/flight/target-pitch` | double (deg) | پیچ هدف |
| `controls/flight/target-spd` | double (kt) | سرعت هدف (`AccelTo`) |

> مقدار اولیه‌ی همه‌ی این نودها هنگام spawn از مقادیر سناریو پر می‌شود
> (`src/AIModel/AIBase.cxx:776-792`) - یعنی بلیپ به‌صورت پیش‌فرض مستقیم و با
> ارتفاع/سرعت ثابت پرواز می‌کند تا فرمان جدید بیاید.

### نمونه‌ی نشست Telnet
```
$ telnet localhost 5501
> cd /ai/models/aircraft[2]
> set controls/flight/lateral-mode hdg
> set controls/flight/target-hdg 270
> set controls/flight/target-alt 4000
> set controls/flight/target-spd 180
```

### افزودن/حذف/لود سناریو به‌صورت پویا
ثبت‌شده در `src/AIModel/AIManager.cxx:133-136`، از طریق دستور `run`:
```
run add-aiobject type=aircraft callsign=IRC123 latitude=... longitude=... altitude=... heading=... speed=...
run remove-aiobject id=<N>
run load-scenario id=<scenario-name>
run unload-scenario id=<scenario-name>
```

## 2) دریافت وضعیت ترافیک (FlightGear -> Controller)

### نودهای read-only هر بلیپ (تعریف‌شده در `AIBase.cxx:715-770`)
زیر `/ai/models/aircraft[n]/`:
```
id                              (int, شناسه‌ی یکتا)
callsign                        (string)
sim/multiplay/callsign
position/latitude-deg
position/longitude-deg
position/altitude-ft
orientation/true-heading-deg
orientation/pitch-deg
orientation/roll-deg
velocities/true-airspeed-kt
velocities/vertical-speed-fps
radar/range-nm                  (نسبت به UFO/observer)
radar/bearing-deg
radar/elevation-deg
radar/in-range
```

### کانال HTTP/JSON
- فایل: `src/Network/http/jsonprops.cxx`, `httpd.cxx`
- فعال‌سازی: `--httpd=<port>`
- مثال: `GET http://host:port/json/ai/models` -> کل زیردرخت AI به JSON

### کانال UDP (Generic Protocol)
- فایل: `src/Network/generic.cxx`, فرمت پیکربندی: `fgdata/Protocol/*.xml`
  (نمونه بررسی‌شده: `generic-cockpit.xml`)
- فعال‌سازی: `--generic=socket,out,<Hz>,<host>,<port>,udp,<protocol-name>`
- هر `<chunk>` یک property را به یک فیلد متنی/باینری map می‌کند؛ این پروتکل
  ایندکس داینامیک ندارد، یعنی برای N بلیپ باید N برابر chunk با مسیر
  `/ai/models/aircraft[0]/...` تا `[N-1]/...` نوشته شود (یا یک پروتکل
  generate شده/پویا).

## 3) UFO به‌عنوان جایگاه ناظر برج
- مسیر: `fgdata/Aircraft/ufo/ufo-set.xml`
- بدون فیزیک واقعی، چندین `<view>` پیکربندی‌پذیر
- می‌توان موقعیت اولیه (lat/lon/alt برج) را با `--lat=`, `--lon=`,
  `--altitude=` یا از طریق فایل `-set.xml` اختصاصی ثابت کرد

## 4) فایل‌های کلیدی برای مرجع بعدی (در سورس FlightGear/SimGear)
```
src/Network/propsProtocol.{cxx,hxx}   - سرور Telnet/Property
src/Network/generic.{cxx,hxx}         - پروتکل ژنریک (UDP/serial)
src/Network/http/httpd.{cxx,hxx}      - سرور HTTP
src/Network/http/jsonprops.{cxx,hxx}  - خروجی JSON property tree
src/AIModel/AIBase.{cxx,hxx}          - نودهای مشترک همه‌ی اشیاء AI
src/AIModel/AIAircraft.{cxx,hxx}      - منطق بلیپ هواپیما، حالت کنترل دستی
src/AIModel/AIManager.{cxx,hxx}       - مدیریت سناریو/افزودن و حذف اشیاء
src/AIModel/AIFlightPlan.{cxx,hxx}    - ساختار فلایت‌پلن (در صورت نیاز بعدی)
src/ATC/TowerController.{cxx,hxx}     - منطق داخلی tower controller فلایت‌گیر
src/ATC/trafficcontrol.{cxx,hxx}      - مدیریت صف/جداسازی ترافیک
fgdata/Protocol/*.xml                 - نمونه‌های پیکربندی پروتکل generic
fgdata/Aircraft/ufo/ufo-set.xml       - تعریف هواپیمای UFO
```

## 5) سوالات باز برای ادامه‌ی کار
- آیا برای صف بندی/جداسازی، از منطق داخلی `ATC/trafficcontrol.cxx` و
  `TowerController.cxx` استفاده می‌شود یا کاملاً در سمت سیستم خارجی (GUI)
  بازنویسی می‌شود؟
- فرمت دقیق سناریوی AI (XML) برای بلیپ بدون flight-plan باید نمونه‌سازی و
  تست شود.
- برای UDP با تعداد بلیپ متغیر، نیاز به تولید پویای فایل پروتکل XML
  (script-generated) یا استفاده از HTTP/WebSocket بجای UDP ثابت.
