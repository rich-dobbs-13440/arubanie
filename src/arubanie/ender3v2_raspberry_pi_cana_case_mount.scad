include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

include <NopSCADlib/vitamins/extrusions.scad>

show_mocks = true;
orient_for_build = false;
build_bracket = true;
bracket_y = 20; 
wall = 2;

if (show_mocks && !orient_for_build) {
    //translate([-20, 0, 40]) rotate([0, 0, 90]) extrusion(E2040, 80, cornerHole = true);
    translate([-10, 0, -20]) rotate([90, 0, 0]) extrusion(E2040, 80, cornerHole = true);    
}


module bracket(orient_for_build) {
    rail_guide = [wall, bracket_y, 40];
    base = [20, bracket_y, wall];
    //shim_guide = [3, bracket_y, shim_guide_z];
    
    module hole() {
        rotate([0, -90, 0]) hole_through("M4", cld=0.4, $fn=12);
    }
    module positioned_shape() {
        difference() {
            block(rail_guide, center=BELOW+FRONT+RIGHT);
            for (z = [-10, -30]) {
                translate([-25, 5, z]) hole();
                translate([-25, bracket_y-5, z]) hole();
            }
        }
        difference() {
            union() {
                translate([0, 0, 0]) block(base, center=BELOW+FRONT+RIGHT);
                translate([0, 0, -rail_guide.z]) block(base, center=ABOVE+FRONT+RIGHT);
            }
            translate([10, 5, 10]) hole_through("M4", cld=0.4, $fn=12);
            translate([10, bracket_y-5, 10]) hole_through("M4", cld=0.4, $fn=12);
        }
    }
    if (orient_for_build) {
        rotate([90, 0, 0]) positioned_shape();
    } else {
        positioned_shape();
    }
}


if (orient_for_build) {
    if (build_bracket) {
        translate([0, 0, 0])  bracket(orient_for_build=true);
    }
    
}  else {
    if (build_bracket) {
        bracket(orient_for_build=false);
    }
}