include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <lib/material_colors.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <MCAD/servos.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>
include <NopSCADlib/vitamins/zipties.scad>
use <PolyGear/PolyGear.scad>
use <lib/servo_horn_cavity.scad>
use <lib/triangular_bearing_shaft.scad>


d_filament = 1.75 + 0.;
od_ptfe_tube = 4 + 0;

od_bearing = 22.0 + 0;
id_bearing = 8.0 + 0;
h_bearing = 7.0 + 0;
md_bearing = 14.0 + 0;

ORIENT_AS_ASSEMBLED = 0 + 0;
ORIENT_FOR_BUILD = 1 + 0;
ORIENT_AS_DESIGNED = 2 + 0;



/* [Output Control] */

orientation = 0; // [0:"As assembled", 1:"For build", 2: "As designed"]

orient_for_build = orientation == ORIENT_FOR_BUILD;

show_vitamins = true;
show_filament = true;

build_traveller_pivot_arms = true;

build_shaft = true;
build_shaft_gear = true;


build_clamp_gear = true;
build_clamp_slide = true;
build_filament_clamp = true;

build_end_caps = true;
build_both_end_caps = true;
build_ptfe_glides = false;

build_bearing_holder = false;
build_traveller = false; // Old implementation is being incrementally replaced

alpha_clamp_gear = 1; // [0.25 : transparent, 1: solid]
alpha_clamp_gear_slide = 1; // [0.25 : transparent, 1: solid]
alpha_filament_clamp = 1; // [0.25 : transparent, 1: solid]
alpha_traveller = 1; // [0.25 : transparent, 1: solid]
alpha_shaft_gear = 1; // [0.25 : transparent, 1: solid] 
clamping_lift = 0; // [0: 0.1: 1]

show_cross_section = false;
build_slider_shaft_bearing_insert = false;



/* [Clearances] */ 
ptfe_snap_clearance = 0.17;
ptfe_slide_clearance = 0.5; // [0.5:Actual, 1:test]
ptfe_insert_clearance = 0.3;
part_push_clearance  = 0.2;

elephant_clearance = 1;
slider_clearance = 0.4;



//*********************************************
/* [Bearing Holder Design] */ 
test_bearing_block = false;
include_shaft_bearing_block_base = true;
include_clamp_bearing_block_base = false;
join_block = false;

/* [Glide Design] */
slide_length = 50; // [1 : 1 : 99.9]
r_glide = 4;
glide_engagement = 1; // [0 : 0.1 : 2]
glide_filament_clearance = 2;
dx_glides = r_glide + od_ptfe_tube/2 + glide_filament_clearance; 



/* [General Gear Design] */
gear_height = 5;
hub_height = 4.6;
hub_diameter = 12.5;
z_gear_clearance = 1;
h_traveller_glide = 8;







/* [Clamp Gear Design] */
// 9 teeth => 16.9
clamp_gear_diameter = 16.9 + 0; 

h_slider = 5; // [5: 0.1 : 8]
screw_length = 10; //[4, 6, 8, 10, 12, 16, 20]
x_clamp_nut_block = 7;
h_slide_to_bearing_offset = 0;
h_slide_to_gear_offset = 10;
dx_clamp_gear = x_clamp_nut_block + h_bearing + h_slide_to_bearing_offset + h_slider + h_slide_to_gear_offset;

traveller_bearing_clearance = 4;
dz_clamp_screw = od_bearing/2 + traveller_bearing_clearance; 
    
     
    
    
/* [Shaft Gear Design] */
// 19 teeth => 34.3, 22 teeth => 41, 17 teeth  = 31.6
shaft_gear_teeth = 17;
shaft_gear_diameter = 31.6; //[30: 0.1: 50]
h_shaft_bearing_base = 2; // [0: 0.1: 10]
h_shaft_rider = 9; // [5 : 0.1: 10]


dx_clamp_slide = x_clamp_nut_block + h_bearing + h_slide_to_bearing_offset + h_slider-1; 

/* [End Cap Design] */
end_cap_pad = 4;

