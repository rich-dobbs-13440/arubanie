/* 


Usage:

use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>

sub_micro_servo_mounting(include_children=if_designing) {
    9g_motor_centered_for_mounting();
}

sub_micro_servo_mount_to_axle(
        axle_diameter=4, 
        axle_height= 10,
        wall_height=6,
        radial_allowance=0.4, 
        axial_allowance=0.4, 
        wall_thickness=2, 
        angle = 0);


*/
include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <9g_servo.scad>
use <small_servo_cam.scad>

fa_shape = 10;
fa_bearing = 1;


/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [Show] */

show_default = false;
show_with_servo = false;
show_with_back = false;
show_translation_test = false;
show_mount_to_axle = false;

show_single_horn = true;

/* [Mount to axle example] */
angle = 0; // [-180: 5: +180]
axle_height = 18.5; // [6: 0.5: 20]

axle_diameter=4; // [2: 1: 20]

wall_height=6; // [2: 1: 20]
radial_allowance=0.4; // [0 : 0.2 : 10]
axial_allowance=0.4; // [0 : 0.2 : 10]
wall_thickness=2; // [2: 0.5: 10]

end_of_customization() {}

if (show_default) {
    sub_micro_servo_mounting();
    
}

if (show_with_servo) {
    sub_micro_servo_mounting() {
        9g_motor_centered_for_mounting();
    }
}

if (show_with_back) {
    sub_micro_servo_mounting(size=[18, 32, 18]);
}


if (show_translation_test) {
    color("red") sub_micro_servo_mounting(center=ABOVE);
    color("blue") sub_micro_servo_mounting(omit_top=false, center=BELOW);
    color("green") sub_micro_servo_mounting(center=LEFT);
    color("yellow") sub_micro_servo_mounting(center=RIGHT);
}


if (show_mount_to_axle) {
    sub_micro_servo_mount_to_axle(
        axle_diameter=axle_diameter, 
        axle_height= axle_height,
        wall_height=wall_height,
        radial_allowance=radial_allowance, 
        axial_allowance=axial_allowance, 
        wall_thickness=wall_thickness, 
        angle=angle,
        log_verbosity=verbosity);
}

module end_of_customization() {}


servo_size = [15.45, 23.54, 11.73];

servo_lip = 4;
pilot_diameter = 2;
screw_length = 8;
screw_length_allowance = 2;

if (show_single_horn) {
    //single_horn("clearance", 0.4);
    //single_horn("arm blank", 0.4);
    single_horn("arm holder", 0.4);
}

module single_horn(action, allowance) {
    if (action == "clearance") {
        single_horn_clearance(allowance, allowance);
    } else if (action == "arm blank") {
        arm_clearance(2, 1);
    } if (action == "arm holder") {
        arm_holder(allowance);
        
    }
    
    d_out_hub = 5.72;
    d_inner_hub = 3.81;
    h_hub = 3.30;
    d_arm_end = 3.83;
    h_arm = 1.96;
    r_arm = 25.1;
    screw_diameter = 2;
    slot_width = 1.54;
    
    module arm_holder(allowance) {
        difference() {
            // The blank
            arm_clearance(2, 3.5);
            // The clearance for the arm
            translate([0, 0, 2]) center_reflect([1, 0, 0]) arm_clearance(allowance, allowance);
            // Implement the catch to hold the arm
            translate([0, 0, 2.6]) center_reflect([1, 0, 0]) arm_clearance(-0.7*allowance, 1);
            // Access to center screw
            can(d=5, h=20, fa=fa_shape);
            // Avoid the hub
            translate([0, 0, 2.0]) can(d=13, h=5, center=ABOVE);
            // Screw pilot holes the arm holder
            translate([8, 0, 0]) can(d=1.5, h=20, fa=fa_shape);  
            translate([11, 0, 0]) can(d=1.5, h=20, fa=fa_shape);  // 
            translate([14, 0, 0]) can(d=1.5, h=20, fa=fa_shape);
            translate([17, 0, 0]) can(d=1.5, h=20, fa=fa_shape);
            translate([20, 0, 0]) can(d=1.5, h=20, fa=fa_shape);
            translate([23, 0, 0]) can(d=1.5, h=20, fa=fa_shape);
            translate([26, 0, 0]) can(d=1.5, h=20, fa=fa_shape);
        }
       
    }
  
    module arm_clearance(d_allowance, h_allowance) {
        function swell(d) = d + 2*d_allowance; 
        function swell_h(d) = d + h_allowance; 
        hull() {
            can(d=swell(d_out_hub), h=swell_h(h_arm), center=ABOVE, fa=fa_shape);
            translate([r_arm, 0, 0]) 
                can(d=swell(d_arm_end), h=swell_h(h_arm), center=ABOVE, fa=fa_shape);
            
        }
    }
    
    
}


module bare_pilot_hole() {
    l = screw_length+screw_length_allowance;
    d = pilot_diameter;
    rod(d=d, l=l, center=FRONT, rank=2, fa=4*fa_shape);
}  

