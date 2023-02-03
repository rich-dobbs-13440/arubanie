
include <centerable.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

/* [Visual Tests] */

show_test_rod_all_octants = true;
show_test_rod_rod_single_attribute = false;
show_visual_test_for_crank = false;

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

module rod(d, l, center=0, hollow=false, fa=undef) {
    $fa = is_undef(fa) ? $fa : fa;
    bv = _number_to_bitvector(center);
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
module can(d,h, center=0, hollow=false, fa=undef) {
    $fa = is_undef(fa) ? $fa : fa;
    bv = _number_to_bitvector(center);
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

module crank(size, hole=false, center=0, rotation=0, fa=undef) {
    $fa = is_undef(fa) ? $fa : fa;
    hole_d = is_num(hole) ? hole : 0;
    pivot_size = [size.z, size.y, size.z];
    
    center_translation(pivot_size, center) {
        center_rotation(rotation) {
            difference() {
                union() {
                    block(size, center=FRONT);
                    rod(d=size.z, l=size.y, center=SIDEWISE);
                }
                rod(d=hole_d, l=size.y + 2*eps, center=SIDEWISE);
            }
        }
    } 
}

module _visual_test_for_crank() {

    translate([0, -80, 0]) crank([10, 4, 4], hole=2, center=BEHIND);

    translate([0, -70, 0]) crank([10, 4, 4], hole=2, center=FRONT);

    translate([0, -60, 0]) crank([10, 4, 4], hole=2, center=LEFT);

    translate([0, -50, 0]) crank([10, 4, 4], hole=2, center=RIGHT);

    translate([0, -40, 0]) crank([10, 4, 4], hole=2, center=ABOVE);

    translate([0, -30, 0]) crank([10, 4, 4], hole=2, center=BELOW);

    translate([0, -20, 0]) crank([10, 4, 4]);

    translate([0, -10, 0]) crank([10, 4, 4], hole=2);

    translate([0, 20, 0]) crank([10, 4, 4], hole=2, rotation=ABOVE);

    translate([0, 30, 0]) crank([10, 4, 4], hole=2, rotation=BELOW);

    translate([0, 40, 0]) crank([10, 4, 4], hole=2, rotation=FRONT);

    translate([0, 50, 0]) crank([10, 4, 4], hole=2, rotation=BEHIND);

    translate([0, 70, 0]) crank([10, 4, 4], hole=2, rotation=LEFT);

    translate([0, 80, 0]) crank([10, 4, 4], hole=2, rotation=RIGHT);

    translate([0, 100, 0]) crank([10, 4, 4], hole=2, rotation=ABOVE+RIGHT);
    
}

if (show_visual_test_for_crank) {
    _visual_test_for_crank();   
}


module _visual_test_rod_single_attribute(d, l, a) {
    
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

if (show_test_rod_rod_single_attribute) {
    _visual_test_rod_single_attribute(10, 20, 0.5);
}

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

if (show_test_rod_all_octants) {
    _visual_test_all_octants(10, 20, false, 0.5);
}



