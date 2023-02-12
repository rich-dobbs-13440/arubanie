/* 

Rescuing some well working printable parts that aren't needed in current assemble.

Status:  Just move extracted parts into this file.  Not yet converted 
            into a reuseable component. 

*/



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
            //trigger_shaft();
            trigger_catch();
            //trigger_shaft_gudgeon();
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


module trigger_slider() {
    x = trigger_slider_length;
    y = trigger_bearing_od;
    z = paint_pivot_h/2;
    y_slot = wall_thickness + 2 * trigger_slider_clearance;
    translate([paint_pivot_top_of_yoke - eps, 0, 0]) {
        render() difference() {
            union() {
                block([x, y, z], center=ABOVE+FRONT);
                rod(
                    d=trigger_bearing_od,
                    l=trigger_slider_length, 
                    center=FRONT,
                    fa=fa_as_arg);
            }
            rod(
                d=trigger_bearing_id, 
                l=2* trigger_slider_length, 
                fa=fa_as_arg); 
            block([x, y_slot, 2* z], center=ABOVE+FRONT);
        }
         
    }
}



module trigger_catch() {
    dz_build_plane = paint_pivot_h/2; 
    difference() {
        rotate([-90, 180, 90]) master_air_brush_trigger_catch();
        translate([0, 0, dz_build_plane]) {
            block([100, 100, 50], center=ABOVE);
        } 
        // Make sure that the is no interference with the barrel:
        rotate([0,-75,0]) 
            translate([0, 0, 0.75*barrel_diameter]) 
                rod(d=barrel_diameter, l=20);
    }
}


module trigger_shaft() {
    fa_as_arg = $fa;
    
    translate([-eps, 0, 0]) { 
        rod(
            d=trigger_shaft_diameter, 
            l=trigger_shaft_length, 
            center=FRONT,
            fa=fa_as_arg);
        // Slide section has support
        translate([trigger_shaft_length+eps, 0, 0]) 
            block(
                [trigger_slider_length, wall_thickness, paint_pivot_h/2], 
                center=BEHIND+ABOVE);  
    }   
}


module trigger_shaft_gudgeon() {
    dx = trigger_shaft_length + paint_pivot_h/2-eps;
    translate([dx, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            trigger_shaft_diameter, 
            trigger_shaft_gudgeon_length, 
            trigger_shaft_pivot_allowance, 
            range_of_motion=[90, 90],
            pin= "M3 captured nut",
            fa=fa_as_arg);




module trigger_rod() {

    pintle(
        paint_pivot_h, 
        trigger_shaft_diameter, 
        trigger_rod_length/2 + eps, 
        trigger_shaft_pivot_allowance,
        range_of_motion=[90, 90], 
        pin= "M3 captured nut",
        fa=fa_as_arg);
    translate([trigger_rod_length, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            trigger_shaft_diameter, 
            trigger_rod_length/2 + eps, 
            trigger_shaft_pivot_allowance, 
            range_of_motion=[90, 90],
            pin= "M3 captured nut", 
            fa=fa_as_arg);
        
}


module connected_trigger_rod(angle) {
    dx = trigger_shaft_length + paint_pivot_h/2-eps;
    translate([dx, 0, 0]) {
        rotate([0, angle, 0]) { 
            trigger_rod();
        }
    }
}