dx_clamp_shaft = 
    x_clamp_nut_block 
    + h_bearing 
    + h_slide_to_bearing_offset 
    + h_slider
    + h_slide_to_gear_offset 
    + shaft_gear_diameter/2;
dx_end_cap = -dx_clamp_shaft - shaft_gear_diameter/2 - end_cap_pad; 
x_end_cap = dx_glides  + r_glide + dx_clamp_shaft + shaft_gear_diameter/2 + od_ptfe_tube/2 + 2 * end_cap_pad; // [1:0.1:40]
y_end_cap = 10; //max(d_shaft_clearance, 2*dx_glides); 
z_end_cap = 6; // [1:0.1:20]

end_cap = [x_end_cap, y_end_cap, z_end_cap];

/* [Clamp Shaft Design] */


gear_filament_clearance = 6;

    
 
   
    
  
//


shaft_length = slide_length + 2*z_end_cap +  2*gear_height; //+ 2*z_clearance






/* [Traveller Design] */
z_traveller = 2; // [0.5:"Test fit", 2:"Prototype", 4:"Production"]
bearing_block_wall = z_traveller;

dx_traveller = dx_end_cap;
z_bearing_engagement = 2.5; //[0.5:"Test fit", 1:"Prototype", 2.5:"Production"]

module end_of_customization() {}


* color("green") ziptie(small_ziptie);

* color("blue")  ziptie(small_ziptie, r = 5, t = 20); //! Draw specified ziptie wrapped around radius `r` 
                                                    //and optionally through panel thickness `t`
//translate([0, 0, h_bearing/2 + 2]) ball_bearing(BB608);




module filament(as_clearance) {
    d = as_clearance ? 2.5 : d_filament;
    alpha = as_clearance ? 0 : 1;
    color("red", alpha) {
        can(d=d, h=slide_length + 40, $fn=12);
    }
    
}



if (show_vitamins && show_filament && !orient_for_build ) {
    filament(as_clearance=false);
}


module end_cap(orient_for_build) {
    module blank() {
        translate([dx_end_cap, 0, 0]) block(end_cap, center=ABOVE+FRONT); 
    }
    module shape() {
        z_glide = 100;
        a_lot = 4*z_end_cap;
        color("aquamarine") {
            render(convexity=10) difference() {
                blank();
                filament(as_clearance=true);
//                translate([0, 0, -slide_length/2]) 
//                   ptfe_glides(orient_for_build = false, as_clearance = true, clearance=part_push_clearance); 
                translate([0, 0, -slide_length/2]) 
                   //slider_shaft(orient_for_build = false, as_clearance = true, clearance=ptfe_slide_clearance); 
                    slider_shaft(orient_for_build = false, as_clearance = true); 
                translate([-dx_clamp_shaft, 0, 0]) 
                    //can(d=d_shaft_clearance , h=a_lot);    
                    slider_shaft(orient_for_build = false, as_circular_clearance = true); 
            }
        }
    }
    
    if (orient_for_build) {
        translate([0, 0, z_end_cap]) rotate([180, 0, 0]) shape();
        if (build_both_end_caps) {
            translate([0, 20, z_end_cap]) rotate([180, 0, 0]) shape();
        }
    } else {
        center_reflect([0, 0, 1]) translate([0, 0, slide_length/2]) shape();
    }
}



module base_gear(teeth) {
    translate([0, 0, 1.2]) 
        bevel_gear(
          n = teeth,  // number of teeth
          m = 1.7,   // module
          w = 7,   // tooth width
          cone_angle     = 45,
          pressure_angle = 25,
          helix_angle    = -45,   // the sign gives the handiness
          backlash       = 0.1);
} 




