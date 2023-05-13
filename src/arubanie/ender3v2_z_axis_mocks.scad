include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/stepper.scad>
use <NopSCADlib/vitamins/rod.scad>



show_mocks = true;
show_modified_z_axis = true;
build_drill_guide = false;

module end_of_customization() {}

z_z_axis_support = 2.56;
plate_behind_right = [6.3, 34, z_z_axis_support];
plate_front_edge = [23, 0.1, z_z_axis_support];
plate_behind_left = [6.3-1, 16, z_z_axis_support];

bottom_of_plate_to_top_of_spring_arm = 17.59;
z_spring_arm = 10.53;
spring_arm_end_diameter = 11.76;
spring_arm_end = [12.55-spring_arm_end_diameter/2, spring_arm_end_diameter, z_spring_arm];

z_axis_translation = [(7.9+4.7)/2-2.5, (23.2+11.4)/2+2, 0];
z_axis_bearing_extent = [8, 24, 5];
od_z_axis_bearing = 11;

dz_spring_arm = bottom_of_plate_to_top_of_spring_arm - z_z_axis_support;

z_axis_tapped_screw_translation = [13, 26, 0];

z_extruder_base = dz_spring_arm - z_spring_arm;
dx_extruder_base = 5;


M4_nut_thickness = 3.2;
M4_washer_thickness = 0.5;

stepper_translation = [-21-6, 5, 0];
idler_translation = [-24, 20, 0];

BRONZE = "#b08d57";
STAINLESS_STEEL = "#CFD4D9";
BLACK_IRON = "#3a3c3e";

module z_axis_support() {
    color("Gray", alpha=1) {
        hull() { 
            block(plate_behind_right, center = BELOW+BEHIND+RIGHT);
            translate([0, plate_behind_right.y, 0]) 
                block(plate_front_edge, center = BELOW+FRONT+RIGHT);
            translate([plate_behind_left.x-plate_behind_right.x, 0, 0]) 
                block(plate_behind_left, center=BELOW+BEHIND+LEFT);     
        } 
    }
}


module spring_arm(as_clearance=false, clearance=0.2) {    
    effective_clearance = as_clearance ? clearance : 0;
    y_end = 24 + spring_arm_end_diameter/2;
    
    module profile(x, dx, dy) {
        translate([-dx, y_end-dy, 0]) 
            block([x, 0.1, z_spring_arm] + [2*clearance, 0, clearance], center=BEHIND+ABOVE); 
    }
    module shape() {
        hull() {
            translate([0, y_end, 0]) 
                        can(d = spring_arm_end_diameter + 2 * effective_clearance, h = z_spring_arm, center=BEHIND+ABOVE+LEFT);
            profile(spring_arm_end.x, spring_arm_end_diameter/2, 0);
            profile(12.71, 0, 10.33);
        }
        hull() {
            profile(12.71, 0, 10.33);
            profile(13.66, 0, 13.22);
            profile(13.66, 0, 16.69);
            profile(8.91, 0, 22.58);
        }
        hull() {
            profile(8.91, 0, 22.58);
            profile(8.91, 0, 31.87);
        }
        hull() {
            profile(8.91, 0, 31.87);
            profile(8.24, 2.45, 34.18);
            profile(8.24, 2.45, 41.92);
        }
        hull() {
            profile(8.24, 2.45, 41.92); 
            profile(8.24, 2.45, 49.70);
            translate([-8.24-2.45, y_end-49.70, z_spring_arm/2]) rotate([0, 90, 0]) cylinder(d=z_spring_arm, h=8.24);
            
        }
    }
    color("brown") 
        translate([-dx_extruder_base+1 + effective_clearance, 0, z_extruder_base]) 
            shape();
}




module extruder_base() {
    color("chocolate") 
        translate([-dx_extruder_base, -16, 0]) 
            block([42, 42, z_extruder_base], center=ABOVE+BEHIND+RIGHT);
}


module stepper() {
    
