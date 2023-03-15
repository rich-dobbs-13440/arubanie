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
show_top_level = true;
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




