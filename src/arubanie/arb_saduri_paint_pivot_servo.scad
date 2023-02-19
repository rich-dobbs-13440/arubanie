

include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

fa_shape = 10;
fa_bearing = 1;
infinity = 300;


/* [ Build or Design] */

orient_for_build = true;


/* [Paint Flow Servo Design] */
show_paint_flow_servo_mount = true;
show_paint_flow_servo = false;

size_paint_servo_mount = [10, 32, 36];

/* [Master Air Brush Design] */
// Only works if not in build orientation
show_air_brush = true;

air_brush_alpha = 0.10; // [0:0.05:1]

barrel_clearance = 0.3;
wall_thickness = 2;
barrel_clip_inside_diameter = master_air_brush("barrel diameter") + barrel_clearance; 
barrel_clip_outside_diameter = barrel_clip_inside_diameter + 2 * wall_thickness;
barrel_clip_strap_length = 4;


paint_flow_servo_color = "MediumTurquoise"; // [DodgerBlue, MediumTurquoise, Coral]
paint_flow_servo_alpha = 1; // [0:0.05:1]

if (show_paint_flow_servo_mount) {
    show_servo = orient_for_build ? false : show_paint_flow_servo;
    color(paint_flow_servo_color, alpha=paint_flow_servo_alpha) {
        paint_flow_servo_mount(show_servo);
    } 
}

mounting_screw_plate();

module build_plane_clearance() {
    block([infinity, infinity, infinity], center=BELOW);
}

module simple_barrel_clearance() {
    translate(-disp_air_brush_relative_paint_pivot_cl) { 
        rod(d=barrel_clip_inside_diameter, l=100);
    }
}



module mounting_screw_plate() {
    module mounting_screw_clearance() {
        dy = paint_pivot_screw_dy/2;
        center_reflect([0, 1, 0]) 
            translate([0, dy, 25]) hole_through(name = "M3");
    }
    x = 10;
    y = paint_pivot_screw_dy + 10;
    z = wall_thickness;
    difference() {
        union() {
            block([x, y, z], center=ABOVE);
            translate(-disp_air_brush_relative_paint_pivot_cl) {
                rod(d=barrel_clip_outside_diameter, l=barrel_clip_strap_length);
            }
                
        }
        mounting_screw_clearance();
        simple_barrel_clearance() ;
        build_plane_clearance();
    }
}  



module paint_flow_servo_mount(show_servo) {
    dx = 0;
        //- air_barrel_clip_outside_diameter/2
        //- size_paint_servo_mount.y/2 ; 
    //dz = paint_pivot_h/2; 
    difference() {
        translate([dx, 0, 0]) { 

                sub_micro_servo_mounting(
                    //size=size_paint_servo_mount,
                    center=ABOVE+BEHIND,
                    rotation=LEFT,
                    include_children=show_servo) {
                        
                    9g_motor_centered_for_mounting();
                }
                
                
        }
        simple_barrel_clearance();
    }  
}