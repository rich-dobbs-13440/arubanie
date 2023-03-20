/*

use <lib/dupont_pins.scad>

w_h = DUPONT_HOUSING_WIDTH();
l_hsg_std = DUPONT_HOUSING_WIDTH();
l_h_short = DUPONT_SHORT_HOUSING();

l_hdr = function DUPONT_HEADER() = 2.5; 
l_hdr_clrnc =  DUPONT_HEADER_CLEARANCE();
l_pin = function DUPONT_PIN_LENGTH();
w_pin =  DUPONT_PIN_SIZE();
d_wire = DUPONT_WIRE_DIAMETER();

dupont_connector(
    wire_color="yellow", 
    housing_color="black",         
    center=ABOVE,
    housing=DUPONT_STD_HOUSING(),
    has_pin=false);

*/
include <centerable.scad>
use <shapes.scad>

/* [Housing Length] */

housing_ = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

/* [Show] */
show_top_level = false;
delta_ = 7;

module end_customization() {}



function DUPONT_HOUSING_WIDTH() = 2.54; // Tenth of an inch
function DUPONT_STD_HOUSING() = 14.0; //mm
function DUPONT_SHORT_HOUSING() = 12.0; // mm
function DUPONT_HEADER() = 2.5; // mm
function DUPONT_HEADER_CLEARANCE() = 0.2; // mm
function DUPONT_PIN_LENGTH() = 7.8; // mm
function DUPONT_PIN_SIZE() = 0.7; // mm
function DUPONT_WIRE_DIAMETER() = 1.0; // mm


module x_position(idx) {
    if (show_top_level) {
        translate([delta_*idx, 0, 0]) children();
    }
}

// Usage Demo:

x_position(0) dupont_connector(housing=housing_);
x_position(1) dupont_connector();
x_position(2) dupont_connector(has_pin=true);
x_position(3)  dupont_connector("chartreuse", "salmon", ABOVE, DUPONT_SHORT_HOUSING());
x_position(4) dupont_connector(
        wire_color="pink", 
        housing_color="blue",         
        center=LEFT,
        housing=DUPONT_STD_HOUSING(),
        has_pin=true);

x_position(-1) rotate([0, 0, 90]) male_pin(); 
x_position(-2) rotate([0, 0, 90]) male_pin_holder(show_mock=true, z_spring=2);
x_position(-3) rotate([0, 0, 90]) male_pin_holder();

x_position(-7) male_pin_holder();


module dupont_connector(
        wire_color="yellow", 
        housing_color="black",         
        center=ABOVE,
        housing=DUPONT_STD_HOUSING(),
        has_pin=false) {    
    difference() {   
        union() {
            color(housing_color) block([DUPONT_HOUSING_WIDTH(), DUPONT_HOUSING_WIDTH(), housing], center = ABOVE, rank=10);
            color(wire_color) can(d=DUPONT_WIRE_DIAMETER(), h = housing + 8, center=ABOVE, rank=-3);
        }
        if (!has_pin) {
            can(d=DUPONT_PIN_SIZE() + 0.5, h = 0.1, taper=DUPONT_PIN_SIZE(), center=ABOVE, rank = 15);
        }
    }
    
    if (has_pin) {
        // For headers should make it square!
        color("silver") can(d=DUPONT_PIN_SIZE(), h = DUPONT_PIN_LENGTH(), center=BELOW);
    } 
           
}


/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
l_pin_strip = 115.1;
pin_count = 20;
delta_pin_strip = l_pin_strip / (pin_count -1);    

/* [Pin Measurements] */

/*
    Parts of a pin as I've named them

    pin

    strike
    detent
    barrel 
    conductor_wrap
    insulation_wrap
    the strip with a hole in it.

*/

    wire_diameter = 1.66; // Includes insulation
    d_wire_conductor = 1.13;
    exposed_wire = 2.14; 
    
    
    d_pin = 0.6; 
    x_pin = 6.62;
    z_metal_pin = 0.2;
    // The strike is what keeps the pin from being removed from the housing 
    x_strike_mp = 3.22;
    y_strike_mp = 1.75;
    z_strike_mp = 1.80;
    // The detent is the area that can be caught by something to retain the housing 
    x_detent_mp =  0.8;
    y_detent_mp = 1.65;
    z_detent_mp = 0.56;
    x_barrel_mp = 2.79;
    od_barrel_mp = 1.55;
    x_conductor_wrap_mp = 3.79;
    y_conductor_wrap_mp = 2.00;
    z_conductor_wrap_mp = 1.73;
    x_insulation_wrap_mp = 2.18;
    y_insulation_wrap_mp = 2.88;
    z_insulation_wrap_mp =  2.46;
    y_insulation_wrap_bottom_mp = 1.58;
    x_strip_mp = 2.22;
    y_strip_mp = delta_pin_strip;
    z_strip_mp = z_metal_pin;
    d_strip_mp = 1.4;
    
    dx_detent_mp = x_strike_mp;
    dx_barrel_mp = dx_detent_mp + x_detent_mp;
    dx_conductor_wrap_mp = dx_barrel_mp + x_barrel_mp;
    dx_insulation_wrap_mp = dx_conductor_wrap_mp + x_conductor_wrap_mp;
    dx_strip_mp = dx_insulation_wrap_mp + x_insulation_wrap_mp;
    dx_strip_hole_mp = dx_strip_mp + x_strip_mp/2;
    
    x_pin_to_strip_edge = dx_strip_hole_mp + x_strip_mp;



