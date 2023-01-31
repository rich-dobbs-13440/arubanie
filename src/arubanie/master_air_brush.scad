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

include <master_airbrush_measurements.scad>;

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show] */

show_air_brush = true;
barrel_diameter_clearance = 0.75;

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

module _brace() {
    // Entire block, before carve outs
    x = brace_length + air_hose_diameter/2;
    z = brace_height + barrel_diameter/2;
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    dz = -brace_height/2;
    translate([dx, 0, dz]) rotate([90, 0, 0]) cube([brace_length, brace_width, z]);
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
            _brace();
            _trigger(trigger_angle);
        }
    }
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

