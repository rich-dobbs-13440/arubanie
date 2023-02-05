/* 

All the parts in the assembly that captures the trigger for control of the 
air air and paint flow.

The coordinate system is based center of rotation of the paint pivot.

*/

include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <trigger_holder.scad>
use <master_air_brush.scad>

/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;

$fs = 0.8;
eps = 0.001;

infinity = 1000;




/* [ Example for demonstration] */

orient_for_build_example = true;

paint_pivot_h_example = 8; 
paint_pivot_w_example = 6; 
paint_pivot_inside_dy_example = 16.5/2; //10; // 16.5/2;
// This controls printablity vs play in the pivot.
paint_pivot_allowance_example  = 0.4;
paint_pivot_top_range_of_motion_example  = 145;
paint_pivot_bottom_range_of_motion_example = 90;

paint_pivot_ranges_example = [
    paint_pivot_top_range_of_motion_example, 
    paint_pivot_bottom_range_of_motion_example
];


/* [ Paint Gudgeon Design] */
show_paint_pivot_gudgeon_yoke = true;

// Set to clear the trigger, at depressed with clearance for trigger cap.
// But also need to allow air barrel clip to clear!
paint_pivot_length_gudgeon = 22;
wall_thickness = 2;
paint_pivot_bridge_thickness = 4;



paint_pivot_top_of_yoke =  
    paint_pivot_length_gudgeon 
    + paint_pivot_bridge_thickness;

paint_gudgeon_color = "LightSkyBlue"; // [DodgerBlue, LightSkyBlue, Coral]
paint_gudgeon_alpha = 1; // [0:0.05:1]



/* [Trigger Shaft Design] */
show_trigger_shaft_assembly = true;

trigger_shaft_position = 0.5; // [0.0 : 0.01: 1.0]

trigger_shaft_bearing_clearance = 0.4;
trigger_shaft_diameter = 5;
trigger_shaft_length = 19;
trigger_shaft_gudgeon_length = 2;
trigger_shaft_min_x = 10;
trigger_shaft_catch_clearance = 1;

trigger_bearing_id = 
    trigger_shaft_diameter + 2 * trigger_shaft_bearing_clearance;
    
trigger_shaft_range = 
    paint_pivot_length_gudgeon 
    - trigger_shaft_min_x 
    - trigger_shaft_catch_clearance;
  
trigger_shaft_dx = 
    trigger_shaft_min_x
    + trigger_shaft_position * trigger_shaft_range;
    
trigger_shaft_color = "PaleGreen"; // [DodgerBlue, PaleGreen, Coral]
trigger_shaft_alpha = 1; // [0:0.05:1]




/* [Trigger Slider Design] */
show_trigger_slider = true;
trigger_slider_clearance = 1;
trigger_slider_length = trigger_shaft_range - trigger_slider_clearance;
trigger_slider_color = "LightSteelBlue"; // [DodgerBlue, LightSteelBlue, Coral]
trigger_slider_alpha = 1; // [0:0.05:1]




/* [Air Flow Servo Design] */
show_air_flow_servo_mount = true;
show_air_flow_servo = false;

air_flow_servo_dx = 65; // [20 : 1 : 150]
air_flow_servo_dy = -12; // [-20 : 1 : 20]
air_flow_servo_dz = 0; // [-20 : 1 :20]

air_flow_servo_disp = 
    [air_flow_servo_dx, air_flow_servo_dy,air_flow_servo_dz]; 
    
size_air_servo_mount = [10, 34, 32];
air_flow_servo_color = "PaleTurquoise"; // [DodgerBlue, PaleTurquoise, Coral]
air_flow_servo_alpha = 1; // [0:0.05:1]

module end_of_customization() {}



barrel_diameter = master_air_brush("barrel diameter");


module air_flow_servo_joiner(
        anchor_size, paint_pivot_inside_dy, paint_pivot_h) {
    
    dx_inner = paint_pivot_top_of_yoke; 
    dy_inner = -paint_pivot_inside_dy;
    dz_inner = paint_pivot_h/2;
    disp_inner = [dx_inner, dy_inner, dz_inner];
  
    disp_outer = [air_flow_servo_disp.x, air_flow_servo_disp.y, paint_pivot_h/2];
    
    hull() {
        translate(disp_inner) block(anchor_size, center=FRONT+BELOW+LEFT); 
        translate(disp_outer) block(anchor_size, center=FRONT+BELOW+LEFT); 
    }  
    
}


module air_flow_servo_attachment(
        paint_pivot_inside_dy, paint_pivot_h, paint_pivot_w) {
            
    floor_anchor_size = [1, paint_pivot_w, wall_thickness];
    air_flow_servo_joiner(floor_anchor_size, paint_pivot_inside_dy, paint_pivot_h);
    
    wall_anchor_size = [1, wall_thickness, paint_pivot_h];
    air_flow_servo_joiner(wall_anchor_size, paint_pivot_inside_dy, paint_pivot_h);
}


module air_flow_servo_mount(show_servo, paint_pivot_h) {
    
    translate(air_flow_servo_disp) 
    translate([0, 0, paint_pivot_h/2]) // To make it on the build plate
    rotate([0,180,0])  // To handle building toward negative z
    sub_micro_servo_mounting(
        size=size_air_servo_mount,
        include_children=show_servo,
        center=ABOVE,
        rotation=LEFT) {
            rotate([180,0,0])
            9g_motor_centered_for_mounting();
    }  
}


