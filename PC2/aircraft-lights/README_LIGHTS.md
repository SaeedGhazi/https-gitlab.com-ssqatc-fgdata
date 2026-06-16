# چراغ فرود و تاکسی برای A346 — راهنما و روال کار

## فایل‌های این بسته
| فایل | جا |
|------|-----|
| `346-LandingLights.xml` | در `AI/Aircraft/A346/Lights/346-LandingLights.xml` کپی شود |
| `A346-main.xml` | جایگزین `AI/Aircraft/A346/A346-main.xml` (فقط یک `<model>` اضافه دارد) |

> اگر نمی‌خواهی main.xml را جایگزین کنی، فقط این دو خط را کنار NavLights اضافه کن:
> ```xml
> <model><path>Lights/346-LandingLights.xml</path></model>
> ```

---

## روال کار (چطور یک چراغ ساخته می‌شود)

ساخت چراغ فرود/تاکسی در FlightGear سه لایه دارد:

### ۱) انتخاب نوع و مشخصات نور
- **چراغ فرود (Landing):** مخروط **باریک** (`spot-cutoff` ~۱۶°)، **برد بلند**
  (`range-m` ~۹۰۰)، رو به جلو با شیب کم (`pitch-deg` ~۴ پایین).
- **چراغ تاکسی (Taxi):** مخروط **پهن** (`spot-cutoff` ~۲۸°)، **برد کوتاه**
  (`range-m` ~۱۲۰)، شیب بیشتر رو به پایین (`pitch-deg` ~۱۱).

### ۲) پیداکردن مختصات نصب در فریم مدل
فریم FlightGear (همان `<offsets>`):
```
-x = جلو(دماغه)   +x = عقب(دم)   +y = راست   -y = چپ   +z = بالا   -z = پایین
```
(از موقعیت موتورهای A346 در main.xml تأیید شد: بیرونی y=±۱۹، داخلی y=±۹.)

نصب واقعی A340-600:
- **چراغ فرود:** ریشه‌ی بال، چپ و راست → `x=-7, y=∓4, z=-1.5`
- **چراغ تاکسی:** روی ارابه‌ی دماغه → `x=-28, y=0, z=-3`

### ۳) ساخت بلوک `<light>` + اتصال به سوییچ
هر چراغ = یک `<light type="spot">` + یک انیمیشن `select` که با property کنترلی
روشن/خاموشش می‌کند. **property نسبی** انتخاب شده تا هم کاربر و هم بلیپ AI کار کند:
```
controls/lighting/landing-lights   (چراغ فرود)
controls/lighting/taxi-light        (چراغ تاکسی)
```

---

## نصب
```bash
mkdir -p $FG_ROOT/AI/Aircraft/A346/Lights
cp 346-LandingLights.xml  $FG_ROOT/AI/Aircraft/A346/Lights/
cp A346-main.xml          $FG_ROOT/AI/Aircraft/A346/A346-main.xml
```

## روشن/خاموش کردن

**هواپیمای کاربر:** کلید پیش‌فرض، یا منوی روشنایی، یا property:
```
/controls/lighting/landing-lights = true
/controls/lighting/taxi-light = true
```

**بلیپ AI (مهم برای پروژه‌ی برج):** چون مسیر نسبی است، برای بلیپ شماره‌ی n:
```
telnet localhost 5000
> set /ai/models/aircraft[2]/controls/lighting/landing-lights true
> set /ai/models/aircraft[2]/controls/lighting/taxi-light true
```
یا در Nasal: `ac.setValue("controls/lighting/landing-lights", 1);`

---

## ⚠️ پیش‌نیاز رندر (مهم)
چراغ‌های `<light>` spot از سیستم **clustered/ALS** استفاده می‌کنند. برای دیده‌شدن
نورِ روی زمین باید رندر ALS (Atmospheric Light Scattering) یا Compositor فعال باشد:
- منوی **View → Rendering Options → Shader = ALS** (یا Compositor).
- اگر رندر کلاسیک (legacy) باشد، این نورها زمین را روشن نمی‌کنند.

> برای پروژه‌ی برج چندمانیتوره: هر چراغ spot هزینه‌ی GPU دارد. ۳ چراغ برای یک
> هواپیما اوکی است؛ اگر روی **همه‌ی بلیپ‌ها** فعال شود، بار رندر بالا می‌رود —
> فقط روی بلیپ‌های نزدیک/فعال روشن کن.

---

## تنظیم دقیق موقعیت (Fine-tuning)
موقعیت‌ها تقریبی‌اند؛ برای دیدن مخروط نور و تنظیم آن:
```
set /sim/debug/show-light-volumes true
```
این مخروط رنگی هر چراغ را نشان می‌دهد (رنگ‌ها از `<debug-color>`: فرود چپ=قرمز،
راست=سبز، تاکسی=آبی). سپس `position` و `direction` را در XML تغییر بده تا مخروط
دقیقاً از لامپ به جلو/پایین بیفتد. مقادیری که معمولاً تنظیم می‌کنی:
- `position/x,y,z` → محل لامپ
- `direction/pitch-deg` → شیب رو به پایین
- `spot-cutoff` → پهنای مخروط
- `range-m` و `attenuation/l,q` → برد و افت شدت

---

## (اختیاری) لامپِ دیداری از فاصله
نور spot زمین را روشن می‌کند ولی خودِ «حبابِ روشن لامپ» را از دور نشان نمی‌دهد.
اگر می‌خواهی از برج، نقطه‌ی روشنِ لامپ هم دیده شود، یک corona/billboard کوچک
emissive سرِ همان مختصات اضافه کن (مثل الگوی NavLights موجود `346-NavLights.xml`).