module shaft_gear(orient_for_build = false, orient_to_center_of_rotation=false,  show_vitamins=false) {
    translation = 
        orient_for_build ? [0, 0, 0] : 
        orient_to_center_of_rotation ? [0, 0, -clamp_gear_diameter/2] :
        [-dx_clamp_shaft, 0, 0];
    module shape() {
        render(convexity=20) difference() {
            base_gear(teeth=shaft_gear_teeth);
            //can(d=md_bearing-0.01, h=100);
            //translate([0, 0, 6]) 
            //can(d=od_bearing + 1, h=100);
            can(d=md_bearing, h=100);   
        }
        shaft_rider(h=10, orient_for_build=false, show_vitamins=false);
//        translate([0, 0, h_shaft_rider]) 
//            slider_shaft_bearing_insert(orient_for_build=true, protect_from_elephant_foot=false);
    }
    
    if (show_vitamins) {
        dz_bb = -h_bearing/2 - clamp_gear_diameter/2 - h_shaft_bearing_base;
        dz_insert = dz_bb + h_bearing/2 ; // -clamp_gear_diameter/2;
//        translate([0, 0, dz_bb]) ball_bearing(BB608);
        //translate([0, 0, dz_insert]) slider_shaft_bearing_insert();
        //translate(translation) shaft_rider(h=10, orient_for_build=orient_for_build, show_vitamins=show_vitamins);
    }
    color("pink", alpha_shaft_gear) {
        if (orient_for_build) {
            translate([0, 0, h_shaft_bearing_base]) shape();
        } else {
            translate(translation) shape();
        } 
    }   
}




module clamp_gear(orient_for_build, orient_to_center_of_rotation=false, show_vitamins=false) {
    
    translation = 
        orient_to_center_of_rotation ? [shaft_gear_diameter/2, 0, 0] :
        [-dx_clamp_gear, 0, 0]; //dz_clamp_screw];
    a_lot = 100;
    h_neck = 2;
    dz = h_neck + h_bearing + h_slider + elephant_clearance ;
    module shape() {
        base_gear(teeth=9);
        can(d=id_bearing, taper= id_bearing + 4, h=h_neck, center=BELOW);
        translate([0, 0, -h_neck]) 
            can(d=id_bearing, h=h_bearing, center=BELOW);
        translate([0, 0, -h_neck-h_bearing]) 
            can(d=id_bearing, h=h_slider, center=BELOW, $fn=6);
        translate([0, 0, -h_neck-h_bearing-h_slider]) 
            can(d = id_bearing-2*elephant_clearance, taper=id_bearing, h=elephant_clearance, center=BELOW, $fn=6);        
    }
    if (show_vitamins) {
        translate(translation + [3, 0, 0])  rotate([0, 90, 0]) ball_bearing(BB608);
    }
    color("violet", alpha=alpha_clamp_gear) {
        if (orient_for_build) {
            translate([0, 0, dz]) shape();
        } else {
            translate(translation) rotate([0, -90, 0])  shape();
        } 
    }     
}


module clamp_slide(orientation, show_vitamins=false) {
    wall = 1;
    a_lot = 100;
    d_cavity = id_bearing + 2*slider_clearance;
    d_slider = d_cavity + 2 * wall;
    h_base = 4; 
    module shape() {
        render(convexity=10) difference() {
            union() {
                can(d=d_slider, h=h_slider + 3, center=ABOVE, $fn=6);
                can(d=d_slider, h=h_base, center=BELOW, $fn=6);
            }
            can(d=d_cavity, h=a_lot, center=ABOVE, $fn=6);
            translate([0, 0, 25]) hole_through("M2", cld=0.6,  $fn=12);
            translate([0, 0, -2]) nutcatch_parallel("M2", clh=5, clk=0.4, $fn=12);
        }
    }

    translation = 
        orientation == ORIENT_FOR_BUILD ? [0, 0, h_base] :
        orientation == ORIENT_AS_ASSEMBLED ? [-(screw_length + clamping_lift), 0, 0] :
        [0, 0, 0];
    
    rotation = 
        orientation == ORIENT_AS_ASSEMBLED ? [0, -90, 0] : 
        [0, 0, 0];
        
        
     
