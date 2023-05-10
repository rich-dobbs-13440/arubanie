include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>
include <MCAD/stepper.scad>
use <NopSCADlib/vitamins/rod.scad>
use <lib/ptfe_tubing.scad>

/* [Output Control] */
orient_for_build = false;


build_filament_guide_faceplate = true;
build_filament_guide = true;
build_filament_clip = true;
build_cam = true;
build_servo_mount = true;
build_mounting_plate_spacers = true;
build_servo_gear = true;
build_drill_guide = true;
build_test_fit_servo = true;

show_mocks = true;
show_z_axis_support = true;
show_servo = true;

cam_alpha = 1; // [0.25, 1]

/* [Servo Design and Chararacteristics] */

servo_clearance = 0; //[0: "Futaba S3003", 0:"Radio Shack 2730766"]

x_servo = 18; // [0: 40]
y_servo = 4; // [-20: 20]
z_servo = -24; // [-40: 0]

servo_shaft_diameter = 5.78; //[5.78:"Radio Shaft Standard"]
z_servo_plate = 2.5; //[0.5:"Position test", 1:"Trial", 2:"Solid", 2.5:"Flush"]

test_fit_height = 0.5; // [0.25, 1, 2.5, 4]
test_fit_tolerances = [0.4, 0.5, 0.6, 0.7]; // initial: [0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1],

/* [Filament Clip Design] */

d_cam_clearance = 24.0; // [5: 0.5: 20]
d_extruder_gear_clearance = 22.5; // [5: 0.5: 25]
d_idler_gear_clearance = 19; // [1: 0.5: 30]

/* [Cam Design] */

cam_min_diameter = 9.5;
cam_offset = 3;


/* [Actuator Design] */
x_actuator = 100;
z_actuator = 100;



module end_of_customization() {}

z_z_axis_support = 2.56;
plate_behind_right = [6.3, 34, z_z_axis_support];
plate_front_edge = [23, 0.1, z_z_axis_support];
plate_behind_left = [6.3-1, 16, z_z_axis_support];

bottom_of_plate_to_top_of_spring_arm = 17.59;
z_spring_arm = 10.53;
spring_arm_end_diameter = 11.76;
spring_arm_end = [12.55-spring_arm_end_diameter/2, spring_arm_end_diameter, z_spring_arm];

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

stepper_translation = [-21-6, 5, 0];
idler_translation = [-24, 20, 0];

z_extruder_base = dz_spring_arm - z_spring_arm;
dx_extruder_base = 5;

filament_guide_translation = [20, 12, 0];
filament_entrance_translation = [-4, 14., z_extruder_base + 5.31];

l_filament_entrance = 23;
multiplex_translation = filament_entrance_translation + [l_filament_entrance-1, 0, 0];

dz_cam = bottom_of_plate_to_top_of_spring_arm - z_spring_arm - z_z_axis_support + 2;  
echo("dz_cam", dz_cam);

h_cam = bottom_of_plate_to_top_of_spring_arm - z_z_axis_support - dz_cam;

od_ptfe_tubing = 4.05;

z_axis_translation = [(7.9+4.7)/2-2.5, (23.2+11.4)/2+2, 0];
z_axis_bearing_extent = [8, 24, 5];
od_z_axis_bearing = 11;


y_actuator = filament_entrance_translation.y;

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