    translate(stepper_translation) 
        rotate([180, 0, 0]) 
            motor(Nema17, NemaMedium, dualAxis=false);
}


module z_axis_threaded_rod(as_clearance=false, clearance=0.2) {
    translate(z_axis_translation) { 
        if (as_clearance) {
            can(d=8 + 2*clearance, h=50);
        } else {
            starts = 4;
            pitch = 2;
            leadscrew(d=8 , l=50, lead=starts * pitch, starts=starts, center = true);  
        }
    }  
}


module z_axis_bearing(as_clearance=false, clearance=0.2) {
    module screw_item() {
        if (as_clearance) {
            translate([0, 0, 4]) hole_through("M3", h=5); 
        } else {
            screw("M3x12");
        }
    }
    module screws() {
        color(STAINLESS_STEEL) {
            translate([0, 0, z_z_axis_support]) 
                center_reflect([0, 1, 0]) 
                    translate([0, 9, 0]) 
                        screw_item(); 
        }        
    }
    translate(z_axis_translation + [0, 0, -z_z_axis_support]) {
        color(BRONZE) {
            intersection() {
                block(z_axis_bearing_extent, center=BELOW);
                can(d=z_axis_bearing_extent.y, h=4, center=BELOW, $fn=36);
            }
            if (as_clearance) {
                hull() {
                    d = 11 + 2 * clearance;
                    can(d=d, h=3.5, center=ABOVE);
                    translate([0, 15, 0]) can(d=d, h=3.5, center=ABOVE);
                }
            } else {
                can(d=11, h=3.5, center=ABOVE);
            }
        }
        if (as_clearance) {
            hull() screws();
        } else {
            screws();
        }

    }
}


module servo_mount_screws(as_clearance=false, as_pilot_holes=false, screw_length=20) {
    
    if (as_clearance) {
        translate([0, 0, -100 -z_z_axis_support-z_servo_plate])  
            rotate([180, 0, 0]) 
                hole_through("M4", h=100, $fn=12);
        translate(z_axis_tapped_screw_translation + [0, 0, -100-z_z_axis_support-z_servo_plate]) 
            rotate([180, 0, 0]) 
                hole_through("M3", h=100, $fn=12);
        //translate([0, 0, 20+M4_nut_thickness]) hole_through("M4", cld=0.6, $fn=12);
        // Need space fo nut and washer to rotate
        can(d=9.2, h=dz_cam, center=ABOVE); 
    } else if (as_pilot_holes) {
        translate([0, 0, 25]) hole_through("M3", $fn=12);
        translate(z_axis_tapped_screw_translation + [0, 0, 25]) hole_through("M2.5",$fn=12); 
    } else {
        color("silver") {
            screw_name = str("M3x", screw_length); 
            translate(z_axis_tapped_screw_translation) screw(screw_name, $fn=12);
            translate(z_axis_tapped_screw_translation + [0, 0, -4]) nut("M3");
            translate([0, 0, -z_z_axis_support]) 
                rotate([180, 0, 0]) screw("M4x20", $fn=12);
            rotate([180, 0, 0]) nut("M4");
            translate([0, 0, M4_nut_thickness]) 
                rotate([180, 0, 15]) nut("M4"); 
        }    
    }
}


module drill_guide(orient_for_build=false) {
    z_drill_guide = 2;
    difference() {
        translate([-5, -5, 0]) 
            block([21, 35, z_drill_guide], center=ABOVE+FRONT+RIGHT);
        z_axis_threaded_rod(as_clearance = true);
        z_axis_bearing(as_clearance = true);
        servo_mount_screws(as_pilot_holes=true);
    }  
    
}


if (show_mocks) {
    z_axis_support();
    z_axis_threaded_rod();
    z_axis_bearing();
    spring_arm();
    extruder_base();
    stepper();    
}

if (show_modified_z_axis) {
    servo_mount_screws(as_clearance=false);
}

if (build_drill_guide) {
    drill_guide();    
}