    translate(translation) rotate(rotation) {
        if (show_vitamins && orientation != ORIENT_FOR_BUILD) {
            color(BLACK_IRON) screw(str("M2x", screw_length));
            translate([0, 0, -2]) color(BLACK_IRON) nut("M2");
        }        
        color("brown", alpha=alpha_clamp_gear_slide) shape() ;
    }
//        } else {
//            //translate(translation) rotate([0, -90, 0])  
//            shape();
//        } 
//    }  
}

module bearing_holder(
        bearing_clearance=0.3, 
        h=2, 
        cap=false, 
        screw_attachment=false, 
        wall = 1, 
        show_mocks=false) {
    
    a_lot = 100;
    id = od_bearing + 2 * bearing_clearance;
    od = id + 2 * wall;
    //can(d = od_bearing + 2 * wall, hollow = od_bearing - 2 * wall, h = 2*wall, center=BELOW);
    can(d = od, hollow = id, h = h, center=ABOVE);
    if (cap) {
        translate([0, 0, h]) {
            difference() {
                can(d=od, h=1);
                can(d=id, taper=id-2, h=2);
            }
        }
    }
    if (screw_attachment) {
        d_screw = od/2 + 3;
        difference() {
            block([od + 12, 5, wall], center=ABOVE);
            can(d=id, h=a_lot);
            center_reflect([1, 0, 0]) 
                translate([d_screw, 0, 25]) 
                    hole_through("M2", $fn=12);
        }
        if (show_mocks) {
            color(BLACK_IRON) 
                center_reflect([1, 0, 0]) 
                    translate([d_screw, 0, wall]) 
                        screw("M2x6");
        }
    }
}

if (build_bearing_holder) {
    dx = od_bearing + 5;
    //translate([0*dx, 0, 0]) bearing_holder(1);  // Way too much
    //translate([1*dx, 0, 0])bearing_holder(0.5);  // Still too much
    //translate([2*dx, 0, 0]) bearing_holder(0.2);  // Too tight
    //translate([3*dx, 0, 0])bearing_holder(0.1);  // Too tight
    //translate([4*dx, 0, 0]) bearing_holder(bearing_clearance=0.3, h=4); 
    translate([4*dx, 0, 0]) bearing_holder(bearing_clearance=0.3, h=8, cap=true, screw_attachment=true);  
    //translate([5*dx, 0, 0])bearing_holder(0.4); // Too loose
}

module bearing_block(show_vitamins=false) {
    
    a_lot = 100;
    bearing_wall = 2;
    h_neck = 2;
    s = od_bearing + 2 * bearing_wall;
    d_bearing_retention = od_bearing - 1;
    dz_shaft = clamp_gear_diameter/2 + h_bearing  + h_shaft_bearing_base;
    dx_clamp = shaft_gear_diameter/2 + h_bearing  + h_neck;
    
    module block_joiner() {
        if (join_block) {
            translate([dx_clamp+bearing_wall, 0, -dz_shaft]) 
                block([2*bearing_wall, s/2, 2*bearing_wall], center=BEHIND);
        }
    }
    module blank() {
        union() {
            if (include_shaft_bearing_block_base) {
                hull() {
                    translate([0, 0, -dz_shaft]) can(d=s, h=2*bearing_wall);
                    block_joiner();
                }
            }
            if (include_clamp_bearing_block_base) {
                hull() {
                    translate([dx_clamp, 0, 0]) rotate([0, 90, 0]) can(d=s, h=2*bearing_wall);
                    block_joiner();
                }   
            }
        }        
    }
    difference() {
        blank();
        clamp_gear(orient_to_center_of_rotation=true, show_vitamins=true);
        shaft_gear(orient_to_center_of_rotation=true, show_vitamins=true);
        can(d=d_bearing_retention, h=a_lot);
        rotate([0, 90, 0]) can(d=d_bearing_retention, h=a_lot);

    }
    if (show_vitamins) {
        clamp_gear(orient_to_center_of_rotation=true, show_vitamins=true);
        shaft_gear(orient_to_center_of_rotation=true, show_vitamins=true);
    }
}


if (test_bearing_block) {
    bearing_block(show_vitamins = show_vitamins);
} 

