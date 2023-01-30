/* 
    Usage:

        use <small_pivot_vertical_rotation.scad>
    
        small_pivot_vertical_rotation(
            h, w, lp, lg, allowance, angle=0)
        
    Arguments:
        h           height of connecting linkages
        w           width of the connecting linkages
        lp          pintle length measured from the pivot center.
        lg          gudgeon length measured from the pivot center.
        allowance   size of gaps in the part for printability.
           
    Notes:
    
        The pintle is the part with a pin in it.
        The gudgeon is the part that contains the bushing that rotates. 
        
        Currently angle rotates the pintle, with an angle of 0 degrees
        corresponding to the pintle going in along the positive x axis.
        
        
        
    
*/




include <not_included_batteries.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>
include <logging.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

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
    top_pintle = range[0]-180;
    bottom_pintle = 180-range[0];
    gudgeon_stops = [bottom_gudgeon, top_gudgeon];
    pintle_stops =  [bottom_pintle, top_pintle];
    
    al = allowance;
    rotate([0, angle, 0]) pintle(h, w, lp, al, pintle_stops);
    gudgeon(h, w, lg, al, gudgeon_stops);
}

* small_pivot_vertical_rotation(5, 10, 20, 30, 0.3, range=[150, 135], angle=0);
