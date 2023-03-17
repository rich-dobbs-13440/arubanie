

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



wire_diameter = 1.66; // Includes insulation
d_wire_conductor = 1.13;
exposed_wire = 2.14; 









/* [Design] */



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
/* [Retainer Washer Design] */
// This how thick the washer is
y_retainer_washer = 0.5; // [0:0.05:1]
// This is the thickness of the washer surface
dy_retainer_washer = 0.40; // [0:0.05:1]
padding_retainer_washer = 2;


/* [Show] */
orient = "For build"; //["As designed", "As assembled", "For build"]
orient_for_build = orient == "For build";
show_jaw_yoke = true;

show_male_pin_holder = true;

show_retainer_washer = true;

/* [Show Mocks] */
show_male_pin = false;
show_lower_jaw = true;
show_lower_jaw_anvil = true;
show_lower_jaw_anvil_retainer = true;


module end_of_customization() {}



/* [Pin Measurements] */
    d_pin = 0.50; 
    x_pin = 6.62;
    // The strike is what keeps the pin from being removed from the housing 
    x_strike_mp = 3.22;
    y_strike_mp = 1.75;
    z_strike_mp = 1.80;
    // The detent is the area that can be caught by something to retain the housing 
    x_detent_mp =  0.8;
    y_detent_mp = 1.65;
    z_detent_mp = 0.56;
    x_wire_barrel_mp = 2.79;
    od_wire_barrel_mp = 1.55;
    x_wire_wrap_mp = 3.79;
    y_wire_wrap_mp = 2.00;
    z_wire_wrap_mp = 1.73;
    x_insulator_wrap_mp = 2.18;
    y_insulator_wrap_mp = 2.77;
    z_insulator_wrap_mp =  2.46;


    
/* [Jaw Measurements] */
 

/* 

Origin will be at center_line of jaw at the front, with jaw being on the 
x axis, with x being positive as you go deeper into the jaw.
*/
    jaw_thickness = 7.33;
    front_to_front_of_25 = 3.42;
    front_to_back_of_25 = 5.24;
    lower_jaw_height = 1.81;
    x_lower_jaw_anvil = 23.4;
    y_lower_jaw_anvil =7.21;
    z_lower_jaw_anvil = 7.05;   
    lower_jaw_anvil_blank = [x_lower_jaw_anvil, y_lower_jaw_anvil, z_lower_jaw_anvil]; 

dx_025_anvil = 3.63;    

/* [Anvil Retainer Dimension] */
    x_anvil_retainer = 17.09;
    y_anvil_retainer = 4.18;
    z_anvil_retainer = 9.6;
    anvil_retainer_extent = [x_anvil_retainer, y_anvil_retainer, z_anvil_retainer];
    w_rim_ar = 2.28; 
    d_screw_hole_ar = 5.12;
    d_rim_ar = d_screw_hole_ar + 2*w_rim_ar;
    z_axis_ar = z_anvil_retainer - w_rim_ar - d_screw_hole_ar/2;
    y_web_ar = 2.69;
    x_inset_ar = 10.88;
    y_inset_ar = (y_anvil_retainer - y_web_ar) / 2;
    
if (show_lower_jaw) {
   rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 0]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, 0] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 0]: 
        assert(false);    
    translate(translation) rotate(rotation) jaw();
}

module jaw() {
    dy_between_jaw_sides = 4.6;
    x_jaw = 24;
    y_jaw = 2.5;
    z_jaw = 14.1;
    color("SlateGray") {
        center_reflect([0, 1, 0]) {
            render(convexity = 10) difference() {
                translate([-0.5, dy_between_jaw_sides/2]) { 
                    hull() {
                        translate([0, 0, 0]) block([x_jaw, y_jaw, 0.01], center=ABOVE+RIGHT+FRONT);
                        block([0.01, y_jaw, 7.3], center=ABOVE+RIGHT+FRONT);
                        translate([9, 0, 0]) block([0.01, y_jaw, 12.6], center=ABOVE+RIGHT+FRONT);
                        translate([x_jaw, 0, 0]) block([0.01, y_jaw, z_jaw], center=ABOVE+RIGHT);
                    }
                    
                }
                translate([x_lower_jaw_anvil/2, 0, z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE+RIGHT);
            }
        }  
    }
}
    
if (show_retainer_washer) {
   rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 90]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, 0] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 0]: 
        assert(false);    
    translate(translation) rotate(rotation) retainer_washer();
}

