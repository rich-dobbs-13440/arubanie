
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
height_ = 7.60; // [0:0.4:30]
width_ = 3;
length_ = 16;      

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


* render() difference() {
    z_hinge(pin_diameter_, height_, allowance_) {
        block([length_, width_, height_], center=RIGHT);
    }
    plane_clearance(BEHIND);
}

render() difference() {
    z_clasp(height_, allowance_) {
        block([length_, width_, height_], center=RIGHT);
    }
    plane_clearance(BEHIND);
}

module z_clasp(h, al) {
    n_leaf = 6;
    id = 2;
    od = 5;
    z_body(h, al, id, od, n_leaf) {
        children();
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
    z_body(h, al, id, od, n_leaf) {
        children();
    } 
    
    module pin() {
        translate([0, od/2, 0]) can(d=id-al, h=h);
    }
}
    
module z_body(h, al, id, od, n_leaf) {
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
            
            translate([0, od/2, 0]) can(d=id+al, h=dz/2, center=ABOVE);
            translate([0, od/2, 3*dz/2]) can(d=id+al, h=dz/2, center=ABOVE);
        }
        for (t_z = [-h/2 : 2*dz : h/2]) {
            translate([0, 0, t_z-dz/2-al/2]) pair_of_leafs();
        }
    }  
}