module pilot_hole(screw_offset, screw_block) {
    t = [
        -(screw_block.x/2), 
        -screw_block.y/2 + screw_offset, 
        0
    ];
    translate(t) bare_pilot_hole(); 
}


module drill_pilot_hole(screw_offset, screw_block) {
    difference() {
        children();
        pilot_hole(screw_offset, screw_block);
    }
}


module back_wall(extent, servo_clearance, remainder) {
    back_wall = [
        remainder.x, 
        extent.y, 
        min(extent.z, servo_clearance.z)];
    dx_back_wall = servo_clearance.x/2;
   
    servo_connector_window = [4, 7, 9];
    dy_window = servo_clearance.y/2; 
    
    translate([dx_back_wall, 0, 0])
        render() difference() {
            cube(back_wall, center=true);
            translate([0, dy_window, 0]) cube(servo_connector_window, center=true);
            translate([0, -dy_window, 0]) cube(servo_connector_window, center=true);
        } 
}

module screw_blocks(screw_offset, extent, servo_clearance, remainder) {
    screw_block = [
        min(extent.x, servo_clearance.x), 
        remainder.y/2, 
        min(extent.z, servo_clearance.z)];
    dx_screw_block = -(extent.x - screw_block.x)/2;
    dy_screw_block = servo_clearance.y/2 + screw_block.y/2;
    
    center_reflect([0,1,0]) 
        translate([dx_screw_block, dy_screw_block, 0]) 
            drill_pilot_hole(screw_offset, screw_block) 
                cube(screw_block, center=true);  
}

module base_and_top(extent, servo_clearance, remainder, omit_top) {
    base = [
        extent.x, 
        extent.y,
        remainder.z/2
    ];
    dz_base = -servo_clearance.z/2- base.z/2;
    
    translate([0, 0, dz_base]) 
    cube(base, center=true);

    if (!omit_top) {
        translate([0, 0, -dz_base]) 
            cube(base, center=true);
    }
}


module sub_micro_servo_mounting(
    size=undef, 
    screw_offset=1.5, 
    clearance = [0.5, 1, 1],
    omit_top=true, 
    center=0, 
    rotation=0,
    include_children=true) {
        
    extent = is_undef(size) ? [16, 32, 18] : size;
    
    servo_clearance = servo_size + clearance + clearance;
    remainder = extent - servo_clearance;
        
    

    center_translation(extent, center) {
        center_rotation(rotation) {
            translate([extent.x/2, 0, 0]) {
                back_wall(extent, servo_clearance, remainder);
                screw_blocks(screw_offset, extent, servo_clearance, remainder);
                base_and_top(extent, servo_clearance, remainder, omit_top);
            }
            if (include_children) {
                # children();  // Show mounted servo, if any
            }
        }
    } 
    
    
    
}



