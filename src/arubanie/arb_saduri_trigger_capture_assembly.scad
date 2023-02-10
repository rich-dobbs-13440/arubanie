/* 

All the parts in the assembly that captures the trigger for control of the 
air air and paint flow.

The coordinate system is based center of rotation of the paint pivot.

*/
include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <lib/small_3d_printable_scotch_yoke.scad>
use <trigger_holder.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;

$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [ Example for demonstration] */
orient_for_build_example = true;


/* [ Paint Gudgeon Design] */
show_paint_pivot_gudgeon_yoke = true;

// Set to clear the trigger, at depressed with clearance for trigger cap.
// But also need to allow air barrel clip to clear!
paint_pivot_inner_height = 22;
wall_thickness = 2;
paint_pivot_bridge_thickness = 4;

paint_pivot_top_of_yoke =  
    paint_pivot_inner_height 
    + paint_pivot_bridge_thickness;

paint_gudgeon_color = "LightSkyBlue"; // [DodgerBlue, LightSkyBlue, Coral]
paint_gudgeon_alpha = 1; // [0:0.05:1]



/* [Paint Pull Rod Design] */
show_paint_pull_rod = true;
paint_pull_rod_length = 54; // [40:70]

paint_pull_rod_color = "Orange"; // [DodgerBlue, Orange, Coral]
paint_pull_rod_alpha = 1; // [0:0.05:1]
//paint_pull_rod_angle = 34; // [0: 5 : 40]

/* [Air Flow Actuator Design] */
show_scotch_yoke = true;
show_scotch_yoke_mount = true;
show_air_flow_servo = false;

air_flow_servo_angle = 0; // [-180 : 10 : 180]

dx_scotch_yoke = 55; // Must clear paint pot


air_flow_servo_color = "PaleTurquoise"; // [DodgerBlue, PaleTurquoise, Coral]
air_flow_servo_alpha = 1; // [0:0.05:1]


/* [Trigger Shaft Design] */

trigger_shaft_min_x = 10;
trigger_shaft_catch_clearance = 1;
trigger_shaft_diameter = 5;

trigger_shaft_range = 
    paint_pivot_inner_height 
    - trigger_shaft_catch_clearance
    - trigger_shaft_min_x ;
    


module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation_example = orient_for_build_example ? FOR_BUILD : FOR_DESIGN;

barrel_diameter = master_air_brush("barrel diameter");



//module supported_servo_mounting(show_servo) {
//  
//    sub_micro_servo_mounting(
//        size=size_air_servo_mount,
//        include_children=show_servo,
//        center=ABOVE,
//        rotation=LEFT) {
//            rotate([180,0,0])
//            9g_motor_centered_for_mounting();
//    } 
   

module air_flow_scotch_yoke(show_servo, angle) {
    
//    translate(air_flow_servo_disp) {
//        translate([0, 0, paint_pivot_h/2]) { // To make it on the build plate
//            rotate([0,180,0]) { // To handle building toward negative z
//                supported_servo_mounting(show_servo);
//            }
//        }
//    }
    
    radial_allowance = 0.4;
    axial_allowance = 0.4;
    support_axle = ["servo horn", true];
    bearing_width = 4;
    
    dimensions = 
        scotch_yoke(
            trigger_shaft_diameter, 
            trigger_shaft_range, 
            radial_allowance, 
            axial_allowance, 
            wall_thickness, 
            bearing_width,
            angle,
            support_axle);

    log_v1("dimensions", dimensions, verbosity, INFO);

    
    dz = paint_pivot_h/2;
    translate([dx_scotch_yoke, 0, dz]) {
        mirror([0, 1, 0]) { // Want servo on +y, +x quadrant
            rotate([0, 180, 0]) {  // Cope with building downward
                rotate([0, 0, 90]) { // Align push rod with trigger
                    scotch_yoke(
                        trigger_shaft_diameter, 
                        trigger_shaft_range, 
                        radial_allowance, 
                        axial_allowance, 
                        wall_thickness,
                        bearing_width, 
                        angle,
                        support_axle);
                    
                    scotch_yoke_mounting(
                        dimensions,
                        extend_left=16.5,
                        extend_right=false,
                        extra_push_rod=3,
                        screw_mounting="M3");
                }
            }
        }
    }
}


