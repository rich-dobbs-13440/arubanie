/* 


Usage:

use <lib/sub_micro_servo.scad>

sub_micro_servo_mounting(bar_thickness=4);

*/
include <centerable.scad>
use <shapes.scad>

eps =0.001;

/* [Show] */

show_default = true;
show_translation_test = false;


if (show_default) {
    mounting();
}

if (show_translation_test) {
    color("red") mounting(center=ABOVE);
    color("blue") mounting(omit_top=false, center=BELOW);
    color("green") mounting(center=LEFT);
    color("yellow") mounting(center=RIGHT);
}

module end_of_customization() {}


servo_size = [15.45, 23.54, 11.73];

servo_lip = 4;
pilot_diameter = 2;
screw_length = 8;
screw_length_allowance = 2;

//minimum_size = [ 4*pilot_diameter, servo_length + 2 * servo_lip, 4*pilot_diameter];

//minimum_size_err_msg = text("The servo size is below the minimum allowed of ", minimum_size);

module pilot_hole(screw_offset, screw_block) {
    t = [
        -(screw_block.x/2 + eps), 
        -screw_block.y/2 + screw_offset, 
        0
    ];
    l = screw_length+screw_length_allowance;
    d = pilot_diameter;
    translate(t) rod(d=d, l=l, center=FRONT);    
}


module drill_pilot_hole(screw_offset, screw_block) {
    difference() {
        children();
        pilot_hole(screw_offset, screw_block);
    }
}


module mounting(size=undef, screw_offset=1.5, omit_top=true, center=0, rotation=0) {
    extent = is_undef(size) ? [16, 32, 18] : size;
    clearance = [0.5, 1, 1];
    servo_clearance = servo_size + clearance + clearance;
    remainder = extent - servo_clearance;
    echo("remainder", remainder);
    
    back_wall = [
        remainder.x, 
        extent.y, 
        min(extent.z, servo_clearance.z)];
    dx_back_wall = servo_clearance.x/2; 
    
    screw_block = [
        extent.x, 
        remainder.y/2, 
        min(extent.z, servo_clearance.z)];
    dy_screw_block = servo_clearance.y/2 + screw_block.y/2;
    
    base = [
        extent.x, 
        extent.y,
        remainder.z/2
    ];
    dz_base = -servo_clearance.z/2- base.z/2;

    
    center_translation(extent, center) {
        center_rotation(rotation) {
            
            translate([extent.x/2, 0, 0]) {
//                % cube(servo_size, center=true);
//                % cube(servo_clearance, center=true);
//                % cube(extent, center=true);
                
                translate([dx_back_wall, 0, 0])
                    cube(back_wall, center=true);
                
                center_reflect([0,1,0]) 
                    translate([0, dy_screw_block, 0]) 
                        drill_pilot_hole(screw_offset, screw_block) {
                            cube(screw_block, center=true);
                        }
                
                translate([0, 0, dz_base]) 
                    cube(base, center=true);

                if (!omit_top) {
                    translate([0, 0, -dz_base]) 
                        cube(base, center=true);
                }
            }
            * cube(remainder);
        }
    } 
}



