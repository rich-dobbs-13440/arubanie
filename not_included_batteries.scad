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
     
     use <not_included_batteries.scad>
*/  

include <TOUL.scad>
include <logging.scad>
use <vector_operations.scad>

function find_all_kvp(list_kvp, identifier) =  
    [ for (item = list_kvp) if (item[0] == identifier) item[1] ];
        
function dct_assert_one_and_only(matches) = 
    assert(len(matches) < 2, "Not a dictionary! Multiple matches.")
    assert(len(matches) != 0, "No match found for key")
    matches[0];       
        
function find_in_dct(dct, key, required=false) =
    required ? 
        dct_assert_one_and_only(find_all_kvp(dct, key)) :
        find_all_kvp(dct, key)[0];
        

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

X_BITS = [0, 2];
Y_BITS = [2, 2];
Z_BITS = [4, 2];
O_BITS = [6, 1];

XYZO_BITMAP = [X_BITS, Y_BITS, Z_BITS, O_BITS];

function _center_to_bitvector(center) = [ 
    for (i = [0:3]) let(places = XYZO_BITMAP[i][0], bits = XYZO_BITMAP[i][1]) 
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
    Cuboid is a cube with a specific translation about the origin.
    
    Example usage:
    
    size = [10, 2, 6];
    cuboid(size); // Centered on X, Y, & Z axises
    
    cuboid(size, center=ABOVE); // Centered on X, Y axises
    cuboid(size, center=ABOVE+FRONT); // Centered on X
    cuboid(size, center=ABOVE+FRONT+LEFT); // One corner is at origin
    
*/
module cuboid(size, center=0) { 
    disp = _center_to_displacement(center, size);
    translate(disp) cube(size, center=true);  
}



// Rod is a cylinder on its edge, with a specific translation 
// about the origin and orientation
module rod(d, l, center=0) {

    function m_x(center) = bw_extract(center, 0, 2) == PLUS ? 0.5 :
                           bw_extract(center, 0, 2) == MINUS ? -0.5 : 0;
    function m_y(center) = bw_extract(center, 2, 2) == PLUS ? 0.5 :
                           bw_extract(center, 2, 2) == MINUS ? -0.5 : 0;
    function m_z(center) = bw_extract(center, 4, 2) == PLUS ? 0.5 :
                           bw_extract(center, 4, 2) == MINUS ? -0.5 : 0;
    
    function is_sideways(center) = bw_extract(center, 6, 1) == 1;
    
    log_s("center", center, INFO, IMPORTANT);
    log_s("is_sideways", is_sideways(center), INFO, IMPORTANT);
    
    x = is_sideways(center) ? d : l;
    y = is_sideways(center) ? l : d;
    dx = x * m_x(center);
    dy = y * m_y(center);
    dz = d * m_z(center);
    
    a = is_sideways(center) ? 90 : 0;
    
    translate([dx, dy, dz])
    rotate([0, 0, a])
    rotate([0, 90, 0])
    cylinder(d=d, h=l, center=true);
}
    

* rod(d=10, l=20, center=BEHIND); 
* rod(d=10, l=20, center=FRONT);
* color("Lavender")   rod(d=10, l=20, center=LEFT);
* color("red")        rod(d=10, l=20, center=RIGHT);
* color("Aqua")   rod(d=10, l=20, center=ABOVE);
* color("blue")        rod(d=10, l=20, center=BELOW);

* color("blue") rod(d=10, l=20);
* rod(d=10, l=20, center = SIDEWISE + FRONT + ABOVE + LEFT);

module rod2(d, l, center=0) {
    bv = _center_to_bitvector(center);
    is_sideways = bv[3] == 1;
    x = is_sideways ? d : l;
    y = is_sideways ? l : d;
    z = d;
    size=[x, y, z];
    disp = _center_to_displacement(center, size);
    a = is_sideways ? 90 : 0;
    translate(disp)
    rotate([0, 0, a])
    rotate([0, 90, 0])
    cylinder(d=d, h=l, center=true);  
    
}


module _visual_test_rod_single_attribute(d, l, a) {
    
    color("SteelBlue", alpha = a) 
    rod2(d=d, l=l, center=BEHIND); 

    color("FireBrick", alpha = a) 
    rod2(d=d, l=l, center=FRONT);

    color("Lavender", alpha = a)   
    rod2(d=d, l=l, center=LEFT);

    color("RosyBrown", alpha = a)        
    rod2(d=d, l=l, center=RIGHT);

    color("Aqua", alpha = a)   
    rod2(d=d, l=l, center=ABOVE);

    color("blue", alpha = a)        
    rod2(d=d, l=l, center=BELOW);
}
* _visual_test_rod_single_attribute(10, 20, 0.5);

module _visual_test_all_octants(d, l, a) {
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
    
    function i_x(x) = x == BEHIND ? 0 : 1;
    function i_y(y) = y == LEFT ? 0 : 1;
    function i_z(z) = z == ABOVE ? 0 : 1;
    
    function map_to_color(x, y, z) = colors[i_x(x)][i_y(y)][i_z(z)];
    for (x_a = [BEHIND, FRONT]) {
        for (y_a = [LEFT, RIGHT]) {
            for (z_a = [ABOVE, BELOW]) {
                color(map_to_color(x_a, y_a, z_a), alpha = a)        
                rod2(d=d, l=l, center=x_a+y_a+z_a);                
            }
        }
    }
    
}
 _visual_test_all_octants(10, 20, 0.5);

* rod(d=10, l=20, center = SIDEWISE + FRONT + ABOVE + LEFT);



//    log_v1("s", s, INFO, IMPORTANT); 
//    bv = center_to_bitvector(center);
//    log_v1("bv", bv, INFO, IMPORTANT); 
//    sv = bv_to_sign(bv);
//    log_v1("sv", sv, INFO, IMPORTANT);

//
//dct = [["wall_y", 1.07], ["floor_z", 2.42]];
//    
//dct_matches = find_all_kvp(dct, "wall_y");
//echo("matches", dct_matches);
//
//not_a_dct = concat(dct, [["wall_y", 3.07]]);
//echo("not_a_dct", not_a_dct);
//not_a_dct_matches = find_all_kvp(not_a_dct, "wall_y");
//echo("not_a_dct", not_a_dct);
//echo("not_a_dct_matches", not_a_dct_matches);
//echo("len(not_a_dct_matches)", len(not_a_dct_matches));
//
//
//assert(find_in_dct(dct, "wall_y") == 1.07);
//
////echo(find_in_dct(element_dct, "wall_y"));
////
//run_assert_test_1 = true;
//if (run_assert_test_1) {
//    list = [ ["wall_y", 3], ["wall_y", 5] ];
//    
//    echo("strcat(list):", strcat(list));
//    
////    matches = find_all_kvp(list, "wall_y");
////    echo("matches", matches);
////    echo("len(matches)", len(matches));
////    //assert(len(matches) <= 1);
//    a = find_in_dct(dct, "wall_y", required=true);
//    echo(a);
//}