module trigger_slider() {
    x = trigger_slider_length;
    y = trigger_bearing_od;
    z = paint_pivot_h/2;
    y_slot = wall_thickness + 2 * trigger_slider_clearance;
    render() translate([paint_pivot_top_of_yoke - eps, 0, 0]) {
        difference() {
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
}


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


module paint_pivot_gudgeons() {

    translate([0, paint_pivot_cl_dy, 0]) {
        paint_pivot_gudgeon(0.75*paint_pivot_inner_height);
    }
    translate([0, -paint_pivot_cl_dy, 0]) {
        paint_pivot_gudgeon(paint_pivot_top_of_yoke);
    }
}


module paint_pivot_gudgeon_bridge() {
    // Mechanically connects to the gudgeons on each side

        translate([paint_pivot_inner_height-eps, 0, 0]) {
            block(
                [paint_pivot_bridge_thickness, 
                2* paint_pivot_inside_dy+eps,
                paint_pivot_h
            ],
            center=FRONT); 
        }

    // Add fillets to strengthen corners
    center_reflect([0,1,0]) {
    translate([
        paint_pivot_inner_height,
        paint_pivot_inside_dy, 
        0]) {
        
            block([
                    paint_pivot_bridge_thickness,
                    wall_thickness,
                    paint_pivot_h
                ], center=LEFT+BEHIND);
        }
    }
}

module paint_pull_gudgeon() {
    dx = paint_pivot_top_of_yoke + paint_pivot_h;
    dy = paint_pivot_cl_dy;
    gudgeon_length = 20; //400; //paint_pivot_h + 0.4*trigger_rod_length + eps;

    translate([dx, dy, 0]) {
        # gudgeon(
            paint_pivot_h, 
            paint_pivot_w, 
            gudgeon_length, 
            paint_pivot_allowance, 
            range_of_motion=[145, 90],
            pin= "M3 captured nut",
            fa=fa_as_arg);
    }

}


module paint_pull_rod() {
    paint_pull_pivot_allowance = paint_pivot_allowance;
    pintle(
        paint_pivot_h, 
        paint_pivot_w, 
        paint_pull_rod_length/2 + eps, 
        paint_pull_pivot_allowance,
        range_of_motion=[145, 90], 
        pin= "M3 captured nut",
        fa=fa_as_arg);
    translate([paint_pull_rod_length, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            paint_pivot_w, 
            paint_pull_rod_length/2 + eps, 
            paint_pull_pivot_allowance, 
            range_of_motion=[135, 135],
            pin= "M3 captured nut", 
            fa=fa_as_arg);
        
}


module connected_paint_pull_rod(angle=0) {
    dx = paint_pivot_top_of_yoke + paint_pivot_h;
    dy = paint_pivot_cl_dy;
    translate([dx, dy, 0]) {
        rotate([0, angle, 0]) { 
            paint_pull_rod();
        }
    }
}


module paint_pivot_gudgeon_yoke() {         
    paint_pivot_gudgeons();
    paint_pivot_gudgeon_bridge(); 
    paint_pull_gudgeon();

}


module show_gudgeon_assembly_design_orientation(orient_for_build) {

    if (show_paint_pull_rod) {
        color(paint_pull_rod_color, alpha=paint_pull_rod_alpha) {
            //angle = orient_for_build ? 0: paint_pull_rod_angle;
            connected_paint_pull_rod(); //angle);
        }
    }
      
    if (show_paint_pivot_gudgeon_yoke) {
        color(paint_gudgeon_color, alpha=paint_gudgeon_alpha) {
            paint_pivot_gudgeon_yoke();
        }
    }  

    if (show_scotch_yoke) {
        show_servo = orient_for_build ? false : show_air_flow_servo;
        color(air_flow_servo_color, alpha=air_flow_servo_alpha) {
           air_flow_scotch_yoke(show_servo, air_flow_servo_angle);
        }
    }
}

module show_gudgeon_assembly(orient_for_build, viewing_orientation) {
    rotate(viewing_orientation) {
        show_gudgeon_assembly_design_orientation(orient_for_build);
    }
} 


show_gudgeon_assembly(
    orient_for_build=orient_for_build_example,
    viewing_orientation=viewing_orientation_example);

