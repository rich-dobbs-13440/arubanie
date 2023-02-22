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
include <nutsnbolts-master/cyl_head_bolt.scad>


/* [Boiler Plate] */

fa_bearing = 1;
fa_shape = 20;
infinity = 1000;


/* [Show] */
show_ = true;
show_gudgeon = false;
show_pintle = false;
show_removable_pin_clearance = false;
show_removable_pin_gudgeon_bearing = false;
show_pintle_external_nut_catch = false;


/* [Example] */

// Height of connecting linkages
h_ = 8; // [4 : 10]
//Width of the connecting linkages
w_= 5; // [4 : 10]           
// Pintle length measured from the pivot center.
lp_ = 10; // [-1 : 20]          
// Gudgeon length measured from the pivot center.
lg_ = 20; // [-1 : 20]              
// Size of gaps in the part for printability.
allowance_ = 0.4; // [0.4 : 0.05 : 0.6] 
// Range of motion above and below the horizontal plain.
top_range_ = 135; //[60 : 5: 175] 
bottom_range_ = 135; //[60 : 5: 175]  
pin_ = "permanent pin";
// Angle for positioning the pintle.
angle_ = 0; // [-180 : 5 : +180]  

catch_strength_l = w_/2;


module end_of_customization() {}

// ------------------------ Start of demonstration -------------------------------
if (show_removable_pin_clearance) {
    removable_pin_clearance(
        h_, 
        w_, 
        lp_, 
        allowance_, 
        catch_strength_l, 
        catch_max_l=5);
}


if (show_) {
    small_pivot_vertical_rotation(
        h_, 
        w_, 
        lp_, 
        lg_, 
        allowance_, 
        range=[top_range_, bottom_range_], 
        angle=angle_);    
}


if (show_gudgeon) {
    color("ForestGreen", alpha=0.5) 
        gudgeon(
            h_, 
            w_, 
            lg_, 
            allowance_, 
            [top_range_, bottom_range_]);
}


if (show_pintle) {
    color("CornflowerBlue", alpha=0.5) 
        pintle(
            h_, 
            w_, 
            lp_, 
            allowance_, 
            [top_range_, bottom_range_],
            pin=pin_);    
}


if (show_pintle_external_nut_catch) {
    w = 6;
    h = 8;
    difference() {
        translate([0, w/2, 0]) crank([8, w/2, h], center=RIGHT);
        pintle(
            h=h, 
            w=w, 
            l=20,
            al=0.4,
            pin="M3 captured nut",
            just_pin_clearance=true); 
    } 
    pintle(
        h=h, 
        w=w, 
        l=16,
        al=0.4,
        pin="M3 captured nut"); 
    
    gudgeon(
        h=h, 
        w=w, 
        l=16,
        al=0.4,
        pin="M3 captured nut"); 
}

// ------------------------ Start of Implementation -------------------------------


function _nominal_diameter(h, w, l, al) = h/2;
function _pin_od(h, w, l, al)           = _nominal_diameter(h, w, l, al) - al/2;
function _bushing_id(h, w, l, al)       = _nominal_diameter(h, w, l, al) + al/2;

function _bushing_width(h, w, l, al)    = w/2 - al;
function _leaf_width_total(h, w, l, al) = w/2 - al;
function _leaf_width(h, w, l, al)       = _leaf_width_total(h, w, l, al)/2;
function _leaf_disp(h, w, l, al)        = w/2 -_leaf_width(h, w, l, al);

function check_assertions(h, w, l, allowance, range_of_motion) =
    assert(is_num(h), "You must specify the argument h, which is the pivot height") 
    assert(is_num(w), "You must specify the argument w, which is the pivot width") 
    assert(is_num(l), "You must specify the argument l, which is the pivot length") 
    assert(is_num(allowance)) 
    
    assert(is_num(range_of_motion[0])) 
    assert(is_num(range_of_motion[1])) 
    assert(len(range_of_motion) == 2) 
    
    assert(h > 4 * allowance, "Height is too small compared to allowance.") 
    assert(h > 2, "Height is too small for 3D printing.")
    assert(w < 20, "Width is too large.  This design target to smaller uses.")
    true;


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

