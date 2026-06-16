# راهنمای جامع توسعه‌ی هواگرد در FlightGear

> مرجع کامل ساخت هواپیما و بالگرد برای FlightGear — از ساختار پکیج و FDM تا
> انیمیشن، افکت‌های ویژه، performance، autopilot، صدا، لیوری، و یکپارچه‌سازی با
> سیستم AI/Property-Tree برای پروژه‌ی برج مراقبت (ATC Tower Trainer / OIII).
>
> این سند با تجمیع سه مقاله‌ی ویکی رسمی (`Howto:Make an aircraft`،
> `Aircraft-set.xml`، `Howto:Make a helicopter`)، پیش‌نویس داخلی پروژه، و
> **استخراج مستقیم از سورس‌کد** `simgear/scene/model/animation.cxx`،
> `flightgear/src/Autopilot/*`، `flightgear/src/AIModel/*` و
> `fgdata/AI/Aircraft/performancedb.xml` نوشته شده است. هرجا که نام تگ یا
> property آمده، با کد واقعی کراس‌چک شده است.

---

## فهرست مطالب

1. [مفاهیم پایه و معماری](#۱-مفاهیم-پایه-و-معماری)
2. [ساختار پوشه و فایل‌های پکیج](#۲-ساختار-پوشه-و-فایل‌های-پکیج)
3. [فایل اصلی `-set.xml`](#۳-فایل-اصلی--setxml)
4. [مدل دینامیک پرواز (FDM): JSBSim و YASim](#۴-مدل-دینامیک-پرواز-fdm)
5. [مدل سه‌بعدی و فایل `-main.xml`](#۵-مدل-سه‌بعدی-و-فایل--mainxml)
6. [انیمیشن‌ها (مرجع کامل انواع)](#۶-انیمیشن‌ها--مرجع-کامل-انواع)
7. [افکت‌ها، شیدرها و Lightmap](#۷-افکت‌ها-شیدرها-و-lightmap)
8. [سیستم ذرات: دود، شعله، Afterburner](#۸-سیستم-ذرات-particles)
9. [صدا (`-sound.xml`)](#۹-صدا)
10. [Performance و دیتابیس AI](#۱۰-performance-و-دیتابیس-ai)
11. [Autopilot و کنترلرها](#۱۱-autopilot-و-کنترلرها)
12. [بالگرد (Helicopter / YASim Rotor)](#۱۲-بالگرد-helicopter)
13. [اسکریپت‌نویسی Nasal](#۱۳-اسکریپت‌نویسی-nasal)
14. [لیوری و انتخاب رنگ‌بندی](#۱۴-لیوری-liveries)
15. [هواپیمای AI و یکپارچه‌سازی با برج مراقبت (پروژه OIII)](#۱۵-هواپیمای-ai-و-پروژه-برج-مراقبت)
16. [دیباگ، اعتبارسنجی و چک‌لیست نهایی](#۱۶-دیباگ-و-چک‌لیست-نهایی)
17. [پیوست: مرجع سریع Property Tree](#۱۷-پیوست-مرجع-سریع-property-tree)

---

## ۱. مفاهیم پایه و معماری

FlightGear حول یک پایگاه‌داده‌ی درختی و زنده به نام **Property Tree** کار می‌کند.
هر چیز — از موقعیت هواپیما تا وضعیت یک کلید کابین — یک گره (node) در این درخت است.
تمام زیرسیستم‌ها (FDM، رندر، صدا، Nasal، شبکه) فقط از طریق همین درخت با هم حرف
می‌زنند. درک این نکته کلید همه‌چیز است: **ساخت هواپیما یعنی وصل‌کردن مدل سه‌بعدی و
فیزیک به property‌های درست.**

شاخه‌های مهم درخت:

| مسیر | محتوا |
|------|-------|
| `/sim/` | پیکربندی شبیه‌ساز و متادیتای هواپیما (`/sim/aircraft`, `/sim/model/path`) |
| `/controls/` | فرامین خلبان (گاز، فرمان، فلپ، گیر، …) |
| `/surface-positions/` | موقعیت واقعی سطوح کنترل (خروجی FDM) برای انیمیشن |
| `/gear/gear[n]/` | وضعیت ارابه‌ی فرود |
| `/orientation/` | زوایای heading/pitch/roll |
| `/velocities/` | سرعت‌ها (airspeed، vertical-speed، …) |
| `/engines/engine[n]/` | وضعیت موتورها (rpm، n1، n2، thrust) |
| `/ai/models/aircraft[n]/` | هواپیماهای AI / بلیپ‌های رادار |
| `/instrumentation/` | اویونیک و ابزار دقیق |

> برای دیدن زنده‌ی درخت: منوی **Debug → Browse Internal Properties** یا از طریق
> `--telnet=5000` و سپس `telnet localhost 5000`.

### چرخه‌ی توسعه (۴ گام ساده‌شده)
1. **مدل سه‌بعدی** را بساز (Blender/SketchUp → خروجی `.ac` یا `.obj`).
2. **FDM** را بنویس (JSBSim یا YASim) — اینکه هواپیما چطور پرواز می‌کند.
3. **انیمیشن‌ها** را بساز — اتصال FDM به مدل بصری.
4. **سیستم‌ها** را پیاده کن — autopilot، اویونیک، Nasal، صدا.

> توصیه‌ی رسمی ویکی: **از صفر شروع نکن.** یک هواپیمای مشابه (با همان نوع FDM) را
> کپی کن و تغییر بده. منحنی یادگیری به‌شدت کاهش می‌یابد.

---

## ۲. ساختار پوشه و فایل‌های پکیج

هر هواپیما در `$FG_ROOT/Aircraft/<name>/` قرار می‌گیرد. ساختار استاندارد:

```
Aircraft/B737/
├── B737-set.xml          ← نقطه‌ی ورود؛ شناسنامه و لیست فایل‌ها
├── B737-common.xml       ← (اختیاری) داده‌ی مشترک بین چند variant
├── b737-jsbsim.xml       ← FDM (JSBSim) — دینامیک پرواز
├── Engines/              ← فایل موتور و propeller (JSBSim)
│   └── eng_CFM56.xml
├── Models/
│   ├── B737-main.xml     ← پیکربندی مدل: انیمیشن، افکت، چراغ‌ها
│   ├── B737.ac           ← مدل سه‌بعدی
│   └── *.png/.dds        ← تکسچرها (توان ۲: 512، 1024، 2048…)
├── Nasal/                ← اسکریپت‌های سیستم‌ها
│   └── systems.nas
├── Sounds/
│   └── b737-sound.xml
├── Systems/              ← autopilot، electrical، …
│   └── autopilot.xml
├── Liveries/             ← رنگ‌بندی‌ها
├── Previews/             ← تصاویر launcher (1024×768)
└── thumbnail.jpg         ← 171×128 برای launcher
```

**قواعد مهم (از ویکی):**
- نام فایل‌ها و پوشه‌ها **به حروف بزرگ/کوچک حساس‌اند** (Linux). همیشه آدرس‌دهی نسبی
  از ریشه‌ی هواپیما استفاده کن.
- تصاویر باید ابعاد توان‌۲ داشته باشند (`128×256`, `1024×1024`). سقف معمول 4096.
- فایل‌های FDM مربوط به JSBSim **باید با space باشند، نه tab.**
- هر فایلی که به `-set.xml` ختم شود، یک هواپیمای مجزا تلقی می‌شود — برای داده‌ی
  مشترک از `-common.xml` استفاده کن، نه `-set.xml`.

---

## ۳. فایل اصلی `-set.xml`

این فایل یک `PropertyList` است که هنگام لود هواپیما، property‌ها را مقداردهی می‌کند
و به بقیه‌ی فایل‌ها اشاره می‌دهد. نام فایل = نامی که با `--aircraft=` صدا زده می‌شود
(مثلاً `b737-set.xml` ⇐ `fgfs --aircraft=b737`).

### ۳.۱ اسکلت کامل

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PropertyList>
  <sim>
    <!-- ===== متادیتا ===== -->
    <description>Boeing 737-800</description>
    <long-description>
      The 737-800 is a narrow-body twinjet... (قابل جستجو در launcher)
    </long-description>
    <author>Jane Doe (FDM), John Roe (3D model)</author>
    <aircraft-version>2024.1</aircraft-version>
    <minimum-fg-version>2020.3.0</minimum-fg-version>
    <status>production</status>   <!-- early-production / production / advanced -->

    <!-- ===== رتبه‌بندی کیفیت (1..5) ===== -->
    <rating>
      <FDM type="int">4</FDM>
      <systems type="int">3</systems>
      <cockpit type="int">4</cockpit>
      <model type="int">5</model>
    </rating>

    <!-- ===== تگ‌ها (برای فیلتر در launcher) ===== -->
    <tags>
      <tag>boeing</tag>
      <tag>jet</tag>
      <tag>narrow-body</tag>
      <!-- تگ‌های رفتاری مهم: glider, helicopter, seaplane, floats,
           skis, amphibious, airship, vtol -->
    </tags>

    <!-- ===== FDM ===== -->
    <flight-model>jsbsim</flight-model>   <!-- jsbsim | yasim | ufo | null -->
    <aero>b737-jsbsim</aero>               <!-- نام فایل FDM بدون پسوند -->

    <!-- ===== مدل بصری ===== -->
    <model>
      <path>Aircraft/B737/Models/B737-main.xml</path>
    </model>

    <!-- ===== تنظیمات فلپ، نما، startup ===== -->
    <startup>
      <splash-texture>Aircraft/B737/Previews/splash.png</splash-texture>
    </startup>
    <view>
      <internal type="bool">true</internal>
      <config>
        <x-offset-m type="double">-0.5</x-offset-m>
        <y-offset-m type="double">0.2</y-offset-m>
        <z-offset-m type="double">0.0</z-offset-m>
      </config>
    </view>
  </sim>

  <!-- ===== ماژول‌های Nasal ===== -->
  <nasal>
    <b737>
      <file>Aircraft/B737/Nasal/systems.nas</file>
      <file>Aircraft/B737/Nasal/autopilot_helper.nas</file>
    </b737>
  </nasal>
</PropertyList>
```

### ۳.۲ Variantها (چند هواپیما در یک پوشه)
وقتی چند نسخه داری (مثل 737-700/800/900)، یکی را اصلی علامت بزن:

```xml
<!-- در فایل اصلی (b737-800-set.xml): -->
<sim><primary-set type="bool">true</primary-set></sim>

<!-- در هر variant (b737-900-set.xml): -->
<sim><variant-of>b737-800</variant-of></sim>
```

### ۳.۳ شکستن فایل بزرگ (include)
برای خوانایی، بخش‌ها را به فایل جدا منتقل کن و include کن:

```xml
<sim include="Systems/views.xml"/>
<!-- یا -->
<PropertyList include="b737-common.xml">
```

### ۳.۴ Authors، URLs، Previews (نسخه‌های جدید FG)

```xml
<authors>
  <author n="0">
    <name>Wilbur Wright</name>
    <description>FDM, systems</description>
    <nick>wwright</nick>
  </author>
</authors>

<urls>
  <home-page>https://...</home-page>
  <support>https://forum.flightgear.org</support>
  <code-repository>https://...</code-repository>
</urls>

<previews>
  <preview>
    <type>exterior</type>          <!-- exterior | panel | interior -->
    <splash type="bool">true</splash>
    <path>Previews/exterior-1.png</path>
  </preview>
</previews>
```

### ۳.۵ بخش Performance/Flight-planning در `-set.xml`
برای اینکه هواپیما در flight-planner و به‌عنوان AI رفتار درستی داشته باشد:

```xml
<sim>
  <aircraft-class>jet_transport</aircraft-class>  <!-- map به performancedb -->
</sim>
```

---

## ۴. مدل دینامیک پرواز (FDM)

سه موتور فیزیک موجود است:

| موتور | بهترین برای | ویژگی |
|-------|-------------|-------|
| **YASim** | بالگرد، داده‌ی کم، VTOL، towing شبکه‌ای | از هندسه‌ی فیزیکی محاسبه می‌کند؛ ساده‌تر برای شروع |
| **JSBSim** | داده‌ی واقعی windtunnel، pushback، دقت بالا | مبتنی بر ضرایب آیرودینامیک؛ پیچیده‌تر |
| **UIUC** | (قدیمی، کم‌استفاده) | — |

> ابزار `Aeromatic` (فقط JSBSim) می‌تواند از مشخصات پایه، یک FDM اولیه بسازد.

### ۴.۱ نمونه‌ی YASim (هواپیمای بال‌ثابت ساده)

```xml
<?xml version="1.0"?>
<airplane mass="12500">     <!-- وزن خالی، پوند -->
  <approach speed="120" aoa="6">
    <control-setting axis="/controls/engines/engine[0]/throttle" value="0.4"/>
    <control-setting axis="/controls/flight/flaps" value="1.0"/>
  </approach>
  <cruise speed="320" alt="30000">
    <control-setting axis="/controls/engines/engine[0]/throttle" value="0.9"/>
  </cruise>

  <cockpit x="3.2" y="0" z="0.5"/>

  <fuselage ax="6" ay="0" az="0" bx="-9" by="0" bz="0" width="2.0" taper="0.3"/>

  <wing x="0.5" y="0.8" z="-0.4" length="8" chord="2.2"
        sweep="20" dihedral="5" incidence="2" taper="0.4">
    <stall aoa="16" width="2" peak="1.5"/>
    <flap0 start="0.1" end="0.5" lift="1.4" drag="1.2"/>
    <flap1 start="0.5" end="0.9" lift="1.2" drag="1.1"/>  <!-- aileron -->
    <control-input axis="/controls/flight/aileron" control="FLAP1" split="true"/>
    <control-input axis="/controls/flight/flaps"   control="FLAP0"/>
  </wing>

  <hstab x="-8" y="0" z="0.5" length="3" chord="1.5" taper="0.5">
    <stall aoa="18" width="3" peak="1.5"/>
    <flap0 start="0" end="1" lift="1.5" drag="1.5"/>
    <control-input axis="/controls/flight/elevator" control="FLAP0"/>
  </hstab>

  <jet x="0" y="2" z="-0.5" mass="3500" thrust="20000"/>

  <gear x="3" y="0" z="-2" compression="0.3">
    <control-input axis="/controls/gear/brake-left" control="BRAKE"/>
  </gear>
</airplane>
```

### ۴.۲ اتصال FDM به کنترل‌ها
نکته‌ی کلیدی: `control-input` ورودی خلبان (`/controls/...`) را به سطح فیزیکی وصل
می‌کند، و FDM به‌صورت خودکار `/surface-positions/*-pos-norm` را برای انیمیشن
به‌روزرسانی می‌کند. مثلاً:
- `/controls/flight/aileron` → FDM → `/surface-positions/left-aileron-pos-norm`
- `/controls/flight/flaps` → FDM → `/surface-positions/flap-pos-norm`

> ⚠️ نام دقیق این property‌ها مهم است: `flap-pos-norm` (مفرد، بدون s). اشتباه
> رایج `flaps-pos-norm` است که هیچ انیمیشنی را راه نمی‌اندازد.

---

## ۵. مدل سه‌بعدی و فایل `-main.xml`

فایل `-main.xml` (یک `PropertyList`) مدل `.ac` را لود می‌کند و انیمیشن/افکت/چراغ به
آن می‌چسباند.

```xml
<?xml version="1.0"?>
<PropertyList>
  <!-- لود مدل سه‌بعدی پایه -->
  <path>B737.ac</path>

  <!-- مدل‌های فرعی (موتور، چراغ، …) -->
  <model>
    <name>nav-lights</name>
    <path>Aircraft/B737/Models/NavLights.xml</path>
    <offsets>
      <x-m>0</x-m><y-m>0</y-m><z-m>0</z-m>
    </offsets>
  </model>

  <!-- انیمیشن‌ها اینجا می‌آیند (بخش ۶) -->
  <animation>...</animation>

  <!-- افکت‌ها (بخش ۷) -->
  <effect>...</effect>
</PropertyList>
```

دستگاه مختصات مدل در FlightGear:
- **X**: محور طولی (مثبت = به سمت دماغه/جلو؟ بسته به مدل؛ معمولاً X- = جلو در YASim).
- **Y**: محور عرضی (بال‌ها).
- **Z**: محور عمودی (مثبت = بالا).
> همیشه با تست بصری چک کن؛ جهت محورها بسته به نرم‌افزار مدل‌سازی فرق می‌کند.

---

## ۶. انیمیشن‌ها — مرجع کامل انواع

> این لیست **مستقیماً از `simgear/scene/model/animation.cxx`** استخراج شده است
> (تابع نگاشت `type` به کلاس انیمیشن). هر انیمیشن داخل تگ `<animation>` در فایل
> `-main.xml` تعریف می‌شود و معمولاً یک `<object-name>` (نام آبجکت در فایل `.ac`)
> و یک `<property>` (گره‌ی محرک) دارد.

### فهرست انواع رسمی

| `type` | کاربرد |
|--------|--------|
| `rotate` / `spin` | چرخش حول یک محور (عقربه، چرخ، توربین) |
| `translate` | جابه‌جایی خطی (اهرم، فلپ کشویی) |
| `scale` | تغییر اندازه |
| `select` | نمایش/پنهان‌کردن شرطی آبجکت |
| `range` | نمایش بر اساس فاصله (LOD ساده) |
| `dist-scale` | مقیاس بر اساس فاصله |
| `billboard` | همیشه رو به دوربین (دود، هاله) |
| `flash` | چشمک/نور وابسته به زاویه |
| `timed` | توالی زمانی فریم‌ها |
| `light` | منبع نور پویا |
| `pick` | کلیک‌پذیری (دکمه، سوییچ) |
| `knob` | پیچ گردان (تعامل اسکرول/درگ) |
| `slider` | اهرم کشویی تعاملی |
| `touch` | ناحیه‌ی لمسی |
| `interaction` | ناحیه‌ی تعامل عمومی |
| `locked-track` | همیشه به سمت یک نقطه نشانه می‌رود |
| `textranslate` | جابه‌جایی تکسچر (نوار متحرک) |
| `texrotate` | چرخش تکسچر |
| `textrapezoid` / `texmultiple` | تبدیلات تکسچر پیشرفته |
| `pbr` | متریال PBR |
| `noshadow` | حذف سایه برای آبجکت |
| `null` / `none` | گروه‌بندی بدون اثر (برای ساختاردهی) |

### ۶.۱ `rotate` — چرخش (مثال: عقربه‌ی سرعت)

```xml
<animation>
  <type>rotate</type>
  <object-name>AirspeedNeedle</object-name>
  <property>/velocities/airspeed-kt</property>
  <factor>2.0</factor>           <!-- درجه به‌ازای هر واحد property -->
  <offset-deg>-90</offset-deg>
  <min-deg>-90</min-deg>
  <max-deg>270</max-deg>
  <center>
    <x-m>0.0</x-m><y-m>0.0</y-m><z-m>0.0</z-m>
  </center>
  <axis>
    <x>0</x><y>0</y><z>1</z>
  </axis>
</animation>
```

برای نگاشت غیرخطی از `<interpolation>` استفاده کن:

```xml
<animation>
  <type>rotate</type>
  <object-name>AltimeterNeedle</object-name>
  <property>/instrumentation/altimeter/indicated-altitude-ft</property>
  <interpolation>
    <entry><ind>0</ind>    <dep>0</dep></entry>
    <entry><ind>1000</ind> <dep>36</dep></entry>
    <entry><ind>10000</ind><dep>360</dep></entry>
  </interpolation>
  <axis><x>0</x><y>0</y><z>1</z></axis>
</animation>
```

### ۶.۲ `spin` — چرخش پیوسته (پروانه/توربین)

```xml
<animation>
  <type>spin</type>
  <object-name>Propeller</object-name>
  <property>/engines/engine[0]/rpm</property>
  <factor>1.0</factor>           <!-- ضریب rpm -->
  <center><x-m>0</x-m><y-m>0</y-m><z-m>0</z-m></center>
  <axis><x>1</x><y>0</y><z>0</z></axis>
</animation>
```

### ۶.۳ `translate` — جابه‌جایی (مثال: اهرم گاز)

```xml
<animation>
  <type>translate</type>
  <object-name>ThrottleLever</object-name>
  <property>/controls/engines/engine[0]/throttle</property>
  <factor>0.1</factor>           <!-- متر به‌ازای هر واحد -->
  <axis><x>1</x><y>0</y><z>0</z></axis>
</animation>
```

### ۶.۴ `select` — نمایش شرطی (مثال: ارابه‌ی فرود)

```xml
<animation>
  <type>select</type>
  <object-name>gear_assembly</object-name>
  <condition>
    <greater-than>
      <property>/gear/gear[0]/position-norm</property>
      <value>0.25</value>
    </greater-than>
  </condition>
</animation>
```

عملگرهای `<condition>` (از SimGear): `and`, `or`, `not`, `less-than`,
`greater-than`, `less-than-equals`, `greater-than-equals`, `equals`,
`property`. مثال ترکیبی:

```xml
<condition>
  <and>
    <property>/controls/lighting/nav-lights</property>
    <greater-than>
      <property>/sim/time/sun-angle-rad</property>
      <value>1.57</value>
    </greater-than>
  </and>
</condition>
```

### ۶.۵ `pick` — کلیک‌پذیری (سوییچ/دکمه)

```xml
<animation>
  <type>pick</type>
  <object-name>StarterSwitch</object-name>
  <action>
    <button>0</button>                <!-- کلیک چپ -->
    <binding>
      <command>property-toggle</command>
      <property>/controls/engines/engine[0]/starter</property>
    </binding>
  </action>
  <hovered>
    <binding>
      <command>set-tooltip</command>
      <tooltip-id>starter</tooltip-id>
      <label>Engine Starter</label>
    </binding>
  </hovered>
</animation>
```

### ۶.۶ `knob` و `slider` — کنترل‌های تعاملی پیشرفته

```xml
<animation>
  <type>knob</type>
  <object-name>HeadingKnob</object-name>
  <property>/autopilot/settings/heading-bug-deg</property>
  <factor>1</factor>
  <axis><x>0</x><y>0</y><z>1</z></axis>
  <center><x-m>0</x-m><y-m>0</y-m><z-m>0</z-m></center>
  <action>
    <binding>
      <command>property-adjust</command>
      <property>/autopilot/settings/heading-bug-deg</property>
      <step>1</step>
      <min>0</min><max>360</max><wrap>true</wrap>
    </binding>
  </action>
</animation>
```

### ۶.۷ `timed` — توالی زمانی (مثلاً انیمیشن چشمک‌زن چندفریمی)

```xml
<animation>
  <type>timed</type>
  <object-name>BeaconFlash</object-name>
  <branch-duration-sec>
    <value>0.05</value>
    <value>1.2</value>
  </branch-duration-sec>
</animation>
```

### ۶.۸ `texrotate` / `textranslate` — انیمیشن تکسچر (بدون تغییر هندسه)
برای عقربه‌های نقاشی‌شده روی تکسچر یا نوارهای متحرک — سبک‌تر از هندسه.

```xml
<animation>
  <type>texrotate</type>
  <object-name>RpmGauge</object-name>
  <property>/engines/engine[0]/rpm</property>
  <factor>0.36</factor>
  <center><x>0.5</x><y>0.5</y></center>
  <axis><x>0</x><y>0</y><z>1</z></axis>
</animation>
```

### ۶.۹ `range` — حذف جزئیات از دور (بهینه‌سازی)

```xml
<animation>
  <type>range</type>
  <object-name>CockpitDetails</object-name>
  <min-m>0</min-m>
  <max-m>500</max-m>     <!-- فراتر از 500 متر، رندر نشود -->
</animation>
```

> 💡 **برای پروژه‌ی برج (دید از فاصله):** استفاده‌ی هوشمندانه از `range` و
> `noshadow` روی جزئیات کوچک، بار رندر چند دوربین را به‌شدت کم می‌کند.

---

## ۷. افکت‌ها، شیدرها و Lightmap

افکت‌ها (`<effect>`) متریال‌های پیشرفته (نور شب، بازتاب، PBR) را به آبجکت‌ها
می‌چسبانند و از یک افکت پایه `<inherits-from>` ارث می‌برند.

### ۷.۱ Lightmap (روشن‌شدن پنجره/لوگو در شب)

```xml
<effect>
  <inherits-from>Effects/light-map</inherits-from>
  <object-name>Fuselage</object-name>
  <object-name>CabinWindows</object-name>
  <parameters>
    <texture n="3">
      <image>Aircraft/B737/Models/lightmap.png</image>
      <type>2d</type>
    </texture>
    <lightmap-enabled type="int">1</lightmap-enabled>
    <lightmap-factor type="float">
      <use>/controls/lighting/cabin-norm</use>
    </lightmap-factor>
  </parameters>
</effect>
```

### ۷.۲ Reflection / Chrome (بدنه‌ی براق)

```xml
<effect>
  <inherits-from>Effects/reflect</inherits-from>
  <object-name>Fuselage</object-name>
  <parameters>
    <reflect-enabled type="int">1</reflect-enabled>
    <reflect-correction type="float">0.6</reflect-correction>
  </parameters>
</effect>
```

### ۷.۳ PBR (متریال فیزیکی مدرن)
از انیمیشن `type=pbr` یا افکت‌های PBR استفاده کن (نیازمند rendering pipeline
ALS/Compositor). برای پروژه‌های performance-critical (مثل برج چنددوربینه) با احتیاط
به‌کار ببر چون هزینه‌ی GPU دارد.

> ⚙️ افکت‌ها به سطح رندرینگ (`/sim/rendering/shaders/*`) وابسته‌اند. اگر کاربر
> شیدرها را پایین بیاورد، باید fallback مناسب داشته باشی.

---

## ۸. سیستم ذرات (Particles)

سیستم ذرات SimGear (`particles.cxx`) برای دود اگزوز، شعله، afterburner، گردوغبار
چرخ‌ها و آتش استفاده می‌شود. یک فایل XML جدا که به‌عنوان `<model>` لود می‌شود.

### ۸.۱ نمونه‌ی دود موتور (`SSQ_flame.xml` style)

```xml
<?xml version="1.0"?>
<PropertyList>
  <particlesystem>
    <name>engine-smoke</name>
    <texture>smoke.png</texture>
    <emissive type="bool">false</emissive>
    <placer>
      <type>point</type>
    </placer>
    <shooter>
      <theta-min-deg>0</theta-min-deg>
      <theta-max-deg>5</theta-max-deg>
      <speed>
        <value>2.0</value>
        <spread>0.5</spread>
      </speed>
    </shooter>
    <counter>
      <particles-per-sec>
        <value>40</value>
        <condition>
          <greater-than>
            <property>/engines/engine[0]/n1</property>
            <value>80</value>           <!-- فقط در توان بالا -->
          </greater-than>
        </condition>
      </particles-per-sec>
    </counter>
    <particle>
      <start>
        <size><value>0.2</value></size>
        <color><red><value>0.2</value></red>
               <green><value>0.2</value></green>
               <blue><value>0.2</value></blue>
               <alpha><value>0.6</value></alpha></color>
      </start>
      <end>
        <size><value>3.0</value></size>
        <color><alpha><value>0.0</value></alpha></color>
      </end>
      <life-sec><value>2.5</value></life-sec>
    </particle>
  </particlesystem>
</PropertyList>
```

سپس در `-main.xml` با `<offsets>` پشت موتور قرارش بده:

```xml
<model>
  <name>engine-smoke-left</name>
  <path>Aircraft/B737/Models/engine-smoke.xml</path>
  <offsets>
    <x-m>-2.5</x-m>  <!-- پشتِ نازل -->
    <y-m>-5.0</y-m>  <!-- موتور چپ -->
    <z-m>-1.0</z-m>
  </offsets>
</model>
```

### ۸.۲ Afterburner
همان ساختار، با `emissive=true`، رنگ آبی/نارنجی، و `<condition>` روی
`/controls/engines/engine[0]/afterburner`.

---

## ۹. صدا

فایل `-sound.xml` (یک `PropertyList`) صداها را به property‌ها وصل می‌کند:

```xml
<?xml version="1.0"?>
<PropertyList>
  <fx>
    <engine>
      <name>engine-rumble</name>
      <path>Aircraft/B737/Sounds/jet.wav</path>
      <mode>looped</mode>
      <property>/engines/engine[0]/n1</property>
      <volume>
        <factor>0.7</factor>
        <property>/engines/engine[0]/n1</property>
        <min>0.0</min><max>1.0</max>
      </volume>
      <pitch>
        <factor>0.5</factor>
        <offset>0.5</offset>
        <property>/engines/engine[0]/n1</property>
      </pitch>
      <position>
        <x>-2</x><y>5</y><z>-1</z>
      </position>
    </engine>

    <gear-touch>
      <name>touchdown</name>
      <path>Aircraft/B737/Sounds/touch.wav</path>
      <mode>once</mode>
      <condition>
        <property>/gear/gear[1]/wow</property>
      </condition>
    </gear-touch>
  </fx>
</PropertyList>
```

در `-set.xml`: `<sim><sound><path>Aircraft/B737/Sounds/b737-sound.xml</path></sound></sim>`

---

## ۱۰. Performance و دیتابیس AI

وقتی هواپیما به‌عنوان **AI Traffic** (نه هواپیمای کاربر) لود می‌شود، FlightGear به‌جای
اجرای FDM کامل، نرخ صعود و سرعت‌ها را از یک دیتابیس مرکزی می‌خواند:

```
$FG_ROOT/AI/Aircraft/performancedb.xml
```

### ۱۰.۱ ساختار (از فایل واقعی fgdata)

```xml
<PropertyList>
  <performancedb>
    <aircraft>
      <type>jet_transport</type>          <!-- کلاس پایه‌ی جنریک -->
      <acceleration-kts-hour>5.0</acceleration-kts-hour>
      <deceleration-kts-hour>2.0</deceleration-kts-hour>
      <climb-rate-fpm>3000.0</climb-rate-fpm>
      <descent-rate-fpm>1500.0</descent-rate-fpm>
      <rotate-speed-kts>100.0</rotate-speed-kts>
      <takeoff-speed-kts>140.0</takeoff-speed-kts>
      <climb-speed-kts>300.0</climb-speed-kts>
      <cruise-speed-kts>430.0</cruise-speed-kts>
      <descent-speed-kts>300.0</descent-speed-kts>
      <approach-speed-kts>170.0</approach-speed-kts>
      <touchdown-speed-kts>130.0</touchdown-speed-kts>
      <taxi-speed-kts>15.0</taxi-speed-kts>
    </aircraft>

    <aircraft>
      <type>320</type>
      <base>jet_transport</base>          <!-- ارث‌بری از کلاس بالا -->
      <match>A320</match>                 <!-- تطبیق با نام/مدل -->
      <climb-rate-fpm>2500.0</climb-rate-fpm>
    </aircraft>
  </performancedb>
</PropertyList>
```

**کلاس‌های جنریک موجود:** `heavy_jet`, `jet_transport`, `turboprop_transport`,
`light`, `jet_fighter`, `ww2_fighter`, `tanker`, `shuttle`, `ufo`.

### ۱۰.۲ نحوه‌ی نگاشت (از `AIAircraft.cxx`)
- هنگام ساخت بلیپ از سناریو، خاصیت `class` خوانده می‌شود:
  `setPerformance("", class="jet_transport")`.
- `getDataFor(type, class)` در DB تطبیق می‌دهد.
- اگر چیزی نیافت، پیش‌فرض `jet_transport` استفاده می‌شود.

> ⚠️ تطبیق به متن `<type>`/`<match>` و به حروف بزرگ/کوچک حساس است. اگر بلیپ
> performance غلط می‌گیرد، اول `class` در فایل سناریو و سپس `<match>` را چک کن.

---

## ۱۱. Autopilot و کنترلرها

Autopilot در FlightGear یک زنجیره از **کنترلرها** است که هر فریم اجرا می‌شوند.
انواع کنترلر (از `src/Autopilot/`):

| فایل/نوع | کاربرد |
|----------|--------|
| `pid-controller` | کنترلر PID کامل (Kp/Ki/Kd) |
| `pi-simple-controller` | PI ساده |
| `filter` (`digitalfilter`) | فیلترهای gain/exponential/noise-spike/… |
| `predictor` | پیش‌بینی مقدار آینده |
| `logic` | منطق بولی |
| `flipflop` | فلیپ‌فلاپ (RS/JK/…) برای منطق حالت‌دار |

### ۱۱.۱ نمونه‌ی PID (نگه‌داشتن ارتفaع با elevator)

```xml
<?xml version="1.0"?>
<PropertyList>
  <pid-controller>
    <name>Altitude Hold</name>
    <debug>false</debug>
    <enable>
      <property>/autopilot/locks/altitude</property>
      <value>altitude-hold</value>
    </enable>
    <input>
      <property>/position/altitude-ft</property>
    </input>
    <reference>
      <property>/autopilot/settings/target-altitude-ft</property>
    </reference>
    <output>
      <property>/controls/flight/elevator-trim</property>
    </output>
    <config>
      <Kp>-0.0002</Kp>
      <Ti>10.0</Ti>
      <Td>0.00001</Td>
      <min>-1.0</min>
      <max>1.0</max>
    </config>
  </pid-controller>
</PropertyList>
```

### ۱۱.۲ نمونه‌ی filter (نرم‌کردن یک ورودی پرتنش — مفید برای ضدلرزش)

```xml
<filter>
  <name>smooth-heading</name>
  <type>exponential</type>
  <input><property>/orientation/heading-deg</property></input>
  <output><property>/instrumentation/heading-smoothed-deg</property></output>
  <filter-time>0.5</filter-time>
</filter>
```

> 💡 **ارتباط با ضدلرزش بلیپ‌ها در پروژه:** همین `filter` نوع `exponential` را
> می‌توان روی `target-alt`/`roll` بلیپ‌ها گذاشت تا حرکت نرم شود — جایگزین
> snap کردن مستقیم property که باعث پرش بصری می‌شود.

در `-set.xml`:
```xml
<sim><systems><autopilot><path>Aircraft/B737/Systems/autopilot.xml</path></autopilot></systems></sim>
```

---

## ۱۲. بالگرد (Helicopter)

فیزیک بالگرد با YASim توصیه می‌شود (محاسبه‌ی downwash بومی). به‌جای wing از
`<rotor>` و `<rotorgear>` استفاده می‌شود.

### ۱۲.۱ کنترل اصلی
بالگرد فلپ/اسپویلر ندارد. کنترل صعود از طریق گام جمعی روتور:
- `/controls/rotor/collective` — گام جمعی (بالا/پایین)
- cyclic (جلو/عقب و چپ/راست) — کج‌کردن صفحه‌ی روتور
- `/controls/rotor/reltarget`، `/controls/rotor/engine-on` — موتور/گاورنر

### ۱۲.۲ نمونه‌ی روتور (Bo105، از ویکی)

```xml
<rotor name="main" x="-2.75" y="0.0" z="1.55"
       nx="0.05" ny="0" nz="1." fx="1" fy="0" fz="0" ccw="1"
       maxcollective="15.8" mincollective="0.2"
       mincyclicele="-4.7" maxcyclicele="10.5"
       mincyclicail="-4.23" maxcyclicail="5.65"
       diameter="9.98" numblades="4" weightperblade="75"
       relbladecenter="0.5" dynamic="1" rpm="442"
       rellenflaphinge="0.18" delta3="0" delta=".125"
       pitch-a="10" pitch-b="15"
       flapmin="-15" flapmax="15" flap0="-5"
       translift-ve="20" translift-maxfactor="1.5">
  <control-input axis="/controls/rotor/collective" control="COLLECTIVE"/>
  <control-input axis="/controls/flight/elevator"  control="CYCLICELE"/>
  <control-input axis="/controls/flight/aileron"   control="CYCLICAIL"/>
</rotor>

<rotorgear max-power-engine="280" engine-prop-factor="0.02"
           engine-accel-limit="5" max-power-rotor-brake="100"
           rotorgear-friction="2" yasimdragfactor="10" yasimliftfactor="140">
  <control-input axis="/controls/rotor/engine-on"  control="ROTORGEARENGINEON"/>
  <control-input axis="/controls/rotor/reltarget"  control="ROTORRELTARGET"/>
</rotorgear>
```

### ۱۲.۳ پارامترهای مهم روتور (خلاصه از README.yasim)
- `diameter`, `numblades`, `weightperblade`, `chord`, `twist`, `taper`
- `maxcollective`/`mincollective`, `maxcyclicele`/`maxcyclicail`
- `translift-maxfactor`/`translift-ve` — lift انتقالی در پرواز رو به جلو
- `ground-effect-constant` — افزایش torque نزدیک زمین
- `number-of-parts`/`number-of-segments` — دقت شبیه‌سازی (۸/۸ برای روتور اصلی،
  ۴/۵ برای دم؛ بیشتر = CPU بیشتر). `number-of-parts` باید مضرب ۴ باشد.
- `ccw` — جهت چرخش (`1` = پادساعت‌گرد).

### ۱۲.۴ انیمیشن پره‌ها
انیمیشن روتور باید همزمان `rotors/main/rpm` (چرخش) و زاویه‌ی flap/cyclic پره‌ها را
بخواند. از `spin` برای چرخش و `rotate` برای flapping استفاده کن.

---

## ۱۳. اسکریپت‌نویسی Nasal

Nasal زبان اسکریپت داخلی FlightGear است؛ برای سیستم‌هایی که با XML نمی‌شود.

### ۱۳.۱ الگوهای پایه

```nasal
# خواندن/نوشتن property
var alt = getprop("/position/altitude-ft");
setprop("/controls/gear/gear-down", 1);

# گره‌ها (سریع‌تر برای دسترسی مکرر — handle را کش کن)
var n = props.globals.getNode("/controls/flight/flaps", 1);
n.setValue(0.5);

# listener (event-driven؛ فقط هنگام تغییر اجرا می‌شود — بهینه)
setlistener("/controls/gear/gear-down", func(node) {
    print("Gear command: ", node.getValue());
});

# timer (polling؛ با نرخ مشخص اجرا می‌شود)
var t = maketimer(0.1, func {
    # کد هر 0.1 ثانیه
});
t.start();

# اجرای پس از init شدن FDM
setlistener("/sim/signals/fdm-initialized", func {
    print("FDM ready");
});
```

### ۱۳.۲ نکته‌ی کارایی (حیاتی برای پروژه‌ی برج)
- **`setlistener` را به `maketimer` ترجیح بده** برای چیزهایی که به‌ندرت عوض می‌شوند
  (گیر، فلپ، حالت). polling با نرخ بالا روی N آبجکت = اتلاف CPU و frame-spike.
- اگر مجبور به timer هستی، **handle گره‌ها را یک‌بار بیرون از حلقه کش کن**، نه با
  `getprop`/`getNode` رشته‌ای در هر تیک.
- توابع سنگین مثل `geo.elevation()` را کش کن (FlightGear بومی این را هر ۳–۱۳ ثانیه
  با رندوم‌سازی انجام می‌دهد؛ از همان الگو پیروی کن).

### ۱۳.۳ نمونه: محاسبه‌ی Bank Angle برای بلیپ AI

```nasal
# اعمال زاویه‌ی غلت بر اساس نرخ گردش (برای بلیپ‌های بدون خلبان)
var updateBank = func(path) {
    var ac = props.globals.getNode(path);
    if (ac == nil) return;
    var spd  = ac.getValue("velocities/true-airspeed-kt") or 0;
    var rate = ac.getValue("velocities/heading-rate-degps") or 0;
    # فرمول استاندارد (تقریب rate-one turn)
    var bank = (spd * rate) / 10.0;
    ac.setValue("orientation/roll-deg", bank);
};
```

---

## ۱۴. لیوری (Liveries)

سیستم لیوری اجازه می‌دهد تکسچر هواپیما بدون تغییر مدل عوض شود.

```
Aircraft/B737/Liveries/
├── default.xml
├── Lufthansa.xml
└── Lufthansa.png
```

نمونه‌ی `Lufthansa.xml`:

```xml
<?xml version="1.0"?>
<PropertyList>
  <sim>
    <description>Lufthansa</description>
    <variant>B737</variant>
  </sim>
  <object>
    <name>Fuselage</name>
    <texture>Lufthansa.png</texture>
  </object>
</PropertyList>
```

برای فعال‌سازی منوی لیوری، ماژول `liveries.nas` استاندارد را در `-set.xml` لود کن
(الگوی aircraft موجود را کپی کن).

---

## ۱۵. هواپیمای AI و پروژه‌ی برج مراقبت

این بخش مخصوص پروژه‌ی ATC Tower Trainer (OIII مهرآباد) است: هواپیماها به‌عنوان بلیپ
AI لود و از طریق Property Tree کنترل می‌شوند.

### ۱۵.۱ ساختار مدل AI
مدل ساده‌شده‌ی AI در مسیر زیر قرار می‌گیرد (نه پوشه‌ی کامل Aircraft):

```
$FG_ROOT/AI/Aircraft/<Type>/Models/<Type>.xml   (یا .ac مستقیم)
```

این مدل سبک‌تر است (بدون کابین کامل) چون از فاصله دیده می‌شود — ایده‌آل برای دید برج.

### ۱۵.۲ Property‌های کنترلی استاندارد بلیپ
هر بلیپ زیر `/ai/models/aircraft[n]/` این گره‌ها را دارد:

| گره | کاربرد |
|-----|--------|
| `controls/flight/target-hdg` | هدینگ هدف |
| `controls/flight/target-alt` | ارتفاع هدف (ft) |
| `controls/flight/target-spd` | سرعت هدف (kt) |
| `controls/flight/target-roll` | غلت هدف |
| `controls/flight/lateral-mode` | حالت جانبی (`roll`/…) |
| `controls/flight/vertical-mode` | حالت عمودی (`alt`/…) |
| `position/{latitude,longitude}-deg`, `altitude-ft` | موقعیت |
| `velocities/true-airspeed-kt` | سرعت واقعی |
| `gear/gear[n]/position-norm` | وضعیت چرخ‌ها |
| `surface-positions/flap-pos-norm` | وضعیت فلپ (مفرد!) |
| `orientation/{heading,pitch,roll}-deg` | جهت‌گیری بصری |

### ۱۵.۳ کانال فرمان کنترلر (الگوی پیشنهادی)
یک property رشته‌ای واحد به‌عنوان کانال فرمان، و parse در Nasal:

```nasal
setlistener("/instructor/command", func(n) {
    var cmd = n.getValue();
    if (cmd == nil or cmd == "") return;
    var p = split(";", cmd);     # مثال: "HDG;2;280" → بلیپ ۲ به هدینگ 280
    if (size(p) < 3) return;
    var idx = num(p[1]);
    var ac = props.globals.getNode("/ai/models/aircraft[" ~ idx ~ "]");
    if (ac == nil) return;
    if (p[0] == "HDG") ac.setValue("controls/flight/target-hdg", num(p[2]));
    if (p[0] == "ALT") ac.setValue("controls/flight/target-alt", num(p[2]));
    if (p[0] == "SPD") ac.setValue("controls/flight/target-spd", num(p[2]));
});
```

این فرمان‌ها از بیرون از طریق `--telnet=5000`، HTTP/JSON، یا Generic protocol
نوشته می‌شوند:
```
telnet localhost 5000
> set /instructor/command HDG;2;280
```

### ۱۵.۴ قفل بلیپ روی زمین (با کش ارتفاع — ضدلرزش)

```nasal
# به‌جای geo.elevation هر تیک، ارتفاع میدان را ثابت/کش کن
var FIELD_ELEV_FT = 3962;   # OIII مهرآباد ≈ مسطح

var clamp = func {
    foreach (var ac; props.globals.getNode("/ai/models").getChildren("aircraft")) {
        if (ac.getValue("on-ground") != "true") continue;
        ac.setValue("position/altitude-ft", FIELD_ELEV_FT);
    }
};
# نرخ پایین کافی است؛ نوشتن هر تیک = پرش بصری
var t = maketimer(1.0, clamp); t.start();
```

> برای جزئیات بهینه‌سازی رندر چنددوربینه و رفع پرش، به یادداشت‌های performance
> پروژه (`PC2/research-notes/`) رجوع کن.

---

## ۱۶. دیباگ و چک‌لیست نهایی

### ۱۶.۱ ابزارها
- **`fg-check-aircraft`** (از بسته‌ی FGMeta-Python): اعتبارسنجی `-set.xml`.
- **Property Browser** داخل شبیه‌ساز: دیدن زنده‌ی درخت.
- **`--log-level=info`** / `alert`: گزارش خطاهای لود مدل/FDM/Nasal.
- پیش‌تست XML: باز کردن فایل در مرورگر (نشان‌دادن خطای ساختاری XML).
- **`--telnet=5000`**: خواندن/نوشتن property از بیرون.

### ۱۶.۲ خطاهای رایج
| نشانه | علت محتمل |
|-------|-----------|
| «گلایدر آبی-زرد» به‌جای مدل | مسیر مدل غلط یا نام پوشه اشتباه (`expected-aircraft-dir-name`) |
| انیمیشن کار نمی‌کند | نام `object-name` با فایل `.ac` مطابق نیست، یا property اشتباه (`flaps-pos-norm` vs `flap-pos-norm`) |
| هواپیما لود نمی‌شود | تگ بسته‌نشده در XML، یا `<flight-model>`/`<aero>` غلط |
| performance غلط AI | عدم تطبیق `class`/`<match>` با `performancedb.xml` (حساس به حروف) |
| تکسچر سیاه | ابعاد غیرتوان‌۲ یا مسیر مطلق به‌جای نسبی |

### ۱۶.۳ چک‌لیست انتشار
- [ ] تمام تگ‌های XML درست بسته شده‌اند (مخصوصاً `<condition>` تودرتو).
- [ ] `object-name`ها دقیقاً با نام آبجکت‌های `.ac` مطابق‌اند (حساس به حروف).
- [ ] همه‌ی مسیرها نسبی از ریشه‌ی هواپیما هستند.
- [ ] property‌های انیمیشن با FDM واقعی کراس‌چک شده‌اند.
- [ ] متادیتا (`description`, `author`, `rating`, `tags`) پر شده.
- [ ] thumbnail و حداقل یک preview موجود است.
- [ ] برای AI: مدل سبک در `AI/Aircraft/` + ورودی `performancedb.xml`.
- [ ] تست با `--log-level=alert` بدون خطا لود می‌شود.

---

## ۱۷. پیوست: مرجع سریع Property Tree

```
/controls/
  flight/{aileron,elevator,rudder,flaps,spoilers,speedbrake,elevator-trim}
  engines/engine[n]/{throttle,mixture,starter,afterburner,reverser}
  gear/{brake-left,brake-right,gear-down}
  rotor/{collective,reltarget,engine-on}        ← بالگرد
/surface-positions/
  {flap-pos-norm,speedbrake-pos-norm,spoiler-pos-norm,
   left-aileron-pos-norm,right-aileron-pos-norm,
   elevator-pos-norm,rudder-pos-norm,nose-wheel-pos-norm}
/gear/gear[n]/{position-norm,wow,compression-norm}
/engines/engine[n]/{rpm,n1,n2,thrust_lb,fuel-flow-gph,running}
/orientation/{heading-deg,pitch-deg,roll-deg}
/velocities/{airspeed-kt,true-airspeed-kt,vertical-speed-fps,mach}
/position/{latitude-deg,longitude-deg,altitude-ft,altitude-agl-ft}
/autopilot/
  locks/{altitude,heading,speed}
  settings/{target-altitude-ft,heading-bug-deg,target-speed-kt}
/ai/models/aircraft[n]/...                       ← بلیپ‌های AI (بخش ۱۵)
/sim/
  model/path, aircraft, current-view/view-number
  signals/{fdm-initialized,click}
  rendering/shaders/*
```

---

### منابع
- FlightGear Wiki: `Howto:Make an aircraft`، `Aircraft-set.xml`، `Howto:Make a helicopter`
- سورس‌کد: `simgear/scene/model/animation.cxx` (انواع animation)،
  `flightgear/src/Autopilot/*` (کنترلرها)، `flightgear/src/AIModel/*` (AI/ground)،
  `fgdata/AI/Aircraft/performancedb.xml` (دیتابیس performance)
- مستندات YASim: `README.yasim`, `README.yasim.rotor`
- JSBSim: مستندات رسمی JSBSim + ابزار Aeromatic

> این سند یک مرجع کاری زنده است؛ با پیشرفت پروژه‌ی OIII (به‌خصوص کانال فرمان
> instructor و بهینه‌سازی رندر) به‌روزرسانی شود.