module male_pin(alpha=1) {
    // Initially model pin before construction with pin on x_axis,
    // with the pin itself negative, and the parts used in assembly
    // increasing in the x domain.abs
    module wing(base, tip) {
        module bottom() {
            translate([0, base.y/2, -base.z]) rod(d=z_metal_pin, l=base.x); 
        }  
        module top() {
            translate([0, tip.y/2, tip.z]) rod(d = z_metal_pin, l = tip.x);                
        }
        translate([base.x/2, 0, 0]) {

            center_reflect([0, 1, 0]) { 
                hull() {
                    top();
                    bottom();
                }
            } 
            hull() {
                center_reflect([0, 1, 0]) bottom();  
            }
        }      
    } 
    
    module strike() {
        extent = [x_strike_mp, y_strike_mp, z_strike_mp];
        hull() {
            translate([x_strike_mp/2, 0, -z_strike_mp/2]) 
                block([x_strike_mp/2, y_strike_mp, z_metal_pin], center=ABOVE+FRONT);
            rod(d=d_pin, l=0.01, center=FRONT);
            block([z_metal_pin, z_metal_pin, z_metal_pin], center=FRONT);
            translate([x_strike_mp, 0, 0]) block([0.01, y_strike_mp, z_strike_mp], center=BEHIND);
        }
        
        //block(strike, center=FRONT);
    }
    module detent() {    
        bottom = [
            x_detent_mp,
            y_detent_mp,
            z_detent_mp
        ];
        
        translate([dx_detent_mp, 0, -y_detent_mp/2]) block(bottom, center=FRONT + ABOVE);
  
    }
    module barrel() {  
        translate([dx_barrel_mp, 0, 0])
            rod(d=od_barrel_mp, l=x_barrel_mp, hollow=od_barrel_mp-2*z_metal_pin, center=FRONT);
    }
    
    module conductor_wrap() {
        extent = [x_conductor_wrap_mp, y_conductor_wrap_mp, z_conductor_wrap_mp];
        
        translate([dx_conductor_wrap_mp, 0, 0]) 
            wing(
                [x_conductor_wrap_mp, wire_diameter, od_barrel_mp/2], 
                [0.8*x_conductor_wrap_mp, y_conductor_wrap_mp, z_conductor_wrap_mp - od_barrel_mp/2]); 
    }
    module insulation_wrap() {
        translate([dx_insulation_wrap_mp, 0, 0]) 
            wing(
                [x_insulation_wrap_mp, wire_diameter, od_barrel_mp/2], 
                [0, y_insulation_wrap_mp, z_insulation_wrap_mp - od_barrel_mp/2]);         
    } 
    module strip() {
        translate([dx_strip_mp, 0, -z_insulation_wrap_mp/2+2*z_metal_pin])
            difference() {
                block([x_strip_mp, y_strip_mp, z_metal_pin], center=FRONT);
                translate([x_strip_mp/2, 0, 0]) can(d=d_strip_mp, h=5);
            }
    }
    color("silver", alpha=alpha) {
        rod(d=d_pin, l=x_pin, center=BEHIND);
        strike();
        detent();
        barrel();
        conductor_wrap();
        insulation_wrap(); 
        strip();
    }  
}


module male_pin_holder(
        show_mock=true, 
        z_spring = 2.54, 
        x_stop = dx_barrel_mp, 
        d_pin_clearance = 0.4, 
        clearance_fraction=.1, 
        z_column=0, 
        dx_column=0, 
        latch_release_diameter = 2,
        latch_release_height = 2,
        color_name="orange", 
        alpha=1) {
    
    assert(!is_undef(z_column));
    assert(!is_undef(x_stop));
    assert(!is_undef(z_spring));
    assert(!is_undef(show_mock));
    
    body = [14, 2.54, 2.54];
    x_split = 7;
    z_split = 0.5;

    latch_x = x_detent_mp * (1-clearance_fraction);
    latch_dx = (x_detent_mp * clearance_fraction)/2;
    latch = [latch_x, body.y, body.z/2 + z_spring];
    spring = [
        body.x + x_strike_mp + x_detent_mp,
        body.y,
        z_spring];
    
    lower_body = [body.x + x_stop, body.y, body.z];

    split = [x_split, 10, z_split];
    split_front = [1, 10, body.z/2 + z_split];
    column = [body.y, body.y, z_column];
    
    
    module pin_clearance() {
        rod(d=d_pin+d_pin_clearance, l=100, $fn=12); 
    }

    color(color_name, alpha) {
        render(convexity=10) difference() {
            union() {
                block(body, center=BEHIND);
                
                translate([-body.x, 0, -body.z/2]) 
                    block(lower_body, center=BELOW+FRONT);                
                
                translate([-body.x, 0, body.z/2]) 
                    block(spring, center=ABOVE+FRONT);
                
                translate([0.75*x_strike_mp, 0, 0.75*body.z]) 
                    #rod(
                        d=latch_release_diameter, 
                        l = body.y/2 + latch_release_height, 
                        center=SIDEWISE+RIGHT+ABOVE, 
                        $fn=12);
                
                translate([x_strike_mp + latch_dx, 0, 0]) 
                    block(latch, center=ABOVE+FRONT);
                
                translate([dx_column, -body.y/2, -body.z/2]) 
                    block(column, center=RIGHT+FRONT+BELOW);
            }
            pin_clearance();
            
            // Bevel to make entrance easier!
            rod(d=d_pin, taper=d_pin+1, l=1, $fn=12, center=BEHIND);
            
            translate([1, 0, 2]) block(split, center=BEHIND+BELOW);
            block(split_front, center=FRONT+ABOVE);
        }
    }
    if (show_mock) {
        male_pin();
    }
}