module servo(as_clearance = false, clearance = 0) {
    a_lot = 100;
    translate(servo_translation) rotate([0, 0, servo_rotation]) {
        if ( as_clearance) {
            block(servo_blank + 2*[clearance, clearance, clearance]); 
            translate([0, 10, 0]) can(d=13 + 2*clearance, h=a_lot);     
        } else {
            translate(-servo_blank/2) futabas3003(position=[0,0,0], rotation=[0, 0, 0]);
        }
    }
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


if (show_mocks && !orient_for_build) {
    servo_mount_screws(as_clearance=false);
    if (show_z_axis_support) {
        z_axis_support();
    }
    z_axis_threaded_rod();
    z_axis_bearing();
    spring_arm();
    extruder_base();
    if (show_servo) {
        servo(as_clearance=false);
    }
    stepper();
    filament_guide_screws(as_clearance=false);
    
}


module servo_screws(as_clearance=false, as_spacers=false, orient_for_build=false) {
    module item() {
        if (as_clearance) {
            translate([0, 0, 25]) hole_through("M2.5", $fn=12);
        } else if (as_spacers) {
            h_spacer = - z_z_axis_support - z_servo_plate - dz_top_of_servo_ears;
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
    dy = orient_for_build ? 5 : 0.615 * servo_blank.y;
    translate(servo_translation) rotate([0, 0, servo_rotation]) {         
        translate([0.25 * servo_blank.x, dy, 0]) item();
        translate([0.25 * servo_blank.x, -dy, 0]) item();
        translate([-0.25 * servo_blank.x, dy, 0]) item();
        translate([-0.25 * servo_blank.x, -dy, 0]) item();          
    }
}


module servo_mount_screws(as_clearance=false, as_pilot_holes=false) {
    m3_screw_translation = [13, 26, 0];
    if (as_clearance) {
        translate([0, 0, -100-z_z_axis_support-z_servo_plate]) // -z_z_axis_support-z_servo_plate])  
            rotate([180, 0, 0]) 
                hole_through("M4", h=100, $fn=12);
        translate(m3_screw_translation + [0, 0, -100-z_z_axis_support-z_servo_plate]) 
            rotate([180, 0, 0]) 
                hole_through("M3", h=100, $fn=12);
        //translate([0, 0, 20+M4_nut_thickness]) hole_through("M4", cld=0.6, $fn=12);
        // Need space fo nut and washer to rotate
        can(d=9.2, h=dz_cam, center=ABOVE); 
    } else if (as_pilot_holes) {
        translate([0, 0, 25]) hole_through("M3", $fn=12);
        translate(m3_screw_translation + [0, 0, 25]) hole_through("M2.5",$fn=12); 
    } else {
        color("silver") {
            translate(m3_screw_translation) screw("M3x6", $fn=12);
            translate(m3_screw_translation + [0, 0, -4]) nut("M3");
            translate([0, 0, -z_z_axis_support]) 
                rotate([180, 0, 0]) screw("M4x20", $fn=12);
            rotate([180, 0, 0]) nut("M4");
            translate([0, 0, M4_nut_thickness]) 
                rotate([180, 0, 15]) nut("M4"); 
        }    
    }
}


module filament_guide_screws(as_clearance=false) {
    module item() {
        if (as_clearance) {
            h_clearance = 4;
            translate([0, 0, -z_z_axis_support-h_clearance]) {  
                rotate([180, 0, 0]) {
                    hole_through("M2.5", h=h_clearance, cld=0.04, $fn=12);
                }
            }
            translate([0, 0, -1]) {
                rotate([180, 0, 0]) {
                    nutcatch_parallel("M2.5", clh=2, clk=1);
                }
            }             
        } else {
            color(BLACK_IRON) {
                translate([0, 0, -z_z_axis_support]) {
                    rotate([180, 0, 0]) {
                        screw("M2.5x20",  $fn=12);
                    }
                }
                translate([0, 0, 2]) nut("M2.5");
            }
        }
    }
    translate([20, 6, 0]) item();
    translate([20, 18, 0]) item();
}

module multiplex_clearance() {
    translate(multiplex_translation) 
        rotate([0, -90, 0]) 
            can(d=20, taper=2.0, h=21, center=BELOW);
}


module multiplex_entrance_guide(as_clearance = false, clearance=0.2) {
    actual_clearance = as_clearance ? clearance : 0;
    clearances = 2 * [actual_clearance, actual_clearance, actual_clearance];
    entrance = [0.1, 2*multiplex_translation.z, 2*multiplex_translation.z];
    module entrance() {
        block(entrance + clearances, center = FRONT);
    }
    translate(multiplex_translation-filament_guide_translation) {
        hull() {
            block([0.1, 5, 5], center = FRONT);
            translate([15, 0, 0]) entrance();
            translate([19, 0, 0]) entrance();
        }
    }
    
}


module filament_guide(orient_for_build=false, as_clearance = false, clearance=0.2) {
    z_filament_entrance = 9.5;
    screw_block = [5, 20, 15];
    entrance_guide = [8, 7, 13];
    module located_shape() {
        render(convexity=10) difference() {
            translate(filament_guide_translation) {
                block(screw_block, center=ABOVE);
                translate([-1, 2, 0]) block(entrance_guide, center=ABOVE+BEHIND);
                multiplex_entrance_guide(as_clearance, clearance);
            }
            filament_guide_screws(as_clearance=true);
            z_axis_bearing(as_clearance=true);
            z_axis_threaded_rod(as_clearance=true, clearance=0.3);
            translate(filament_entrance_translation) {
                ptfe_tubing(od=4, as_clearance=true, center=FRONT, l=l_filament_entrance);
            }
            multiplex_clearance();
        }
    }
    if (orient_for_build) {
        translate(-filament_guide_translation) located_shape();
    } else {
        color("violet") located_shape();
    }
}

module filament_guide_faceplate(orient_for_build=false) {
    wall = 2;
    clip = [5, 2*multiplex_translation.z, 2*multiplex_translation.z] + 2* [wall, wall, -2];
    module clip() {
        render() difference() {
            translate(multiplex_translation + [20, 0,-2]) {
                block(clip , center=BEHIND);
            }
            translate([0, 0, 0]) filament_guide(orient_for_build=false, as_clearance=true);
            translate([0, 0, -0.5]) filament_guide(orient_for_build=false, as_clearance=true);
            translate([-0.2, 0, 0]) multiplex_clearance();
        }
    }
    module ptfe_sockets() {
        difference() {
            translate(multiplex_translation + [20, 0, -2]) {        
                block([6, clip.y, 2*multiplex_translation.z + 5] , center=FRONT);
            }
            plane_clearance(BELOW);
            for (az = [-12, -0, 12]) {
                for (ay = [-12, -0, 12]) {
                    translate(multiplex_translation) {
                        rotate([0, ay, az]) {
                            translate([22, 0, 0])
                            ptfe_tubing(od=4, as_clearance=true, center=FRONT, l=100); 
                        }
                    }
                }
            }      
        }
    }
    if (orient_for_build) {
        clip();
        ptfe_sockets();
    } else {
        color("aquamarine") {
            clip();
            ptfe_sockets();
        }
    }
}


module filament_clip(orient_for_build=false) {
    clip_height = z_spring_arm ;
    wall = 2;
    clip = [12.71, 22.58, clip_height] + 2*[wall, wall, 0];
    dz = z_extruder_base + z_spring_arm + wall;
    //rotation = orient_for_build ? [180, 0, 0] : [0, 0, 0];
    //rotate(rotation) {
    a_lot = 100;
    entrance = [4, 6, clip.z];
    module cam_clearance() {
        translate([3, 0, 0]) can(d=d_cam_clearance, h=a_lot);
    }
    module extruder_gear_clearance() {
        translate(stepper_translation) {
            can(d=d_extruder_gear_clearance, h=a_lot);
        }
    }
    module idler_gear_clearance() {
        translate(idler_translation) {
            can(d=d_idler_gear_clearance, h=a_lot);
        }
    }
    module entrance_clearance() {
        translate(filament_entrance_translation) 
            rotate([0, -90, 0]) 
                can(d=13, taper=2.5, h=20, center=BELOW);
    }
    
