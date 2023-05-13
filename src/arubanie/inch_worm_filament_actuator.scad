include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <MCAD/servos.scad>
//use <lib/ptfe_tubing.scad>

/* [Output Control] */

orient_for_build = false;

show_vitamins = true;

build_end_caps = true;
build_both_end_caps = true;
build_ptfe_glides = true;
build_packing_gland_face = true;

/* [Glide Design] */
slide_length = 50;
r_glide = 3;
glide_engagement = 2.4; // [2 : 0.1 : 5]
ptfe_snap_clearance = 0.2;
dx_glides = 8; // [1:0.1:10]

/* [End Cap Design] */
x_end_cap = 40; // [1:0.1:40]
y_end_cap = 10; // [1:0.1:20]
z_end_cap = 5; // [1:0.1:20]
part_push_clearance  = 0.2;

end_cap = [x_end_cap, y_end_cap, z_end_cap];

module end_of_customization() {}

module filament(as_clearance) {
    d = as_clearance ? 2.0 : 1.75;
    alpha = as_clearance ? 0 : 1;
    color("red", alpha) {
        can(d=d, h=slide_length + 40);
    }
    
}

module ptfe_tube(as_clearance, h, clearance) {
    d = as_clearance ? 4 + 2*clearance : 4;
    color("white") can(d=d, h=h);
}

if (show_vitamins && !orient_for_build) {
    filament(as_clearance=false);
}


module end_cap(orient_for_build) {
    module blank() {
        translate([0, 0, z_end_cap/2]) {
            hull() {
//                {
//                    glide_placement() {
//                        rotate([0, 0, -135]) glide_block(h=z_end_cap);
//                        rotate([0, 0, 0]) glide_block(h=z_end_cap);
//                    }
//                }
                block(end_cap); 
            }
        }
    }
    module shape() {
        z_glide = 100;
        color("aquamarine") {
            render(convexity=10) difference() {
                blank();
                filament(as_clearance=true);
                ptfe_glides(as_clearance = true, clearance=part_push_clearance); 
                //ptfe_tube_packing_clearance();
                //face_plate_screw_clearance();
    //            glide_placement() {
    //                        rotate([0, 0, -135]) glide_end_cap(as_clearance=true);
    //                        rotate([0, 0, 0]) glide_end_cap(as_clearance=true);
    //            }            
            }
        }
        
    }
    
    if (orient_for_build) {
        translate([0, 0, z_end_cap]) rotate([180, 0, 0]) shape();
        if (build_both_end_caps) {
            translate([0, 20, z_end_cap]) rotate([180, 0, 0]) shape();
        }
    } else {
        center_reflect([0, 0, 1]) translate([0, 0, slide_length/2]) shape();
    }
}

module glide_placement() {

    for (angle = [0 : 120: 240]) {
        rotate([0, 0, angle]) {
            translate([r_glide, 0, 0]) children();
        }
    }
}


module ptfe_glides(orient_for_build=false, show_vitamins=false, as_clearance=false, clearance=0) {
    translation = orient_for_build ? [0, 0, glide_length/2] : [dx_glides, 0, 0];
    if (show_vitamins) {  
        translate(translation) glide_placement() ptfe_tube(as_clearance=false, h=slide_length);
    }
    a_lot = 10;
    z_clearance = clearance ? a_lot : 0.01;
    glide_length = slide_length+2*z_end_cap + 2*z_clearance;
    module blank() {
        can(d=r_glide+2*glide_engagement, h=glide_length);
    }
    module shape() {
        color("blue") {
            render() difference() { 
                blank();
                glide_placement() ptfe_tube(as_clearance=true, h=slide_length, clearance=ptfe_snap_clearance);
            }
        }       
    }
    if (orient_for_build) {
        translate([0, 0, glide_length/2]) shape();
    } else {
        translate(translation) shape();
    }
}



if (build_end_caps) {
    if (orient_for_build) {
        translate([0, 0, 0]) end_cap(orient_for_build=true);
    } else {
        end_cap(orient_for_build=false);
    }
}

if (build_ptfe_glides) {
    if (orient_for_build) {
        translate([0, 0, 0]) ptfe_glides(orient_for_build=true, show_vitamins=false);
    } else {
        ptfe_glides(orient_for_build=false, show_vitamins=show_vitamins);
    }
}