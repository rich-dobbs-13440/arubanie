/*

Usage:

use <master_air_brush.scad>

air_brush(trigger_angle);

Note: The air brush is oriented on its side, with the coordinate 
      system centered on the intersection of the axis for the 
      main barrel and the air barrel.  

      The tip of the gun is in the positive x direction.
      The trigger is in the positive y direction.

*/ 

include <lib/not_included_batteries.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show] */

show_air_brush = true;
show_brace = false;
barrel_diameter_clearance = 0.75;

module end_of_customization() {}


measured_barrel_diameter = 12.01; 
barrel_length = 68.26;
barrel_back_to_air_hose = 21.27;
brace_height = 6.9;
brace_width = 7.40;
brace_length = 28.88;
air_hose_diameter = 8.66;
air_hose_barrel_length = 10.34;
m_trigger_pad_diameter = 10.18;
m_trigger_pad_thickness = 2.63;
m_trigger_pad_cl_to_barrel_cl_0_degrees = 10.65;

pad_diameter = 10.74;
pad_height = 2.60;

_dct_name_to_dimension = [
    ["barrel diameter", measured_barrel_diameter],
    ["barrel radius", measured_barrel_diameter/2],
    ["air hose diameter", air_hose_diameter],
    ["back length", barrel_back_to_air_hose],
    ["bottom length", air_hose_barrel_length + measured_barrel_diameter/2],
    ["trigger height", m_trigger_pad_cl_to_barrel_cl_0_degrees],
];


function master_air_brush(key) = find_in_dct(_dct_name_to_dimension, key, required=true);  

assert(!is_undef(master_air_brush("barrel radius")));
assert(!is_undef(master_air_brush("back length")));
assert(!is_undef(master_air_brush("trigger height")));


show_name = false;
if (show_name) {
    linear_extrude(2) text("master_airbrush_measurements.scad", halign="center");
}

barrel_diameter = measured_barrel_diameter + barrel_diameter_clearance;
_trigger_pad_diameter = m_trigger_pad_diameter + 0.0;
_trigger_pad_thickness = m_trigger_pad_thickness + 0.0;

module _barrel() {
    // Display horizontal zero 
    h = barrel_length +2*eps;
    d = barrel_diameter;
    translate([-eps, 0, 0]) rotate([0,90,0]) cylinder(h=h, d=d, center=false);
}

module _air_hose_barrel() {
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    h = air_hose_barrel_length + barrel_diameter/2;
    
    translate([dx, 0, 0]) 
        rotate([90,0,0]) 
            cylinder(h=h, d=air_hose_diameter, center=false);
}

module _brace_cl_cl() {

    brace_radius = brace_width/2;
    brace_cl_l = brace_length + air_hose_diameter/2;
    dy = -barrel_diameter/2;
    brace_top_cl_l = air_hose_diameter/2 + 3;
    dyt = -(brace_height+barrel_diameter/2);
    hull() {
        translate([0, dy, 0])
            rod(d=brace_width, l=brace_cl_l, center=FRONT);
        translate([0, dyt, 0])
            rod(d=brace_width, l=brace_top_cl_l, center=FRONT+RIGHT);
    }
    block([brace_cl_l, barrel_diameter/2, brace_width], center=FRONT+LEFT);
}


if (show_brace) {
    _brace_cl_cl();
}
    
    
    
module _trigger_piece(angle) {
    pivot_offset = 3; // This is a guess
    dy_pivot = m_trigger_pad_cl_to_barrel_cl_0_degrees + pivot_offset;
    translate([0, -pivot_offset, 0])
    rotate([0, 0, angle]) {
        translate([0, dy_pivot, 0]) rotate([90, 0, 0]) {
            cylinder(h=_trigger_pad_thickness, d=_trigger_pad_diameter, center=true);
        }
    }
}

* _trigger_piece(30);

module _trigger(angle) {
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    dy = m_trigger_pad_cl_to_barrel_cl_0_degrees;
    translate([dx, 0, 0]) _trigger_piece(angle);
}

module air_brush(trigger_angle) {

    dx = -barrel_back_to_air_hose - air_hose_diameter/2;
    color("Red", alpha=0.25) {
        translate([dx, 0, 0]) {
            _barrel();
            _air_hose_barrel();
            _trigger(trigger_angle);
        }
    }
    _brace_cl_cl();
}
if (show_air_brush) {
    air_brush(trigger_angle=30);
}



module _trigger_cap_clearance() {
    width = 40;
    bottom_radius = 8;
    top_radius = 22;
    height = top_radius - bottom_radius;
    dz = -width/2;
    rotate([90, 0, 0]) translate([0,0,dz])  {
        rotate_extrude(angle = 30, convexity = 2) {
           translate([bottom_radius,0,0]) square([height,width]);
        }  
    }  
}

* _trigger_cap_clearance();

