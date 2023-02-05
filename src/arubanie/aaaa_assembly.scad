include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>


use <lib/small_servo_cam.scad>
use <lib/not_included_batteries.scad>
use <master_air_brush.scad>
use <trigger_holder.scad>



/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;
$fs = 0.8;
eps = 0.001;

infinity = 1000;




/* [Air Barrel Clip Design] */
show_air_barrel_clip = true;

air_barrel_allowance = 0.3;
air_barrel_clearance = 0.4;
wall_thickness = 2;

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


/* [Master Air Brush Design] */
show_air_brush = false;

air_brush_alpha = 0.10; // [0:0.05:1]

barrel_allowance = 0.2;
barrel_clearance = 0.1;

barrel_clip_inside_diameter = 
    master_air_brush("barrel diameter")
    + barrel_allowance 
    + barrel_clearance;
    
barrel_clip_outside_diameter = 
    barrel_clip_inside_diameter + 2 * wall_thickness;




/* [Paint Pivot Design] */

// Relative to CL of air barrel
dx_paint_pivot_offset = 0; // [-3:0.25:+3]
// Relative to CL of main barrel
dz_paint_pivot_offset = -3; // [-5:0.05:0]



paint_pivot_h = 8; 
paint_pivot_w = 6; 
paint_pivot_bridge_thickness = 4;
paint_pivot_inside_dy = 10; // 16.5/2;
// This controls printablity vs play in the pivot.
paint_pivot_allowance = 0.4;
paint_pivot_top_range_of_motion = 145;
paint_pivot_bottom_range_of_motion = 90;

paint_pivot_ranges = [
    paint_pivot_top_range_of_motion, 
    paint_pivot_bottom_range_of_motion
];

paint_pivot_cl_dy = paint_pivot_inside_dy + paint_pivot_w/2;
paint_pivot_outside_dy = paint_pivot_inside_dy + paint_pivot_w;

disp_air_brush_relative_paint_pivot_cl = 
    [dx_paint_pivot_offset, 0, paint_pivot_h/2 + dz_paint_pivot_offset];




/* [ Paint Pintle Design] */
show_paint_pivot_pintle_yoke = true;
paint_pivot_length_pintle = 14;

paint_pintle_color = "MediumSeaGreen"; // [DodgerBlue, MediumSeaGreen, Coral]
paint_pintle_alpha = 1; // [0:0.05:1]




/* [ Paint Gudgeon Design] */
show_paint_pivot_gudgeon_yoke = true;

// Set to clear the trigger, at depressed with clearance for trigger cap.
paint_pivot_length_gudgeon = 18;

gudgeon_angle = 0; // [-145:5: 0]
trigger_angle = 270 - gudgeon_angle; //135-gudgeon_angle ;

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




/* [Paint Flow Servo Design] */
show_paint_flow_servo_mount = true;
show_paint_flow_servo = false;

size_paint_servo_mount = [10, 36, 36];

paint_flow_servo_color = "MediumTurquoise"; // [DodgerBlue, MediumTurquoise, Coral]
paint_flow_servo_alpha = 1; // [0:0.05:1]




/* [Build vs Design] */
orient_for_build = true;
permanent_pin=true; 



module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation = orient_for_build ? FOR_BUILD : FOR_DESIGN;


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
            air_brush_simple_clearance();
        }
    }

}


module air_flow_servo_joiner(anchor_size) {
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


module air_flow_servo_attachment() {
    floor_anchor_size = [5, paint_pivot_w, wall_thickness];
    air_flow_servo_joiner(floor_anchor_size);
    
