# سیستم مدیریت بهینه و اصلاح شده ترافیک سناریو بر اساس معماری بومی پرپرتی تری
setlistener("/sim/signals/fdm-initialized", func { 
    screen.log.write("Scenario Core Sync: ACTIVE (Gear-Fix applied)");

    var doit = func {
        var ai_models_node = props.globals.getNode("/ai/models");
        if (ai_models_node == nil) return;

        # دریافت لیست تمام هواپیماهای ساخته شده توسط هسته شبیه‌ساز
        var aircraft_list = ai_models_node.getChildren("aircraft");
        
        foreach(var ac; aircraft_list) {
            # پیدا کردن کالسایین هواپیما برای اطمینان از لود فیزیک
            var callsign_node = ac.getNode("callsign");
            if (callsign_node == nil) continue;

            # ۱. بررسی گره on-ground در ریشه اصلی هواپیما (کاملاً مطابق کد تست شده و موفق شما)
            var ongnd_node = ac.getNode("on-ground");
            if (ongnd_node == nil) {
                ongnd_node = ac.initNode("on-ground", "true", "STRING");
            }
            
            var status = ongnd_node.getValue();

            # ۲. دریافت گره‌های موقعیت جغرافیایی بومی برای چسباندن هواپیما به سطح زمین
            var lat_node = ac.getNode("position/latitude-deg");
            var lon_node = ac.getNode("position/longitude-deg");
            var alt_node = ac.getNode("position/altitude-ft");
            var tgt_alt  = ac.getNode("controls/flight/target-alt");
            var speed_node = ac.getNode("velocities/true-airspeed-kt");

            if (lat_node != nil and lon_node != nil and alt_node != nil) {
                var lat = lat_node.getValue();
                var lon = lon_node.getValue();
                
                # محاسبه ارتفاع زمین در فرودگاه مهرآباد (OIII) یا هر نقطه سناریو
                var elv = geo.elevation(lat, lon);
                
                if (elv != nil) {
                    var ground_alt_ft = elv * 3.28084;

                    # اگر تگ سناریو روی زمین (true) بود، ارتفاع را روی سطح زمین قفل کن
                    if (status == "true" or status == 1 or status == "1") {
                        alt_node.setValue(ground_alt_ft);
                        if (tgt_alt != nil) tgt_alt.setValue(ground_alt_ft);

                        # اگر سرعت هواپیمای ترافیک از ۱۴۰ نات گذشت (تیک‌آف)، روی زمین را غیرفعال کن
                        if (speed_node != nil and speed_node.getValue() > 140) {
                            ongnd_node.setValue("false");
                            if (tgt_alt != nil) tgt_alt.setValue(6000.0);
                        }
                    }
                }
            }

            # ۳. بررسی وضعیت gear-down از ریشه اصلی هواپیما (لود شده از فایل XML سناریو)
            var gear_dn_node = ac.getNode("gear-down");
            if (gear_dn_node == nil) {
                gear_dn_node = ac.initNode("gear-down", "true", "STRING");
            }
            var gear_status = gear_dn_node.getValue();

            # اعمال تغییرات مستقیم روی گره بومی شبیه‌ساز بدون ایجاد گره سفارشی یا اشتباه
            # پیمایش داینامیک از چرخ ۰ تا ۴ (پوشش کامل تا ۵ ارابه فرود برای هواپیماهای پهن‌پیکر مثل A346)
            for (var g = 0; g < 5; g += 1) {
                # ساخت مسیر دقیق منطبق با ساختار اعلامی شما: gear/gear[x]/position-norm
                var gear_path = "gear/gear[" ~ g ~ "]/position-norm";
                var gear_pos_norm = ac.getNode(gear_path);
                
                # اگر گره از قبل توسط مدل هواپیما ایجاد شده باشد، مقدار را ست می‌کند
                if (gear_pos_norm != nil) {
                    if (gear_status == "true" or gear_status == 1 or gear_status == "1") {
                        gear_pos_norm.setValue(1.0); # نمایان شدن ارابه فرود
                    } else {
                        gear_pos_norm.setValue(0.0); # جمع شدن و مخفی شدن ارابه فرود
                    }
                }
            }

            # ۴. بررسی و اعمال وضعیت فلپ‌ها (Flaps Down) از روی فایل سناریو
            var flaps_dn_node = ac.getNode("flaps-down");
            if (flaps_dn_node == nil) {
                flaps_dn_node = ac.initNode("flaps-down", "false", "STRING");
            }
            
            var flaps_status = flaps_dn_node.getValue();
            var flaps_pos_norm = ac.getNode("surface-positions/flaps-pos-norm");

            if (flaps_pos_norm != nil) {
                if (flaps_status == "true" or flaps_status == 1 or flaps_status == "1") {
                    flaps_pos_norm.setValue(1.0); # فلپ‌ها کاملاً باز
                } else {
                    flaps_pos_norm.setValue(0.0); # فلپ‌ها بسته
                }
            }
        }
    };

    # اجرای مداوم و تکرارشونده اسکریپت هر ۰.۲ ثانیه
    var timer = maketimer(0.2, doit);
    timer.start();
});
