include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

show_camera = true;
build_body_clamp = false;
wall = 4;
clamp_width = 2;  // [5:25]
clamp_arm_x = 40;
clamp_arm_y = 2; 
clamp_arm_z = 5;
module end_of_customization() {}

/* Dimension */ 

camera_back_cutout = [17.97, 46, 4.87];
camera_body = [24.25, 70.16, 26.73];
camera_lens_face = [2.60, 63.4, 28.84];
camera_top_hinge = [58.15, 42.42, 6.5];
camera_top_hinge_upper_front = [5.98, camera_top_hinge.y, camera_back_cutout.z + camera_top_hinge.z];


module logitech_c920_camera(show_body = true, show_top_hinge = true, as_clearance = false) {
    clearance = as_clearance ? 0.2 : 0;
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
        body();
    }
    if (show_top_hinge) {
        top_hinge();
    }
    
    
}

if (show_camera) {
    logitech_c920_camera();
}

module body_clamp() {
    blank = [camera_back_cutout.x-3, clamp_width, camera_body.z + wall];
    top_clamp = [camera_body.x + 2, blank.y, wall+1];
    arm = [clamp_arm_x, clamp_arm_y, clamp_arm_z];
    color("red") {   
        difference() {
            union() {
                block(blank, center=ABOVE+FRONT);
                block([wall, blank.y, blank.z], center=ABOVE+BEHIND);
                translate([0, 0, blank.z]) block(top_clamp, center=BELOW+FRONT);
                translate([0, clamp_width/2, camera_top_hinge.z]) block(arm, center=ABOVE+BEHIND+LEFT);
            }
            logitech_c920_camera(as_clearance=true);
        }
    }
    
}

if (build_body_clamp) {
    body_clamp();
}