module tuned_M2_nutcatch_side_cut(as_clearance = true) {
    if (as_clearance) {
        nutcatch_sidecut("M2", $fn = 12, clh=.5); 
    } else {
        #nut("M2");
    }
}


module filament_clamp(include_mounting=true, include_servo_attachment=true, include_vitamins=true) {
    z = 16;
    screw_wall = 2;
    wall = 2;
    x_mounting = 12;
    y_clamp_nut_block = 8;
    pivot_screw_length = 16;
    module clamp_screw_clearance() {
        translate([0, 0, 0]) {
            rotate([0, 90, 0]) {
                hole_through("M2", $fn = 12);
            } 
            translate([-2.2, 0, 0]) rotate([0, -90, 180]) {
                 tuned_M2_nutcatch_side_cut(); 
            }            
        }
    }
    module nut_block() {
        block([x_clamp_nut_block, y_clamp_nut_block, z], center=BEHIND);
        can(d=5, h=z);
    }
    module mounting() {
        translate([0, 0, -z/2]) block([x_clamp_nut_block, 14, wall], center=BEHIND+ABOVE);
        center_reflect([0, 1, 0]) {
            hull() {                        
                translate([-x_mounting-x_clamp_nut_block, od_bearing/2, -z/2]) 
                    block([1, 6, wall], center=ABOVE+BEHIND);

                translate([0, 6, -z/2]) block([x_clamp_nut_block, 5, wall], center=ABOVE+BEHIND+RIGHT);
                
            }
            translate([-x_mounting-x_clamp_nut_block, od_bearing/2, 0]) {
                // Retain bearing
                block([wall, 3, z], center=LEFT);
                // Screw pad
                block([wall, 10, z], center=RIGHT);
            }
        }        
    }
    module mounting_screws(as_clearance = true) {
        module basic_bearing_mount() {
            if (as_clearance) {
                translate([-x_mounting, od_bearing/2 + 4, 0]) {
                    rotate([0, 90, 0]) {
                        hole_through("M2", cld=0.4, $fn = 12);
                    } 
                } 
            }
        } 
        module vertical_mount() {
            if (as_clearance) {
                translate([0,0, 25]) hole_through("M2", cld=0.4, $fn = 12);
            }
        }
        center_reflect([0, 1, 0]) {
            basic_bearing_mount();
            translate([0, 4, 0]) basic_bearing_mount();
            translate([0,0, -4]) basic_bearing_mount();
            // Just in case holes
            translate([0 , 14, 0]) vertical_mount();
            translate([-6 , 9, 0]) vertical_mount();
            translate([-14 , 11, 0]) vertical_mount();
        }

        
    }
    
    module servo_attachment() {
        center_reflect([0, 1, 0]) {
            rotate([0, 0, 90]) nut_block();
            translate([0, 3+pivot_screw_length, 0]) block([x_clamp_nut_block, screw_wall, z], center=LEFT); 
            translate([0, 0, -z/2]) 
                block([x_clamp_nut_block, 3+pivot_screw_length, screw_wall], center=ABOVE+RIGHT); 
            
        }
        
    }
    module pivot_screws(as_clearance = false) {
        center_reflect([0, 1, 0]) {
            translate([0, 3, 0]) { 
                if (as_clearance) {
                     rotate([90, 0, 0]) hole_through("M2", $fn=12, cld=0.4);
                     rotate([0, -90, 90]) tuned_M2_nutcatch_side_cut(as_clearance=true);  
                } else {
                    color(BLACK_IRON) {
                        rotate([0, -90, -90]) 
                            translate([0, 0, pivot_screw_length]) 
                                screw(str("M2x", pivot_screw_length));
                        rotate([0, -90, 90]) 
                           tuned_M2_nutcatch_side_cut(as_clearance=false);  
                    }
                    
                }
            }
        }
    }
    
    
    module shape() {
        color("chocolate", alpha=alpha_filament_clamp) {
            render(convexity=10) difference() {
                union() {
                    nut_block();
                    if (include_mounting) {
                        mounting();
                    }
                    if (include_servo_attachment) {
                        servo_attachment();
                    }
                }
                filament(as_clearance=true);
                clamp_screw_clearance();
                if (include_mounting) {
                    mounting_screws(as_clearance = true); 
                }
                if (include_servo_attachment) {
                    pivot_screws(as_clearance = true);
                }
                translate([0, 0, 3]) plane_clearance(ABOVE); 
            }
            
        } 
    } 
    module vitamins() {
        pivot_screws(as_clearance = false);
        mounting_screws(as_clearance = false);  
    }
    if (include_vitamins && !orient_for_build) {
        vitamins();
    }
    shape();
    
}
// **************************************************************************************

