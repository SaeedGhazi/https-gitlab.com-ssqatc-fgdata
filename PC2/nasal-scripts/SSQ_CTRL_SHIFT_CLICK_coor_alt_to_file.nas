setlistener("/sim/signals/click", func {
    var shift = getprop("/devices/status/keyboard/shift");
    var ctrl  = getprop("/devices/status/keyboard/ctrl");
    var alt   = getprop("/devices/status/keyboard/alt");

    var base_path = getprop("/sim/fg-home") ~ "/Export/";

    # حالت اول: ثبت تک‌نقطه (Shift + Ctrl + Click)
    if (shift and ctrl and !alt) {
        var click_pos = geo.click_position();
        if (click_pos == nil) return;

        var filename = base_path ~ "Extract_by_click.txt";
        var f = io.open(filename, "a"); 
        if (f == nil) return gui.popupTip("Error: Create Export folder!");

        var data = sprintf("%.8f %.8f %.2f\n", click_pos.lat(), click_pos.lon(), click_pos.alt() * 3.2808399);
        io.write(f, data);
        io.close(f);
        gui.popupTip("Point appended to Extract_by_click.txt");
    }

    # حالت دوم: تولید شبکه خودکار (Ctrl + Alt + Click)
    else if (ctrl and alt and !shift) {
        var lat_min = 35.433659;
        var lon_min = 51.122385;
        var lat_max = 35.399354;
        var lon_max = 51.188460;
        var steps = 40;

        var filename = base_path ~ "Extract_by_grid.txt";
        var f = io.open(filename, "w");
        if (f == nil) return gui.popupTip("Error: Create Export folder!");

        gui.popupTip("Generating Grid... Please wait.");
        for (var i = 0; i <= steps; i += 1) {
            var curr_lat = lat_min + (i * (lat_max - lat_min) / steps);
            for (var j = 0; j <= steps; j += 1) {
                var curr_lon = lon_min + (j * (lon_max - lon_min) / steps);
                var elev = geo.elevation(curr_lat, curr_lon);
                if (elev == nil) elev = getprop("/position/altitude-ft") * 0.3048;
                io.write(f, sprintf("%.8f %.8f %.2f\n", curr_lat, curr_lon, elev * 3.2808399));
            }
        }
        io.close(f);
        gui.popupTip("Grid saved to Extract_by_grid.txt");
    }

    # حالت سوم: استخراج ارتفاع از لیست مختصات (Shift + Alt + Click) [اصلاح شده]
    else if (shift and alt and !ctrl) {
        var input_file = base_path ~ "coor_list.txt";
        var output_file = base_path ~ "Extract_by_file.txt";
        
        var f_in = io.open(input_file, "r");
        if (f_in == nil) return gui.popupTip("Error: coor_list.txt not found!");

        var f_out = io.open(output_file, "w");
        if (f_out == nil) {
            io.close(f_in);
            return gui.popupTip("Error: Cannot create Extract_by_file.txt");
        }

        gui.popupTip("Processing file... Please wait.");
        
        var line = "";
        # اصلاح متد خواندن: io.readln به جای io.readline 
        while ((line = io.readln(f_in)) != nil) {
            var coords = split(" ", line);
            if (size(coords) >= 2) {
                var c_lat = num(coords[0]);
                var c_lon = num(coords[1]);
                
                if (c_lat != nil and c_lon != nil) {
                    # استخراج ارتفاع زمین (متر) 
                    var elev_m = geo.elevation(c_lat, c_lon);
                    
                    # هندل کردن زمانی که داده زمین هنوز لود نشده است 
                    if (elev_m == nil) elev_m = 0.0; 
                    
                    # نوشتن در فایل خروجی (Lat Lon Alt_m) 
                    io.write(f_out, sprintf("%.8f %.8f %.2f\n", c_lat, c_lon, elev_m));
                }
            }
        }

        io.close(f_in);
        io.close(f_out);
        gui.popupTip("Process complete! Check Extract_by_file.txt");
    }    
});