module retainer_washer() {
    washer = [
        x_anvil_retainer + 2 * padding_retainer_washer, 
        y_retainer_washer, 
        z_anvil_retainer + padding_retainer_washer
    ];
    
    difference() {
        block(washer, center=BELOW+RIGHT, rank=-5);
        translate([0, y_anvil_retainer/2+dy_retainer_washer, 0]) anvil_retainer();
        translate([0, 0, -z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE+RIGHT);
    }
}

if (show_lower_jaw_anvil_retainer) {
    rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 90]: 
        assert(false, assert_msg("orient: ", orient));
    dy_assembly = -(x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp);
    translation = 
        orient_for_build ? [0, 0, 2.54/2] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [dx_025_anvil, dy_assembly, z_lower_jaw_anvil]: 
        assert(false);
    translate(translation) rotate(rotation) anvil_retainer();
}

module anvil_retainer() {
    color("SlateGray") {

        render(convexity=10) difference() {
            hull() {
                block([x_anvil_retainer, y_anvil_retainer, 0.01], center=BELOW);
                translate([0, 0, -z_axis_ar]) rod(d=d_rim_ar, l=y_anvil_retainer, center=SIDEWISE);
            }
            translate([0, 0, -z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE);
            center_reflect([0, 1, 0]) {
                translate([0, y_web_ar/2, 0]) {
                    hull() {
                        block([x_inset_ar, 10, 0.01], center=BELOW+RIGHT, rank=5);
                        translate([0, 0, -z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE+RIGHT);
                    }
                }
            }
        }
    }
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
            block(lower_jaw_anvil_blank, center=ABOVE+FRONT);    
            pin_side_25_mold();
            wire_side_25_mold();
        }
    }
    translate([x_lower_jaw_anvil/2, 0, 0]) anvil_retainer();
    
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
    dy_assembly = -(x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp);
    translation = 
        orient_for_build ? [0, 0, 2.54/2] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [dx_025_anvil_mp, dy_assembly, z_lower_jaw_anvil]: 
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
    spring = [x_strike_mp + x_detent_mp, 2.54, (2.54-z_strike_mp)/2];
    latch_x = x_detent_mp * (1-clearance_fraction);
    latch_dx = (x_detent_mp * clearance_fraction)/2;
    latch = [latch_x, 2.54, 2.54/2];
    spring_backer = [
        14 + x_strike_mp,
        2.54,
        male_pin_holder_spring_thickness];
    split = [x_split_male_pin_holder, 10, 0.5];
    split_front = [1, 10, 2.54/2+0.2];
    //latch_release = [2.54, 2.54, z_latch_release];
    stop_block = [
        x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp - y_lower_jaw_anvil/2, 
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
                translate([x_strike_mp + latch_dx, 0, 0]) block(latch, center=ABOVE+FRONT);
                translate([0, -2.54/2, 2.54/2]) block(stop_block, center=RIGHT+FRONT+ABOVE);
            }
            translate([1, 0, 0]) rod(d=d_pin+d_pin_clearance, l=x_pin+2, center=BEHIND, $fn=12);
            translate([1, 0, 1.5]) block(split, center=BEHIND+BELOW);
            block(split_front, center=FRONT+ABOVE);
        }
    }
}

if (show_jaw_yoke) {
    jaw_yoke(); 
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
