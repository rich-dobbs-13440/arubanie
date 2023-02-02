/*
     OpenSCAD does not have Python's "batteries included" philosophy.
     This is a collection point for things that help make 
     the language more productive out of the box.

     It is missing a standard library that transforms it from a 
     barebones language to a more productive, less frustrating 
     tool

     Expect that it will just use other files that do the actual
     implementation, since otherwise this will become quite bulky.
     However, will start by just implementing things here.

     Note:  This library is targeted toward use with 19.05.
     
     Usage:
     
     use <lib/not_included_batteries.scad>
*/  

include <TOUL.scad>
include <logging.scad>
use <centerable.scad>
use <vector_operations.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

module end_of_customization() {}

show_name = false;
if (show_name) {
    linear_extrude(2) text("not_included_batteries.scad", halign="center");
}

function find_all_in_kv_list(list_kvp, identifier) =  
    [ for (item = list_kvp) if (item[0] == identifier) item[1] ];
        
function _dct_assert_one_and_only(matches) = 
    assert(len(matches) < 2, "Not a dictionary! Multiple matches.")
    assert(len(matches) != 0, "No match found for key")
    matches[0];       
        
function find_in_dct(dct, key, required=false) =
    required ? 
        _dct_assert_one_and_only(find_all_in_kv_list(dct, key)) :
        find_all_in_kv_list(dct, key)[0];
        
module construct_plane(vector, orientation, extent=100) {
    axis_offset = v_o_dot(vector, orientation);
    normal = [1, 1, 1] - orientation;
    plane_size = v_mul_scalar(normal, extent) + [0.1, 0.1, 0.1];
    color("gray", alpha=0.05) translate(axis_offset) cube(plane_size, center=true);
}

module display_displacement(displacement, barb_color="black", shaft_color="black", label=undef) {
    barb_length = 3;
    barb_diameter = 0.5;
    fraction = 1-barb_length/norm(displacement);
    displacement_minus_barb = v_mul_scalar(displacement, fraction);

    color(shaft_color) hull() {
        sphere(r=0.3);
        translate(displacement_minus_barb) sphere(0.3);
    }

    color(barb_color) hull() {
        translate(displacement) sphere(eps);
        translate(displacement_minus_barb) sphere(barb_diameter);
    }

}