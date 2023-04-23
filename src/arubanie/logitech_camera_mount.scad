include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

show_camera = true;
show_camera_body = true;
orient_for_build = false;
test_fit = false;


build_camera_clamp = true;
build_top_hinge_clip = true;
build_tilt_arc_plate = true;
build_clamp_arm = true;
build_back_plate = true;

camera_tilt = 32; // [-15: 32]
wall = 4;
camera_clearance = 0.4;
clamp_width = 3;  // [5:25]
clamp_arm_x = 15;
clamp_arm_y = 3; 
clamp_arm_z = 5;

back_plate_z = 20;
top_hinge_clip_x = 8;

module end_of_customization() {}

/* Dimension */ 

camera_back_cutout = [17.97, 46, 4.87];
camera_body = [24.25, 70.16, 26.73];
camera_lens_face = [2.60, 63.4, 28.84];
camera_top_hinge = [58.15, 42.42, 6.5];
camera_top_hinge_upper_front = [5.98, camera_top_hinge.y, camera_back_cutout.z + camera_top_hinge.z];
tilt_forward = -32;
tilt_back = 15;

dy_body_clamp = camera_back_cutout.y/2+2; 

module logitech_c920_camera(show_body = true, show_top_hinge = true, camera_tilt = 0, as_clearance = false, camera_clearance=0.2) {
    clearance = as_clearance ? camera_clearance : 0;
    dz_body = (camera_lens_face.z - camera_body.z)/2;
    camera_tilt_center_of_rotation = [-5, 0, 0];
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
    if (as_clearance) {
        body();
        top_hinge();
    } else {
        if (show_body) {
            color("gray") translate(-camera_tilt_center_of_rotation) rotate([0, camera_tilt, 0]) translate(camera_tilt_center_of_rotation) body();
        }
        if (show_top_hinge) {
            color("SlateGray") top_hinge();
        }
    }
    
    
}

if (show_camera && !orient_for_build) {
    logitech_c920_camera(show_body = show_camera_body, camera_tilt = camera_tilt);
}


module camera_clamp_screw_clearance() {
    translate([0, 0, back_plate_z]) {
        center_reflect([0, 0, 1]) {
            translate([-2.5, -8, 3]) rotate([90, 0, 0]) hole_through("M2", $fn=12);
            translate([-2.5, -4, 3]) rotate([90, 180, 0]) nutcatch_sidecut("M2");
        } 
    }   
}


module camera_clamp() {
    blank = [camera_body.x + wall, clamp_width, camera_lens_face.z + 2*wall];
    difference() {
        translate([0, 0, -wall])  {
            block(blank, center=ABOVE+FRONT);
            block([5, blank.y, blank.z], center=ABOVE+BEHIND);
        }  
        translate([0, dy_body_clamp, 0]) 
            logitech_c920_camera(as_clearance=true, camera_clearance=camera_clearance);
        camera_clamp_screw_clearance();
    }  
}



module back_plate_to_clamp_arm_screw_clearance() {
    translate([0, 0, back_plate_z]) {
        center_reflect([0, 1, 0]) {
            center_reflect([0, 0, 1]) {
                translate([5, 5, 3]) {
                    rotate([0, 90, 0]) {
                        translate([0, 0, 0])nutcatch_parallel("M2", clh=5);
                        hole_through("M2", $fn=12);
                    }
                }
            }
        }
    }
}

module back_plate() {
    difference() {    
        translate([0, 0, back_plate_z]) block([5, 2 * dy_body_clamp - clamp_width, 15], center=BEHIND);
        //translate([-2, 0, back_plate_z]) block([5, 2 * dy_body_clamp - clamp_width-8, 20], center=BEHIND);
        center_reflect([0, 1, 0]) translate([0, dy_body_clamp, 0]) camera_clamp_screw_clearance();
        back_plate_to_clamp_arm_screw_clearance();
    }
    
    
}

module clamp_arm() {
    translate([-clamp_arm_x, 0, back_plate_z]) {
        difference() {       
            hull() {
                rod(d=8, l=wall, center=SIDEWISE);
                translate([10, 0, 0]) block([0.1, wall, 15], center=FRONT);
            }
            translate([0, -25, 0]) rotate([90, 0, 0]) hole_through("M3", cld=0.4, $fn=12);  
        }
        
    }
    difference() { 
        translate([-5, 0, back_plate_z]) block([2, 15, 15], center=BEHIND);
        back_plate_to_clamp_arm_screw_clearance();
    }
}

if (build_clamp_arm) {
    clamp_arm();
}


module camera_clamp_assembly() {
    // The camer clamp holds the actual camera, and positions it with respect to tilt.
    
    arm = [clamp_arm_x, clamp_arm_y, clamp_arm_z];
    

    color("red") {
        translate([-clamp_arm_x/sqrt(2) - 4, 0, camera_top_hinge.z + clamp_arm_z/2]) {

        }
        center_reflect([0, 1, 0]) {
            
        }
        translate([-1, 0, camera_lens_face.z/2]) {
            center_reflect([0, 0, 1]) translate([0, 0, clamp_arm_z/2]) block([0.5, 2*dy_body_clamp, 0.5], center=FRONT);
            block([wall, 2*dy_body_clamp, clamp_arm_z], center=BEHIND);
            clamp_arm();
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
    

    module top() {
        dz_pivot = 9;
        difference() {       
            hull() {
                translate([0, 0, dz_pivot]) rod(d=8, l=wall, center=SIDEWISE);
                translate([0, 0, 4]) block([8, wall, 0.01]);
            }
            translate([0, -25, dz_pivot]) rotate([90, 0, 0]) hole_through("M3", cld=0.4, $fn=12);  
        }
        
        difference() {
            block([top_hinge_clip_x, camera_top_hinge.y + 16, camera_top_hinge.z/2 + 2], center=ABOVE);
                //translate([0, 1.5*wall, 0]) block([top_hinge_clip_x, 10, 8], center=RIGHT+ABOVE);
            translate([10, 0, 0]) logitech_c920_camera(as_clearance=false);
            screw_clearance();
            //arc_screw_clearance();
            
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

module tilt_arc_plate() {
}

if (build_camera_clamp) {
    if (orient_for_build) {
        
        count = test_fit ? 1 : 2;
        for (i = [0:count-1]) {
            translate([i * 50, 0, clamp_width/2]) rotate([90, 0, 0]) camera_clamp();
        }
        translate([0, 30, 5]) rotate([0, -90, 0]) back_plate();
        
    } else {
        center_reflect([0, 1, 0]) translate([0, dy_body_clamp, 0]) camera_clamp();
        if (build_back_plate) {
            back_plate();
        }
    }
}

if (build_top_hinge_clip) {
    top_hinge_clip(orient_for_build=orient_for_build);
}

if (build_tilt_arc_plate) {
    tilt_arc_plate();
}
