/* 

All the parts in the assembly that captures the air brush to
provide a base for rotation of the trigger capture assembly

The coordinate system is based center of rotation of the paint pivot.

*/

include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <trigger_holder.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;

$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [ Build or Design] */

orient_for_build_example = true;


/* [Master Air Brush Design] */
// Only works if not in build orientation
show_air_brush = true;

air_brush_alpha = 0.10; // [0:0.05:1]

//barrel_allowance = 0.2;
barrel_clearance = 0.3;

wall_thickness = 2;

barrel_clip_inside_diameter = master_air_brush("barrel diameter") + barrel_clearance;
    
barrel_clip_outside_diameter = barrel_clip_inside_diameter + 2 * wall_thickness;


/* [Air Barrel Clip Design] */
show_air_barrel_clip = true;

//air_barrel_allowance = 0.3;
air_barrel_clearance = 0.7;

air_barrel_clip_color = "PaleGreen"; // [DodgerBlue, PaleGreen, Coral]
air_barrel_clip_alpha = 1; // [0:0.05:1]


air_barrel_clip_inside_diameter =  master_air_brush("air barrel diameter") + air_barrel_clearance; 

air_barrel_clip_outside_diameter = 
    air_barrel_clip_inside_diameter + 2 * wall_thickness; 

brace_inside_diameter = master_air_brush("brace width") + air_barrel_clearance;
    
brace_length = master_air_brush("brace length") + air_barrel_clearance;
    
brace_height = 
    master_air_brush("brace height")
    + master_air_brush("barrel diameter")/2
    - master_air_brush("brace width") /2;

air_barrel_cl_to_back_length = 
    master_air_brush("back length") + master_air_brush("air barrel radius");



/* [ Paint Pintle Design] */
show_paint_pivot_pintle_yoke = true;
paint_pivot_length_pintle = 12;
bridge_thickness = 4;

paint_pintle_color = "MediumSeaGreen"; // [DodgerBlue, MediumSeaGreen, Coral]
paint_pintle_alpha = 1; // [0:0.05:1]



/* [ Example for demonstration] */

trigger_angle_example = 0;;

module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation_example = orient_for_build_example ? FOR_BUILD : FOR_DESIGN;


module air_barrel_clip(include_fillet=false) {
    id = air_barrel_clip_inside_diameter;
    od = air_barrel_clip_outside_diameter;
    h = master_air_brush("bottom length"); 
    fa_as_arg = $fa;
    {
        render() difference() {
            translate(disp_air_brush_relative_paint_pivot_cl) { 
                can(d=od, h=h, hollow=id, center=BELOW, fa=fa_as_arg);
                if (include_fillet) {
                    block([od/2+eps,od/2+eps,h], center=BELOW+LEFT+BEHIND);  // fillet with servo support
                }
            }
            translate(disp_air_brush_relative_paint_pivot_cl) { 
                air_brush_simple_clearance(air_barrel_clearance, barrel_clearance);
            }
            paint_pivot_pin_clearance();
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


module paint_pivot_pintle_bridge(use_crank=false) {
    x = wall_thickness;
    // Make the pintle bridge go inside, so as to not interfere with 
    // rotation stops:
    y = 2 * paint_pivot_inside_dy;
    z = paint_pivot_h;
    dx = -paint_pivot_length_pintle; //-air_barrel_clip_outside_diameter/2;
    dz = paint_pivot_h/2;
    
    module mounting_screw_plate() {
        x = 10;
        y = paint_pivot_screw_dy + 10;
        z = 2*wall_thickness;
        translate([dx, 0, dz]) block([x, y, z], center=BELOW+BEHIND);
    } 
    
    render() difference() {
        union() {
            translate([dx, 0, dz]) block([x, y, z], center=FRONT+BELOW);
            translate([0, 0, dz])
                if (use_crank){
                    x_crank = paint_pivot_length_pintle;
                    y_crank = 2 * paint_pivot_inside_dy;
                    z_crank = paint_pivot_h;
                    crank([x_crank, y_crank, z_crank], center=BELOW, rotation=BEHIND);
                } else {
                    rod(d=paint_pivot_h, l=2 * paint_pivot_inside_dy, center=BELOW+SIDEWISE);
                }
            pintle_barrel_clip();
            mounting_screw_plate(); 
        }
        translate(disp_air_brush_relative_paint_pivot_cl) { 
            air_brush_simple_clearance(air_barrel_clearance, barrel_clearance);
        }
        paint_pivot_pin_clearance();
        paint_pivot_pintle_bridge_mounting_nut_clearance();
    }
    //paint_pivot_pintle_bridge_mounting_nut_clearance();
}




module paint_pivot_pintle_bridge_mounting_nut_clearance() {
    dx = -(paint_pivot_length_pintle + 5);
    dy = paint_pivot_screw_dy/2;
    dz = paint_pivot_h/2 - wall_thickness;
    center_reflect([0, 1, 0]) {
        translate([dx, dy, dz]) nutcatch_parallel("M3", clh=25, clk=0.2);
        translate([dx, dy, 25]) hole_through(name = "M3");
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




module air_brush_trigger_on_top(disp_air_brush_relative_paint_pivot_cl, trigger_angle) {
    translate(disp_air_brush_relative_paint_pivot_cl) {
        rotate([90, 0, 0]) air_brush(trigger_angle, alpha=air_brush_alpha);
    }
}

//translate(disp_air_brush_relative_paint_pivot_cl) {


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
