include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>

orient_for_build = false;
build_collet = true;
build_body = true;
build_c_clip = true;


/* [Quick_connect_design] */
show_cross_section = false;
insert_clip = false;

tubing_od = 4 + 0;



/* [Collet Design] */
tubing_allowance = 0.3;

collet_retention_wall = 0.5;
collet_wall = 1.5;
collet_clamp_wall = 1;
collet_entrance_clearance = 3;
collet_kerf = 1.5;

d_neck = tubing_od + 2*collet_wall;
d_collet_face = d_neck + 4;
od_collet_clamp = d_neck + 2*collet_clamp_wall;

h_face = 3;
h_neck = 4.4;
h_clamp = 3;
h_assembly_taper = 1.5;

/* [Body Design] */

body_wall = 1;

h_fingernail_gap = 1;
h_collet_retention = 2;
h_clamp_taper = 2;
h_cavity_clearance = 1; 
h_body_exit = 2;
id_tubing_exit = tubing_od + 2;
alpha_body = 1; //[0.25, 1]

h_body_cavity = h_clamp + h_assembly_taper + h_cavity_clearance;
h_body = h_collet_retention + h_clamp_taper + h_body_cavity + h_body_exit; 
d_collet_retention = od_collet_clamp - 2*collet_retention_wall;
od_body = od_collet_clamp + 2 * body_wall;


/* [Clip Design] */
opening_fraction = 0.9;
x_handle_fraction = .9;
clip_wedge_angle = 10; 
z_clip_clearance = 0.55;
y_handle_upright = 2;
y_handle_gap = 0.5;
z_handle_ridge = 2;
    
h_clip = h_neck - h_collet_retention - z_clip_clearance;; // Need to calculate
od_clip = d_collet_face + 1;

module end_of_customization() {}


a_lot = 100;


module quick_connect_collet(tubing_allowance=0) {
    module cutout() {
    }
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
            can(d=tubing_od + collet_entrance_clearance, taper=tubing_od + 2 * tubing_allowance, h=h_face/2); 
            translate([0, 0, h_face+h_clip]) block([collet_kerf, a_lot, a_lot], center=ABOVE);
            translate([0, 0, h_face+h_clip]) block([a_lot, collet_kerf, a_lot], center=ABOVE);
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
                can(d=d_collet_face - 2, taper=od_body, h=h_fingernail_gap, center=ABOVE);
                translate([0, 0, h_fingernail_gap]) can(d=od_body, h=h_body - h_fingernail_gap , center=ABOVE);
            }
            can(d=tubing_od + 2 * tubing_allowance, h=a_lot);
            translate([0, 0, 0]) 
                can(d=d_collet_retention, h=h_collet_retention, center=ABOVE);
            translate([0, 0, h_collet_retention]) 
                can(d=d_collet_retention, taper=od_collet_clamp, h=h_clamp_taper, center=ABOVE);
            translate([0, 0, h_collet_retention+h_clamp_taper]) 
                can(d=od_collet_clamp, h=h_body_cavity, center=ABOVE);
            // Taper at outlet, in case elephant foot interfers with tubing pass through
            translate([0, 0, h_collet_retention+h_clamp_taper + h_body_cavity]) 
                can(d=tubing_od, taper=id_tubing_exit, h=h_body_exit, center=ABOVE);            
            if (show_cross_section) {
                plane_clearance(RIGHT);
            }
        }
    }
    color("blue", alpha=alpha_body) {
        if (orient_for_build) {
             translate([0, 0, h_body]) rotate([180, 0, 180]) shape();
        } else { 
            // For display, the default is in the open position, without clamping on the tube.  
            translate([0, 0, h_face]) shape();
        }
    }
}
 
module c_clip(orient_for_build) {
    // Use a sprue to connect the three small parts, which increased bed adhesion. 
    // The pieces break off the sprue without an issue.
    sprue = [od_clip + 2, 2, 1];
    x_handle = x_handle_fraction * od_clip;
    y_handle = od_clip/2 + y_handle_gap + y_handle_upright;
    z_handle_upright = h_clip + z_handle_ridge;

    module shape() {
        render(convexity=10)  difference() {
            union() {
                can(d=od_clip, h=h_clip, center=ABOVE);
                block([x_handle, y_handle, h_clip], center=ABOVE+LEFT);
                
                translate([0, -y_handle, 0]) block([x_handle, y_handle_upright, z_handle_upright], center=ABOVE+RIGHT);
                block(sprue, center=ABOVE);
            }
            can(d=d_neck, h=a_lot);
            block([opening_fraction*d_neck, a_lot, a_lot], center=RIGHT);
            //rotate([clip_wedge_angle, 0, 0]) translate([0, od_clip/2, h_clip/2] 
            translate([0, 0.25*d_neck, 0]) rotate([-clip_wedge_angle, 0, 0]) translate([0, 0, h_clip]) plane_clearance(RIGHT+ABOVE); 
            if (show_cross_section) {
                plane_clearance(RIGHT);
            }  
        }            
    }
    color("pink", alpha=alpha_body) {
        if (orient_for_build) {
             //translate([0, 0, h_fingernail_gap + h_body]) rotate([180, 0, 0]) 
            shape();
        } else {   
            translate([0, 0, h_face]) shape();
        }
    }    
}
 
if (build_collet) {
    quick_connect_collet(tubing_allowance=tubing_allowance);
 }
 
if (build_body) {
    if (orient_for_build) {
        dx_body = d_collet_face/2 + od_body/2 + od_clip + 1;
        translate([dx_body, 0, 0]) quick_connect_body(orient_for_build=true);
    } else {
        dz = insert_clip ? h_clip : 0;
        translate([0, 0, dz]) quick_connect_body(orient_for_build=false);
    }
}

if (build_c_clip) {
    if (orient_for_build) {
        dx_c_clip = d_collet_face/2 + 0.5 + od_clip/2;
        translate([dx_c_clip, 0, 0]) c_clip(orient_for_build=true);
    } else {
        if (insert_clip) {
            c_clip(orient_for_build=false);
        }
    }        
}
  