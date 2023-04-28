include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>
include <MCAD/stepper.scad>
use <NopSCADlib/vitamins/rod.scad>

orient_for_build = false;

build_cam = true;
build_servo_mount = true;
build_mounting_plate_spacers = true;
build_servo_gear = true;

cam_alpha = 1; // [0.25, 1]

show_mocks = true;
show_z_axis_support = true;
show_servo = true;

cam_min_diameter = 10.5;
cam_offset = 3;

z_servo_plate = 0.5; //[0.5:"Position test", 1:"Trial", 2:"Solid"]

servo_clearance = 0; //[0: "Futaba S3003", 0:"Radio Shack 2730766"]

x_servo = 18; // [0: 40]
y_servo = 4; // [-20: 20]
z_servo = -23; // [-40: 0]


module end_of_customization() {}

z_z_axis_support = 2.56;
plate_behind_right = [6.3, 34, z_z_axis_support];
plate_front_edge = [23, 0.1, z_z_axis_support];
plate_behind_left = [6.3-1, 16, z_z_axis_support];

bottom_of_plate_to_top_of_spring_arm = 17.59;
spring_arm = [10, 50, 10.53];
M4_nut_thickness = 3.2;
M4_washer_thickness = 0.5;

servo_mount_blank = [25, 48, z_servo_plate];
dy_servo_mount = 33 - servo_mount_blank.y;
servo_mount_translation = [-5, dy_servo_mount, -z_z_axis_support];


servo_blank = [20.1, 39.9, 36.1]; //[18.8, 38.6, 34.9];
servo_rotation = 155; 
servo_translation = [x_servo, y_servo, z_servo];
dz_top_of_servo_ears = z_servo + 11;
echo("dz_top_of_servo_ears", dz_top_of_servo_ears);



dz_spring_arm = bottom_of_plate_to_top_of_spring_arm - z_z_axis_support;
dz_cam = bottom_of_plate_to_top_of_spring_arm - spring_arm.z - z_z_axis_support + 2;  
echo("dz_cam", dz_cam);

h_cam = bottom_of_plate_to_top_of_spring_arm - z_z_axis_support - dz_cam;

module z_axis_support() {
    color("Gray", alpha=1) 
        hull() { 
            block(plate_behind_right, center = BELOW+BEHIND+RIGHT);
            translate([0, plate_behind_right.y, 0]) 
                block(plate_front_edge, center = BELOW+FRONT+RIGHT);
            translate([plate_behind_left.x-plate_behind_right.x, 0, 0]) 
                block(plate_behind_left, center=BELOW+BEHIND+LEFT);     
        } 
}



module spring_arm() {
    color("brown") translate([-cam_min_diameter/2, 8, dz_spring_arm]) block(spring_arm, center=BELOW+BEHIND);
}

module extruder_base() {
    color("chocolate") 
        translate([-cam_min_diameter/2, -16, 0]) 
            block([42, 42, dz_spring_arm-spring_arm.z], center=ABOVE+BEHIND+RIGHT);
}

module stepper() {
    translate([-21-6, 5, 0]) 
        rotate([180, 0, 0]) 
            motor(Nema17, NemaMedium, dualAxis=false);
}


module servo(as_clearance = false, clearance = 0) {
    a_lot = 100;
    translate(servo_translation) rotate([0, 0, servo_rotation]) {
        if ( as_clearance) {
            block(servo_blank + 2*[clearance, clearance, clearance]); 
            translate([0, 10, 0]) can(d=10 + 2*clearance, h=a_lot);     
        } else {
            translate(-servo_blank/2) futabas3003(position=[0,0,0], rotation=[0, 0, 0]);
        }
    }
}

module z_axis_threaded_rod() {
    starts = 4;
    pitch = 2;
    translate([(7.9+4.7)/2, (23.2+11.4)/2, 0]) leadscrew(d=8 , l=50, lead=starts * pitch, starts=starts, center = true);  
    
}



if (show_mocks && !orient_for_build) {
    servo_mount_screws(as_clearance=false);
    if (show_z_axis_support) {
        z_axis_support();
    }
    z_axis_threaded_rod();
    spring_arm();
    extruder_base();
    if (show_servo) {
        servo(as_clearance=false);
    }
    stepper();
    
}


