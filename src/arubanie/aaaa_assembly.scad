include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/9g_servo.scad>
use <lib/not_included_batteries.scad>
use <master_air_brush.scad>
use <trigger_holder.scad>


/* [Boiler Plate] */

$fa = 10;
$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [Show Parts] */
show_air_brush = false;
show_pintle_assembly = true;
show_gudgeon_assembly = true;
show_gudgeon_subassembly = true;
show_trigger_cage_section_subassembly = true;
show_trigger_shaft_subassemby = true;
show_air_barrel_clip = true;
show_air_flow_servo = true;

/* [Servo Design] */

servo_dx = 60; // [20 : 1 : 60]
servo_dy = 0; // [-20 : 1 : 20]
servo_dz = -16; // [-20 : 1 :20]
servo_rx = 0; // [-180 : 15 : +180]
servo_ry = 0; // [-180 : 15 : +180]
servo_rz = 0; // [-180 : 15 : +180]

/* [Part Colors] */

main_pintle_color = "Tomato"; // [DodgerBlue, Tomato, LightSalmon, DarkSalmon, Salmon, Coral]
main_gudgeon_color = "Chocolate"; // [DodgerBlue, Tomato, LightSalmon, DarkSalmon, Salmon, Coral]
pintle_bridge_color = "DarkSalmon"; // [DodgerBlue, LightSalmon, DarkSalmon, Salmon, Coral]
gudgeon_bridge_color = "LightSalmon"; // [DodgerBlue, LightSalmon, DarkSalmon, Salmon, Coral]
air_barrel_clip_color = "Coral"; // [DodgerBlue, LightSalmon, DarkSalmon, Salmon, Coral]

/* [Transparency] */
main_pintle_alpha = 1; // [0:0.05:1]
main_gudgeon_alpha = 1; // [0:0.05:1]
pintle_bridge_alpha = 1; // [0:0.05:1]
gudgeon_bridge_alpha = 1; // [0:0.05:1]
air_barrel_clip_alpha = 1; // [0:0.05:1]

air_brush_alpha = 0.10; // [0:0.05:1]


/* [Constructions] */
show_constructions = false;
// Note: show_constructions must be enabled!
show_construction_displacements = false;
// Note: show_constructions must be enabled!
show_construction_planes = false;

/* [Build vs Design] */
orient_for_build = true;
permanent_pin=true; 

/* [Pivot Design] */


gudgeon_angle = 0; // [-145:5: 0]
trigger_angle = 270 - gudgeon_angle; //135-gudgeon_angle ; 

dx_trigger_pivot_offset = 0; // [-3:0.25:+3]
dz_trigger_pivot_offset = -3; // [-5:0.05:0]

barrel_allowance = 0.2;
barrel_clearance = 0.1;

// This controls printablity vs play in the pivot.
pivot_allowance = 0.4;

pivot_top_range_of_motion = 145;
pivot_bottom_range_of_motion = 90;
pivot_h = 8; 
pivot_w = 4; //[4, 5]
/* [Air Barrel Clip Design] */
air_barrel_allowance = 0.3;
air_barrel_clearance = 0.4;
wall_thickness = 2;

/* [Trigger Cage Design] */


shaft_position_above_pivot = 22; // [10 : 0.25 : 22]

trigger_cage_section_length = 16;
trigger_cage_height = 7.5;
trigger_shaft_length_clearance = 1;
trigger_shaft_bearing_clearance = 0.5;
trigger_shaft_diameter = 5;
trigger_cage_lower_offset = 9;

module end_of_customization() {}



FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  // TBD

viewing_orientation = orient_for_build ? FOR_BUILD : FOR_DESIGN;

pivot_ranges = [pivot_top_range_of_motion, pivot_bottom_range_of_motion];

// Main Design Calculations

trigger_shaft_length = 
    trigger_cage_section_length 
    + trigger_shaft_length_clearance;

trigger_bearing_id =
    trigger_shaft_diameter 
    + 2 * trigger_shaft_bearing_clearance;
echo("trigger_bearing_id", trigger_bearing_id);

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

barrel_clip_inside_diameter = 
    master_air_brush("barrel diameter")
    + barrel_allowance 
    + barrel_clearance;
    
barrel_clip_outside_diameter = 
    barrel_clip_inside_diameter + 2 * wall_thickness;
    
dy_trigger_pivot_cl = 
    barrel_clip_outside_diameter/2 
    + pivot_w/2;
    
pivot_length_gudgeon = 16; // Function of range of motion, but just kludging it for now.
    
// Calculate Displacement vectors in attempt to make code cleaner.  
// Note: not sure that this is working out.
    
D_MIRROR_SIDES = [0, dy_trigger_pivot_cl, 0];

