// function dupont_pin_width() = 2.54; // Using standard dimensions, rather than measured
// function dupont_pin_length() = 14.0; // Using standard dimensions, rather than measured
// function dupont_wire_diameter() = 1.25 ; // measured plus allowance
// function 

include <centerable.scad>
use <shapes.scad>

/* [Pin Length] */

pin_length = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

/* [Show] */
delta_ = 10;

module end_customization() {}

DUPONT_WIDTH = 2.54; // Tenth of an inch
DUPONT_STD_HOUSING = 14.0; //mm
DUPONT_SHORT_HOUSING = 12.0; // mm
DUPONT_HEADER = 2.5; // mm
DUPONT_HEADER_CLEARANCE = 0.2; // mm
DUPONT_PIN_LENGTH = 7.8;
DUPONT_PIN_SIZE = 0.7;
DUPONT_WIRE_DIAMETER = 1.0; // mm


module x_position(idx) {
    translate([delta_*idx, 0, 0]) children();
}

x_position(1) dupont_connector();
x_position(2) dupont_connector(has_pin=true);

x_position(3)  dupont_connector("chartreuse", "salmon", ABOVE, DUPONT_SHORT_HOUSING);
x_position(4) dupont_connector(
        wire_color="pink", 
        housing_color="blue",         
        center=LEFT,
        housing=DUPONT_STD_HOUSING,
        has_pin=true);


module dupont_connector(
        wire_color="yellow", 
        housing_color="black",         
        center=ABOVE,
        housing=DUPONT_STD_HOUSING,
        has_pin=false) {    
    difference() {   
        union() {
            color(housing_color) block([DUPONT_WIDTH, DUPONT_WIDTH, housing], center = ABOVE, rank=10);
            color(wire_color) can(d=DUPONT_WIRE_DIAMETER, h = housing + 4, center=ABOVE, rank=-3);
        }
        if (!has_pin) {
            can(d=DUPONT_PIN_SIZE + 0.5, h = 0.1, taper=DUPONT_PIN_SIZE, center=ABOVE, rank = 15);
        }
    }
    
    if (has_pin) {
        // For headers should make it square!
        color("silver") can(d=DUPONT_PIN_SIZE, h = DUPONT_PIN_LENGTH, center=BELOW);
    } 
           
}




