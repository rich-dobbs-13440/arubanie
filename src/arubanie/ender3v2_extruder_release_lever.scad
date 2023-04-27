include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>
include <MCAD/stepper.scad>

build_cam = true;
build_servo_mount = true;
build_mounting_plate = true;
orient_for_build = false;

cam_alpha = 0.25; // [0.25, 1]

show_mocks = true;
show_plate = true;
show_servo = true;

cam_min_diameter = 11;
cam_offset = 3;

z_servo_plate = 0.5; //[0.5:"Position test", 1:"Trial", 2:"Solid"]

x_servo = 22; // [0: 40]
y_servo = 2; // [-20: 20]
z_servo = -23; // [-40: 0]

module end_of_customization() {}

z_plate = 2.56;
plate_behind_right = [6.3, 34, z_plate];
plate_front_edge = [23, 0.1, z_plate];
plate_behind_left = [6.3-1, 16, z_plate];

bottom_of_plate_to_top_of_spring_arm = 17.59;
spring_arm = [10, 50, 10.53];
M4_nut_thickness = 3.2;
M4_washer_thickness = 0.5;

servo_mount_blank = [36, 52, z_servo_plate];
dy_servo_mount = 33 - servo_mount_blank.y;
servo_mount_translation = [-5, dy_servo_mount, -z_plate];

servo_blank = [20.1, 39.9, 36.1]; //[18.8, 38.6, 34.9];
servo_rotation = 155; 
servo_translation = [x_servo, y_servo, z_servo];
z_top_of_servo_ears = z_servo + 11;



dz_spring_arm = bottom_of_plate_to_top_of_spring_arm - z_plate;
dz_cam = bottom_of_plate_to_top_of_spring_arm - spring_arm.z - z_plate + 2;  

h_cam = bottom_of_plate_to_top_of_spring_arm - z_plate - dz_cam;

module plate() {
    color("Gray", alpha=1) 
        hull() { 
            block(plate_behind_right, center = BELOW+BEHIND+RIGHT);
            translate([0, plate_behind_right.y, 0]) 
                block(plate_front_edge, center = BELOW+FRONT+RIGHT);
            translate([plate_behind_left.x-plate_behind_right.x, 0, 0]) 
                block(plate_behind_left, center=BELOW+BEHIND+LEFT);     
        } 
}

module screw_post(as_clearance=false) {
    if (as_clearance) {
        translate([0, 0, 20]) hole_through("M4", cld=0.6, $fn=12);
        // Need space fo nut and washer to rotate
        can(d=9.2, h=dz_cam, center=BELOW);
    } else {
        color("silver") {
            translate([0, 0, -z_plate]) rotate([180, 0, 0]) screw("M4x20", $fn=12);
            rotate([180, 0, 0]) nut("M4");
            translate([0, 0, M4_nut_thickness]) rotate([180, 0, 15]) nut("M4");
        }
    }
}

module spring_arm() {
    color("brown") translate([-cam_min_diameter/2, 0, dz_spring_arm]) block(spring_arm, center=BELOW+BEHIND);
    
}

module servo(as_clearance = false, clearance = 0) {
    a_lot = 100;
    translate(servo_translation) rotate([0, 0, servo_rotation]) {
        if ( as_clearance) {
            block(servo_blank + 2*[clearance, clearance, clearance]); 
            translate([0, 10, 0]) can(d=12 + 2*clearance, h=a_lot);     
        } else {
            translate(-servo_blank/2) futabas3003(position=[0,0,0], rotation=[0, 0, 0]);
        }
    }
}

module stepper() {
    translate([-21-6, 5, 0]) 
        rotate([180, 0, 0]) 
            motor(Nema17, NemaMedium, dualAxis=false);
}

if (show_mocks && ! orient_for_build) {
    screw_post();
    translate([13, 26, 0]) screw("M3x6", $fn=12);
    translate([13, 26, -4]) nut("M3");
    if (show_plate) {
        plate();
    }
    spring_arm();
    if (show_servo) {
        servo(as_clearance=false);
    }
    stepper();
    
}

module mounting_plate_screws(as_clearance=false) {
    module corner_item() {
        if (as_clearance) {
            translate([0, 0, 25]) hole_through("M2.5", $fn=12);
        }
    }
    module mount_item() {
        if (as_clearance) {
            translate([0, 0, 25]) hole_through("M2.5", $fn=12);
        }        
    }
    translate(servo_translation) rotate([0, 0, servo_rotation]) { 
        translate([0.55 * servo_blank.x, 0.615 * servo_blank.y, 0]) corner_item();
        translate([0.55 * servo_blank.x, -0.615 * servo_blank.y, 0]) corner_item();
        translate([-0.6 * servo_blank.x, 0.615 * servo_blank.y, 0]) corner_item();
        translate([-0.6 * servo_blank.x, -0.615 * servo_blank.y, 0]) corner_item();
        
        translate([0.25 * servo_blank.x, 0.615 * servo_blank.y, 0]) mount_item();
        translate([0.25 * servo_blank.x, -0.615 * servo_blank.y, 0]) mount_item();
        translate([-0.25 * servo_blank.x, 0.615 * servo_blank.y, 0]) mount_item();
        translate([0.25 * servo_blank.x, 0.615 * servo_blank.y, 0]) mount_item();        
        
    }
    
}

