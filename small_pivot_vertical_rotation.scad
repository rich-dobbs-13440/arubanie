include <not_included_batteries.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>
include <logging.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;


/* [Show] */
show_pivot = true;
show_pintle_assembly = false;
show_gudgeon_assembly = false;
show_cutout_for_rotation_stop = false;

angle = 0; // [-180 : +180]

/* [Dimensions] */
allowance = 0.3; // [0:0.1:1.2]
height = 5; // [2:1:10]
width = 5; // [2:1:10]
length = 50; //[0:1:400]

function _nominal_diameter(h, w, l, al) = h/2;
function _pin_od(h, w, l, al)           = _nominal_diameter(h, w, l, al) - al;
function _bushing_id(h, w, l, al)       = _nominal_diameter(h, w, l, al) + al;

function _bushing_width(h, w, l, al)    = w/2 - al;
function _leaf_width_total(h, w, l, al) = w/2 - al;
function _leaf_width(h, w, l, al)       = _leaf_width_total(h, w, l, al)/2;
function _leaf_disp(h, w, l, al)        = w/2 -_leaf_width(h, w, l, al);


module cutout_for_rotation_stop(h, w, l, al) {
    //translate([0, 0, disp])
    rotate([0, 45, 0]) 
    block([h, 2*w, l]);
    
    rotate([0, -45, 0]) 
    block([h, 2*w, l]);   
}

if (show_cutout_for_rotation_stop) {
    cutout_for_rotation_stop(height, width, length, allowance);
}

module pintle(h, w, l, al) {
    
    leaf_width = _leaf_width(h, w, l, al);
    leaf_disp = _leaf_disp(h, w, l, al);
    pin_od = _pin_od(h, w, l, al);
    
    // The pin
    rod(pin_od, l=w, center=SIDEWISE);
    
    // Left outer leaf
    translate([0, -leaf_disp, 0]) {
        block([l/2, leaf_width, h], center=LEFT+FRONT);
        rod(h, l=leaf_width, center=SIDEWISE+LEFT);
    }
    
    // Right outer leaf
    translate([0, leaf_disp, 0]) {
        block([l/2, leaf_width, h], center=RIGHT+FRONT);
        rod(h, l=leaf_width, center=SIDEWISE+RIGHT);
    } 
   
    // Block joining the leafs
    difference() {
        block([l/2, w, h], center=FRONT);
        cutout_for_rotation_stop(h, w, l, al);
    }
}

if (show_pintle_assembly) {
    rotate([0, angle, 0]) 
    color("red", alpha =0.25) 
    pintle(height, width, length, allowance);
}

module gudgeon(h, w, l, al) {
        
    bushing_id = _bushing_id(h, w, l, al); 
    bushing_od = h;
    bushing_width = _bushing_width(h, w, l, al);

    rod(bushing_od, l=bushing_width, center=SIDEWISE, hollow=bushing_id);
    
    // Center leaf
    difference() {
        block([l/2, bushing_width, h], center=BEHIND);
        rod(bushing_od, l=2*w, center=SIDEWISE);
    } 
    
    // Connector body  
    difference() {
        block([l/2, w, h], center=BEHIND);
        cutout_for_rotation_stop(h, w, l, al);
    }
}

if (show_gudgeon_assembly) {
    gudgeon(height, width, length, allowance);
}

module small_pivot_vertical_rotation(h, w, l, allowance) {
    
    assert(h > 4 * allowance, "Height is too small compared to allowance.");
    assert(h > 2, "Height is too small for 3D printing.");
    assert(w < 20, "Width is too large.  This design target to smaller uses.");
    
    al = allowance;
    
    pintle(h, w, l, al);
    gudgeon(h, w, l, al);
  
}

if (show_pivot) {
    small_pivot_vertical_rotation(height, width, length, allowance);
}