module traveller_pivot_arms(orientation, show_vitamins) {
    a_lot = 100;
    d_horn = 6.2;
    wall = 2;
    id = od_ptfe_tube  + 2*ptfe_insert_clearance;
    od = id + 2*wall;
    iy_pivot = x_clamp_nut_block;
    dy_inside_bearing = 2;
    dx_pivot_arm = 6;
    dy_i = iy_pivot + dy_inside_bearing;
    arm_length = 20;
    x_yoke = 20;
    
    z_cavity = 3.5;
    z_screw_hold = 0.75;
    z_total = z_cavity+ z_screw_hold;
    z_arm = 2;

    horn_blank = [8, 8, z_total];
    module traveller_pivot() {
        can(d=od, hollow=id, h=dx_pivot_arm, center=ABOVE); 
    }
    module servo_horn() {
        render(convexity=10) difference() {
            block(horn_blank, center=ABOVE); 
            translate([0, 0, z_screw_hold]) { 
                horn_cavity(
                    diameter=d_horn,
                    height=a_lot,
                    shim_count = 5,
                    shim_width = 1,
                    shim_length = .5);
            }
            can(d=2, h=a_lot);
        }
    }
    module located_horn() {
        translate([arm_length, 0, 0]) servo_horn();
    }
    module barrel_servo_connector() {
        render(convexity = 10) difference() {
            hull() {
                located_horn();
                traveller_pivot(); 
            }
            translate([0, 0, z_arm]) plane_clearance(ABOVE);
            hull() located_horn();
            hull() traveller_pivot(); 
        }
    }
    module yoke() {
        center_reflect([0, 1, 0]) {
            translate([0, dy_i, 0]) {
                rotate([-90, 0, 0]) traveller_pivot();
                difference() {
                    block([x_yoke, wall, od], center=FRONT+RIGHT);
                    rod(d=id, l=a_lot, center=SIDEWISE);
                }
            }
        }
        translate([x_yoke, 0, 0]) block([wall, 2* dy_i, od], center=BEHIND);
    }
    
    module yoke_holes() {
        center_reflect([0, 1, 0]) 
            translate([0, 3.5, 0]) 
                rotate([0, -90, 0]) 
                    hole_through("M2", $fn=12, cld=0.4);
    }
    render(convexity = 10) difference() {    
        yoke();
        // Temporary development expedient
        yoke_holes();
        
    }
    //connector();
    //located_horn();  
}



module traveller(orient_for_build, show_vitamins) {
    //translation = orient_for_build ? [0, 0, 0] : [-dx_clamp_shaft, 0, 0];
    r_glide_mod = r_glide + od_ptfe_tube/2 + ptfe_slide_clearance;


    dx_clamp_bearing = -h_bearing/2 - x_clamp_nut_block;
    
    module blank() {
        hull() {
            translate([-dx_clamp_shaft, 0, 0]) 
                can(d=od_bearing + 2*bearing_block_wall, h=z_traveller, center=ABOVE);
            translate([dx_glides, 0, 0]) 
                can(
                    d=2*r_glide_mod + 2 + bearing_block_wall, 
                    h=z_traveller, 
                    hollow=2*r_glide_mod + 1, 
                    center=ABOVE);
        }
        translate([-dx_clamp_shaft, 0, 0]) 
                can(
                    d=od_bearing + 2*bearing_block_wall, 
                    hollow = od_bearing - 2,
                    h=z_bearing_engagement +z_traveller, 
                    center=ABOVE);        
        translate([dx_glides, 0, -z_traveller]) can(d=2*r_glide_mod + 2, h=10, hollow=2*r_glide_mod + 1, center=ABOVE);
        // riders on glides:
      
    }

