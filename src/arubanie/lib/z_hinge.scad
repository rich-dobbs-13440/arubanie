
include <logging.scad>
include <centerable.scad>
use <shapes.scad>
include <not_included_batteries.scad>


/* [Boiler Plate] */

fa_bearing = 1;
fa_shape = 20;
infinity = 30;


/* [Show] */
show_ = true;
show_gudgeon = false;
show_pintle = false;
show_removable_pin_clearance = false;
show_removable_pin_gudgeon_bearing = false;
show_pintle_external_nut_catch = false;

/* [Dimenstions] */

allowance_ = 0.4;
pin_diameter_ = 1.5;
height_ = 10; // [0:0.4:30]
width_ = 3;
length_ = 16; 
ball_d_ = 2; // [0:0.5:4]
overlap_ = 0.05; // [0:0.05:2]

/* [Colors] */
//color_behind = std_color_pallete[0];
//color_front = std_color_pallete[1];
//color_core = std_color_pallete[2];
//color_attach_middle = std_color_pallete[3];
//color_bearing = std_color_pallete[4];
//color_bottom = std_color_pallete[5];
//color_attach_bottom = std_color_pallete[6];
//color_top = std_color_pallete[7];;
//color_attach_top = std_color_pallete[8];
//color_bottom_bearing = std_color_pallete[9];


*render() difference() {
    z_hinge(pin_diameter_, height_, allowance_) {
        block([length_, width_, height_], center=RIGHT);
    }
    plane_clearance(BEHIND);
}

//render() difference() {
    z_clasp(height_, allowance_, ball_d_, overlap_) {
        block([length_, width_, height_], center=RIGHT);
    }
//    plane_clearance(BEHIND);
//}

module z_clasp(h, al, ball_d, overlap) {
    n_leaf = 4;
    id = 0.6* ball_d;
    wall_thickness = 1;
    od = id + 2*wall_thickness;
    z_body(h, al, id, od, n_leaf,free_pin=true) {
        children();
    }
    dz = (h + al)/n_leaf;
    for (z =[-h/2 : dz : h/2 - dz]) {
        z_offset = dz-ball_d/2 + overlap;
        translate([0, 0, z+z_offset]) half_sphere();
    }
    module half_sphere() {
        render() difference() {
            translate([0, od/2, 0]) sphere(d=ball_d);
            plane_clearance(BELOW);
        }
    }
}

module z_hinge(pin_d, h, al, min_leaf_width=2) {
    
    function round_down_odd(x) = 2*floor(x/2) - 1;
    
    wall_thickness = 1;
    id = pin_d+al;
    od = id + 2*al + 2*wall_thickness;
    n_leaf = max(round_down_odd(h/min_leaf_width), 3);
    echo("n_leaf", n_leaf);
    pin();
    z_body(h, al, id, od, n_leaf, free_pin=false) {
        children();
    } 
    
    module pin() {
        translate([0, od/2, 0]) can(d=id-al, h=h);
    }
}
    
module z_body(h, al, id, od, n_leaf, free_pin=false) {
    x_leaf = od/2 + al/2;
    dz = (h + al)/n_leaf; 
    echo("dz", dz);
    
    render() difference() {
        union() {
            children();
            can(d=od, h=h, center=RIGHT);
        }
        clearance();
    }
    
    module junction(x, z) {
        translate([x, 0, z]) rod(d = 0.4, l=10, center= SIDEWISE);
    }
    
    module segment(x1, z1, x2, z2) {
        hull() {
            junction(x1, z1);
            junction(x2, z2);
        }  
        
    }
    
    module clearance() {
        module pair_of_leafs() {
            z1 = 0;
            z2 = z1 + dz/2;
            z3 = z2;
            z4 = z3 + dz;
            z5 = z4;
            z6 = z5 + dz/2;
            
            segment(x_leaf, z1, x_leaf, z2);
            segment(x_leaf, z2, -x_leaf, z3);
            segment(-x_leaf, z3, -x_leaf, z4);
            segment(-x_leaf, z4, x_leaf, z5);
            segment(x_leaf, z5, x_leaf, z6);
            if (!free_pin) {
                translate([0, od/2, 0]) can(d=id+al, h=dz/2, center=ABOVE);
                translate([0, od/2, 3*dz/2]) can(d=id+al, h=dz/2, center=ABOVE);
            }
        }
        for (t_z = [-h/2 : 2*dz : h/2+dz]) {
            translate([0, 0, t_z-dz/2-al/2]) pair_of_leafs();
        }
        if (free_pin) {
            h_pin = h - dz;
            translate([0, od/2, 0]) can(d=id+al, h=h_pin);
        }
    }  
}
