include <lib/not_included_batteries.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <master_air_brush.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show Parts] */
show_air_brush = false;
show_main_pivot = true;
show_air_barrel_clip = true;

/* [Constructions] */
show_constructions = false;
// Note: show_constructions must be enabled!
show_construction_displacements = false;
// Note: show_constructions must be enabled!
show_construction_planes = false;

/* [Build vs Design] */
orient_for_build = true;

/* [Pivot Design] */

trigger_angle = 0; //[-45:15:+45]
pivot_top_range_of_motion = 135;
pivot_bottom_range_of_motion = 135; // [45:5:90]
pintle_angle = 0; // [0, 45, 90, 135, 145]

pivot_h = 4; //[4:0.5:6]
pivot_w = 4; //[1:15]
gudgeon_extension = 20; //[0:30]
// This controls printablity vs play in the pivot.
pivot_allowance = 0.4;
dx_trigger_pivot_offset = 0; // [-3:0.25:+3]
dz_trigger_pivot_offset = -3; // [-5:0.05:0]

barrel_allowance = 0.2;
barrel_clearance = 1.0;
/* [Air Hose Clip Design] */
air_hose_allowance = 0.2;
air_hose_clearance = 0.5;
wall_thickness = 2;

module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  // TBD

viewing_orientation = orient_for_build ? FOR_BUILD : FOR_DESIGN;


dy_trigger_pivot_offset = 
        master_air_brush("barrel radius") 
        + barrel_allowance
        + barrel_clearance
        + pivot_w/2;

D_CL_TRG_PVT = [
            dx_trigger_pivot_offset, 
            dy_trigger_pivot_offset, 
            dz_trigger_pivot_offset];
D_CL_TRG_BLD_PLT = D_CL_TRG_PVT + [0, 0, pivot_h/2];

D_AIR_BARREL_TOP = [0, 0, -master_air_brush("bottom length")];
D_AIR_BARREL_BACK = [-master_air_brush("air barrel radius"), 0, 0];
D_AIR_BARREL_RIGHT = [0, master_air_brush("air barrel radius"), 0];
D_BARREL_BACK = [-master_air_brush("back length"), 0, 0];
D_BARREL_RIGHT = [0, master_air_brush("barrel radius"), 0];

D_TRIGGER_TOP = [0, 0, master_air_brush("trigger height")];

IDX_DISP_LABEL = 0;
IDX_DISP_VAL = 1;
IDX_DISP_CLR = 2;

displacements = [
    ["D_CL_TRG_PVT", D_CL_TRG_PVT, "Red"],
    ["D_CL_TRG_BLD_PLT", D_AIR_BARREL_TOP, "Orange"], 
    ["D_AIR_BARREL_TOP", D_AIR_BARREL_TOP, "Yellow"], 
    ["D_AIR_BARREL_BACK", D_AIR_BARREL_BACK, "Green"],
    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Blue"],
    ["D_BARREL_RIGHT", D_BARREL_RIGHT, "Indigo"],
    ["D_TRIGGER_TOP", D_TRIGGER_TOP, "Violet"],
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



module main_pivot() {

    
    // = dx_trigger_pivot_offset;
    // = dz_trigger_pivot_offset;
    pivot_lenth_pintle = abs(D_BARREL_BACK.x);
    pivot_length_gudgeon = 
        + D_TRIGGER_TOP.z
        + gudgeon_extension;
    color("salmon", alpha=0.2)
        translate(D_CL_TRG_PVT)
            rotate([0, 0, 180]) // Want the pintle toward the read
                small_pivot_vertical_rotation(
                    pivot_h, 
                    pivot_w, 
                    pivot_lenth_pintle, 
                    pivot_length_gudgeon, 
                    pivot_allowance, 
                    range=[pivot_top_range_of_motion, pivot_bottom_range_of_motion], 
                    angle=pintle_angle);
                    
    // Pivot to air barrel mounting
    h_ptabm = D_BARREL_RIGHT.y;
    //d(d=pivot_w, h=h_ptabm);
    
    // Pivot bridge
    x = master_air_brush("back length");
    y = master_air_brush("barrel diameter") 
        + 2 * barrel_allowance
        + 2 * barrel_clearance
        + 2 * eps;
    z = master_air_brush("barrel radius") + wall_thickness  ; 
    dxb = dx_trigger_pivot_offset; 
    dzb = dz_trigger_pivot_offset + pivot_h/2;
    color("Goldenrod", alpha=0.25) 
        render() difference() {
            translate([dxb, 0, dzb]) 
                block([x, y, z], center=BEHIND+BELOW);
            air_brush_trigger_on_top();
        }
    
    // Gudgeon bridge
    xgb = pivot_h;
    ygb = y;
    zgb = pivot_h;
    
    dxgb = pivot_length_gudgeon - xgb/2;
    dzgb = D_TRIGGER_TOP.z;
    color("DarkSalmon")
        translate([dxgb, 0, dzgb]) block([xgb, ygb, zgb]);
}

module air_barrel_clip() {
    //air_hose_diameter
    id = master_air_brush("air barrel diameter") + air_hose_allowance + air_hose_clearance;
    od = id + wall_thickness;
    h = master_air_brush("bottom length"); 
    color("BurlyWood" , alpha=0.25) {
        render() difference() {
            can(d=od, h=h, hollow=id, center=BELOW);
            air_brush_trigger_on_top();
        }
    }
}

module air_brush_trigger_on_top() {
    rotate([90, 0, 0]) air_brush(trigger_angle, alpha=0.1);
}

rotate(viewing_orientation) {
    
    if (show_constructions && show_construction_displacements) {
            display_construction_displacements();
    }

    if (show_main_pivot) { 
            main_pivot(); 
            mirror([0, 1, 0]) main_pivot();
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






