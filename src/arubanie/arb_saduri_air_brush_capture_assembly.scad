/* 

All the parts in the assembly that captures the air brush to
provide a base for rotation of the trigger capture assembly

The coordinate system is based center of rotation of the paint pivot.

*/

include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
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
trigger_angle_example = 90;



/* [Master Air Brush Design] */
show_air_brush = true;

air_brush_alpha = 0.10; // [0:0.05:1]

barrel_allowance = 0.2;
barrel_clearance = 0.1;

wall_thickness = 2;

barrel_clip_inside_diameter = 
    master_air_brush("barrel diameter")
    + barrel_allowance 
    + barrel_clearance;
    
barrel_clip_outside_diameter = barrel_clip_inside_diameter + 2 * wall_thickness;


/* [Air Barrel Clip Design] */
show_air_barrel_clip = true;

air_barrel_allowance = 0.3;
air_barrel_clearance = 0.4;

air_barrel_clip_color = "PaleGreen"; // [DodgerBlue, PaleGreen, Coral]
air_barrel_clip_alpha = 1; // [0:0.05:1]


air_barrel_clip_inside_diameter = 
    master_air_brush("air barrel diameter")
    + air_barrel_allowance 
    + air_barrel_clearance; 

air_barrel_clip_outside_diameter = 
    air_barrel_clip_inside_diameter + 2 * wall_thickness; 

brace_inside_diameter = master_air_brush("brace width") +
    + air_barrel_allowance 
    + air_barrel_clearance;
    
brace_length = master_air_brush("brace length")
    + air_barrel_allowance 
    + air_barrel_clearance;
    
brace_height = master_air_brush("brace height")
    + master_air_brush("barrel diameter")/2
    - master_air_brush("brace width") /2;

air_barrel_cl_to_back_length = 
    master_air_brush("back length") + master_air_brush("air barrel radius");



/* [ Paint Pintle Design] */
show_paint_pivot_pintle_yoke = true;
paint_pivot_length_pintle = 14;
bridge_thickness = 4;

paint_pintle_color = "MediumSeaGreen"; // [DodgerBlue, MediumSeaGreen, Coral]
paint_pintle_alpha = 1; // [0:0.05:1]



/* [Paint Flow Servo Design] */
show_paint_flow_servo_mount = true;
show_paint_flow_servo = false;

size_paint_servo_mount = [10, 36, 36];

paint_flow_servo_color = "MediumTurquoise"; // [DodgerBlue, MediumTurquoise, Coral]
paint_flow_servo_alpha = 1; // [0:0.05:1]



module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation_example = orient_for_build_example ? FOR_BUILD : FOR_DESIGN;

module air_barrel_clip() {
    id = air_barrel_clip_inside_diameter;
    // For now, oversize clip to strength connection to servo mount,
    // rather than modeling a fillet for this section.
    od = air_barrel_clip_outside_diameter + 1;
    h = master_air_brush("bottom length"); 
    fa_as_arg = $fa;
    translate(disp_air_brush_relative_paint_pivot_cl) {
        render() difference() {
            can(d=od, h=h, hollow=id, center=BELOW, fa=fa_as_arg);
            air_brush_simple_clearance(disp_air_brush_relative_paint_pivot_cl);
        }
    }
}


module pintle_barrel_clip() { 
    id = barrel_clip_inside_diameter;
    od = barrel_clip_outside_diameter;
    l = air_barrel_cl_to_back_length;
    render() difference() {
        translate(disp_air_brush_relative_paint_pivot_cl) {
            rod(d=od, hollow=id, l=l, center=BEHIND, fa=fa_as_arg);
        }
        translate([0, 0, paint_pivot_h/2]) block([4*l, 2*od, 2*od], center=ABOVE);
    }
}


module paint_pivot_pintle_bridge() {
    x = bridge_thickness;
    // Make the pintle bridge go inside, so as to not interfere with 
    // rotation stops:
    y = 2 * paint_pivot_inside_dy + eps;
    z = barrel_clip_inside_diameter/2 - dz_paint_pivot_offset + wall_thickness;
    dx = -air_barrel_clip_outside_diameter/2;
    dz = paint_pivot_h/2;
    
