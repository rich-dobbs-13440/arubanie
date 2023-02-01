/* 
    Usage:

        use <small_pivot_vertical_rotation.scad>
    

        small_pivot_vertical_rotation(
            h, w, lp, lg, allowance, range=[top, bottom], angle=0) {

        
    Arguments:
        h           Height of connecting linkages
        w           Width of the connecting linkages
        lp          Pintle length measured from the pivot center.
        lg          Gudgeon length measured from the pivot center.
        allowance   Size of gaps in the part for printability.
        range       Range of motion above and below the horizontal plain.
                    Defaults to [135, 135]
        angle       Angle for positioning the pintle.  
           
    Notes:
    
        The pintle is the part with a pin in it.
        The gudgeon is the part that contains the bushing that rotates. 
        
        Currently angle rotates the pintle, with an angle of 0 degrees
        corresponding to the pintle going in along the positive x axis.
        
        
        
    
*/

include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>


/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Example] */

show_example = true;
// Height of connecting linkages
h_example = 4; // [4 : 10]
//Width of the connecting linkages
w_example = 4; // [4 : 10]           
// Pintle length measured from the pivot center.
lp_example = 10; // [0 : 20]          
// Gudgeon length measured from the pivot center.
lg_example = 20; // [0 : 20]              
// Size of gaps in the part for printability.
allowance_example = 0.4; // [0.4 : 0.05 : 0.6] 
// Range of motion above and below the horizontal plain.
top_range_example = 135; //[60 : 5: 175] 
bottom_range_example = 135; //[60 : 5: 175]  
// Angle for positioning the pintle.
angle_example = 0; // [-180 : 5 : +180]   



module end_of_customization() {}

function _nominal_diameter(h, w, l, al) = h/2;
function _pin_od(h, w, l, al)           = _nominal_diameter(h, w, l, al) - al;
function _bushing_id(h, w, l, al)       = _nominal_diameter(h, w, l, al) + al;

function _bushing_width(h, w, l, al)    = w/2 - al;
function _leaf_width_total(h, w, l, al) = w/2 - al;
function _leaf_width(h, w, l, al)       = _leaf_width_total(h, w, l, al)/2;
function _leaf_disp(h, w, l, al)        = w/2 -_leaf_width(h, w, l, al);


module rotation_stop(h, w, angle, al) {
    rotate([0, angle, 0]) {
        rod(d=h+2*al, l=1.1*w, center=SIDEWISE);
        block([10*h, 1.1*w, h+2*al], center=FRONT);
    }
    
}


module cutout_for_rotation_stops(h, w, l, al, stops) {

    assert(is_list(stops));
    for (stop = stops) {
        rotation_stop(h, w, stop, al); 
    } 
}


module pintle(h, w, l, al, stops) {

    leaf_width = _leaf_width(h, w, l, al);
    leaf_disp = _leaf_disp(h, w, l, al);
    pin_od = _pin_od(h, w, l, al);
    
    // The pin
    rod(pin_od, l=w, center=SIDEWISE);
    
    // Left outer leaf
    translate([0, -leaf_disp, 0]) {
        block([l, leaf_width, h], center=LEFT+FRONT);
        rod(h, l=leaf_width, center=SIDEWISE+LEFT);
    }
    
    // Right outer leaf
    translate([0, leaf_disp, 0]) {
        block([l, leaf_width, h], center=RIGHT+FRONT);
        rod(h, l=leaf_width, center=SIDEWISE+RIGHT);
    } 
   
    // Block joining the leafs
    difference() {
        block([l, w, h], center=FRONT);
        cutout_for_rotation_stops(h, w, l, al, stops);
    }
}


module gudgeon(h, w, l, al, stops) {
       
    bushing_id = _bushing_id(h, w, l, al); 
    bushing_od = h;
    bushing_width = _bushing_width(h, w, l, al);

    rod(bushing_od, l=bushing_width, center=SIDEWISE, hollow=bushing_id);
    
    // Center leaf
    difference() {
        block([l, bushing_width, h], center=BEHIND);
        rod(bushing_od, l=2*w, center=SIDEWISE);
    } 
    
    // Connector body  
    difference() {
        block([l, w, h], center=BEHIND);
        cutout_for_rotation_stops(h, w, l, al, stops);
    }
}


module small_pivot_vertical_rotation(
        h, w, lp, lg, allowance, range=[135, 135], angle=0) {
    
    assert(is_num(h));
    assert(is_num(w));
    assert(is_num(lp));
    assert(is_num(lg));
    assert(is_num(allowance));
    assert(is_num(angle));
    
    assert(is_num(range[0]));
    assert(is_num(range[1]));
    assert(len(range) == 2);
    
    assert(h > 4 * allowance, "Height is too small compared to allowance.");
    assert(h > 2, "Height is too small for 3D printing.");
    assert(w < 20, "Width is too large.  This design target to smaller uses.");
    
//    warn(
//        lp >= 2.5*h,
//        "lp >= 2.5*h",
//        "Pintle length should be at least 2.5 times the height.",
//        "The length is not sufficient to correctly implement rotation stops."
//    );
//    warn(
//        lg >= 2.5*h,
//        "lp >= 2.5*h",
//        "Gudgeon length must be at least 2.5 times the height",
//        "The length is not sufficient to correctly implement rotation stops."
//    );
//    

    top_gudgeon = -range[0];
    bottom_gudgeon = range[1];
    assert(!is_undef(bottom_gudgeon));
    top_pintle = range[0]-180;
    bottom_pintle = 180-range[0];
    gudgeon_stops = [bottom_gudgeon, top_gudgeon];
    pintle_stops =  [bottom_pintle, top_pintle];
    
    al = allowance;
    rotate([0, angle, 0]) pintle(h, w, lp, al, pintle_stops);
    gudgeon(h, w, lg, al, gudgeon_stops);
}

if (show_example) {
    small_pivot_vertical_rotation(
        h_example, 
        w_example, 
        lp_example, 
        lg_example, 
        allowance_example, 
        range=[top_range_example, bottom_range_example], 
        angle=angle_example);    
}
