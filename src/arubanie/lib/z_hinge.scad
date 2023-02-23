
include <logging.scad>
include <centerable.scad>
use <shapes.scad>
include <not_included_batteries.scad>


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

/* [Dimenstions] */

allowance_ = 0.4;
pin_diameter_ = 1.5;
height_ = 7.60; // [0:0.4:30]
width_ = 3;
length_ = 16;



//        dx = 2;
//        dz = 2;


//x1 = 2; // [-20:20]
//z1 = 0; // [-20:20]
//x2 = 2; // [-20:20]
//z2 = 2; // [-20:20]
//x3 = -2; // [-20:20]
//z3 = 2; // [-20:20]
//x4 = -2; // [-20:20]
//z4 = 4; // [-20:20]
//x5 = 2; // [-20:20]
//z5 = 4; // [-20:20]        

/* [Colors] */
color_behind = std_color_pallete[0];
color_front = std_color_pallete[1];
color_core = std_color_pallete[2];
color_attach_middle = std_color_pallete[3];
color_bearing = std_color_pallete[4];
color_bottom = std_color_pallete[5];
color_attach_bottom = std_color_pallete[6];
color_top = std_color_pallete[7];;
color_attach_top = std_color_pallete[8];
//color_bottom_bearing = std_color_pallete[9];



z_hinge(pin_diameter_, height_, allowance_) {
    block([length_, width_, height_], center=RIGHT);
}





module z_hinge(pin_d, h, al, min_leaf_width=2) {
    
    function round_down_odd(x) = 2*floor(x/2) - 1;
    
    wall_thickness = 1;
    id = pin_d+al;
    od = id + 2*al + 2*wall_thickness;
    x_leaf = od/2 + al/2;
    
    n_leaf = max(round_down_odd(h/min_leaf_width), 3);
    echo("n_leaf", n_leaf);
    dz = (h + al)/n_leaf; // 2.4;
    echo("dz", dz);
    
    pin(); 
    render() difference() {
        union() {
            children();
            can(d=od, h=h, center=RIGHT);
        }
        clearance();
    }
    
    module pin() {
        translate([0, od/2, 0]) can(d=id-al, h=h);
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
            
        }

        center_reflect([0, 0, 1]) {
            for (t_z = [0: 2*dz : h/2]) {
                translate([0, 0, t_z]) pair_of_leafs();
            }
        } 
    }
    
    
    
    

    
}
//    
//    h_middle = 1; 
//    
//    dz_bearing = h_middle + sqrt(2)* al;
//    h_bearing = d/2-sqrt(2)*al;
//    dz_top_bearing = dz_bearing + h_bearing;
//    h_bottom = h/2 - dz_top_bearing;
//    h_top = h_bottom;
//    
//    color("lime") union() {
//    
//        color(color_behind) {
//            render() difference() {
//                children();
//                outer();
//                plane_clearance(FRONT);
//            }
//        }
//        
//        color(color_attach_bottom) {
//            attach_hard(BEHIND, -h/2, h_bottom) children();
//        }
//        color(color_bottom) bottom();
//        color(color_top) top(); 
//        color(color_bearing) bearing();
//        color(color_attach_top) {
//            attach_hard(BEHIND, h/2-h_top, h_top) children();
//        }
//        attach(BEHIND, -dz_bearing-h_bearing, h_bearing) children();
//        attach(BEHIND, dz_bearing, h_bearing) children();
//    }
//    
//    
//    
//    //color(color_front) {
//        
//        
//        render() difference() {
//            children();
//            outer();
//            plane_clearance(BEHIND);
//        }
//        
//        color(color_attach_middle) {
//            attach_hard(FRONT, -h_middle, 2*h_middle) children();
//        }
//        color(color_core, alpha=0.25) core();
//        
//        
//    //}
//    
//    
//    
//
//    
//
//
//
//    
//
//    
//    module top() {// h_top
//        dz = h/2;
//        translate([0, 0, dz]) can(d = d, h=h_top, center=BELOW);  
//    }
//    
//    module bottom() {
//        dz = -h/2;
//        translate([0, 0, dz]) can(d = d, h=h_bottom, center=ABOVE);   
//    }
//    
//    module core() {
//        center_reflect([0, 0, 1]) {
//            middle();
//            translate([0, 0, h_middle]) cone();
//        }
//    }
//    
//    module outer() {
//        can(d=d+2*al, h=2*h);
//    }
//    
//    module overlap() {
//        can(d=d+4*al, h=4*h);
//    }
//    
//    module inner(side) {
//        assert(is_num(side));
//        render() intersection() {   
//            children();
//            overlap();
//            plane_clearance(side);
//        }     
//    }  
//  
//    module attach_hard(side, dz, z) {
//        render() difference() {
//            //inner(side) 
//            children();
//            translate([0, 0, dz]) plane_clearance(BELOW);
//            translate([0, 0, dz+z]) plane_clearance(ABOVE);
//            translate([0, 0, dz+z]) plane_clearance(side);
//            //can(d=d, h=infinity);
//        }
//    }  
//    
//    module attach(side, dz, z) {
//        render() difference() {
//            inner(side) children();
//            translate([0, 0, dz]) plane_clearance(BELOW);
//            translate([0, 0, dz+z]) plane_clearance(ABOVE);
//            can(d=d, h=infinity);
//        }
//    }
//
//    module core_clearance() {
//        center_reflect([0, 0, 1]) {
//            translate([0, 0, sqrt(2)*al]) core();
//        }
//    }
//    
//    module middle() {
//        can(d=d, h=h_middle, center=ABOVE);
//    }
//    module cone() {
//        can(d=d, taper=0, h=d/2, center=ABOVE);
//    } 
//
//    module bearing() {
//        color(color_bearing) {
//
//            center_reflect([0, 0, 1]) {
//                render() difference() {
//                    translate([0, 0, dz_bearing]) can(d=d, h=h_bearing, center=ABOVE);
//                    core_clearance();
//                }
//            }
//        }
//    }
//}