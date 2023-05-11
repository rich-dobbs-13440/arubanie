include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>

orient_for_build = false;
build_quick_connect_collet = true;
build_quick_connect_body = true;

/* [Quick_connect_design] */
show_cross_section = false;

tubing_od = 4;
tubing_allowance = 0.4;

collet_wall = 1;
collet_clamp_wall = 1;
body_wall = 1;
collet_retention_wall = 0.1;

h_face = 3;
h_neck = 3;
h_clamp = 3;
h_assembly_taper = 2;
h_collet_retention = 1;
h_clamp_taper = 1;
h_cavity_clearance = 1;

h_body_cavity = h_clamp + h_assembly_taper + h_neck - h_collet_retention - h_clamp_taper + h_cavity_clearance;

d_neck = tubing_od + 2*collet_wall;
d_collet_face = d_neck + 4;
od_collet_clamp = d_neck + 2*collet_clamp_wall;
d_collet_retention = od_collet_clamp - 2*collet_retention_wall;
od_body = od_collet_clamp + 2 * body_wall;


alpha_body = 0.25; //[0.25, 1]

module end_of_customization() {}


a_lot = 100;


module quick_connect_collet(tubing_allowance=0) {
    color("green") {
        render(convexity=10) difference() {
            union() {
                can(d=d_collet_face, h=h_face, center=ABOVE);
                translate([0, 0, h_face]) can(d=d_neck,  h=h_neck, center=ABOVE);
                translate([0, 0, h_face + h_neck]) 
                    can(d=od_collet_clamp,  h=h_clamp, center=ABOVE);
                translate([0, 0, h_face + h_neck + h_clamp]) 
                    can(d=od_collet_clamp,  taper=d_neck, h=h_assembly_taper, center=ABOVE);
            }
            can(d=tubing_od + 2 * tubing_allowance, h=a_lot);
            can(d=tubing_od+2, taper=tubing_od + 2 * tubing_allowance, h=h_face/2); 
            translate([0, 0, 4]) block([1, a_lot, a_lot], center=ABOVE);
            translate([0, 0, 4]) block([a_lot, 1, a_lot], center=ABOVE);
            if (show_cross_section) {
                plane_clearance(RIGHT);
            }             
         }
     }     
 }
 
module quick_connect_body(orient_for_build = false) {
    module shape() {
        render(convexity=10) difference() {
            union() {
                can(d=d_collet_face, h=od_body, center=ABOVE);
            }
            can(d=tubing_od + 2 * tubing_allowance, h=a_lot);
            can(d=d_collet_retention, h=h_collet_retention, center=ABOVE);
            translate([0, 0, h_collet_retention]) can(d=d_collet_retention, taper=od_collet_clamp, h=h_clamp_taper, center=ABOVE);
            translate([0, 0, h_collet_retention+h_clamp_taper]) can(d=od_collet_clamp, h=h_body_cavity, center=ABOVE);
            if (show_cross_section) {
                plane_clearance(RIGHT);
            }
        }
    }
    color("blue", alpha=alpha_body) {
        if (orient_for_build) {
             translate([0, 0, od_body]) rotate([180, 0, 0]) shape();
        } else {   
            translate([0, 0, 5]) shape();
        }
    }
 }
 
if (build_quick_connect_collet) {
    quick_connect_collet(tubing_allowance=tubing_allowance);
 }
 
if (build_quick_connect_body) {
    if (orient_for_build) {
        translate([15, 0, 0]) quick_connect_body(orient_for_build=true);
    } else {
        quick_connect_body(orient_for_build=false);
    }
}
  