//mounting_plate_screws(as_clearance=true);

module mounting_plate() {
    color("orange") {
        difference() {
            servo(as_clearance=true, clearance = 10);
            servo(as_clearance=true, clearance = 1);
            translate([0, 0, z_top_of_servo_ears+2]) plane_clearance(ABOVE);
            translate([0, 0, z_top_of_servo_ears]) plane_clearance(BELOW);
            translate([servo_mount_translation.x, 0, 0]) plane_clearance(BEHIND);
            translate([0, servo_mount_translation.y+servo_mount_blank.y, 0]) plane_clearance(RIGHT);
            mounting_plate_screws(as_clearance=true);
            
        }
    }
}

if (build_mounting_plate) {
    mounting_plate();
}

module servo_mount() {
    a_lot = 100;
    color("pink"){
        render(convexity=10) difference() {
            union() {
                translate(servo_mount_translation) 
                    block(servo_mount_blank, center=BELOW+FRONT+RIGHT);
                translate(servo_mount_translation + [0, 0, z_servo_plate]) 
                    block(servo_mount_blank, center=BELOW+FRONT+RIGHT);
                translate([0, 0, -z_top_of_servo_ears-z_plate-z_servo_plate]) 
                    mounting_plate();     
            }
            translate([0, 0, 10]) hole_through("M4", $fn=12);
            translate([13, 26, 10]) hole_through("M3", $fn=12);
            translate([9.5, 5, 0]) block([a_lot, a_lot, a_lot], center=RIGHT+BEHIND); 
            plate(); 
            translate([-plate_behind_right.x, 0, 0]) plane_clearance(BEHIND);
            mounting_plate_screws(as_clearance=true);
            servo(as_clearance=true, clearance = 1); 
        }  
    } 
}

module cam_handle_screw_clearance() {
   translate([3, -cam_offset-1, h_cam/2]) rotate([0, -90, 0]) {
       nutcatch_sidecut("M3", clh=0.4);
       translate([0, 0, 6]) hole_through("M3", $fn=12);
   }
}


module cam() { 
    module chamfered_can(chamfer_bottom=true) {
        chamfer = 2;
        hull() {
            if (chamfer_bottom) {
                translate([0, 0, chamfer]) {
                    can(d=cam_min_diameter, h=h_cam, center=ABOVE);
                    can(d=cam_min_diameter-chamfer, h=chamfer, center=BELOW);
                }
            } else {
                translate([0, 0, h_cam]) {
                    can(d=cam_min_diameter, h=h_cam, center=BELOW);
                    can(d=cam_min_diameter-chamfer, h=chamfer, center=ABOVE);
                }
                
            }
        }
    }
    module cam_shape() {
        hull() {
            translate([0, +4, 0])chamfered_can(chamfer_bottom=false);
            translate([2, +4, 0])chamfered_can(chamfer_bottom=false);
            translate([0, -cam_offset, 0]) chamfered_can(chamfer_bottom=false);
            translate([1.5*cam_offset, -cam_offset, 0]) chamfered_can(chamfer_bottom=false);
        }        
    }
    
    module servo_adapter() {
        can(d=cam_min_diameter, h=6, center=ABOVE);
        render(convexity=10) difference() {
            import("resource/cam_gear_form.stl");
            rotate([0, 0, 45]) plane_clearance(BEHIND+RIGHT);
            rotate([0, 0, 75]) plane_clearance(BEHIND+RIGHT);
        }
          
    }
    
    //color("green") translate([0, 0, dz_cam]) cam_handle_screw_clearance();
    color("red", alpha=cam_alpha) {
        render(convexity=10) difference() {
            union() {
                translate([0, 0, dz_cam]) cam_shape();
                translate([0, 0, 1])servo_adapter();
            }
            translate([0, 0, dz_cam]) cam_handle_screw_clearance();
            translate([0, 0, dz_cam]) screw_post(as_clearance=true);
        }
    }   
}

if (build_cam) {
    cam();
}

if (build_servo_mount) {
    if (orient_for_build) {
        translate([50,0, z_plate + z_servo_plate]) servo_mount();
    } else {
        servo_mount();
    }
}