    wall_anchor_size = [1, wall_thickness, paint_pivot_h];
    air_flow_servo_joiner(wall_anchor_size);
}


module air_flow_servo_mount(show_servo) {
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


module trigger_slider() {
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


module trigger_catch() {
    dz_build_plane = paint_pivot_h/2; 
    difference() {
        rotate([-90, 180, 90]) master_air_brush_trigger_catch();
        translate([0, 0, dz_build_plane]) {
            block([100, 100, 50], center=ABOVE);
        } 
        // Make sure that the is no interference with the barrel:
        rotate([0,-45,0]) 
            translate([0, 0, 0.75*barrel_clip_inside_diameter]) 
                rod(d=barrel_clip_inside_diameter, l=20);
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


module trigger_shaft_gudgeon() {
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


module paint_pivot_gudgeons() {
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


module paint_pivot_gudgeon_bridge() {
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


module paint_pivot_gudgeon_yoke() {
    paint_pivot_gudgeons();
    paint_pivot_gudgeon_bridge(); 
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
    
    x = paint_pivot_bridge_thickness;
    // Make the pintle bridge go inside, so as to not interfere with 
    // rotation stops:
    y = 2 * paint_pivot_inside_dy + eps;
    z = barrel_clip_inside_diameter/2 - dz_paint_pivot_offset + wall_thickness;
    dx = -air_barrel_clip_outside_diameter/2;
    dz = paint_pivot_h/2;
    
    x_crank = paint_pivot_h + paint_pivot_bridge_thickness;
    y_crank = 2 * paint_pivot_inside_dy + eps;
    z_crank = paint_pivot_h;
    

    render() difference() {
        union() {
            translate([dx, 0, dz]) block([x, y, z], center=BEHIND+BELOW);
            translate([0, 0, dz]) 
                crank([x_crank, y_crank, z_crank], center=BELOW, rotation=BEHIND);
            pintle_barrel_clip(); 
            
        }
        air_brush_simple_clearance();
    }

}


module paint_pivot_pintles() {
    center_reflect([0, 1, 0]) {
        translate([0, paint_pivot_cl_dy, 0]) {
            rotate([0, 0, 180]) { // Flip to desired orientation
               pintle(
                    paint_pivot_h, 
                    paint_pivot_w, 
                    paint_pivot_length_pintle, 
                    paint_pivot_allowance, 
                    range_of_motion=paint_pivot_ranges,
                    permanent_pin=permanent_pin,
                    fa=fa_as_arg);
            }
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
                        //rotate([180,0,0])
                        9g_motor_centered_for_mounting();
                }
            }
        }
        air_brush_simple_clearance();
    }  
}



module air_brush_trigger_on_top() {
    translate(disp_air_brush_relative_paint_pivot_cl) {
        rotate([90, 0, 0]) air_brush(trigger_angle, alpha=air_brush_alpha);
    }
}



module air_brush_simple_clearance() {

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


module show_gudgeon_assembly(gudgeon_angle) {
    rotate([0, gudgeon_angle, 0]) {

        if (show_trigger_shaft_assembly) {
            color(trigger_shaft_color, alpha=trigger_shaft_alpha) {
                translate([trigger_shaft_dx, 0, 0]) {
                    trigger_shaft();
                    trigger_catch();
                    trigger_shaft_gudgeon();
                }
            }
        }
        
        if (show_trigger_slider) {
            color(trigger_slider_color, alpha=trigger_slider_alpha) {
                trigger_slider();
            }
        }
            
        if (show_paint_pivot_gudgeon_yoke) {
            color(paint_gudgeon_color, alpha=paint_gudgeon_alpha) {
            paint_pivot_gudgeon_yoke();
            }
        }  
       
        if (show_air_flow_servo_mount) {
            show_servo = orient_for_build ? false : show_air_flow_servo;
            color(air_flow_servo_color, alpha=air_flow_servo_alpha) {
                air_flow_servo_mount(show_servo);
                air_flow_servo_attachment();
            }
        }
    }
}



rotate(viewing_orientation) {

    angle = orient_for_build ? 0 : gudgeon_angle;
    show_gudgeon_assembly(angle);

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
       air_brush_trigger_on_top(); 
    }
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

