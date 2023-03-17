

include <logging.scad>
include <centerable.scad>
use <dupont_pins.scad>
use <shapes.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

/* 

Parts of a pin

pin

strike
detent
wire_barrel 
wire_wrap
insulation_wrap



*/ 


/* [Jaw Measurements] */
wire_diameter = 1.66; // Includes insulation
d_wire_conductor = 1.13;
exposed_wire = 2.14; 




jaw_thickness = 7.33;
front_to_front_of_25 = 3.42;
front_to_back_of_25 = 5.24;
lower_jaw_height = 1.81;
x_lower_jaw_anvil = 24;
y_lower_jaw_anvil =7.21;
z_lower_jaw_anvil = 7.05;   
    lower_jaw_anvil_blank = [x_lower_jaw_anvil, y_lower_jaw_anvil, z_lower_jaw_anvil]; 

dx_025_anvil = 3.63;
/* [Pin Measurements] */
d_pin = 0.50; 
x_pin = 6.62;
// The strike is what keeps the pin from being removed from the housing 
x_strike = 3.22;
y_strike = 1.75;
z_strike = 1.80;
// The detent is the area that can be caught by something to retain the housing 
x_detent =  0.8;
y_detent = 1.65;
z_detent = 0.56;
x_wire_barrel = 2.79;
od_wire_barrel = 1.55;
x_wire_wrap = 3.79;
y_wire_wrap = 2.00;
z_wire_wrap = 1.73;
x_insulator_wrap = 2.18;
y_insulator_wrap = 2.77;
z_insulator_wrap =  2.46;



// Origin will be at center_line of jaw, at front 

/* [Design] */

/* 

Origin will be at center_line of jaw at the front, with jaw being on the 
x axis, with x being positive as you go deeper into the jaw.
*/

d_pin_clearance = 0.5;
male_pin_holder_spring_thickness = 2.54;
alpha_male_pin_holder = 1; // [0, 0.25, 0.50, 0.75, 1]
x_split_male_pin_holder = 7; // [0 : 1 : 12]
clearance_fraction_male_pin_holder = 0.1; //[0: 0.01: 0.20]

x_jaw_yoke_behind = 20; // [0:1:20]
x_jaw_yoke_front = 20; // [0:1:20]
y_jaw_yoke = 10; // [0:1:10]
z_jaw_yoke = 2; // [0:0.25:4]



z_latch_release = 14; // [0:0.25:20]

/* [Show] */
show_jaw_yoke = true;
show_male_pin = true;
show_male_pin_holder = true;
show_lower_jaw_anvil = true;
orient = "For build"; //["As designed", "As assembled", "For build"]

orient_for_build = orient == "For build";



module end_of_customization() {}

if (show_jaw_yoke) {
    jaw_yoke(); 
}

if (show_lower_jaw_anvil) {
    lower_jaw_anvil();
}

module lower_jaw_anvil() {

    module pin_side_25_mold() {
        hull() {
            translate([dx_025_anvil, 0, z_lower_jaw_anvil]) block([2.71, 20, 0.01], center=ABOVE+LEFT);
            translate([dx_025_anvil, 0, 4.81]) block([1.70, 20, 0.01], center=ABOVE+LEFT);
        }
    }
    module wire_side_25_mold() {
        hull() {
            translate([dx_025_anvil, 0, z_lower_jaw_anvil]) block([3.08, 20, 0.01], center=ABOVE+RIGHT);
            translate([dx_025_anvil, 0, 3.89]) block([2.60, 20, 0.01], center=ABOVE+RIGHT);
        }        
    }
    
    color("DarkSlateGray") {

        difference() {
            union() {
                block(lower_jaw_anvil_blank, center=ABOVE+FRONT);
                hull() {
                    translate([2.86, 0, 0]) block([17.09, 4.19, 0.01], center=BELOW+FRONT);
                    translate([x_lower_jaw_anvil/2, 0, -5.89]) rod(d=5.76, l=4.14, center=SIDEWISE);
                }
            }
            pin_side_25_mold();
            wire_side_25_mold();
        }
    }
    
}

module male_pin() {
    // Initially model pin before construction with pin on x_axis,
    // with the pin itself negative, and the parts used in assembly
    // increasing in the x domain.abs
    module strike() {
        strike = [x_strike, y_strike, z_strike];
        block(strike, center=FRONT);
    }
    module detent() {    
        bottom = [
            x_detent,
            y_detent,
            z_detent
        ];
        
