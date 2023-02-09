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
include <centerable.scad>
use <shapes.scad>
use <9g_servo.scad>
use <small_servo_cam.scad>

eps =0.001;

/* [Show] */

show_default = false;
show_with_servo = false;
show_with_back = false;
show_translation_test = false;
show_mount_to_axle = true;

/* [Mount to axle example] */
angle = 0; // [-90: 5: +90]
axle_height = 12; // [6: 1: 20]

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
    sub_micro_servo_mount_to_axle(axle_height=axle_height, angle=angle);
}

module end_of_customization() {}


servo_size = [15.45, 23.54, 11.73];

servo_lip = 4;
pilot_diameter = 2;
screw_length = 8;
screw_length_allowance = 2;

//minimum_size = [ 4*pilot_diameter, servo_length + 2 * servo_lip, 4*pilot_diameter];

//minimum_size_err_msg = text("The servo size is below the minimum allowed of ", minimum_size);

module bare_pilot_hole() {
    l = screw_length+screw_length_allowance;
    d = pilot_diameter;
    rod(d=d, l=l, center=FRONT);
}  

module pilot_hole(screw_offset, screw_block) {
    t = [
        -(screw_block.x/2 + eps), 
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
        min(extent.x, servo_clearance.x)+eps, 
        remainder.y/2, 
        min(extent.z, servo_clearance.z)+eps];
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
                // Dev Code:
                //% cube(servo_size, center=true);
                //% cube(servo_clearance, center=true);
                //% cube(extent, center=true);
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
        angle = 0) {
            
    //assert(axle_height >= 12);
            
          
    
    horn_thickness = 3;
    horn_radius = 11.0;
    horn_overlap = 0.5;
    hub_backer_l = 2;
    hub_backer_diameter = 16;
    dx_horn = horn_thickness + axial_allowance + hub_backer_l - horn_overlap;
    dx_servo_offset = 11.32; 
    dx_servo = dx_horn +  dx_servo_offset;

    servo_width = 12.00;
    size_pillar = [6, 4, servo_width/2 + axle_height];
    x_servo_side_wall = dx_servo - size_pillar.x;
    y_hub_clearance = 28/2;
    servo_length = 24.00;
    servo_axle_x_offset = 6;
    y_plus = servo_axle_x_offset;  // Axis differ by 90 degerees!
    y_minus = servo_length - servo_axle_x_offset;

                
    color("orange") x_axis_servo_hub(angle);
    rotary_servo_mount();
        
   
    module rotary_servo_mount() {
        color("red") servo_mounting_pillars();
        color("blue") hub_yoke();
        color("green") minus_joiner();
        color("purple") plus_joiner();
    }
    
    module truncated_horn() {
        difference() {
            translate([dx_horn, 0, 0]) {
                rotate([45, 0, 0]) {
                    rotate([0, 90, 0]) 
                        bare_hub(horn_thickness);
                }
            }
            translate([0, 0, -axle_height]) block([100, 100, 100], center=BELOW);
        }
    }
    
    module printable_horn() { 
        truncated_horn();
        difference() {
            translate([dx_horn, 0, 0]) {
                block([1.8*horn_thickness, 10, axle_height], center=BELOW);
            }
            hull() {
                truncated_horn();
            }
        }
    }
            
    module x_axis_servo_hub(angle) {
        rotate([angle, 0, 0]) {
            translate([axial_allowance, 0, 0]) {
                rod(d=hub_backer_diameter, l=hub_backer_l, center=FRONT);
                rod(d=axle_diameter, l=wall_thickness + 2 * axial_allowance, center=BEHIND);
            }
            printable_horn();
        }
        
    }
    
    module support_horn() {
        // Support horn for 3D printing
        size_support = [
            2*horn_thickness-0.2, 
            0.75*horn_radius, 
            0.25*horn_radius
        ];
        translate([dx_outside+dx_horn, 0, 0])
            block(size_support, center=ABOVE);
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
                block(side_wall, center=FRONT+ABOVE+RIGHT);
            }
        }
        translate([0, 0, -axle_height]) block(bearing_wall, center=BEHIND+ABOVE);  
    }
    
    module minus_joiner() { 
        y = y_minus - y_hub_clearance + size_pillar.y;
        dx = x_servo_side_wall;
        translate([dx, -y_hub_clearance, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+BEHIND+LEFT);
    }
    
    module plus_joiner() {
        y = y_hub_clearance - y_plus + wall_thickness;
        dx = x_servo_side_wall;
        translate([dx, y_plus, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+FRONT+RIGHT);
    }
    

    

    


}



