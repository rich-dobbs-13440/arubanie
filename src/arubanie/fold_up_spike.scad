include <lib/not_included_batteries.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <master_air_brush.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show] */
show_air_brush = false;
show_main_pivot = true;
show_air_barrel_clip = true;
//show_air_barrel_

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

module main_pivot() {
    dy = master_air_brush("barrel radius") 
        + barrel_allowance
        + pivot_w/2
        + barrel_clearance;
    
    dx = dx_trigger_pivot_offset;
    dz = dz_trigger_pivot_offset;
    pivot_lenth_pintle = master_air_brush("back length");
    pivot_length_gudgeon = 
        master_air_brush("trigger height")
        + gudgeon_extension;
    translate([dx, dy, dz])
        rotate([0, 0, 180]) // Want the pintle toward the read
            small_pivot_vertical_rotation(
                pivot_h, 
                pivot_w, 
                pivot_lenth_pintle, 
                pivot_length_gudgeon, 
                pivot_allowance, 
                range=[pivot_top_range_of_motion, pivot_bottom_range_of_motion], 
                angle=pintle_angle);
    
    // Pivot bridge
    x = master_air_brush("back length");
    y = master_air_brush("barrel diameter") 
        + 2 * barrel_allowance
        + 2 * barrel_clearance
        + 2 * eps;
    z = master_air_brush("barrel radius") + wall_thickness  ; 
    dxb = dx_trigger_pivot_offset + pivot_h/2; 
    dzb = dz_trigger_pivot_offset + pivot_h/2;
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
    dzgb = dz;
    
    translate([dxgb, 0, dzgb]) block([xgb, ygb, zgb]);
}

module air_barrel_clip() {
    //air_hose_diameter
    id = master_air_brush("air hose diameter") + air_hose_allowance + air_hose_clearance;
    od = id + wall_thickness;
    h = master_air_brush("bottom length"); 
    render() difference() {
        can(d=od, h=h, hollow=id, center=BELOW);
        air_brush_trigger_on_top();
    }
}

module air_brush_trigger_on_top() {
    rotate([90, 0, 0]) air_brush(trigger_angle);
}

rotate(viewing_orientation) {

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
}

//module 



