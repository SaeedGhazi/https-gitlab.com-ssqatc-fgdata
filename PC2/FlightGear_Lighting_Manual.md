# راهنمای جامع نورپردازی (Lighting) در FlightGear

> مرجع کامل انواع چراغ در FlightGear و نحوه‌ی پیاده‌سازی/تغییر آن‌ها — از چراغ‌های
> هواپیما (landing، taxi، navigation، beacon، strobe، logo، cabin) تا چراغ‌های
> فرودگاهی (باند، approach، PAPI، taxiway) و دکل‌های نوری و فلودلایت‌های ثابت.
>
> این سند بر پایه‌ی **سورس‌کد** (`simgear/scene/model/SGLight.cxx`,
> `animation.cxx`, `Nasal/aircraft.nas`) و **نمونه‌های واقعی fgdata**
> (`Aircraft/c172p/Models/c172p.xml`, `Effects/lights/procedural_light_*.xml`,
> `Aircraft/ufo/Models/ufo-spotlight.xml`) نوشته شده و با پروژه‌ی برج OIII تست شده.

---

## فهرست

1. [سه مکانیزم بنیادی نور](#۱-سه-مکانیزم-بنیادی-نور)
2. [فریم مختصات و property‌های کنترلی](#۲-فریم-مختصات-و-property‌های-کنترلی)
3. [مرجع کامل تگ `<light>`](#۳-مرجع-کامل-تگ-light)
4. [چشمک و توالی: `aircraft.light` و انیمیشن `flash`](#۴-چشمک-و-توالی)
5. [چراغ‌های ناوبری (Nav: قرمز/سبز/سفید)](#۵-چراغ‌های-ناوبری)
6. [Beacon و Strobe](#۶-beacon-و-strobe)
7. [Landing Light و Taxi Light](#۷-landing-light-و-taxi-light)
8. [مخروط نور دیداری (light-cone)](#۸-مخروط-نور-دیداری-light-cone)
9. [چراغ‌های داخلی/بدنه: cabin، dome، logo، wing-ice](#۹-چراغ‌های-داخلی-و-بدنه)
10. [چراغ‌های فرودگاهی (باند/approach/PAPI/taxiway)](#۱۰-چراغ‌های-فرودگاهی)
11. [دکل‌های نوری، فلودلایت و چراغ‌های ثابت scenery](#۱۱-دکل‌های-نوری-و-چراغ‌های-ثابت)
12. [پیش‌نیاز رندر و کارایی](#۱۲-پیش‌نیاز-رندر-و-کارایی)
13. [دیباگ و ریز-تنظیم](#۱۳-دیباگ-و-ریز-تنظیم)
14. [مرجع سریع](#۱۴-مرجع-سریع)

---

## ۱. سه مکانیزم بنیادی نور

در FlightGear «چراغ» یک چیز واحد نیست؛ **سه مکانیزم مستقل** وجود دارد که اغلب با هم
ترکیب می‌شوند. درک تفاوتشان کلید همه‌چیز است:

| مکانیزم | چه می‌کند | چه نمی‌کند | کاربرد |
|---------|-----------|-----------|--------|
| **A) نقطه‌ی نور دیداری** (light-point / corona / emissive) | یک حبابِ روشنِ رنگی که از دور دیده می‌شود | محیط را روشن **نمی‌کند** | nav، beacon، strobe، logo |
| **B) نور پویا** (`<light>` spot/point — SGLight) | زمین و موانع را **واقعاً روشن می‌کند** | به‌خودیِ‌خود حبابِ دیداری ندارد | landing، taxi، floodlight |
| **C) مخروط دیداری** (`Effects/light-cone`) | ستونِ نیمه‌شفافِ نور در هوا/مه | چیزی را روشن **نمی‌کند** | افکت بصری پرتو |

> 🔑 **اشتباه رایج:** فقط مخروط (C) می‌گذارند و انتظار دارند زمین روشن شود. برای
> روشن‌شدن زمین، **حتماً (B)** لازم است. چراغ فرود واقعی = (B) برای روشنایی +
> (C) برای پرتو دیداری + گاهی (A) برای حبابِ لامپ.

| لایه | تگ/ابزار | فایل نمونه |
|------|----------|-----------|
| A | `<model>` به `Effects/lights/procedural_light_*.xml` یا light-point در `.ac` | `procedural_light_nav_right.xml` |
| B | `<light><type>spot/point</type></light>` | `c172p.xml` (ProceduralLandingLight) |
| C | `<effect><inherits-from>Effects/light-cone</inherits-from>` روی مش مخروط | `landinglight.xml` |

---

## ۲. فریم مختصات و property‌های کنترلی

### فریم مدل (همان `<offsets>`)
```
-x = جلو (دماغه)      +x = عقب (دم)
+y = راست (starboard)  -y = چپ (port)
+z = بالا             -z = پایین
```
در `<light><direction>`: مقدار **مثبت `pitch-deg` = رو به پایین**؛ `heading-deg=0`
= رو به جلو. (یا از `lookat-x/y/z-m` برای هدف‌گیری دقیق استفاده کن.)

### property‌های کنترلی استاندارد FlightGear
```
/controls/lighting/landing-lights     (جمع)   ← چراغ فرود
/controls/lighting/taxi-light          (مفرد)  ← چراغ تاکسی
/controls/lighting/nav-lights                  ← ناوبری
/controls/lighting/beacon                      ← بیکن
/controls/lighting/strobe                      ← استروب
/controls/lighting/logo-lights                 ← لوگو
/controls/lighting/cabin-lights                ← کابین
/controls/lighting/instruments-norm            ← شدت ابزار (0..1)
```
> ⚠️ به مفرد/جمع دقت کن: استاندارد `taxi-light` (مفرد) و `landing-lights` (جمع)
> است. اگر نام را اشتباه بنویسی، منو/کلید پیش‌فرض چراغ را روشن نمی‌کند.

### مسیر نسبی برای AI (مهم برای پروژه‌ی برج)
در فایل مدل، property را **بدون `/` ابتدایی** بنویس:
```xml
<condition><property>controls/lighting/landing-lights</property></condition>
```
این برای هواپیمای کاربر به `/controls/...` و برای بلیپ AI به
`/ai/models/aircraft[n]/controls/...` resolve می‌شود → هر بلیپ مستقل کنترل می‌شود.

---

## ۳. مرجع کامل تگ `<light>`

> منبع: `simgear/scene/model/SGLight.cxx`. این مکانیزم **B** (نور پویا) است.

```xml
<light>
  <name>MyLight</name>
  <type>spot</type>                  <!-- spot | point -->
  <priority>high</priority>          <!-- low | medium | high (اولویت در clustered) -->
  <position>
    <x-m>-26.5</x-m> <y-m>10</y-m> <z-m>2</z-m>
  </position>
  <!-- جهت: یا با زاویه ... -->
  <direction>
    <pitch-deg>15</pitch-deg>        <!-- مثبت = پایین -->
    <roll-deg>0</roll-deg>
    <heading-deg>0</heading-deg>     <!-- 0 = جلو -->
  </direction>
  <!-- ... یا با هدف‌گیری به یک نقطه (دقیق‌تر برای هم‌راستاسازی) -->
  <!-- <direction><lookat-x-m>-316</lookat-x-m><lookat-y-m>10</lookat-y-m><lookat-z-m>-75</lookat-z-m></direction> -->

  <color>   <r>1</r><g>1</g><b>1</b> </color>   <!-- یا ambient/diffuse/specular جدا -->
  <ambient>  <r>0</r><g>0</g><b>0</b><a>1</a> </ambient>
  <diffuse>  <r>1</r><g>0.97</g><b>0.9</b><a>1</a> </diffuse>
  <specular> <r>1</r><g>0.97</g><b>0.9</b><a>1</a> </specular>
  <intensity>1.0</intensity>

  <attenuation> <c>1.0</c> <l>0.001</l> <q>0.00003</q> </attenuation>
  <spot-exponent>4</spot-exponent>   <!-- کم=پخش یکنواخت، زیاد=لکه‌ی متمرکز -->
  <spot-cutoff>38</spot-cutoff>      <!-- نیم‌زاویه‌ی مخروط (درجه)؛ 180=همه‌جهته -->
  <range-m>1200</range-m>            <!-- شعاع تأثیر (culling) -->
  <dim-factor><property>controls/lighting/landing-norm</property></dim-factor>
  <debug-color> <r>1</r><g>0</g><b>0</b><a>1</a> </debug-color>
</light>
```

### جدول پارامترها (از سورس)

| پارامتر | معنی | راهنمای مقدار |
|---------|------|----------------|
| `type` | `point` (همه‌جهته) یا `spot` (مخروطی) | landing/taxi = spot |
| `position/{x,y,z}-m` | محل لامپ در فریم مدل | — |
| `direction/pitch-deg` | شیب (مثبت=پایین) | landing ~۱۵، taxi ~۵ |
| `direction/lookat-*-m` | هدف‌گیری به نقطه (جایگزین زاویه) | برای هم‌راستاسازی دقیق |
| `attenuation/c,l,q` | افت ثابت/خطی/کوادراتیک | برد بلند → `q` خیلی کوچک (~0.00003) |
| `spot-exponent` | تمرکز مرکز مخروط | ۴ پخش، ۱۵ لکه‌ی نقطه‌ای |
| `spot-cutoff` | نیم‌زاویه‌ی مخروط | پهنای منطقه = این |
| `range-m` | شعاع تأثیر | باید به‌اندازه‌ی کافی بزرگ باشد |
| `dim-factor` | ضریب شدت (می‌تواند `<property>` باشد) | برای کم/زیاد یا روشن/خاموش نرم |

### روشن/خاموش‌کردن نور پویا
دو راه:
1. **انیمیشن `select`** روی نام نور (مثل مخروط):
   ```xml
   <animation><type>select</type><object-name>MyLight</object-name>
     <condition><property>controls/lighting/landing-lights</property></condition>
   </animation>
   ```
2. **`dim-factor`** را به یک property `0..1` ببند (۰ = خاموش، نرم‌تر).

---

## ۴. چشمک و توالی

### روش ۱ — Nasal helper `aircraft.light` (استاندارد beacon/strobe)
> منبع: `Nasal/aircraft.nas` (کلاس `aircraft.light`).

```nasal
# aircraft.light.new(state_node, [on_sec, off_sec], switch_node)
# beacon: روشن 0.1s، خاموش 0.9s
var beacon = aircraft.light.new("sim/model/myac/lighting/beacon",
                                [0.10, 0.90],
                                "controls/lighting/beacon");
# strobe: تک‌فلاشِ کوتاه هر ~2s
var strobe = aircraft.light.new("sim/model/myac/lighting/strobe",
                                [0.015, 1.985],
                                "controls/lighting/strobe");
```
- آرگومان دوم `[on, off, on, off, ...]` الگوی زمانی است (می‌تواند چندمرحله‌ای باشد،
  مثل دو فلاش پشت‌سرهم: `[0.05, 0.05, 0.05, 1.5]`).
- نود `state` (خروجی) را در انیمیشن `select` لامپ به‌کار ببر:
  ```xml
  <condition><property>sim/model/myac/lighting/beacon/state</property></condition>
  ```
- متدها: `.switch(bool)`، `.toggle()`، `.cont()` (پیوسته)، `.blink(count, endstate)`.

### روش ۲ — انیمیشن `flash` (بدون Nasal)
> منبع: `animation.cxx` (نوع `flash`). برای روشن‌شوندگیِ وابسته به زاویه‌ی دید.
```xml
<animation>
  <type>flash</type>
  <object-name>StrobeBulb</object-name>
  <center> <x-m>0</x-m><y-m>0</y-m><z-m>0</z-m> </center>
  <axis>   <x>0</x><y>0</y><z>1</z> </axis>
  <power>2</power>
  <two-sides>true</two-sides>
</animation>
```

### روش ۳ — انیمیشن `timed` (توالی فریم‌ها)
```xml
<animation>
  <type>timed</type>
  <object-name>RotatingBeacon</object-name>
  <branch-duration-sec><value>0.1</value><value>0.9</value></branch-duration-sec>
</animation>
```

---

## ۵. چراغ‌های ناوبری

سه چراغ استاندارد: **قرمز روی بال چپ (port)، سبز روی بال راست (starboard)، سفید
روی دم**. ساده‌ترین راه: مدل‌های **آماده‌ی** fgdata.

```xml
<!-- سبز روی بال راست -->
<model>
  <name>nav-light-right</name>
  <path>Effects/lights/procedural_light_nav_right.xml</path>
  <offsets> <x-m>0.1</x-m> <y-m>5.66</y-m> <z-m>0.53</z-m> </offsets>
</model>
<animation>
  <type>select</type>
  <object-name>nav-light-right</object-name>
  <nopreview/>
  <condition><property>controls/lighting/nav-lights</property></condition>
</animation>

<!-- قرمز روی بال چپ -->
<model>
  <name>nav-light-left</name>
  <path>Effects/lights/procedural_light_nav_left.xml</path>
  <offsets> <x-m>0.1</x-m> <y-m>-5.66</y-m> <z-m>0.53</z-m> </offsets>
</model>
<animation>
  <type>select</type><object-name>nav-light-left</object-name><nopreview/>
  <condition><property>controls/lighting/nav-lights</property></condition>
</animation>

<!-- سفید روی دم (white/tail) -->
<model>
  <name>nav-light-tail</name>
  <path>Effects/lights/procedural_light_nav_white.xml</path>
  <offsets> <x-m>17.0</x-m> <y-m>0</y-m> <z-m>1.5</z-m> </offsets>
</model>
```
> مدل‌های `procedural_light_*` خودشان corona + رنگ + رفتار ALS را دارند؛ فقط
> موقعیت و سوییچ را می‌دهی. (مکانیزم A.)

**جایگزین قدیمی:** light-point داخل `.ac` با ماده‌ی emissive و انیمیشن `select`
روی نام آبجکت (`navlight_left/right/back`).

---

## ۶. Beacon و Strobe

- **Beacon:** چراغ قرمزِ چشمک‌زنِ کندِ بالای/زیر بدنه (ضدبرخورد).
- **Strobe:** فلاشِ سفیدِ شدیدِ سریع روی نوک بال‌ها و دم.

```xml
<!-- مدل دیداری (A) -->
<model>
  <name>beacon-light</name>
  <path>Effects/lights/procedural_light_beacon.xml</path>
  <offsets> <x-m>5.5</x-m> <y-m>0</y-m> <z-m>1.07</z-m> </offsets>
</model>
<!-- روشن‌شدن وابسته به state چشمک (از aircraft.light) -->
<animation>
  <type>select</type><object-name>beacon-light</object-name><nopreview/>
  <condition><property>sim/model/myac/lighting/beacon/state</property></condition>
</animation>
```
سپس در Nasal (بخش ۴) با `aircraft.light.new(...)` نودِ `state` را چشمک بزن.

> الگوی زمانی واقعی c172p: beacon = `[0.10, 0.90]`، strobe = `[0.015, 1.985]`.

---

## ۷. Landing Light و Taxi Light

این‌ها باید **زمین را روشن کنند** → مکانیزم **B** (`<light><type>spot>`)، اختیاری
همراه با مخروط دیداری **C**.

```xml
<!-- نور پویا که زمین را روشن می‌کند -->
<animation>
  <type>select</type><object-name>LandingSpotL</object-name>
  <condition><property>controls/lighting/landing-lights</property></condition>
</animation>
<light>
  <name>LandingSpotL</name>
  <type>spot</type>
  <position> <x-m>-7</x-m> <y-m>-4</y-m> <z-m>-1.5</z-m> </position>
  <direction> <lookat-x-m>-300</lookat-x-m> <lookat-y-m>-4</lookat-y-m> <lookat-z-m>-75</lookat-z-m> </direction>
  <diffuse> <r>1</r><g>0.97</g><b>0.9</b><a>1</a> </diffuse>
  <specular><r>1</r><g>0.97</g><b>0.9</b><a>1</a> </specular>
  <attenuation> <c>1</c> <l>0.0008</l> <q>0.00003</q> </attenuation>
  <spot-exponent>4</spot-exponent>
  <spot-cutoff>38</spot-cutoff>
  <range-m>1200</range-m>
</light>
```

### نکات تنظیم (از تجربه‌ی این پروژه)
| می‌خواهی | این را تغییر بده |
|----------|------------------|
| منطقه‌ی روشن **بزرگ‌تر** | `spot-cutoff` ↑ و `spot-exponent` ↓ (مثلاً ۴) |
| نور تا **دورتر** برسد | `attenuation/q` ↓ (~0.00003) و `range-m` ↑ |
| پرتو و زمینِ روشن **هم‌راستا** با مخروط | از `lookat` استفاده کن، نه `pitch-deg` |
| **چراغ تاکسی** | `spot-cutoff` پهن‌تر، `range-m` کوتاه‌تر، شیب بیشتر رو به پایین |

- چراغ فرود: مخروط باریک‌تر، برد بلند، شیب کم (~۱۵° پایین).
- چراغ تاکسی: مخروط پهن، برد کوتاه (~۱۵۰m)، شیب بیشتر (~۵–۱۰° پایین).

---

## ۸. مخروط نور دیداری (light-cone)

مکانیزم **C**: یک مش مخروطی `.ac` با افکت `Effects/light-cone` که ستونِ نور را در
هوا نشان می‌دهد (مثل نور در مه). **زمین را روشن نمی‌کند** — فقط دیداری است.

```xml
<!-- landinglight.xml -->
<PropertyList>
  <path>landing-light-cone.ac</path>
  <effect>
    <inherits-from>Effects/light-cone</inherits-from>
    <object-name>Cone</object-name>
  </effect>
</PropertyList>
```
سپس در فایل والد با `<model>` + `<offsets>` (شامل `pitch-deg`) جای‌گذاری و با
`select` روشن/خاموش کن.

> **هم‌راستاسازی با spot:** نیم‌زاویه‌ی مخروطِ `.ac` ثابت است (مثلاً ~۱۲°). اگر
> `spot-cutoff` نور (B) پهن‌تر باشد، استخرِ نور از لبه‌ی پرتو بیرون می‌زند (که
> واقع‌گرایانه است). برای انطباق کامل یا مخروط را پهن‌تر کن (scale شعاعی `.ac`) یا
> `spot-cutoff` را کم کن.

---

## ۹. چراغ‌های داخلی و بدنه

| چراغ | مکانیزم | پیاده‌سازی |
|------|---------|-----------|
| **Cabin / Dome** | Lightmap (افکت بافت‌محور) | `Effects/lightmap` + property `instruments-norm`/`cabin` |
| **Instrument panel** | Lightmap + `material` emission | `/sim/model/.../lightmap/*/factor` |
| **Logo light** (روشن‌کردن لوگوی دم) | Lightmap یا spot کوچک | `controls/lighting/logo-lights` |
| **Wing/Ice inspection** | spot کوچک رو به بال | `<light>` spot |
| **Courtesy** (زیرِ بال هنگام سوارشدن) | مدل procedural_light | `procedural_light_courtesy.xml` |

نمونه‌ی Lightmap برای روشن‌شدن پنجره/لوگو در شب:
```xml
<effect>
  <inherits-from>Effects/lightmap</inherits-from>
  <object-name>fuselage</object-name>
  <parameters>
    <lightmap-enabled type="int">1</lightmap-enabled>
    <lightmap-factor type="float"><use>controls/lighting/cabin-lights</use></lightmap-factor>
    <texture n="3"><image>Models/lightmap.png</image><type>2d</type></texture>
  </parameters>
</effect>
```

---

## ۱۰. چراغ‌های فرودگاهی

> ⚠️ نکته‌ی کلیدی (از مانوال Navaids): چراغ‌های فرودگاهی از **`apt.dat`** تعریف
> و توسط **TerraGear (`genapts`)** در فایل **`.btg`** «بِیک» می‌شوند. یعنی صرفِ
> تغییر `apt.dat` ظاهرِ چراغ‌ها را عوض نمی‌کند مگر `.btg` را دوباره بسازی.
> (جزئیات: `FlightGear_Navaids_NavData_Manual.md` بخش ۱۷.)

### انواع چراغ باند (در apt.dat)
| چراغ | کد/فیلد apt.dat |
|------|------------------|
| Edge lights (لبه) | فیلد edge-lighting در رکورد باند (کد 100) |
| Centerline (مرکز) | فیلد centerline-lighting |
| Threshold (آستانه) | بخشی از تعریف سرِ باند |
| TDZ (منطقه‌ی نشست) | فیلد TDZ در سرِ باند |
| **REIL** (چشمک سرِ باند) | فیلد REIL در سرِ باند |
| **PAPI/VASI** | **کد 21** (مستقل): lat, lon, type, bearing, glideslope, rwy |
| Approach lighting (ALS/MALSR/…) | فیلد approach-lighting در سرِ باند |

نمونه‌ی PAPI واقعی (OIII):
```
21  35.69639884 051.29440897 2 109.70 3.00 11L PAPI-4L
   └کد └lat        └lon       └نوع └بیرینگ └شیب └باند └توضیح
```

### effectهای رندر چراغ‌های زمینی (در fgdata `Effects/`)
| فایل | کاربرد |
|------|--------|
| `surface-lights.eff` | چراغ‌های نقطه‌ای سطحی (taxiway/apron) |
| `surface-lights-directional.eff` | چراغ‌های جهت‌دار (مثلاً TDZ) |
| `runway.eff` / `runway-dds.eff` | روسازی باند + چراغ‌ها |
| `scenery-lights.eff` | چراغ‌های شهری/محیطی |
| `procedural-light.eff` | نقطه‌ی نورِ procedural (corona) |

### روال تغییر چراغ فرودگاهی
1. `apt.dat` (یا `NavData/apt/OIII.dat`) را ویرایش کن (مثلاً REIL یا PAPI).
2. برای لایه‌ی **منطقی** (PAPI logic, navdata): کش navdata را بازساز.
3. برای لایه‌ی **دیداریِ بِیک‌شده** (مش/چراغ در صحنه): با TerraGear `genapts850`
   فایل `.btg` فرودگاه را دوباره بساز و جایگزین کن.

---

## ۱۱. دکل‌های نوری و چراغ‌های ثابت

برای دکل نور (floodlight mast)، چراغ گردان، یا روشنایی اپرون به‌صورت **شیء ثابت
scenery**:

### روش A — مدل با نور پویا (روشن‌کننده‌ی واقعی)
یک مدل XML بساز که هندسه‌ی دکل + یک `<light>` spot رو به پایین داشته باشد:
```xml
<!-- apron-floodlight.xml -->
<PropertyList>
  <path>floodmast.ac</path>
  <light>
    <name>FloodSpot</name>
    <type>spot</type>
    <position> <x-m>0</x-m><y-m>0</y-m><z-m>20</z-m> </position>  <!-- بالای دکل -->
    <direction> <pitch-deg>80</pitch-deg> </direction>            <!-- تقریباً عمودی پایین -->
    <diffuse><r>1</r><g>0.95</g><b>0.8</b><a>1</a></diffuse>
    <attenuation><c>1</c><l>0.002</l><q>0.0005</q></attenuation>
    <spot-exponent>2</spot-exponent>
    <spot-cutoff>60</spot-cutoff>
    <range-m>200</range-m>
  </light>
</PropertyList>
```

### قراردادن در scenery (`.stg`)
در فایل `<scenery>/Objects/<tile>/<id>.stg`:
```
OBJECT_SHARED Models/Airport/apron-floodlight.xml  51.3224 35.6896 1208.0 0.00
#               └مسیر مدل                            └lon     └lat     └elev  └heading
```
یا `OBJECT_STATIC` برای مدل مخصوصِ همان محل.

### روش B — فقط نقطه‌ی نور دیداری (سبک، بدون روشنایی)
از corona/light-point (مکانیزم A) استفاده کن — برای ده‌ها چراغ محیطی که نباید بار
GPU بیاورند.

> 💡 برای پروژه‌ی برج: ده‌ها دکلِ روشن روی اپرون → اگر همه `<light>` پویا باشند،
> GPU خفه می‌شود. ترکیب کن: **چند floodlight پویا** برای نقاط مهم + **بقیه
> corona/emissive** (دیداری) برای انبوهِ چراغ‌ها.

---

## ۱۲. پیش‌نیاز رندر و کارایی

### پیش‌نیاز رندر
| مکانیزم | نیازمند |
|---------|---------|
| A (دیداری/corona) | همه‌ی pipelineها (سبک) |
| **B (نور پویا `<light>`)** | **ALS یا Compositor/HDR با clustered lighting** — در رندر legacy کار نمی‌کند |
| C (light-cone) | ALS/Compositor (شفافیت) |

فعال‌سازی: Launcher → Rendering → **Compositor/HDR** (یا حداقل ALS).
(پشتیبانی local-light در `Effects/HDR/shading-opaque.eff`.)

### کارایی (حیاتی برای دید چندمانیتوره‌ی OIII)
- هر نور پویا (B) روی GPU هزینه دارد؛ روی RTX 3050 با ۱۵ دوربین، تعداد را محدود کن.
- **روی همه‌ی بلیپ‌های AI نور پویا نگذار.** فقط بلیپ‌های نزدیک/فعال.
- چراغ‌های دیداری (A) و مخروط (C) به‌مراتب ارزان‌ترند → برای انبوه از این‌ها استفاده کن.
- `range-m` را بی‌جهت بزرگ نکن (شعاع بزرگ = آبجکت‌های بیشتری در محاسبه‌ی نور).
- (اختیاری) با Nasal فقط وقتی بلیپ در فاصله‌ی X از برج بود، `<light>` را روشن کن.

---

## ۱۳. دیباگ و ریز-تنظیم

```
# نمایش مخروط/حجمِ هر نور پویا (با رنگ debug-color)
set /sim/debug/show-light-volumes true
```
- موقعیت/جهت را با `position` و `direction` (یا `lookat`) تنظیم کن تا مخروط دقیقاً
  از لامپ به جلو/پایین بیفتد.
- روشن/خاموش‌نشدن چراغ → نام property کنترلی (مفرد/جمع) و درست‌بودن `select` را چک کن.
- نور دیده نمی‌شود ولی select درست است → احتمالاً رندر ALS/Compositor فعال نیست (B/C).
- چراغ دیداری (A) دیده نمی‌شود → corona ممکن است پشتِ بدنه پنهان باشد؛ offset را بیرون ببر.

---

## ۱۴. مرجع سریع

### کدام مکانیزم برای کدام چراغ؟
```
nav (قرمز/سبز/سفید)  → A  (procedural_light_nav_*)
beacon / strobe       → A + چشمک با aircraft.light
landing / taxi        → B (spot) [+ C مخروط دیداری]
logo / cabin / dome   → Lightmap (+ A)
floodlight / دکل      → B (spot) برای مهم‌ها، A برای انبوه
چراغ باند/approach/PAPI → apt.dat → TerraGear .btg
```

### اسکلت حداقلیِ هر مکانیزم
```xml
<!-- A: نقطه‌ی دیداری -->
<model><name>x</name><path>Effects/lights/procedural_light_nav_right.xml</path>
  <offsets><x-m>..</x-m><y-m>..</y-m><z-m>..</z-m></offsets></model>
<animation><type>select</type><object-name>x</object-name>
  <condition><property>controls/lighting/nav-lights</property></condition></animation>

<!-- B: نور پویا -->
<light><name>y</name><type>spot</type>
  <position><x-m>..</x-m><y-m>..</y-m><z-m>..</z-m></position>
  <direction><lookat-x-m>..</lookat-x-m><lookat-y-m>..</lookat-y-m><lookat-z-m>..</lookat-z-m></direction>
  <diffuse><r>1</r><g>1</g><b>1</b><a>1</a></diffuse>
  <attenuation><c>1</c><l>0.001</l><q>0.00003</q></attenuation>
  <spot-exponent>4</spot-exponent><spot-cutoff>38</spot-cutoff><range-m>1200</range-m></light>

<!-- C: مخروط دیداری -->
<effect><inherits-from>Effects/light-cone</inherits-from><object-name>Cone</object-name></effect>
```

### property‌های کنترلی
```
landing-lights(جمع)  taxi-light(مفرد)  nav-lights  beacon  strobe
logo-lights  cabin-lights  instruments-norm
+ state چشمک:  sim/model/<ac>/lighting/{beacon,strobe}/state
```

### چشمک (aircraft.light)
```nasal
aircraft.light.new("sim/model/ac/lighting/beacon", [0.10,0.90], "controls/lighting/beacon");
aircraft.light.new("sim/model/ac/lighting/strobe", [0.015,1.985], "controls/lighting/strobe");
```

---

### منابع
- سورس: `simgear/scene/model/SGLight.cxx` (تگ `<light>`)، `animation.cxx`
  (انواع select/flash/timed/light)، `Nasal/aircraft.nas` (کلاس `aircraft.light`)
- نمونه‌ها: `Aircraft/c172p/Models/c172p.xml`،
  `Effects/lights/procedural_light_*.xml`، `Aircraft/ufo/Models/ufo-spotlight.xml`
- مرتبط: `FlightGear_Aircraft_Development_Manual.md` (بخش ۶ و ۷ و ۸)،
  `FlightGear_Navaids_NavData_Manual.md` (بخش ۱۷: WED/btg و چراغ باند)
- کار عملی این پروژه: `PC2/aircraft-lights/` (چراغ فرود/تاکسی A346)

> سند زنده است؛ با افزودن چراغ‌های جدید (strobe/beacon/floodlight اپرون OIII)
> به‌روز نگه دار.
