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
use <vector_operations.scad>

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
        

function bw_lshift(number, places) = 
    number * pow(2, places);
    
function bw_rshift(number, places) = 
    floor(number / pow(2, places));
    
function bw_extract(number, places, bits) = 
    bw_rshift(number, places) % pow(2, bits);

// A bit less brain-damaged primative shapes

CENTER = 0;   
PLUS = 1;
MINUS = 2;

FRONT = 1;
BEHIND = 2; 
RIGHT = 4;
LEFT =  8;    
ABOVE = 16;
BELOW = 32;
SIDEWISE = 64;

_X_BITS = [0, 2];
_Y_BITS = [2, 2];
_Z_BITS = [4, 2];
_O_BITS = [6, 1];

_XYZO_BITMAP = [_X_BITS, _Y_BITS, _Z_BITS, _O_BITS];

function _center_to_bitvector(center) = [ 
    for (i = [0:3]) let(places = _XYZO_BITMAP[i][0], bits = _XYZO_BITMAP[i][1]) 
       bw_extract(center, places, bits) 
];
    

function _bv_to_sign(bv) = [
    for (i = [0:3]) 
        bv[i] == PLUS ? 1 :
        bv[i] == MINUS ? -1 : 0
];
    

function _center_to_dv(center, s, bv) = [
    for (i = [0:len(s)-1]) s[i] * bv[i]
];
    
function _center_to_displacement(center, size) = 
    _center_to_dv(
        center, 
        v_mul_scalar(size, 0.5), 
        _bv_to_sign(_center_to_bitvector(center)));    


/* 
    Block is a cube with a specific translation about the origin.
    
    Example usage:
    
    size = [10, 2, 6];
    cuboid(size); // Centered on X, Y, & Z axises
    
    block(size, center=ABOVE); // Centered on X, Y axises
    block(size, center=ABOVE+FRONT); // Centered on X
    block(size, center=ABOVE+FRONT+LEFT); // One corner is at origin
    
*/
module block(size, center=0) { 
    disp = _center_to_displacement(center, size);
    translate(disp) cube(size, center=true);  
}



/*
    Rod is a cylinder on its edge, with a specific translation 
    about the origin and orientation.

    Example usage:

    rod(d=10, l=20, center = FRONT);
    rod(d=10, l=20, center = SIDEWISE + FRONT + ABOVE + LEFT);

*/

module rod(d, l, center=0, hollow=false) {
    bv = _center_to_bitvector(center);
    is_sideways = bv[3] == 1;
    x = is_sideways ? d : l;
    y = is_sideways ? l : d;
    z = d;
    size=[x, y, z];
    disp = _center_to_displacement(center, size);
    a = is_sideways ? 90 : 0;
    translate(disp) {
        rotate([0, 0, a])
        rotate([0, 90, 0])
        if (hollow == false) {
            cylinder(d=d, h=l, center=true);
        } else if (is_num(hollow)) {
            render() difference() {
                cylinder(d=d, h=l, center=true);
                cylinder(d=hollow, h=2*l, center=true);
            }
        } else {
            assert(false, str("Don't know how to handle hollow=", hollow));
        } 
    }  
    
}

/*
    Can  is a cylinder on its end, with a specific translation 
    about the origin.
    
*/
module can(d,h, center=0, hollow=false) {
    bv = _center_to_bitvector(center);
    size = [d, d, h];
    disp = _center_to_displacement(center, size);
    translate(disp) {
        if (hollow == false) {
            cylinder(d=d, h=h, center=true); 
        } else if (is_num(hollow)) {
            render() difference() {
                cylinder(d=d, h=h, center=true);
                cylinder(d=hollow, h=2*h, center=true);
            }
        } else {
            assert(false, str("Don't know how to handle hollow=", hollow));
        }  
    }  
}


module _visual_test_rod_single_attribute(
    d, l, a) {
    
    color("SteelBlue", alpha = a) 
    rod(d=d, l=l, center=BEHIND); 

    color("FireBrick", alpha = a) 
    rod(d=d, l=l, center=FRONT);

    color("Lavender", alpha = a)   
    rod(d=d, l=l, center=LEFT);

    color("RosyBrown", alpha = a)        
    rod(d=d, l=l, center=RIGHT);

    color("Aqua", alpha = a)   
    rod(d=d, l=l, center=ABOVE);

    color("blue", alpha = a)        
    rod(d=d, l=l, center=BELOW);
}
 * _visual_test_rod_single_attribute(10, 20, 0.5);

module _visual_test_all_octants(d, l, use_sideways, alpha) {
    colors = [
        [
            ["red", "orange"],
            ["yellow", "green"]
        ],
        [
            ["IndianRed", "LightSalmon"],
            ["Khaki", "LightGreen"]
        ]
    ];
    a_sideways = use_sideways ? SIDEWISE : 0;
    
    function i_x(x) = x == BEHIND ? 0 : 1;
    function i_y(y) = y == LEFT ? 0 : 1;
    function i_z(z) = z == ABOVE ? 0 : 1;
    
    function map_to_color(x, y, z) = colors[i_x(x)][i_y(y)][i_z(z)];
    for (x_a = [BEHIND, FRONT]) {
        for (y_a = [LEFT, RIGHT]) {
            for (z_a = [ABOVE, BELOW]) {
                color(map_to_color(x_a, y_a, z_a), alpha=alpha)        
                rod(d=d, l=l, center=x_a+y_a+z_a+a_sideways);                
            }
        }
    }
    
}
* _visual_test_all_octants(10, 20, false, 0.5);


module construct_plane(vector, orientation, extent=100) {
    axis_offset = v_o_dot(vector, orientation);
    normal = [1, 1, 1] - orientation;
    plane_size = v_mul_scalar(normal, extent) + [0.1, 0.1, 0.1];
    color("gray", alpha=0.05) translate(axis_offset) cube(plane_size, center=true);
}

module display_vector(vector, color_of_v) {
    color("black") hull() {
        sphere(r= 0.1);
        translate(vector) sphere(0.1);
    }
    color(color_of_v, alpha=0.50) hull() {
        sphere(r=eps);
        translate(vector) sphere(1);
    }
}