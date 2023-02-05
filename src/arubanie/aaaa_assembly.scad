include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <lib/small_servo_cam.scad>
use <lib/not_included_batteries.scad>
use <master_air_brush.scad>
use <arb_saduri_trigger_capture_assembly.scad>
use <arb_saduri_air_brush_capture_assembly.scad>


/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;
$fs = 0.8;
eps = 0.001;
infinity = 1000;



/* [Paint Pivot Design] */


paint_pivot_h = 8; 
paint_pivot_w = 6; 
paint_pivot_inside_dy = 10; // 16.5/2;
paint_pivot_bridge_thickness = 4;
// This controls printablity vs play in the pivot.
paint_pivot_allowance = 0.4;
paint_pivot_top_range_of_motion = 120;
paint_pivot_bottom_range_of_motion = 90;

paint_pivot_ranges = [
    paint_pivot_top_range_of_motion, 
    paint_pivot_bottom_range_of_motion
];

paint_pivot_cl_dy = paint_pivot_inside_dy + paint_pivot_w/2;
paint_pivot_outside_dy = paint_pivot_inside_dy + paint_pivot_w;


/* [Build vs Design] */
orient_for_build = true;
permanent_pin=true; 

// Only enabled not oriented for build!
gudgeon_angle_position = 0; // [-1: 0.05 : 0.4]
gudgeon_angle = -120 + 30*(gudgeon_angle_position+1);
trigger_angle = 270 - gudgeon_angle; //135-gudgeon_angle ;

module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation = orient_for_build ? FOR_BUILD : FOR_DESIGN;





rotate(viewing_orientation) {

    angle = orient_for_build ? 0 : gudgeon_angle;
    rotate([0, angle, 0]) {
        show_gudgeon_assembly(
            orient_for_build,
            paint_pivot_h,
            paint_pivot_w,
            paint_pivot_allowance,
            paint_pivot_ranges,
            paint_pivot_inside_dy);
    }

    show_pintle_assembly(
        orient_for_build,
        paint_pivot_h,
        paint_pivot_w,
        paint_pivot_allowance,
        paint_pivot_ranges,
        paint_pivot_inside_dy,
        permanent_pin, 
        trigger_angle);

}


// Note construction and displacements need to be worked upon 
// with labeling etc. prior to be re-enabled.

//    if (show_constructions && show_construction_displacements) {
//            display_construction_displacements();
//    }


//    if (show_constructions && show_construction_planes) {
//            display_construction_planes();
//    }


///* [Constructions] */
//show_constructions = false;
//// Note: show_constructions must be enabled!
//show_construction_displacements = false;
//// Note: show_constructions must be enabled!
//show_construction_planes = false;
//

    
// Calculate Displacement vectors in attempt to make code cleaner.  
// Note: not sure that this is working out.
    
//D_MIRROR_SIDES = [0, dy_trigger_pivot_cl, 0];

//D_CL_TRG_PVT_ADJUSTMENT = [
//            dx_trigger_pivot_offset, 
//            0, 
//            dz_trigger_pivot_offset];
//D_CL_TRG_BLD_PLT = D_CL_TRG_PVT_ADJUSTMENT + [0, 0, pivot_h/2];
// 
//D_AIR_BARREL_TOP = [0, 0, -master_air_brush("bottom length")];
//D_AIR_BARREL_BACK = [-master_air_brush("air barrel radius"), 0, 0];
//D_AIR_BARREL_RIGHT = [0, master_air_brush("air barrel radius"), 0];
//D_BARREL_BACK = [-master_air_brush("back length"), 0, 0];
//D_BARREL_RIGHT = [0, master_air_brush("barrel radius"), 0];
//
//D_TRIGGER_TOP = [0, 0, master_air_brush("trigger height")];
//
//D_GUDGEON_BRIDGE_FRONT = [pivot_length_gudgeon, 0, 0];
//
//
//D_SERVO = [servo_dx, servo_dy , servo_dz];

//IDX_DISP_LABEL = 0;
//IDX_DISP_VAL = 1;
//IDX_DISP_CLR = 2;

//displacements = [
//    ["D_CL_TRG_PVT_ADJUSTMENT", D_CL_TRG_PVT_ADJUSTMENT, "Red"],
//    ["D_CL_TRG_BLD_PLT", D_AIR_BARREL_TOP, "Orange"], 
//    ["D_AIR_BARREL_TOP", D_AIR_BARREL_TOP, "Yellow"], 
//    ["D_AIR_BARREL_BACK", D_AIR_BARREL_BACK, "Green"],
//    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Blue"],
//    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Indigo"],
//    ["D_TRIGGER_TOP", D_TRIGGER_TOP, "Violet"],
////    ["D_GUDGEON_FRONT_BLD_PLT", D_GUDGEON_FRONT_BLD_PLT, "Aqua"],
//];



//
//module display_construction_displacements() {
//    for (d = displacements) {
//        display_displacement(
//            d[IDX_DISP_VAL], 
//            barb_color=d[IDX_DISP_CLR],
//            shaft_color=d[IDX_DISP_CLR],
//            label=d[IDX_DISP_LABEL]);
//    }
//}
//
//module display_construction_planes() {
//    construct_plane(D_BARREL_BACK, [1, 0, 0], 40);
//    construct_plane(D_BARREL_RIGHT, [0, 1, 0], 100);
//    construct_plane(D_AIR_BARREL_BACK, [1, 0, 0], 40);  
//    construct_plane(D_AIR_BARREL_TOP, [0, 0, 1], 100);
//    construct_plane(D_AIR_BARREL_RIGHT, [0, 1, 0], 100); 
//    construct_plane(D_CL_TRG_PVT, [0, 0, 1], 100); 
//    construct_plane(D_CL_TRG_PVT, [1, 0, 0], 40); 
//    construct_plane(D_CL_TRG_BLD_PLT, [0, 0, 1], 100);
//}

