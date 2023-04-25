include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>



show_mocks = true;

cam_min_diameter = 11;
cam_offset = 3;

module end_of_customization() {}

plate = [20, 20, 2.56];
bottom_of_plate_to_top_of_spring_arm = 17.59;
spring_arm = [10, 50, 10.53];
M4_nut_thickness = 3.2;
M4_washer_thickness = 0.5;

dz_cam = 2 * M4_nut_thickness + M4_washer_thickness;
dz_spring_arm = bottom_of_plate_to_top_of_spring_arm - plate.z;

h_cam = bottom_of_plate_to_top_of_spring_arm - plate.z - 2 * M4_nut_thickness - M4_washer_thickness;

module plate() {
    color("Black", alpha=.25) block(plate, center=BELOW);  
}

module screw_post(as_clearance=false) {
    if (as_clearance) {
        translate([0, 0, 20]) hole_through("M4", cld=0.6, $fn=12); 
    } else {
        color("silver") {
            translate([0, 0, -plate.z]) rotate([180, 0, 0]) screw("M4x20", $fn=12);
            rotate([180, 0, 0]) nut("M4");
            translate([0, 0, M4_nut_thickness]) rotate([180, 0, 15]) nut("M4");
        }
    }
}

module spring_arm() {
    color("brown") translate([-cam_min_diameter/2, 0, dz_spring_arm]) block(spring_arm, center=BELOW+BEHIND);
    
}

if (show_mocks) {
    screw_post();
    plate();
    spring_arm();
    futabas3003(position=[-10, 30, 65], rotation=[180, 0, 0]);
    
}

module cam_handle_screw_clearance() {
   translate([5, -cam_offset-1, h_cam/2]) rotate([0, -90, 0]) {
       nutcatch_sidecut("M3", clh=0.4);
       translate([0, 0, 8]) hole_through("M3", $fn=12);
   }
}


module cam() {
    chamfer = 0;
    module chamfered_can() {
        translate([0, 0, chamfer]) {
            can(d=cam_min_diameter, h=h_cam-chamfer, center=ABOVE);
            can(d=cam_min_diameter-chamfer, h=chamfer, center=BELOW);
        }
    }
    module cam_shape() {
        hull() {
            translate([0, +4, 0])chamfered_can();
            translate([2, +4, 0])chamfered_can();
            translate([0, -cam_offset, 0]) chamfered_can();
            translate([1.5*cam_offset, -cam_offset, 0]) chamfered_can();
        }        
    }
    
    module servo_adapter() {
        can(d=9, h=6, center=ABOVE);
        render(convexity=10) difference() {
            import("resource/cam_gear_form.stl");
            rotate([0, 0, 45]) plane_clearance(BEHIND+RIGHT);
            #rotate([0, 0, 75]) plane_clearance(BEHIND+RIGHT);
        }
          
    }
    
    //color("green") translate([0, 0, dz_cam]) cam_handle_screw_clearance();
    color("red", alpha=1) {
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

cam();