D_CL_TRG_PVT_ADJUSTMENT = [
            dx_trigger_pivot_offset, 
            0, 
            dz_trigger_pivot_offset];
D_CL_TRG_BLD_PLT = D_CL_TRG_PVT_ADJUSTMENT + [0, 0, pivot_h/2];
 
D_AIR_BARREL_TOP = [0, 0, -master_air_brush("bottom length")];
D_AIR_BARREL_BACK = [-master_air_brush("air barrel radius"), 0, 0];
D_AIR_BARREL_RIGHT = [0, master_air_brush("air barrel radius"), 0];
D_BARREL_BACK = [-master_air_brush("back length"), 0, 0];
D_BARREL_RIGHT = [0, master_air_brush("barrel radius"), 0];

D_TRIGGER_TOP = [0, 0, master_air_brush("trigger height")];

D_GUDGEON_BRIDGE_FRONT = [pivot_length_gudgeon, 0, 0];


D_SERVO = [servo_dx, servo_dy , servo_dz];

IDX_DISP_LABEL = 0;
IDX_DISP_VAL = 1;
IDX_DISP_CLR = 2;

displacements = [
    ["D_CL_TRG_PVT_ADJUSTMENT", D_CL_TRG_PVT_ADJUSTMENT, "Red"],
    ["D_CL_TRG_BLD_PLT", D_AIR_BARREL_TOP, "Orange"], 
    ["D_AIR_BARREL_TOP", D_AIR_BARREL_TOP, "Yellow"], 
    ["D_AIR_BARREL_BACK", D_AIR_BARREL_BACK, "Green"],
    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Blue"],
    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Indigo"],
    ["D_TRIGGER_TOP", D_TRIGGER_TOP, "Violet"],
//    ["D_GUDGEON_FRONT_BLD_PLT", D_GUDGEON_FRONT_BLD_PLT, "Aqua"],
];



module display_construction_displacements() {
    for (d = displacements) {
        display_displacement(
            d[IDX_DISP_VAL], 
            barb_color=d[IDX_DISP_CLR],
            shaft_color=d[IDX_DISP_CLR],
            label=d[IDX_DISP_LABEL]);
    }
}

module display_construction_planes() {
    construct_plane(D_BARREL_BACK, [1, 0, 0], 40);
    construct_plane(D_BARREL_RIGHT, [0, 1, 0], 100);
    construct_plane(D_AIR_BARREL_BACK, [1, 0, 0], 40);  
    construct_plane(D_AIR_BARREL_TOP, [0, 0, 1], 100);
    construct_plane(D_AIR_BARREL_RIGHT, [0, 1, 0], 100); 
    construct_plane(D_CL_TRG_PVT, [0, 0, 1], 100); 
    construct_plane(D_CL_TRG_PVT, [1, 0, 0], 40); 
    construct_plane(D_CL_TRG_BLD_PLT, [0, 0, 1], 100);
}

module build_plane_clearance() {
    // This is in terms of the origin at
    // the centerlines for the air barrel and main barrel.
    dz = dz_trigger_pivot_offset + pivot_h/2;
    translate([0, 0, dz]) block([100, 100, 50], center=ABOVE);
}

module air_brush_simple_clearance() {
    fa_as_arg = $fa;
    can(d=air_barrel_clip_inside_diameter, h=80, fa=fa_as_arg);
    rod(d=barrel_clip_inside_diameter, l=120, fa=fa_as_arg);
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


module main_gudgeon() {
    color(main_gudgeon_color, alpha=main_gudgeon_alpha) {
        rotate([0, 0, 180]) { // Flip to desired orientation
           gudgeon(
                pivot_h, 
                pivot_w, 
                pivot_length_gudgeon, 
                pivot_allowance, 
                range_of_motion=pivot_ranges);
        }   
    }
}

// ******************************************************
module air_flow_servo() {
    translate(D_SERVO) 
        rotate([servo_rx, servo_ry, servo_rz]) 9g_motor_sprocket_at_origin(); 
}


module gudgeon_bridge() {
    size = [pivot_h, D_MIRROR_SIDES.y + eps, pivot_h];
    color(gudgeon_bridge_color, alpha=gudgeon_bridge_alpha)
        translate([pivot_length_gudgeon, 0, 0]) 
            block(size, center=LEFT+BEHIND);
}

module trigger_shaft() {
    fa_as_arg = $fa;
    translate([-eps, 0, 0]) rod(
        d=trigger_shaft_diameter, 
        l=trigger_shaft_length, 
        center=FRONT);
    translate([trigger_shaft_length, 0, 0]) 
        block([1,2,pivot_h/2], center=ABOVE+BEHIND);
}


module trigger_catch() {
    trigger_shaft();
    difference() {
        rotate([-90, 0, 90]) master_air_brush_trigger_catch();
        translate([0, 0, -dz_trigger_pivot_offset]) build_plane_clearance();
    }
}


module trigger_shaft_bearing_wall(dx_offset) {
    fa_as_arg = $fa;
    size = [wall_thickness, 2*D_MIRROR_SIDES.y, pivot_h- 5*eps];
    dx = pivot_length_gudgeon + dx_offset;
    