    module shape() {
        difference() {
            union() {
                translate([-dx_extruder_base+1+wall, 5, dz]) 
                    block(clip, center=BELOW+BEHIND+RIGHT);
                translate([-dx_extruder_base+1+wall, 11., dz])
                    block(entrance, center=BELOW+FRONT+RIGHT);
            }
            spring_arm(as_clearance=true, clearance=0.2); 
            cam_clearance();
            extruder_gear_clearance();
            idler_gear_clearance();
            z_axis_threaded_rod(as_clearance=true, clearance=1);
            entrance_clearance();
        }
    }
    if (orient_for_build) {
        rotate([180, 0, 0]) 
            translate([0, 0, -dz]) 
                shape();
    } else { 
        color("magenta") shape();
    }
}

module servo_mount() {
    a_lot = 100;
    color("pink"){
        render(convexity=10) difference() {
            hull() {
                translate(servo_mount_translation) 
                    block(servo_mount_blank, center=BELOW+FRONT+RIGHT);
                translate(servo_mount_translation + [0, 0, z_servo_plate]) 
                    block(servo_mount_blank, center=BELOW+FRONT+RIGHT);
                
                translate([servo_translation.x, servo_translation.y, servo_mount_translation.z]) { 
                    rotate([0, 0, servo_rotation]) {
                        block([servo_blank.x, servo_blank.y, 2*z_servo_plate]+[0, 15, 0]);
                    }
                }  
            }

            translate([9.5, 5, 0]) block([a_lot, a_lot, a_lot], center=RIGHT+BEHIND); 
            z_axis_support(); 
            translate([-plate_behind_right.x, 0, 0]) plane_clearance(BEHIND);
            servo_screws(as_clearance=true);
            servo_mount_screws(as_clearance=true);
            servo(as_clearance=true, clearance = 1); 
            filament_guide_screws(as_clearance=true);
        }  
    } 
}

module drill_guide(orient_for_build=false) {
    difference() {
        translate([servo_mount_translation.x, -5, 0]) 
            block([21, 35, z_servo_plate], center=ABOVE+FRONT+RIGHT);
        z_axis_threaded_rod(as_clearance = true);
        z_axis_bearing(as_clearance = true);
        servo_mount_screws(as_pilot_holes=true);
    }  
    
}

module cam_handle_screw_clearance() {
   translate([3, -cam_offset-1, h_cam/2]) rotate([0, -90, 0]) {
       //nutcatch_sidecut("M3", clh=0.4);
       translate([0, 0, 6]) hole_threaded("M3", $fn=12);
   }
}


module cam(orient_for_build=false) { 
    chamfer = 2;
    module chamfered_can(chamfer_bottom=true) {  
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
            translate([0, +2, 0])chamfered_can(chamfer_bottom=false);
            translate([0, -cam_offset, 0]) chamfered_can(chamfer_bottom=false);
            translate([1.5, -cam_offset, 0]) chamfered_can(chamfer_bottom=false);
        }        
    }
    module servo_adapter() {
        can(d=cam_min_diameter, h=6, center=ABOVE);
        render(convexity=10) difference() {
            union() {
                scale([0.92, 0.92, 1])import("resource/cam_gear_form.stl");
                translate([0, 0, 8]) can(d=17, taper=14, h=4);
            }
            rotate([0, 0, 0]) plane_clearance(BEHIND+LEFT);
            rotate([0, 0, 56]) plane_clearance(BEHIND+LEFT);
        }
          
    }
    module assembly() {
        render(convexity=10) difference() {
            union() {
                translate([0, 0, dz_cam-2]) cam_shape();
                translate([0, 0, 1])servo_adapter();
            }
            translate([0, 0, dz_cam+2]) cam_handle_screw_clearance();
            servo_mount_screws(as_clearance=true);
            translate([-cam_min_diameter/2, 0, 0]) plane_clearance(BEHIND);
        }        
    }
    if (orient_for_build) {
         translate([0, 0, h_cam + 6])
            rotate([180, 0, 0]) assembly();
    } else {
        color("red", alpha=cam_alpha) {
            assembly();
        } 
    }  
}


module servo_gear(orient_for_build=false) {
    tolerance = 0.5;
    module gear_form() {
        scale([0.92, 0.92, 1]) import("resource/servo_gear_form.stl");
    }
    module assembly() {
        render(convexity=10) difference() {
            union() {
                gear_form();
                can(d=11, h=5.8, center=BELOW);
                can(d=9, h=5.8, taper=13, center=BELOW);
                can(d=10, h=4.8, center=ABOVE);
            }
            // Hole for inserting servo screw
            translate([0, 0, 1]) can(d=6, h=100, center=ABOVE);
            // pilot hole for servo screw
            can(d=2, h=100);
            translate([0, 0, -7]) horn_cavity(
                diameter=servo_shaft_diameter + 2 * tolerance,
                height=7,
                shim_count = 7,
                shim_width = 1,
                shim_length = .5); 
        }       
    }
    if (orient_for_build) {
        translate([0, 0, 6]) assembly();
    } else {
        color("green") {
            translate([x_servo, y_servo, 0]) {
                rotate([0, 0, servo_rotation]) {
                    translate([0, 10.5, 0]) {
                        assembly();
                    }
                }
            }
        }
    }
}


module horn_goldilocks_array(
        plot = 10,
        shim_counts = [0, 3, 6]) {
    difference() {
        cube([
            plot * len(test_fit_tolerances),
            plot * len(shim_counts),
            test_fit_height
        ]);

        for (i_tolerance = [0 : len(test_fit_tolerances) - 1]) {
            for (i_shim_count = [0 : len(shim_counts) - 1]) {
                translate([
                    i_tolerance * plot + plot / 2,
                    i_shim_count * plot + plot / 2,
                    0
                ]) {
                    // So now we have X and Y as tolerances[i_tolerance] and
                    // shim_counts[i_shim_count], and they can be used to make
                    // each individual test.
                    // Here, for example, they're passed as arguments to an
                    // external cavity() module.
                    translate([0, 0, -1]) horn_cavity(
                        diameter = servo_shaft_diameter
                            + test_fit_tolerances[i_tolerance] * 2,
                        shim_count = shim_counts[i_shim_count],
                        height = test_fit_height + 10
                    );
                }
            }
        }
    }
}


module horn_cavity(
    diameter,
    height,
    shim_count = 3,
    shim_width = 1,
    shim_length = .5,
) {
    e = .005678;

    difference() {
        cylinder(
            h = height,
            d = diameter
        );

        if (shim_count > 0) {
            for (i = [0 : shim_count - 1]) {
                rotate([0, 0, i * 360 / shim_count]) {
                    translate([
                        shim_width / -2,
                        diameter / 2 - shim_length,
                        -e
                    ]) {
                        cube([shim_width, shim_length, height + e * 2]);
                    }
                }
            }
        }
    }
}




if (build_servo_gear) {
    if (orient_for_build) {
       translate([-15, -28, 0]) servo_gear(orient_for_build=true); 
    } else {
       servo_gear(orient_for_build=false);
    }
}


if (build_cam) {
    if (orient_for_build) {
        translate([0, -25, 0]) cam(orient_for_build=true);
    } else {
        cam();
    }
}


if (build_servo_mount) {
    if (orient_for_build) {
        translate([10, 0, z_z_axis_support + z_servo_plate]) servo_mount();
    } else {
        servo_mount();
    }
}


if (build_mounting_plate_spacers) {
    if (orient_for_build) { 
        translate([-12, 40, 0]) servo_screws(as_spacers=true, orient_for_build=true);
    } else {
        servo_screws(as_spacers=true);
    }
}


if (build_filament_guide) {
    if (orient_for_build) {
        translate([-40, -10, 0]) filament_guide(orient_for_build=true);
    } else {
        filament_guide();
    }
}

if (build_filament_guide_faceplate) {
    if (orient_for_build) {
        translate([-50, -20, 0]) filament_guide_faceplate(orient_for_build=true);
    } else {
        filament_guide_faceplate();
    }
    
}


if (build_filament_clip) {
    if (orient_for_build) {
        translate([10, 40, 0]) filament_clip(orient_for_build=true);
    } else {
        filament_clip();
    }
}




if (build_drill_guide) {
    if (orient_for_build) { 
        translate([-18, -70, 0]) drill_guide(orient_for_build=true);
    } else {
        drill_guide();
    }     
}


if (build_test_fit_servo) {
    translate([0, -70, 0]) horn_goldilocks_array();
}