    module shape() {
        a_lot = 30;
        render(convexity=20) difference() {
            blank();
            
            translate([-dx_clamp_shaft, 0, 0]) can(d=od_bearing, h=z_bearing_engagement, center=ABOVE);
            ptfe_tube(as_clearance=true, h=20, clearance=ptfe_snap_clearance);
            filament(as_clearance=true); 
            //ptfe_glides(glide_length=a_lot, orient_for_build = false, as_traveller_clearance = true, clearance=ptfe_slide_clearance); 
            //clamp_screw_clearance();
            
        }
        translate([dx_glides, 0, -z_traveller]) 
            triangle_placement(r=r_glide_mod) block([1,4, 10], center=FRONT+ABOVE);  
        
        
    }    
    if (show_vitamins && !orient_for_build) {
//        * translate([-dx_clamp_shaft, 0, -h_bearing/2 + z_bearing_engagement]) 
//            ball_bearing(BB608);
//        translate([-dx_clamp_shaft, 0, z_bearing_engagement])
//            slider_shaft_bearing_insert(orient_for_build=false, show_vitamins=false);
//        translate([dx_clamp_bearing, 0, dz_clamp_screw]) 
//            rotate([0, 90, 0]) ball_bearing(BB608);
    }
    color("orange", alpha_traveller) {
        if (orient_for_build) {
            translate([0, 0, z_traveller]) shape();
        } else {
            translate([0, 0, 0]) shape();
        } 
    }   
}    


if (build_end_caps) {
    if (orient_for_build) {
        translate([0, 0, 0]) end_cap(orient_for_build=true);
    } else {
        end_cap(orient_for_build=false);
    }
}

if (build_ptfe_glides) {
    if (orient_for_build) {
        translate([30, 0, 0]) ptfe_glides(orient_for_build=true, show_vitamins=false);
    } else {
        ptfe_glides(orient_for_build=false, show_vitamins=show_vitamins);
    }
}

if (build_shaft) {
    if (orient_for_build) {
        translate([40, 0, 0]) slider_shaft(orient_for_build=true);
    } else {
        slider_shaft(orient_for_build=false);
    }    
}

if (build_shaft_gear) {
    if (orient_for_build) {
        translate([70, 0, 0]) shaft_gear(orient_for_build=true, show_vitamins=show_vitamins);
    } else {
        shaft_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}


if (build_clamp_slide) {
    translation = orient_for_build ? [40, 20, 0] : [0, 0, 0];
    translate(translation) clamp_slide(orientation=orientation, show_vitamins=show_vitamins);   
}

if (build_filament_clamp) {
    filament_clamp();
}

if (build_traveller_pivot_arms) {
    translation = orient_for_build ? [100, 0, 0] : [0, 0, 0]; 
    translate(translation) 
        traveller_pivot_arms(
            orientation=orientation, 
            show_vitamins = show_vitamins && ! orient_for_build);
}


if (build_clamp_gear) {
    if (orient_for_build) {
        translate([60, 30, 0]) clamp_gear(orient_for_build=true, show_vitamins=false);
    } else {
        clamp_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}

if (build_clamp_gear) {
    if (orient_for_build) {
        translate([60, 30, 0]) clamp_gear(orient_for_build=true, show_vitamins=false);
    } else {
        clamp_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}

if (build_slider_shaft_bearing_insert) {
    if (orient_for_build) {
        translate([60, -30, 0]) slider_shaft_bearing_insert(orient_for_build=true, show_vitamins=false);
    } else {
        //Is placed as a vitamin for the traveller
    }      
}


if (build_traveller) {
    if (orient_for_build) {
        translate([0, -20, 0]) traveller(orient_for_build=true, show_vitamins=false);
    } else {
        traveller(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}