    translate([dx-2*eps, 0, 0]) 
    difference() {
        block(size, center=BEHIND);
        rod(d=trigger_bearing_id, l=2*trigger_shaft_length, fa=fa_as_arg); // 
    }
}

module trigger_cage_section() {

    
    size = [trigger_cage_section_length + 2* eps, pivot_w, pivot_h];
    dx = pivot_length_gudgeon - eps;
    translate(D_MIRROR_SIDES + [dx, 0, 0]) block(size, center=FRONT);
    translate(-D_MIRROR_SIDES + [dx, 0, 0]) block(size, center=FRONT);
    
    trigger_shaft_bearing_wall(trigger_cage_section_length);
    trigger_shaft_bearing_wall(trigger_cage_lower_offset);
}


module gudgeon_assembly_side() {
    translate(D_MIRROR_SIDES) {
        main_gudgeon();
    } 
}

module gudgeon_assembly_sides() {
    gudgeon_assembly_side();
    mirror([0, 1, 0]) gudgeon_assembly_side();
}

module gudgeon_assembly() {
    translate(D_CL_TRG_PVT_ADJUSTMENT) {
        rotate([0, gudgeon_angle, 0]) {
            if (show_gudgeon_subassembly) {
                gudgeon_assembly_sides();
            }
            if (show_trigger_cage_section_subassembly) {
                trigger_cage_section();
            }
            if (show_trigger_shaft_subassemby) {
            translate([shaft_position_above_pivot, 0, 0]) trigger_catch();
        }
            if (show_air_flow_servo) {
                air_flow_servo();
            }
        }
    }
}


module pintle_bridge_side() {
    x = master_air_brush("back length");
    y = barrel_clip_outside_diameter;
    z = master_air_brush("barrel radius") + wall_thickness  ; 
    dxb = dx_trigger_pivot_offset; 
    dzb = dz_trigger_pivot_offset + pivot_h/2;
    
    
    id = barrel_clip_inside_diameter;
    od = barrel_clip_outside_diameter;
    fa_as_arg = $fa;
    color(pintle_bridge_color, alpha=pintle_bridge_alpha) { 
        difference() {
            union() {
                translate([dxb, 0, dzb]) 
                    block([x, y, z], center=BEHIND+BELOW);
                rod(d=od, hollow=id, l=x, center=BEHIND, fa=fa_as_arg);
            }
            union() {
                air_brush_simple_clearance();
                build_plane_clearance();
            }
        }
    }
}

module main_pintle_side() {
    pivot_lenth_pintle = abs(D_BARREL_BACK.x);
    color(main_pintle_alpha, alpha=main_pintle_alpha) {
        translate(D_CL_TRG_PVT_ADJUSTMENT + D_MIRROR_SIDES) {
            rotate([0, 0, 180]) { // Want the pintle toward the read
                pintle(
                    pivot_h, 
                    pivot_w, 
                    pivot_lenth_pintle, 
                    pivot_allowance, 
                    range_of_motion=pivot_ranges,
                    permanent_pin=permanent_pin);
            }
        }
    } 
}

module pintle_assembly() {
    main_pintle_side();
    mirror([0, 1, 0]) main_pintle_side();
    pintle_bridge_side();
    mirror([0, 1, 0]) pintle_bridge_side();
}


module main_assembly() {
    pintle_assembly();
    
}


module air_barrel_clip() {
    id = air_barrel_clip_inside_diameter;
    od = air_barrel_clip_outside_diameter;
    h = master_air_brush("bottom length"); 
    fa_as_arg = $fa;
    color(air_barrel_clip_color , alpha=air_barrel_clip_alpha) {
        render() difference() {
            can(d=od, h=h, hollow=id, center=BELOW, fa=fa_as_arg);
            air_brush_simple_clearance();
        }
    }
}

module air_brush_trigger_on_top() {
    rotate([90, 0, 0]) air_brush(trigger_angle, alpha=air_brush_alpha);
}



rotate(viewing_orientation) {
    
    if (show_constructions && show_construction_displacements) {
            display_construction_displacements();
    }
    if (show_pintle_assembly) { 
        pintle_assembly();
    }
    if (show_gudgeon_assembly) { 
        gudgeon_assembly();
    }
    if (show_air_barrel_clip) {
        air_barrel_clip();
    }
    if (show_air_brush) {          
        air_brush_trigger_on_top();
    }
    if (show_constructions && show_construction_planes) {
            display_construction_planes();
    }
}






