include <lib/not_included_batteries.scad>
use <lib/small_pivot_vertical_rotation.scad>


include <master_airbrush_measurements.scad>;
use <master_air_brush.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show] */
show_air_brush = false;
show_main_pivot = true;
show_air_barrel_clip = false;
//show_air_barrel_

orient_for_build = false;

/* [Pivot Design] */

trigger_angle = 0; //[-45:15:+45]
pivot_top_range_of_motion = 135;
pivot_bottom_range_of_motion =  55; // [45:5:90]
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
    dy = measured_barrel_diameter/2 
        + barrel_allowance
        + pivot_w/2
        + barrel_clearance;
    
    dx = dx_trigger_pivot_offset;
    dz = dz_trigger_pivot_offset;
    pivot_lenth_pintle = barrel_back_to_air_hose;
    pivot_length_gudgeon = 
        m_trigger_pad_cl_to_barrel_cl_0_degrees
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
    x = barrel_back_to_air_hose;
    y = measured_barrel_diameter 
        + 2 * barrel_allowance
        + 2 * barrel_clearance
        + 2 * eps;
    z = measured_barrel_diameter/2 + wall_thickness  ; 
    dxb = dx_trigger_pivot_offset + pivot_h/2; 
    dzb = dz_trigger_pivot_offset + pivot_h/2;
    render() difference() {
        translate([dxb, 0, dzb]) 
            block([x, y, z], center=BEHIND+BELOW);
        air_brush_trigger_on_top();
    }
    
    // Gudgeon bridge
    block([pivot_h, y, pivot_h]);
}

module air_barrel_clip() {
    //air_hose_diameter
    id = air_hose_diameter + air_hose_allowance + air_hose_clearance;
    od = id + wall_thickness;
    h = air_hose_barrel_length + measured_barrel_diameter/2; 
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



