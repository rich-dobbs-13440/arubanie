


include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>
include <MCAD/stepper.scad>
use <NopSCADlib/vitamins/rod.scad>
use <lib/ptfe_tubing.scad>

include <ender3v2_z_axis_mocks.scad>
use <ender3v2_filament_guide.scad>


/* [Output Control] */
orient_for_build = false;

build_cam = true;
build_servo_mount = true;
build_mounting_plate_spacers = true;
build_servo_gear = true;
build_drill_guide = false;
build_test_fit_servo = true;

show_mocks = true;
show_modified_z_axis = false;
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


/* [Cam Design] */

cam_min_diameter = 9.5;
cam_offset = 3;


/* [Actuator Design] */
x_actuator = 100;
z_actuator = 100;



module end_of_customization() {}





servo_mount_blank = [25, 48, z_servo_plate];
dy_servo_mount = 33 - servo_mount_blank.y;
servo_mount_translation = [-5, dy_servo_mount, -z_z_axis_support];

servo_blank = [20.1, 39.9, 36.1]; //[18.8, 38.6, 34.9];
servo_rotation = 155; 
servo_translation = [x_servo, y_servo, z_servo];
dz_top_of_servo_ears = z_servo + 11;
echo("dz_top_of_servo_ears", dz_top_of_servo_ears);








dz_cam = bottom_of_plate_to_top_of_spring_arm - z_spring_arm - z_z_axis_support + 2;  
echo("dz_cam", dz_cam);

h_cam = bottom_of_plate_to_top_of_spring_arm - z_z_axis_support - dz_cam;

od_ptfe_tubing = 4.05;




//y_actuator = filament_entrance_translation.y;

BRONZE = "#b08d57";
STAINLESS_STEEL = "#CFD4D9";
BLACK_IRON = "#3a3c3e";




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



if (build_test_fit_servo) {
    translate([0, -70, 0]) horn_goldilocks_array();
}