    x_crank = paint_pivot_h + bridge_thickness;
    y_crank = 2 * paint_pivot_inside_dy + eps;
    z_crank = paint_pivot_h;
    

    render() difference() {
        union() {
            translate([dx, 0, dz]) block([x, y, z], center=BEHIND+BELOW);
            translate([0, 0, dz]) 
                crank([x_crank, y_crank, z_crank], center=BELOW, rotation=BEHIND);
            pintle_barrel_clip(); 
            
        }
        air_brush_simple_clearance(disp_air_brush_relative_paint_pivot_cl);
    }

}


module paint_pivot_pintles() {    
    center_reflect([0, 1, 0]) {
        translate([0, paint_pivot_cl_dy, 0]) {
            paint_pivot_pintle(paint_pivot_length_pintle);
        }    
    }
}


module paint_pivot_pintle_yoke() {    
    paint_pivot_pintles();
    paint_pivot_pintle_bridge(); 
}


module paint_flow_servo_mount(show_servo) {
    dx = 
        - size_paint_servo_mount.y/2 
        - air_barrel_clip_outside_diameter/2; 
    dz = paint_pivot_h/2; 
    difference() {
        translate([dx, 0, dz]) { 
            rotate([0,180,0]) { // To handle building toward negative z

                sub_micro_servo_mounting(
                    size=size_paint_servo_mount,
                    center=ABOVE,
                    rotation=LEFT,
                    include_children=show_servo
                    ) {
                        9g_motor_centered_for_mounting();
                }
            }
        }
        air_brush_simple_clearance(disp_air_brush_relative_paint_pivot_cl);
    }  
}

module air_brush_trigger_on_top(disp_air_brush_relative_paint_pivot_cl, trigger_angle) {
    translate(disp_air_brush_relative_paint_pivot_cl) {
        rotate([90, 0, 0]) air_brush(trigger_angle, alpha=air_brush_alpha);
    }
}

module air_brush_simple_clearance(disp_air_brush_relative_paint_pivot_cl) {

    translate(disp_air_brush_relative_paint_pivot_cl) {
    
        can(d=air_barrel_clip_inside_diameter, h=80, fa=fa_as_arg);
        rod(d=barrel_clip_inside_diameter, l=120, fa=fa_as_arg);
        // The nut at the end of the barrel:
        d_nut = 11.95+2;
        l_nut_exc = 4;
        dx_nut = 
            master_air_brush("back length") 
            + master_air_brush("barrel radius");
        translate([-dx_nut, 0, 0]) rod(d=d_nut, l=l_nut_exc, fa=fa_as_arg, center=FRONT);
        // A very rough approximation to the brace
        translate([0, 0, -brace_height]) 
            rod(
                d=brace_inside_diameter, 
                l=brace_length, 
                center=FRONT, 
                fa=fa_as_arg);
        block(
            [brace_length, brace_inside_diameter, brace_height], 
            center=BELOW+FRONT);
    }
}


module show_pintle_assembly(
        orient_for_build,
        viewing_orientation,
        trigger_angle) {

             

    rotate(viewing_orientation) {
            
        if (show_air_barrel_clip) {
            color(air_barrel_clip_color , alpha=air_barrel_clip_alpha) {
                air_barrel_clip();
            }
        }

        if (show_paint_pivot_pintle_yoke) {
            color(paint_pintle_color, alpha=paint_pintle_alpha) {
                paint_pivot_pintle_yoke();
            }
        }    

        if (show_paint_flow_servo_mount) {
            show_servo = orient_for_build ? false : show_paint_flow_servo;
            color(paint_flow_servo_color, alpha=paint_flow_servo_alpha) {
                paint_flow_servo_mount(show_servo);
            } 
        }

        if (show_air_brush && !orient_for_build) {
        air_brush_trigger_on_top(
                disp_air_brush_relative_paint_pivot_cl, 
                trigger_angle); 
        }
    }
}


show_pintle_assembly(
    orient_for_build=orient_for_build_example,
    viewing_orientation=viewing_orientation_example, 
    trigger_angle=trigger_angle_example);

