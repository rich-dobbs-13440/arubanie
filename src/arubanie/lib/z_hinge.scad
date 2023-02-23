
include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>


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
diameter_ = 4;
height_ = 7;

/* [Colors] */
color_behind = "red";
color_front = "orange";
color_bottom = "yellow";
color_front_inner = "green";
color_behind_inner = "blue";
color_top = "indigo";
color_pedistal = "violet";
color_middle = "pink";
color_neck = "tomato";
color_bottom_bearing = "teal";



z_hinge(diameter_, height_, allowance_) {
    block([16, 4, height_], center=ABOVE);
}


module z_hinge(d, h, al) {
    
    h_floor = 2*al;
    dz_middle = h_floor + d/2 - al/2;
    h_middle = 1; // h - 2 * dz_middle;
    dz_neck = dz_middle + h_middle;
    dz_top_bearing = dz_neck + sqrt(al);
    
    color(color_behind) {
        render() difference() {
            children();
            can(d=d+2* al, h=2*h, rank=25);
            plane_clearance(FRONT);
        }
    }
    
    color(color_front) {
        render() difference() {
            children();
            can(d=d+2*al, h=2*h, rank=25);
            plane_clearance(BEHIND);
        }
    } 
    
    bottom() children();
    middle() children();
    top() children();
    
    pedistal();
    neck();
    bottom_bearing() children();
//    top_bearing() children();
    
//    module top_bearing() {
//        h = dz_middle - h_floor - sqrt(2)*al;
//        translate([0, 0, 30]) bearing(h) children();
//    }
    
    module bearing(h) {
        render() difference() {
            union() {
                can(d=d, h=h, center=ABOVE);
                attach(FRONT, 0, h) inner(FRONT) children();   
            }                 
            can(d=3*al, taper=d, h=h, center=ABOVE);   
        }
    }
    
    module bottom_bearing() {
        dz = h_floor;
        h = dz_middle - h_floor - sqrt(2)*al;
        
        color(color_bottom_bearing) {
            translate([0, 0, dz]) {
                bearing(h) children();
            }
        }
        
    }
    
    
    module front_inner() {
        color(color_front_inner) {
            render() intersection() {
                children();
                can(d=d+2* al, h=2*h, rank=50);
                plane_clearance(FRONT);
            }
        } 
    }
    
    module behind_inner() {
        color(color_behind_inner) {
            render() intersection() {
                children();
                can(d=d+2* al, h=2*h, rank=50);
                plane_clearance(BEHIND);
            }
        }
    }
    
    module inner(side) {
        assert(is_num(side));
        render() intersection() {   
            children();
            can(d=d+2* al, h=2*h, rank=50);
            plane_clearance(side);
        }     
    }
    

    
    module attach(side, dz, z) {
        render() difference() {
            inner(side) children();
            translate([0, 0, dz]) plane_clearance(BELOW);
            translate([0, 0, dz+z]) plane_clearance(ABOVE);
        }
    }
    
    module bottom() {
        color(color_bottom) {
            can(d, h_floor, center=ABOVE);
            attach(FRONT, 0, h_floor) inner(FRONT) children();
        }
    }
    
    module middle() {
      color(color_middle) {
            translate([0, 0, dz_middle]) {
                can(d, h_middle, center=ABOVE);
                attach(BEHIND, 0, h_middle) inner(BEHIND) children();
            }
        }
    }
    
    module pedistal() {
        color(color_pedistal)translate([0, 0, h_floor-al/2]) can(d=0, taper=d, h=d/2, center=ABOVE); 
    }
    module neck() {
        color(color_neck) translate([0, 0, dz_neck]) can(d=d, taper=0, h=d/2, center=ABOVE); 
    }
    
    
    
    module top() {
        color(color_top) {
            h_ceiling = 2*al;
            dz = h - h_ceiling;
            translate([0, 0, dz]) 
                can(d, h_ceiling, center=ABOVE);
            attach(FRONT, dz, h_ceiling) inner(FRONT) children();
        }
    }
    
    
    * attach(FRONT, h/2, h/4) children(); 
    * attach(BEHIND, h/4, h) children();
    
    //    
    
//    color(color_floor) floor() children();
//    
//    module floor() {

//        attach(FRONT, 0, h_floor) children();
//    }
//    

////       render() difference() {
////           children()
////           can(d=d, h=2*h);
////           
////            
//////            translate([0, 0, dz+ z]) plane_clearance(ABOVE); 
////        }
//    }

        //can(d, z, center=ABOVE+side);
        
//        difference() {
//
//            plane_clearance(side_clearance_center);
//            translate([0, 0, dz]) plane_clearance(BELOW);
//            translate([0, 0, dz+ z]) plane_clearance(ABOVE);
//        }
//        translate([0, 0, dz+ z]) plane_clearance(ABOVE);
//    }
}