        translate([x_strike, 0, -y_detent/2]) block(bottom, center=FRONT + ABOVE);
  
    }
    module wire_barrel() {
        dx = x_strike + x_detent;
        translate([dx, 0, 0])
            rod(d=od_wire_barrel, l=x_wire_barrel, hollow=d_wire_conductor, center=FRONT);
    }
    
    module wire_wrap() {
        dx = x_strike + x_detent + x_wire_barrel;
        extent = [x_wire_wrap, y_wire_wrap, z_wire_wrap];
        translate([dx, 0, 0]) {
            block(extent, center=FRONT);
        }
        
    }
    module insulator_wrap() {
        dx = x_strike + x_detent + x_wire_barrel + x_wire_wrap ;
        extent = [
            x_insulator_wrap,
            y_insulator_wrap,
            z_insulator_wrap
        ];
        translate([dx, 0, 0]) {
            block(extent, center=FRONT);
        }
    }    
    color("silver") {
        rod(d=d_pin, l=x_pin, center=BEHIND);
        strike();
        detent();
        wire_barrel();
        wire_wrap();
        insulator_wrap(); 
    }  
}


if (show_male_pin_holder) {
    oriented_male_pin_holder();
}

module oriented_male_pin_holder() {
    rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 90]: 
        assert(false, assert_msg("orient: ", orient));
    dy_assembly = -(x_strike + x_detent + x_wire_barrel+x_wire_wrap);
    translation = 
        orient_for_build ? [0, 0, 2.54/2] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [dx_025_anvil, dy_assembly, z_lower_jaw_anvil]: 
        assert(false);
    translate(translation) rotate(rotation) {
        male_pin_holder(clearance_fraction=clearance_fraction_male_pin_holder); 
       if (show_male_pin) {
            male_pin();  
        }
    } 
}

module male_pin_holder(clearance_fraction=.2) {
    body = [14, 2.54, 2.54];
    spring = [x_strike+x_detent, 2.54, (2.54-z_strike)/2];
    latch_x = x_detent*(1-clearance_fraction);
    latch_dx = (x_detent * clearance_fraction)/2;
    latch = [latch_x, 2.54, 2.54/2];
    spring_backer = [
        14 + x_strike,
        2.54,
        male_pin_holder_spring_thickness];
    split = [x_split_male_pin_holder, 10, 0.5];
    split_front = [1, 10, 2.54/2+0.2];
    //latch_release = [2.54, 2.54, z_latch_release];
    stop_block = [
        x_strike + x_detent + x_wire_barrel + x_wire_wrap - y_lower_jaw_anvil/2, 
        6, 
        spring_backer.z];
    color("orange", alpha_male_pin_holder) {
        difference() {
            union() {
                block(body, center=BEHIND);
                translate([0, 0, -2.54/2]) block(spring, center=ABOVE+FRONT);
                translate([-14, 0, 2.54/2])block(spring_backer, center=ABOVE+FRONT);
                
                translate([0, 0, +2.54/2]) block(spring, center=BELOW+FRONT);
                translate([-14, 0, -2.54/2]) block(spring_backer, center=BELOW+FRONT);
                translate([x_strike + latch_dx, 0, 0]) block(latch, center=ABOVE+FRONT);
                translate([0, -2.54/2, 2.54/2]) block(stop_block, center=RIGHT+FRONT+ABOVE);
            }
            translate([1, 0, 0]) rod(d=d_pin+d_pin_clearance, l=x_pin+2, center=BEHIND, $fn=12);
            translate([1, 0, 1.5]) block(split, center=BEHIND+BELOW);
            block(split_front, center=FRONT+ABOVE);
        }
    }
}




module jaw_yoke() {
    y_total = jaw_thickness + 2 * y_jaw_yoke;
    yoke_behind = [x_jaw_yoke_behind, y_total, z_jaw_yoke];
    yoke_front = [x_jaw_yoke_front, y_jaw_yoke, z_jaw_yoke];
    translation_ht_front = 0.70*yoke_front;
    translation_ht_behind = [-0.8*yoke_behind.x, 0.4*yoke_behind.y, 10];
    
    difference() {
        block(yoke_behind, center=ABOVE+BEHIND);
        center_reflect([0, 1, 0]) translate(translation_ht_behind) hole_through("M3");
    }

    center_reflect([0, 1, 0]) 
        translate([0, jaw_thickness/2, 0]) {
            difference() {
                block(yoke_front, center=ABOVE+FRONT+RIGHT);
                translate(translation_ht_front) hole_through("M3");
            }
        }
    
}