module servo_screws(as_clearance=false, as_spacers=false, orient_for_build=false) {
    module item() {
        if (as_clearance) {
            translate([0, 0, 25]) hole_through("M2.5", $fn=12);
        } else if (as_spacers) {
            h_spacer = - z_z_axis_support - z_servo_plate -dz_top_of_servo_ears;
            z_spacer = orient_for_build ? -servo_translation.z : 11;
            echo("z_spacer: ", z_spacer); 
            color("blue") {
                translate([0, 0, z_spacer]) {
                    difference() {
                        can(d=5, h=h_spacer, center=ABOVE);
                        translate([0, 0, 25]) hole_through("M2.5", cld=0.4, $fn=12);
                    }
                }
            }
        }
    }
    translate(servo_translation) rotate([0, 0, servo_rotation]) {         
        translate([0.25 * servo_blank.x, 0.615 * servo_blank.y, 0]) item();
        translate([0.25 * servo_blank.x, -0.615 * servo_blank.y, 0]) item();
        translate([-0.25 * servo_blank.x, 0.615 * servo_blank.y, 0]) item();
        translate([-0.25 * servo_blank.x, -0.615 * servo_blank.y, 0]) item();        
        
    }
    
}



module servo_mount_screws(as_clearance=false) {
    if (as_clearance) {
        translate([0, 0, -100-z_z_axis_support-z_servo_plate]) // -z_z_axis_support-z_servo_plate])  
            rotate([180, 0, 0]) 
                hole_through("M4", h=100, $fn=12);
        translate([13, 26, -100-z_z_axis_support-z_servo_plate]) 
            rotate([180, 0, 0]) 
                hole_through("M3", h=100, $fn=12);
        //translate([0, 0, 20+M4_nut_thickness]) hole_through("M4", cld=0.6, $fn=12);
        // Need space fo nut and washer to rotate
        can(d=9.2, h=dz_cam, center=ABOVE);        
    } else {
        color("silver") {
            translate([13, 26, 0]) screw("M3x6", $fn=12);
            translate([13, 26, -4]) nut("M3");
            
            translate([0, 0, -z_z_axis_support]) 
                rotate([180, 0, 0]) screw("M4x20", $fn=12);
            rotate([180, 0, 0]) nut("M4");
            translate([0, 0, M4_nut_thickness]) 
                rotate([180, 0, 15]) nut("M4"); 
        }    
    }
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
                
                translate([servo_translation.x, servo_translation.y, servo_mount_translation.z]) { 
                    rotate([0, 0, servo_rotation]) {
                        block([servo_blank.x, servo_blank.y, 2*z_servo_plate]+[0, 15, 0]);
                    }
                }
                //translate([0, 0, -dz_top_of_servo_ears-z_z_axis_support-z_servo_plate]) 
                //    mounting_plate();     
            }

            translate([9.5, 5, 0]) block([a_lot, a_lot, a_lot], center=RIGHT+BEHIND); 
            z_axis_support(); 
            translate([-plate_behind_right.x, 0, 0]) plane_clearance(BEHIND);
            servo_screws(as_clearance=true);
            servo_mount_screws(as_clearance=true);
            //servo(as_clearance=true, clearance = 1); 
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
            rotate([0, 0, 58]) plane_clearance(BEHIND);
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
            servo_mount_screws(as_clearance=true);
        }
    }   
}

module servo_gear(orient_for_build=false) {
    module gear_form() {
        import("resource/servo_gear_form.stl");
    }
    if (orient_for_build) {
        gear_form();
    } else {
        translate([x_servo, y_servo, 0]) 
            rotate([0, 0, servo_rotation]) 
                translate([0, 11, 0]) gear_form();
    }
    
    
}

if (build_servo_gear) {
    if (orient_for_build) {
       translate([-15, -30, 0]) servo_gear(orient_for_build=true); 
    } else {
       servo_gear(orient_for_build=false);
    }
}


if (build_cam) {
    if (orient_for_build) {
        translate([0, -30, -1]) cam();
    } else {
        cam();
    }
}

if (build_servo_mount) {
    if (orient_for_build) {
        translate([40,0, z_z_axis_support + z_servo_plate]) servo_mount();
    } else {
        servo_mount();
    }
}

//if (build_mounting_plate) {
//    if (orient_for_build) { 
//        translate([-7, 20, -dz_top_of_servo_ears]) mounting_plate();
//    } else {
//        mounting_plate();
//    }
//}

if (build_mounting_plate_spacers) {
    if (orient_for_build) { 
        translate([-12, 10, 0]) servo_screws(as_spacers=true, orient_for_build=true);
    } else {
        servo_screws(as_spacers=true);
    }
}


