include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>

orient_for_build = false;
build_quick_connect_collet = true;
build_quick_connect_body = true;

/* [Quick_connect_design] */
tubing_od = 4;


d_collet_face = 10;
collet_wall = 1;

od_collet_clamp = tubing_od + 2*collet_wall;

show_cross_section = false;

alpha_quick_connect_body = 0.25; //[0.25, 1]

module end_of_customization() {}



a_lot = 100;

module ptfe_tubing(od, l, as_clearance = false, center = CENTER, clearance = 0.5) {
   a_lot = 200;
    d = as_clearance ? od + 2 * clearance :  od;
    rod(d=od, l=l, center=center);
    if (as_clearance) {
        rod(d=3, l=a_lot);        
    }
}
 

 
 
module quick_connect_collet() {
    color("green") {
        difference() {
            union() {
                can(d=10, h=3, center=ABOVE);
                can(d=6,  h=6, center=ABOVE);
                translate([0, 0, 6]) can(d=8,  h=3, center=ABOVE);
                translate([0, 0, 9]) can(d=8,  taper=6, h=3, center=ABOVE);
            }
            can(d=tubing_od, h=a_lot);
            translate([0, 0, 4]) block([1, a_lot, a_lot], center=ABOVE);
            translate([0, 0, 4]) block([a_lot, 1, a_lot], center=ABOVE);
            if (show_cross_section && !orient_for_build) {
                plane_clearance(FRONT);
            }             
         }
     }     
 }
 
module quick_connect_body(orient_for_build = false) {
    module shape() {
        difference() {
            union() {
                can(d=d_collet_face, h=10, center=ABOVE);
            }
            can(d=4, h=a_lot);
            can(d=od_collet_clamp, h=15);
            if (show_cross_section && !orient_for_build) {
                plane_clearance(FRONT);
            }
        }
    }
     if (orient_for_build) {
         shape();
     } else {
        color("blue", alpha=alpha_quick_connect_body)
            translate([0, 0, 5]) shape();
     }
 }
 
if (build_quick_connect_collet) {
    quick_connect_collet();
 }
 
if (build_quick_connect_body) {
    if (orient_for_build) {
        translate([15, 0, 0]) quick_connect_body(orient_for_build=true);
    } else {
        quick_connect_body(orient_for_build=false);
    }
  }