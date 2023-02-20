

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

/* [Show] */

show_paint_flow_servo_mount = true;
show_paint_flow_servo = false;
show_mount_plate_joiner = true;
show_screw_plate = true;

/* [Paint Flow Servo Design] */

dx_servo = 40; // [10 : 0.5 : 40]
dz_servo = 15; // [10 : 0.5 : 20]
servo_rotation = -18; // [-20 : 1 : 20]
y_servo_mount_connector = 10; // [0 : 1 : 20]
barrel_clip_strap_length = 10;

dy_servo_support = 15;

/* [Master Air Brush Design] */
// Only works if not in build orientation
show_air_brush = true;

air_brush_alpha = 0.10; // [0:0.05:1]

barrel_clearance = 0.3;
wall_thickness = 2;
barrel_clip_inside_diameter = master_air_brush("barrel diameter") + barrel_clearance; 
barrel_clip_outside_diameter = barrel_clip_inside_diameter + 2 * wall_thickness;



paint_flow_servo_color = "MediumTurquoise"; // [DodgerBlue, MediumTurquoise, Coral]
paint_flow_servo_alpha = 1; // [0:0.05:1]

if (show_paint_flow_servo_mount) {
    show_servo = orient_for_build ? false : show_paint_flow_servo;
    color(paint_flow_servo_color, alpha=paint_flow_servo_alpha) {
        paint_flow_servo_mount(show_servo);
    } 
}

if (show_screw_plate) {
    mounting_screw_plate();
}

if (show_mount_plate_joiner) {
    mount_plate_joiner();
}

module mount_plate_joiner() {
    plate_target = [
        1, 
        y_servo_mount_connector, 
        wall_thickness
    ];
    mount_target = [
        1, 
        y_servo_mount_connector, 
        wall_thickness
    ];
    dy_plate_target = barrel_clip_inside_diameter/2;
    
    difference() {
        hull() {
            translate([0, dy_plate_target, 0]) {
                block(plate_target, center=RIGHT+ABOVE+FRONT);
            }
            translate([dx_servo,dy_servo_support, 0]) {
                block(mount_target, center=RIGHT+ABOVE+FRONT);
            }
        }
        mounting_screw_clearance();
        simple_barrel_clearance() ;
    }
}

module build_plane_clearance() {
    block([infinity, infinity, infinity], center=BELOW);
}

module simple_barrel_clearance() {
    translate(-disp_air_brush_relative_paint_pivot_cl) { 
        rod(d=barrel_clip_inside_diameter, l=100);
    }
}

module mounting_screw_clearance() {
    dy = paint_pivot_screw_dy/2;
    center_reflect([0, 1, 0]) 
        translate([0, dy, 25]) hole_through(name="M3");
}

module mounting_screw_plate() {

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

    function translation_with_y_rotation(disp, angle_y) = 
        let (
            dx = 
                disp.x * cos(angle_y)
                - disp.z * sin(angle_y),
            dz = 
                - disp.x * sin(angle_y)
                - disp.z * cos(angle_y),
            last=undef
        )
        [dx, disp.y, dz];
    
    
    dx_servo_support = 24;
    dx_servo_offset = 6.2;
    dy = dy_servo_support;
    dz_servo_support = 12-0.5;
    dz_offset = dz_servo_support/2;
    y_support = 15;
    dx_servo_offset_n = - (dx_servo_support - dx_servo_offset); 
    echo("cos(servo_rotation)", cos(servo_rotation));
    echo("sin(servo_rotation)", sin(servo_rotation)); 
    disp_far = translation_with_y_rotation(
        [dx_servo_offset, dy_servo_support, dz_offset],
        servo_rotation);
    overlap_and_clearance = [0.5, 0, 3];
    
    disp_near = translation_with_y_rotation(
        [dx_servo_offset_n, dy_servo_support, dz_offset],
        servo_rotation);
    
    difference() {
        translate([dx_servo, 0, dz_servo]) { 

            translate(disp_far+overlap_and_clearance) { 
                block([2, y_support, 50], center=BELOW+FRONT+RIGHT); 
            }
            translate(disp_near) { 
                block([4, y_support, 50], center=BELOW+BEHIND+RIGHT); 
            }

            rotate([0, servo_rotation, 0]) {
                sub_micro_servo__mounting(  
                    mount=RIGHT, 
                    locate_relative_to="SERVO",
                    clearance = [1, 0.5, 0],
                    show_servo=show_servo, 
                    flip_servo=true,
                    omit_top=true,
                    omit_base=true);
            }
      
        }
        build_plane_clearance();
    }
    connector();
    
    module connector() {
        x = disp_far.x - disp_near.x + 2*wall_thickness; 
        size = [x, y_servo_mount_connector, wall_thickness];
        dx = dx_servo + disp_far.x + wall_thickness;
        translate([dx, dy_servo_support, 0]) {
            block(size, center=RIGHT+ABOVE+BEHIND);
        }
    }
     
}