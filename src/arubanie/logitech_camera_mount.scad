include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

show_camera = true;
orient_for_build = false;
build_camera_clamp = false;
build_top_hinge_clip = true;
wall = 4;
camera_clearance = 0.4;
clamp_width = 3;  // [5:25]
clamp_arm_x = 37;
clamp_arm_y = 3; 
clamp_arm_z = 5;

top_hinge_clip_x = 15;

module end_of_customization() {}

/* Dimension */ 

camera_back_cutout = [17.97, 46, 4.87];
camera_body = [24.25, 70.16, 26.73];
camera_lens_face = [2.60, 63.4, 28.84];
camera_top_hinge = [58.15, 42.42, 6.5];
camera_top_hinge_upper_front = [5.98, camera_top_hinge.y, camera_back_cutout.z + camera_top_hinge.z];

dy_body_clamp = camera_back_cutout.y/2+2; 

module logitech_c920_camera(show_body = true, show_top_hinge = true, as_clearance = false, camera_clearance=0.2) {
    clearance = as_clearance ? camera_clearance : 0;
    dz_body = (camera_lens_face.z - camera_body.z)/2;
    a_lot = 100;
    module body() {
        difference() {
            hull() {
                translate([0, 0, dz_body]) 
                    intersection() {
                        block([0.1, camera_body.y, camera_body.z] + 2*[clearance, clearance, clearance], center=ABOVE+FRONT);
                        translate([0, 0, camera_body.z/2]) rod(d=camera_body.y, l=a_lot); 
                    }
                translate([camera_body.x, 0, 0])
                    intersection() { 
                        block([0.1, camera_lens_face.y, camera_lens_face.z] + 2*[clearance, clearance, clearance], center=ABOVE+FRONT);
                        translate([0, 0, camera_lens_face.z/2]) rod(d=camera_lens_face.y, l=a_lot); 
                    }
            }
            block(camera_back_cutout, center=ABOVE+FRONT, rank=3);
        }        
    }
    module top_hinge() {
        translate([15.59, 0, -2.880]) {
            block(camera_top_hinge + 2*[clearance, clearance, clearance], center=ABOVE+BEHIND);
            block(camera_top_hinge_upper_front, center=ABOVE+BEHIND);
        }
        
    }
    if (show_body) {
        color("gray") body();
    }
    if (show_top_hinge) {
        color("SlateGray") top_hinge();
    }
    
    
}

if (show_camera && !orient_for_build) {
    logitech_c920_camera();
}

module camera_clamp() {
    // The camer clamp holds the actual camera, and positions it with respect to tilt.
    blank = [camera_body.x + wall, clamp_width, camera_lens_face.z + 2*wall];
    arm = [clamp_arm_x, clamp_arm_y, clamp_arm_z];
    color("red") {
        translate([-clamp_arm_x/sqrt(2) - 4, 0, camera_top_hinge.z + clamp_arm_z/2]) {
            hull() {
                rod(d=8, l=wall, center=SIDEWISE);
                block([8, wall, clamp_arm_z], center=FRONT);
            }
            
    }
        center_reflect([0, 1, 0]) {
            difference() {
                translate([0, dy_body_clamp, 0]) {
                    translate([0, 0, -wall]) block(blank, center=ABOVE+FRONT);
                    translate([0, 0, -wall]) block([wall, blank.y, blank.z], center=ABOVE+BEHIND);
                    translate([0, clamp_width/2+0.5, camera_top_hinge.z]) rotate([0, 0, 45]) block(arm, center=ABOVE+BEHIND+LEFT);
                    
                }
                logitech_c920_camera(as_clearance=true, camera_clearance=camera_clearance);
            }
        }
    }
    
}

module top_hinge_clip(orient_for_build ) {
    // The top hinge clip grabs the top hinge, and provides a fulcrum for 
    // the camera clamp tilt adjustement.
    
    
    module screw_clearance() {
        center_reflect([0, 1, 0]) {
            translate([0, camera_top_hinge.y/2 + 4, 0]) {
                translate([0, 0, 12]) hole_through("M2", h=10, $fn=12);
                translate([0, 0, -2])nutcatch_parallel("M2", clh=3);
            }
        }
    }
    
    module arc_screw_clearance() {
        center_reflect([1, 0, 0]) {
            translate([3, wall + 5, 10]) {
                    translate([0, 0, 10]) hole_through("M2", h=10, $fn=12);
                    translate([0, 0, -4])nutcatch_parallel("M2", clh=5);
            }
        }        
    }
    module top() {
        difference() {
            union() {
                block([top_hinge_clip_x, camera_top_hinge.y + 16, camera_top_hinge.z/2 + 2], center=ABOVE);
                translate([0, 1.5*wall, 0]) block([top_hinge_clip_x, 10, 8], center=RIGHT+ABOVE);
            }
            translate([10, 0, 0]) logitech_c920_camera(as_clearance=false);
            screw_clearance();
            arc_screw_clearance();
            
        }
        
    }
    module bottom() {
        difference() {
            block([top_hinge_clip_x, camera_top_hinge.y + 16, camera_top_hinge.z/2 + 2], center=BELOW);
            translate([10, 0, 0]) logitech_c920_camera(as_clearance=false);
            screw_clearance();
        }
    }
    if (orient_for_build) {
        translate([-20, 0, top_hinge_clip_x/2]) rotate([0, 90, 0]) top();
        translate([-30, 0, top_hinge_clip_x/2]) rotate([0, 90, 0]) bottom();
    } else {
        translate([-clamp_arm_x/sqrt(2) - 4, 0, 0]) {
            color("green") top();
            
            color("orange") bottom();
        }
    }
}

if (build_camera_clamp) {
    if (orient_for_build) {
         rotate([0, 90, 0]) translate([-(camera_body.x + wall), 0, 0])camera_clamp();
    } else {
        camera_clamp();
    }
}

if (build_top_hinge_clip) {
    top_hinge_clip(orient_for_build=orient_for_build);
}