module sub_micro_servo_mount_to_axle(
        axle_diameter=4, 
        axle_height= 10,
        wall_height=6,
        radial_allowance=0.4, 
        axial_allowance=0.4, 
        wall_thickness=2, 
        angle = 0,
        log_verbosity=INFO) {
    
    marker="----------------";       
    log_s(marker, "sub_micro_servo_mount_to_axle", log_verbosity, DEBUG);        
    log_s("axle_diameter", axle_diameter, log_verbosity, DEBUG);
    log_s("axle_height", axle_height, log_verbosity, DEBUG);
    log_s("wall_height", wall_height, log_verbosity, DEBUG);
    log_s("radial_allowance", radial_allowance, log_verbosity, DEBUG);
    log_s("axial_allowance", axial_allowance, log_verbosity, DEBUG);
    log_s("wall_thickness", wall_thickness, log_verbosity, DEBUG);        
    log_s("angle", axle_diameter, log_verbosity, DEBUG);
    log_s("log_verbosity", log_verbosity, log_verbosity, DEBUG);
            
    fa_shape = 10;
    fa_bearing = 1;
            
    horn_thickness = 3;
    horn_radius = 11.9;
    horn_overlap = 0.5;
    hub_backer_l = 2;
    hub_backer_diameter = 16;
    dx_horn = horn_thickness + axial_allowance + hub_backer_l - horn_overlap;
    dx_servo_offset = 11.32; 
    dx_servo = dx_horn +  dx_servo_offset;

    servo_width = 12.00;
    size_pillar = [6, 4, servo_width/2 + axle_height];
    x_servo_side_wall = dx_servo - size_pillar.x;
    
    servo_length = 24.00;
    servo_axle_x_offset = 6;
    y_plus = servo_axle_x_offset;  // Axis differ by 90 degerees!
    y_minus = servo_length - servo_axle_x_offset;
    
    dy_wall_squared = 
        horn_radius*horn_radius 
        - (axle_height - wall_height)*(axle_height - wall_height);
    dy_wall_min = dy_wall_squared > 0 ? sqrt(dy_wall_squared) : 0;
    dy_wall = max(dy_wall_min + 2, y_plus);
    
    y_hub_clearance = dy_wall; //28/2;
                
    color("orange") x_axis_servo_hub(angle);
    rotary_servo_mount();
        
   
    module rotary_servo_mount() {
        color("red") servo_mounting_pillars();
        *color("blue") hub_yoke();
        *color("green") minus_joiner();
        *color("lime") plus_joiner();
        color("brown") bearing();
        if (dy_wall_squared < 0) {
            central_joiner();
        }
    }
    
    module horn_support() {
//        center_reflect([1, 0, 0]) {
//            translate([0.8, 0, -horn_radius+ radial_allowance]) {
//                intersection() {
//                    rotate([-45, 0, 0]) {
//                        block([1.8, axle_height, axle_height], 
//                        center=BELOW+RIGHT+FRONT);
//                    }
//                    block([2*horn_thickness, 10, axle_height]);
//                }
//            }
//        }
        dz = axle_height - horn_radius + radial_allowance;
        translate([0, 0, -axle_height]) {
            difference() {
                hull() {    
                    translate([-radial_allowance, 0, 0]) 
                        block([2*horn_thickness, 10, 0], center=ABOVE); 
                    translate([0, 0, dz]) 
                        block([2*horn_thickness, 5, 0]); 
                }
                translate([0,0, 1]) block([3*horn_thickness, 3, dz-1.5], center=ABOVE);
            }
        }
    }
    
    module truncate_at_build_plane() {
        difference() {
            children();
            translate([0, 0, -axle_height]) block([100, 100, 100], center=BELOW);
        }
    }
    
    module supported_horn() {
        translate([dx_horn, 0, 0]) {
            rotate([45, 0, 0]) {
                rotate([0, 90, 0]) 
                    bare_hub(horn_thickness);
            }
            horn_support();
        }
    }
            
    module x_axis_servo_hub(angle) {
        rotate([angle, 0, 0]) {
            truncate_at_build_plane() {
                translate([axial_allowance, 0, 0]) {
                    rod(d=hub_backer_diameter, 
                        l=hub_backer_l, 
                        center=FRONT, 
                        fa=2*fa_shape);
                    rod(d=axle_diameter, 
                        l=wall_thickness + 2 * axial_allowance, 
                        center=BEHIND, 
                        fa=fa_bearing);
                }
                supported_horn();
            }
        }
        
    }
 
    module drilled_pillar() {
        screw_offset = 2;
        difference() {
            block(size_pillar, center=BEHIND+ABOVE+RIGHT);
            translate([1, screw_offset, axle_height]) rotate([0, 180, 0]) bare_pilot_hole();
        }
    }

    
    module servo_mounting_pillars() { 
        dy_plus = y_plus;
        
        translate([dx_servo, dy_plus, -axle_height]) {
                    drilled_pillar();     
        }
        
        dy_minus = -y_minus;
        translate([dx_servo, dy_minus, -axle_height]) {
            mirror([0, 1, 0]) drilled_pillar();
        }
        translate([dx_servo, dy_minus, -axle_height])
            block([size_pillar.x, servo_length, wall_thickness], center=BEHIND+ABOVE+RIGHT);
    }
    
    module hub_yoke() {
        side_wall = [x_servo_side_wall, wall_thickness, wall_height];
        bearing_wall = [
            wall_thickness, 
            2*y_hub_clearance + 2 * wall_thickness, 
            wall_height
        ];
        center_reflect([0, 1, 0]) {
            translate([0, y_hub_clearance, -axle_height]) { 
                block(side_wall, center=FRONT+ABOVE+RIGHT, rank=2);
            }
        }
        bore_for_axle(axle_diameter, radial_allowance, l=50) {
            translate([0, 0, -axle_height]) block(bearing_wall, center=BEHIND+ABOVE); 
        } 
    }
    
    module minus_joiner() { 
        y = y_minus - y_hub_clearance + size_pillar.y;
        dx = x_servo_side_wall;
        translate([dx, -y_hub_clearance, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+BEHIND+LEFT, rank=3);
    }
    
    module plus_joiner() {
        y = y_hub_clearance - y_plus + wall_thickness;
        dx = x_servo_side_wall;
        translate([dx, y_plus, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+FRONT+RIGHT, rank=4);
    }
    
    module central_joiner() {
        dx = x_servo_side_wall;
        translate([dx, 0, -axle_height])  
            block([wall_thickness, 2*dy_wall, wall_height], center=ABOVE+BEHIND, rank=5);
    }
    
    module bearing() {
        translate([0, 0, 0]) {
            x_axle_bearing(
                axle_diameter, 
                axle_height, 
                bearing_width=wall_thickness, 
                radial_allowance=radial_allowance);
        }
    }
    
    module bore_for_axle(axle_diameter, radial_allowance, l=50) {
        bore_diameter = axle_diameter + 2 * radial_allowance;
        render() difference() {
            children();
            rod(d=bore_diameter, l=l, fa=fa_bearing);
        }
    }
    
    module x_axle_bearing(axle_diameter, axle_height, bearing_width, radial_allowance) {

        bore_for_axle(axle_diameter, radial_allowance) {
            hull() {
                block([bearing_width, 3*axle_diameter, axle_height], center=BELOW+BEHIND, rank=6);
                rod(d=3*axle_diameter, l=bearing_width, center=BEHIND, fa=fa_shape);
            }
        }

    }
}