module trigger_slider(paint_pivot_h) {
    translate([paint_pivot_top_of_yoke - eps, 0, 0]) {
        rod(
            d=paint_pivot_h, 
            l=trigger_slider_length+2*eps, 
            hollow = trigger_bearing_id,
            center=FRONT,
            fa=fa_as_arg); 
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


module trigger_catch(paint_pivot_h) {
    dz_build_plane = paint_pivot_h/2; 
    difference() {
        rotate([-90, 180, 90]) master_air_brush_trigger_catch();
        translate([0, 0, dz_build_plane]) {
            block([100, 100, 50], center=ABOVE);
        } 
        // Make sure that the is no interference with the barrel:
        rotate([0,-45,0]) 
            translate([0, 0, 0.75*barrel_diameter]) 
                rod(d=barrel_diameter, l=20);
    }
}


module trigger_shaft() {
    fa_as_arg = $fa;
    
    translate([-eps, 0, 0]) 
        rod(
            d=trigger_shaft_diameter, 
            l=trigger_shaft_length, 
            center=FRONT,
            fa=fa_as_arg);    
}


module trigger_shaft_gudgeon(paint_pivot_h, paint_pivot_allowance) {
    dx = trigger_shaft_length + paint_pivot_h/2-eps;
    translate([dx, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            trigger_shaft_diameter, 
            trigger_shaft_gudgeon_length, 
            paint_pivot_allowance, 
            range_of_motion=[90, 90],
            fa=fa_as_arg);
}

module paint_pivot_gudgeons(
    paint_pivot_cl_dy, 
    paint_pivot_h,
    paint_pivot_w,
    paint_pivot_allowance, 
    paint_pivot_ranges) {
    
    
    center_reflect([0, 1, 0]) {
        translate([0, paint_pivot_cl_dy, 0]) {
            rotate([0, 0, 180]) { // Flip to desired orientation
               gudgeon(
                    paint_pivot_h, 
                    paint_pivot_w, 
                    paint_pivot_length_gudgeon, 
                    paint_pivot_allowance, 
                    range_of_motion=paint_pivot_ranges,
                    fa=fa_as_arg);
            }
        }    
    }
}


module paint_pivot_gudgeon_bridge(paint_pivot_outside_dy, paint_pivot_h) {
    // Mechanically connects to the gudgeons on each side
    bore_for_trigger_shaft() {
        translate([paint_pivot_length_gudgeon-eps, 0, 0]) {
            block([paint_pivot_bridge_thickness, 
                2* paint_pivot_outside_dy,
                paint_pivot_h
            ],
            center=FRONT); 
        }
    }
}


module paint_pivot_gudgeon_yoke(
        paint_pivot_cl_dy, 
        paint_pivot_outside_dy,
        paint_pivot_h,
        paint_pivot_w,
        paint_pivot_allowance, 
        paint_pivot_ranges) {
            
    paint_pivot_gudgeons(
        paint_pivot_cl_dy, 
        paint_pivot_h,
        paint_pivot_w,
        paint_pivot_allowance, 
        paint_pivot_ranges);

    paint_pivot_gudgeon_bridge(paint_pivot_outside_dy, paint_pivot_h); 
}


module show_gudgeon_assembly(
        orient_for_build,
        paint_pivot_h,
        paint_pivot_w,
        paint_pivot_allowance,
        paint_pivot_ranges,
        paint_pivot_inside_dy) {

    paint_pivot_cl_dy = paint_pivot_inside_dy + paint_pivot_w/2;
    paint_pivot_outside_dy = paint_pivot_inside_dy + paint_pivot_w;
            
    if (show_trigger_shaft_assembly) {
        color(trigger_shaft_color, alpha=trigger_shaft_alpha) {
            translate([trigger_shaft_dx, 0, 0]) {
                trigger_shaft();
                trigger_catch(paint_pivot_h);
                trigger_shaft_gudgeon(paint_pivot_h, paint_pivot_allowance);
            }
        }
    }
    
    if (show_trigger_slider) {
        color(trigger_slider_color, alpha=trigger_slider_alpha) {
            trigger_slider(paint_pivot_h);
        }
    }
        
    if (show_paint_pivot_gudgeon_yoke) {
        color(paint_gudgeon_color, alpha=paint_gudgeon_alpha) {
            paint_pivot_gudgeon_yoke(
                paint_pivot_cl_dy, 
                paint_pivot_outside_dy,
                paint_pivot_h,
                paint_pivot_w,
                paint_pivot_allowance, 
                paint_pivot_ranges);
        }
    }  
   
    if (show_air_flow_servo_mount) {
        show_servo = orient_for_build ? false : show_air_flow_servo;
        color(air_flow_servo_color, alpha=air_flow_servo_alpha) {
            air_flow_servo_mount(
                show_servo, paint_pivot_h);
            air_flow_servo_attachment(
                paint_pivot_inside_dy, paint_pivot_h, paint_pivot_w);
        }
    }
} 



show_gudgeon_assembly(
    orient_for_build=orient_for_build_example,
    paint_pivot_h=paint_pivot_h_example,
    paint_pivot_w=paint_pivot_w_example,
    paint_pivot_ranges=paint_pivot_ranges_example,
    paint_pivot_allowance=paint_pivot_allowance_example,
    paint_pivot_inside_dy=paint_pivot_inside_dy_example);