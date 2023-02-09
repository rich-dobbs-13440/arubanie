



/* [Trigger Slider Design] */
show_trigger_slider = true;
trigger_slider_clearance = 0.4;
trigger_slider_length = 10; // [0: 20]
trigger_slider_color = "LightSteelBlue"; // [DodgerBlue, LightSteelBlue, Coral]
trigger_slider_alpha = 1; // [0:0.05:1]


/* [Trigger Shaft Design] */
show_trigger_shaft_assembly = true;

trigger_shaft_position = 0.5; // [0.0 : 0.01: 1.0]

trigger_shaft_bearing_clearance = 0.4;
trigger_shaft_diameter = 5;

trigger_shaft_gudgeon_length = 2;
trigger_shaft_min_x = 10;
trigger_shaft_catch_clearance = 1;
trigger_shaft_pivot_allowance = 0.4;

trigger_bearing_id = 
    trigger_shaft_diameter 
    + 2 * trigger_shaft_bearing_clearance;
    
trigger_bearing_od = 
    trigger_bearing_id
    + 2 * wall_thickness;
       
trigger_shaft_range = 
    paint_pivot_inner_height 
    - trigger_shaft_catch_clearance
    - trigger_shaft_min_x ;

trigger_shaft_color = "PaleGreen"; // [DodgerBlue, PaleGreen, Coral]
trigger_shaft_alpha = 1; // [0:0.05:1]

trigger_shaft_length = 
    trigger_shaft_range 
    + 2 * trigger_shaft_catch_clearance
    + trigger_slider_length 
    + paint_pivot_bridge_thickness;  
  
trigger_shaft_dx = 
    trigger_shaft_min_x
    + trigger_shaft_position * trigger_shaft_range;

/* [Trigger Rod Design] */
show_trigger_rod = true;
trigger_rod_length = 25;

trigger_rod_color = "RoyalBlue"; // [DodgerBlue, RoyalBlue, Coral]
trigger_rod_alpha = 1; // [0:0.05:1]
trigger_rod_angle = 34; // [0: 5 : 40]  


    if (show_trigger_shaft_assembly) {
        color(trigger_shaft_color, alpha=trigger_shaft_alpha) {
            translate([trigger_shaft_dx, 0, 0]) {
                trigger_shaft();
                trigger_catch();
                trigger_shaft_gudgeon();
            }
        }
    }
    if (show_trigger_rod) {
        color(trigger_rod_color, alpha=trigger_rod_alpha) {
            angle = orient_for_build ? 0: trigger_rod_angle;
            translate([trigger_shaft_dx, 0, 0]) {
                connected_trigger_rod(angle);
            }
        }
    }


    if (show_trigger_slider) {
        color(trigger_slider_color, alpha=trigger_slider_alpha) {
            trigger_slider();
        }
    }

module trigger_shaft_clearance() {
    fa_as_arg = $fa;
    rod(d=trigger_bearing_id, l=2*trigger_shaft_length, fa=fa_as_arg);
}



module bore_for_trigger_shaft() {
    difference() {
        children();
        trigger_shaft_clearance(); 
    }
}    