module build_pintle(        
        h, 
        w, 
        l, 
        al, 
        range_of_motion, 
        pin) {
            
    module blank(size, hole=-1) {
        if (l >=0) {
            if (hole > 0) {
                crank(size, hole=hole, fa=fa_shape);
            }
            else {
                crank(size, fa=fa_shape);
            }
        } else {
            if (hole > 0) {
                rod(d=h, l=size.y, hollow=hole, center=SIDEWISE);
            } else {
                rod(d=h, l=size.y, center=SIDEWISE);
            }
        }
    }
            
    leaf_width = _leaf_width(h, w, l, al);
    leaf_disp = _leaf_disp(h, w, l, al);
    pin_od = _pin_od(h, w, l, al);
            
    // The pin
    if (pin == "permanent pin") {
        rod(pin_od, l=w, center=SIDEWISE, fa=fa_bearing);
    }
    // The leafs
    size = [l, leaf_width, h];
    for (disp_sign = [-1, 1]) {
    translate([0, disp_sign*(leaf_disp + leaf_width/2) , 0]) {
            if (pin == "permanent pin") {
                blank(size);
            } else if (pin == "M3 captured nut") {
                difference() {
                    blank(size);
                    // The pintle is thinner, so make it the bearing surface
                    // that is round.
                    $fn = 20;
                    translate([0, -w/2, 0]) rotate([90, 0, 0]) hole_through(name = "M3", l=w); 
                        // name of screw family (i.e. M4, M5, etc)
//                        l    = 50.0,  // length of main bolt
//                        cld  =  0.2,  // dia clearance for the bolt
//                        h    =  0.0,  // height of bolt-head
//                        hcld =  1.0)  // dia clearances for the head
                }
            } else {
                blank(size, hole=pin_od+al/2);
            }
        }
    }
   
    // Block joining the leafs
    assert(is_num(range_of_motion[0]));
    assert(is_num(range_of_motion[1]));
    top_stop = range_of_motion[0]-180;
    bottom_stop = 180-range_of_motion[1];
    stops =  [bottom_stop, top_stop];
    difference() {
        block([l, w, h], center=FRONT);
        cutout_for_rotation_stops(h, w, l, al, stops);
    }
}


module build_pin_clearance(w, pin) {
    if (pin == "M3 captured nut") {
        // Create a nut capture flush with the outer leafs, 
        // clk 0.4 is pretty loose. clk 0.0 was too tight with my printer
        // 
        translate([0, -2*w, 0]) rotate([90, 0, 0]) hole_through(name = "M3", l=4*w);
        translate([0, -0.50*w, 0]) rotate([-90,0,0]) nutcatch_parallel("M3", clh=w, clk=0.2);
        translate([0, 0.50*w, 0]) rotate([90,0,0]) nutcatch_parallel("M3", clh=w, clk=0.2);
    } else {
        assert(false, "Not implemented");
    }   
    
}


module pintle(
        h, 
        w, 
        l, 
        al=0.4, 
        range_of_motion=[135, 135], 
        pin="permanent pin",
        just_pin_clearance=false) {

    dmy = check_assertions(h, w, l, al, range_of_motion);
     
    if (just_pin_clearance) {
        build_pin_clearance(w, pin);
    } else {
        build_pintle(h, w, l, al, range_of_motion, pin);
    }
}


module gudgeon(
        h, 
        w, 
        l, 
        al=0.5, 
        range_of_motion=[135, 135],
        pin="permanent pin") {

    dmy = check_assertions(h, w, l, al, range_of_motion);
            
            
    bushing_id = _bushing_id(h, w, l, al); 
    bushing_width = _bushing_width(h, w, l, al);
    size = [l, bushing_width, h];
    // The main crank
    if (pin == "permanent pin") {
        crank(size, hole=bushing_id, rotation=BEHIND, fa=fa_shape, rank=3);
    } else if (pin == "M3 captured nut") {
        difference() {
            crank(size, rotation=BEHIND, fa=fa_shape);
            // The gudgeon is thicker, so make the hole rough to catch the screw thread
            translate([0, -w, 0]) rotate([90, 0, 0]) {
                $fn = 6; 
                hole_through(name = "M3", l=2*w);
            };
        }
    }
    
    // The shoulders  
    top_stop = -range_of_motion[0];
    bottom_stop = range_of_motion[1];
    stops = [bottom_stop, top_stop];   
    difference() {
        block([l, w, h], center=BEHIND, rank=2);
        cutout_for_rotation_stops(h, w, l, al, stops);
    }
}


module small_pivot_vertical_rotation(
        h, w, lp, lg, allowance, range=[135, 135], angle=0) {
    al = allowance;
    rotate([0, angle, 0]) pintle(h, w, lp, al, range);
    gudgeon(h, w, lg, al, range);
}

