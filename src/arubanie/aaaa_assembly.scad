include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/9g_servo.scad>
use <lib/not_included_batteries.scad>
use <master_air_brush.scad>


/* [Boiler Plate] */

$fa = 5;
$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [Show Parts] */
show_air_brush = false;
show_main_pivot = true;
show_air_barrel_clip = true;
show_trigger_cage = true;
show_air_flow_servo = true;

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

/* [Pivot Design] */


gudgeon_angle = 0; // [-145:5: 0]
trigger_angle = 245 - gudgeon_angle; //135-gudgeon_angle ; 
//gudgeon_extension = 10; //[-15:15]

dx_trigger_pivot_offset = 0; // [-3:0.25:+3]
dz_trigger_pivot_offset = -3; // [-5:0.05:0]

barrel_allowance = 0.2;
barrel_clearance = 0.1;

// This controls printablity vs play in the pivot.
pivot_allowance = 0.4;

pivot_top_range_of_motion = 135;
pivot_h = 4; //[4, 5]
pivot_w = 4; //[4, 5]
/* [Air Hose Clip Design] */
air_hose_allowance = 0.2;
air_hose_clearance = 0.5;
wall_thickness = 2;

/* [Trigger Cage Design] */
cage_cant_angle = 18;
trigger_cage_height = 7.5;
cage_allowance = 0.4;
trigger_cap_clearance = 1.0;


module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  // TBD

viewing_orientation = orient_for_build ? FOR_BUILD : FOR_DESIGN;

pivot_ranges = [pivot_top_range_of_motion, pivot_top_range_of_motion];

dy_trigger_pivot_cl = 
        master_air_brush("barrel radius") 
        + barrel_allowance
        + barrel_clearance
        + pivot_w/2;

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

pivot_length_gudgeon = master_air_brush("barrel radius") - dz_trigger_pivot_offset;
D_GUDGEON_BRIDGE_FRONT = [pivot_length_gudgeon, 0, 0];


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


module main_gudgeon() {
    color(main_gudgeon_color, alpha=main_gudgeon_alpha) {
        rotate([0, 0, 180]) { // Flip to desired orientation
           gudgeon(
                pivot_h, 
                pivot_w, 
                pivot_length_gudgeon, 
                pivot_allowance, 
                range_of_motion=
                    [pivot_top_range_of_motion, 
                    pivot_top_range_of_motion]);  
        }   
    }
}


module air_flow_servo() {
    rotate([0, cage_cant_angle, 0])
    translate([60, 0, -16]) rotate([0, 180, 0]) 9g_motor_sprocket_at_origin(); 
}


module gudgeon_bridge() {
    size = [pivot_h, D_MIRROR_SIDES.y + eps, pivot_h];
    color(gudgeon_bridge_color, alpha=gudgeon_bridge_alpha)
        translate([pivot_length_gudgeon, 0, 0]) 
            block(size, center=LEFT+BEHIND);
}



// *********************************************************************
module cage_barrel(inner=false, outer=false) {
    id = master_air_brush("trigger pad diameter") + trigger_cap_clearance;
    od = id + wall_thickness; // We want thin tubes here!
    id_2 = od + cage_allowance;
    od_2 = id_2 + wall_thickness; // We want thin tubes here!
    dx_cage_inner =  pivot_length_gudgeon;
    dx_cage_outer = pivot_length_gudgeon + 10;
    
    render() difference() {
        rotate([0, cage_cant_angle, 0]) {
            if (inner) {
                translate([dx_cage_inner, 0, 0]) { 
                    rod(d=od, hollow=id, l=10, center=FRONT);
                }
            }
            if (outer) {
                translate([dx_cage_outer, 0, 0]) rod(d=od_2, hollow=id_2, l=trigger_cage_height, center=FRONT);
            }
            
        }
        translate([0, 0, pivot_h/2]) block([30, 30, 10], center=ABOVE+FRONT);  
    }
}

module trigger_cage_section() {
    cage_barrel(outer=true);
    
    if (orient_for_build) {
        translate([50, 0, (pivot_length_gudgeon + 0.0 + pivot_h/2)])
            rotate([0,90-cage_cant_angle,0]) 
                cage_barrel(inner=true);
    } else {
        cage_barrel(inner=true);
    }
    
    trigger_cage_section_length = 18.2;
    size = [trigger_cage_section_length + 2* eps, pivot_w, pivot_h];
    dx = pivot_length_gudgeon - eps;
    translate(D_MIRROR_SIDES + [dx, 0, 0]) block(size, center=FRONT);
    translate(-D_MIRROR_SIDES + [dx, 0, 0]) block(size, center=FRONT);
    y = 2*D_MIRROR_SIDES.y; 
    bridge_size = [6.6, y, pivot_h];
    dx_bridge = dx + trigger_cage_section_length;
    difference() {
        translate([dx_bridge, 0, 0]) block(bridge_size, center=BEHIND);
        hull() cage_barrel(outer=true);
    }
    
}


// *********************************************************************

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
            gudgeon_assembly_sides();
            trigger_cage_section();
            if (show_air_flow_servo) {
                air_flow_servo();
            }
        }
    }
}


module pintle_bridge_side() {
    x = master_air_brush("back length");
    y = master_air_brush("barrel diameter") 
        + 2 * barrel_allowance
        + 2 * barrel_clearance
        + 2 * eps;
    z = master_air_brush("barrel radius") + wall_thickness  ; 
    dxb = dx_trigger_pivot_offset; 
    dzb = dz_trigger_pivot_offset + pivot_h/2;
    color(pintle_bridge_color, alpha=pintle_bridge_alpha) { 
        render() difference() {
            translate([dxb, 0, dzb]) 
                block([x, y, z], center=BEHIND+BELOW);
            air_brush_trigger_on_top();
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
                    range_of_motion=pivot_ranges);
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
    gudgeon_assembly();
}


module air_barrel_clip() {
    //air_hose_diameter
    id = master_air_brush("air barrel diameter") + air_hose_allowance + air_hose_clearance;
    od = id + wall_thickness;
    h = master_air_brush("bottom length"); 
    color(air_barrel_clip_color , alpha=air_barrel_clip_alpha) {
        render() difference() {
            can(d=od, h=h, hollow=id, center=BELOW);
            air_brush_trigger_on_top();
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

    if (show_main_pivot) { 
        main_assembly();
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
    
    if (show_trigger_cage) {
        trigger_cage(orient_for_build);
    }


}






