include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <MCAD/servos.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>
use <PolyGear/PolyGear.scad>
//use <lib/ptfe_tubing.scad>

d_filament = 1.75 + 0.;
od_ptfe_tube = 4 + 0;

od_bearing = 22.0 + 0;
id_bearing = 8.0 + 0;
h_bearing = 7.0 + 0;;
md_bearing = 14.0 + 0;


/* [Output Control] */

orient_for_build = false;

show_vitamins = true;

test_bearing_block = true;
build_shaft = true;
build_shaft_gear = true;
build_prong_assembly = true;

build_clamp_gear = true;
build_clamp_slide = true;
build_traveller = true;
build_end_caps = true;
build_both_end_caps = true;
build_ptfe_glides = true;

alpha_clamp_gear = 1; // [0.25 : transparent, 1: solid]
alpha_clamp_gear_slide = 1; // [0.25 : transparent, 1: solid]
alpha_traveller = 1; // [0.25 : transparent, 1: solid]
alpha_shaft_gear = 1; // [0.25 : transparent, 1: solid] 
clamping_lift = 0; // [0: 0.1: 1]

show_cross_section = false;
build_slider_shaft_bearing_insert = false;



/* [Clearances] */ 
ptfe_slide_clearance = 0.5; // [0.5:Actual, 1:test]
// 0.15 was pretty tight, 0.2 was loose, might be interaction with r_rider though
ptfe_snap_clearance = 0.17;
part_push_clearance  = 0.2;
shaft_clearance = 0.4;
elephant_clearance = 1;
slider_clearance = 0.4;




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

s_slider = 6;
h_slider = 5; // [3: 0.1 : 7]
screw_length = 16; //[4, 6, 8, 10, 12, 16, 20]
x_clamp_nut_block = 5.5;
h_slide_to_bearing_offset = 4;
h_slide_to_gear_offset = 2;
dx_clamp_gear = x_clamp_nut_block + h_bearing + h_slide_to_bearing_offset + h_slider + h_slide_to_gear_offset;

traveller_bearing_clearance = 4;
dz_clamp_screw = od_bearing/2 + traveller_bearing_clearance; 
    
    
    
    
/* [Shaft Gear Design] */
// 19 teeth => 34.3
shaft_gear_teeth = 23;
shaft_gear_diameter = 41; //[30: 0.1: 50]
h_shaft_bearing_base = 2; // [0: 0.1: 10]
h_shaft_rider = 9; // [5 : 0.1: 10]


prong_locked = true;

/* [Clamp Shaft Design] */
r_shaft_end = 0.1;
r_shaft = id_bearing/2;
test_fit_shaft_rider = false;
// 4.5, 4.4 yielded lots of play 
r_rider = 4.2; // [1: .1 : 10]
gear_filament_clearance = 6;
dx_clamp_shaft = 
    x_clamp_nut_block 
    + h_bearing 
    + h_slide_to_bearing_offset 
    + h_slider
    + h_slide_to_gear_offset 
    + shaft_gear_diameter/2;
    
dx_clamp_slide = x_clamp_nut_block + h_bearing + h_slide_to_bearing_offset + h_slider-1;    
d_shaft_clearance = 2 * (r_shaft + r_shaft_end + shaft_clearance);




/* [End Cap Design] */
end_cap_pad = 4;
dx_end_cap = -dx_clamp_shaft - shaft_gear_diameter/2 - end_cap_pad; 
x_end_cap = dx_glides  + r_glide + dx_clamp_shaft + shaft_gear_diameter/2 + od_ptfe_tube/2 + 2 * end_cap_pad; // [1:0.1:40]
y_end_cap = max(d_shaft_clearance, 2*dx_glides); 
z_end_cap = 6; // [1:0.1:20]

end_cap = [x_end_cap, y_end_cap, z_end_cap];




/* [Traveller Design] */
z_traveller = 2; // [0.5:"Test fit", 2:"Prototype", 4:"Production"]
bearing_block_wall = z_traveller;

dx_traveller = dx_end_cap;
z_bearing_engagement = 2.5; //[0.5:"Test fit", 1:"Prototype", 2.5:"Production"]

module end_of_customization() {}

BRONZE = "#b08d57";
STAINLESS_STEEL = "#CFD4D9";
BLACK_IRON = "#3a3c3e";

module filament(as_clearance) {
    d = as_clearance ? 2.5 : d_filament;
    alpha = as_clearance ? 0 : 1;
    color("red", alpha) {
        can(d=d, h=slide_length + 40, $fn=12);
    }
    
}

module ptfe_tube(as_clearance, h, clearance) {
    d = as_clearance ? 4 + 2*clearance : 4;
    color("white") can(d=d, h=h, $fn=32);
}

if (show_vitamins && !orient_for_build) {
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
                translate([0, 0, -slide_length/2]) 
                   ptfe_glides(orient_for_build = false, as_clearance = true, clearance=part_push_clearance); 
                translate([0, 0, -slide_length/2]) 
                   slider_shaft(orient_for_build = false, as_clearance = true, clearance=ptfe_slide_clearance); 
                translate([-dx_clamp_shaft, 0, 0]) can(d=d_shaft_clearance , h=a_lot);              
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

module triangle_placement(r) {

    for (angle = [0 : 120: 240]) {
        rotate([0, 0, angle]) {
            translate([r, 0, 0]) children();
        }
    }
}


module ptfe_glides(
        orient_for_build = false, 
        show_vitamins = false, 
        as_clearance = false, 
        as_traveller_clearance = false, 
        clearance = 0) {

    a_lot = 10;
    //z_clearance = clearance ? a_lot : 0.01;
    glide_length = slide_length + z_end_cap;
    translation = orient_for_build ? [0, 0, glide_length/2] : [dx_glides, 0, 0]; 
    module core() {
        s = od_ptfe_tube + 2  + 2 * clearance;
        es = s - 2 * elephant_clearance;
        if (as_clearance) {
            block([s, s, glide_length], center=BEHIND);
        } else {
            hull() {
                translate([-elephant_clearance, 0, 0]) 
                    block([es, es, glide_length], center=BEHIND);
                block([s, s, glide_length - 2], center=BEHIND);
            }
        }
    }   
    module blank() {
        triangle_placement(r=r_glide + glide_engagement + clearance) core();
        if (as_traveller_clearance) {
            triangle_placement(r=r_glide + glide_engagement)
                ptfe_tube(as_clearance=true, h=slide_length, clearance=0);                
        }
    }
    module shape() {
        as_tube_clearance = as_traveller_clearance ? false : true;
        color("blue") {
            render(convexity=10) difference() { 
                blank();
                if (as_tube_clearance) {
                    triangle_placement(r=r_glide) 
                        ptfe_tube(as_clearance=true, h=slide_length-z_gear_clearance, clearance=ptfe_snap_clearance);
                }
                if (show_cross_section) {
                    plane_clearance(ABOVE);
                }
            }
        }       
    }
    
    if (show_vitamins) {  
        translate(translation) 
            triangle_placement(r=r_glide) 
                ptfe_tube(as_clearance=false, h=slide_length-z_gear_clearance);
    }    
    if (orient_for_build) {
        translate([0, 0, glide_length/2]) shape();
    } else {
        translate(translation) shape();
    }
}

module slider_shaft(
        orient_for_build = false, 
        as_clearance = false,
        as_gear_clearance = false,
        clearance = 0) {
    a_lot = 200;
    z_clearance = as_clearance ? a_lot : 0.01;    
    shaft_length = 
            as_gear_clearance ? a_lot :
            slide_length + 2*z_end_cap + 2*z_clearance + 2*gear_height;
    translation = orient_for_build ? [0, 0, shaft_length/2] : [-dx_clamp_shaft, 0, 0];    
    module blank() {
        d_end = 
            as_clearance ? 2 * r_shaft_end  + 2 * clearance : 
            as_gear_clearance ? 2 * r_shaft_end  + 2 * shaft_clearance :
            2 * r_shaft_end;
        r_arm = as_gear_clearance ? r_shaft + sqrt(3) * shaft_clearance : r_shaft;
        hull() {
            triangle_placement(r=r_arm) can(d=d_end, h=shaft_length, $fn=50);
        }
    }
    module shape() {
        color("green") {
            render(convexity=10) intersection() { 
                blank();
                can(d=2*r_shaft - 2*shaft_clearance, h=a_lot);
            }
        }       
    }
    if (as_gear_clearance) {
        blank();
    } else if (orient_for_build) {
        translate([0, 0, shaft_length/2]) shape();
    } else {
        translate(translation) shape();
    } 
}


module bearing_insert_splinter(h) {
    module blank() {
        can(d=id_bearing, h=h, center=ABOVE);
    }    
    module shape() {
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
            rotate([0, 0, 60]) plane_clearance(FRONT);
            rotate([0, 0, -60]) plane_clearance(FRONT);
        }
    }   
    shape(); 
}





module prong_assembly(locked=true, orient_for_build=false, show_vitamins=false) {
    dx_insert = 2.9;
    dy_cut = 2.2; // [0:.1:5]
    prong_insertion_angle = 129; // [120:140]
    h_clip = 2;
    h_total = h_bearing + 4*h_clip;    
    module prong() {
        translate([0, 0, -h_total/2]) bearing_insert_splinter(h=h_total);
        translate([-dx_insert, 0, 0]) {
            center_reflect([0, 0, 1]) {
                translate([0, 0, h_total/2])
                    difference() {
                        can(d=id_bearing, h=2, center=BELOW);
                        plane_clearance(FRONT);
                        rotate([0, 0, 45]) translate([0, -dy_cut, 0]) plane_clearance(LEFT);
                        rotate([0, 0, -45]) translate([0, dy_cut, 0]) plane_clearance(RIGHT);
                    }
            }
        }
    }
    module pronate_prong() {
        rotate([0, 90, 0]) 
            translate([dx_insert, 0, h_total/2]) 
                prong();        
    }
    if (show_vitamins && !orient_for_build) {
        ball_bearing(BB608);
    }
    if (orient_for_build) {
        pronate_prong();
        translate([0, 10, 0]) pronate_prong();
        translate([0, -10, 0]) pronate_prong();

    } else {
        prong_angle = locked ? 120: prong_insertion_angle;
        dx_prong = locked ? 0 : dx_insert;
        translate([dx_prong, 0, 0]) prong();
        rotate([0, 0, prong_angle]) prong();
        rotate([0, 0, -prong_angle]) prong();
    }
}

//translate([0, 0, -7]) rotate([0, 5, 0]) bearing_insert_splinter(h=15);
//translate([0, 0, 5]) rotate([0, 5, 0]) bearing_insert_splinter(h=5);

module slider_shaft_bearing_insert(
        orient_for_build=false, 
        show_vitamins=false, 
        as_clearance=false,
        protect_from_elephant_foot=true) {
    h_face = 2;
    d_face = md_bearing - 2 * part_push_clearance;
    
    module blank() {
        translate([0, 0, h_bearing/2 + h_face]) 
            can(d=id_bearing, h=h_bearing+h_face+1, center=BELOW);
        translate([0, 0, -h_bearing/2-1]) 
            can(d=id_bearing - 2, taper=id_bearing, h = 1.3, center=BELOW);
    }
    module shape() {
        translate([0, 0, h_bearing/2]) {
            if (protect_from_elephant_foot) {
                render(convexity=10) intersection() {
                    can(d=d_face, h = 2, hollow=id_bearing, center=ABOVE);
                    can(d=d_face, h = 2, taper=d_face-2, center=ABOVE);
                }
            } else {
                can(d=md_bearing, h = 2, hollow=id_bearing, center=ABOVE);
            }
        }
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
        }
    }
    if (show_vitamins) {
        ball_bearing(BB608);
        slider_shaft(orient_for_build=true);
    }
    color("DarkSeaGreen") {
        if (as_clearance) {
            can(d=d_face + 5, taper=d_face, h=5, center=BELOW); 
            
        } else if (orient_for_build) {
            translate([0, 0, h_bearing/2 + h_face]) rotate([180, 0, 0]) shape();
        } else {
            //translation = [0, 0, 0];  // centered on bearing
            translation = [0, 0, -h_bearing/2];  // centered on top
            translate(translation) shape();
        } 
    }
}


//


module shaft_rider(h, orient_for_build, show_vitamins) {
    a_lot = 200; 
    module blank() {
        can(d=md_bearing + 1, h=h, center=ABOVE);
    }
    module shape() {    
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
            rotate([0, 0, 60]) triangle_placement(r=r_rider) 
                ptfe_tube(as_clearance=true, h=a_lot, clearance=ptfe_snap_clearance);            
        }
    }
    if (show_vitamins) {
        translate([0, 0, h/2]) 
            rotate([0, 0, 60]) triangle_placement(r=r_rider) 
                ptfe_tube(as_clearance=true, h=h, clearance=ptfe_snap_clearance);         
        //translate([0, 0, -5]) ball_bearing(BB608);
        //slider_shaft(orient_for_build=true);
    }    
    if (orient_for_build) {
        translate([0, 0, 0]) rotate([0, 0, 0]) shape();
    } else {
        translation = [0, 0, 0];  
        translate(translation) shape();
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


if (test_fit_shaft_rider) {
    shaft_rider(h=5, orient_for_build=true, show_vitamins=false);
}

module shaft_gear(orient_for_build = false, orient_to_center_of_rotation=false,  show_vitamins=false) {
    translation = 
        orient_for_build ? [0, 0, 0] : 
        orient_to_center_of_rotation ? [0, 0, -clamp_gear_diameter/2] :
        [-dx_clamp_shaft, 0, 0];
    module shape() {
        render(convexity=20) difference() {
            base_gear(teeth=shaft_gear_teeth);
            can(d=md_bearing-0.01, h=100);   
        }
        shaft_rider(h=h_shaft_rider, orient_for_build=false, show_vitamins=false);
        translate([0, 0, h_shaft_rider]) 
            slider_shaft_bearing_insert(orient_for_build=true, protect_from_elephant_foot=false);
    }
    
    if (show_vitamins) {
        dz_bb = -h_bearing/2 - clamp_gear_diameter/2 - h_shaft_bearing_base;
        dz_insert = dz_bb + h_bearing/2 ; // -clamp_gear_diameter/2;
//        translate([0, 0, dz_bb]) ball_bearing(BB608);
        translate([0, 0, dz_insert]) slider_shaft_bearing_insert();
        //translate(translation ) shaft_rider(h=10, orient_for_build=orient_for_build, show_vitamins=show_vitamins);
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
        [-dx_clamp_gear, 0, dz_clamp_screw];
    s = s_slider + 2 * slider_clearance;
    a_lot = 100;
    h_neck = 2;
    dz = h_neck + h_bearing + h_slider + elephant_clearance ;
    module shape() {
        //render(convexity=20) difference() {
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
        dx_bb = h_bearing/2 + shaft_gear_diameter/2 + h_neck;
        translate([dx_bb, 0, 0])  rotate([0, 90, 0]) ball_bearing(BB608);
    }
    color("violet", alpha=alpha_clamp_gear) {
        if (orient_for_build) {
            translate([0, 0, dz]) shape();
        } else {
            translate(translation) rotate([0, -90, 0])  shape();
        } 
    }     
}

module clamp_slide(orient_for_build=true, show_vitamins=false) {
    
    
    translation = [-dx_clamp_slide - clamping_lift, 0, dz_clamp_screw];    
    module shape() {
        render() difference() {
            block([s_slider, s_slider, h_slider], center=BELOW);
            translate([0, 0, 25]) hole_through("M2", $fn=12);
            translate([0, 0, -h_slider+1.5]) nutcatch_parallel("M2", clh=5, $fn=12);
        }
    }
    if (show_vitamins) {
        color(BLACK_IRON) {
            translate([-clamping_lift-screw_length-d_filament/2 + 0.2, 0, dz_clamp_screw]) 
                rotate([0, -90, 0]) 
                    screw(str("M2x", screw_length));
            translate([-clamping_lift-d_filament/2 -7, 0, dz_clamp_screw]) 
                rotate([0, -90, 0]) 
                    nut("M2");
            // Stationary nut
            *translate([-2.2, 0, gear_diameter/2]) 
                rotate([0, 90, 0]) nut("M2");
        }
    }
    color("brown", alpha=alpha_clamp_gear_slide) {
        if (orient_for_build) {
            rotate([0, 180, 0])  shape();
        } else {
            translate(translation) rotate([0, -90, 0])  shape();
        } 
    }  
}


module bearing_block(show_vitamins=false) {
    a_lot = 100;
    bearing_wall = 2;
    h_neck = 2;
    s = od_bearing + 2 * bearing_wall;
    d_bearing_retention = od_bearing - 1;
    dz_shaft = clamp_gear_diameter/2 + h_bearing  + h_shaft_bearing_base;
    dx_clamp = shaft_gear_diameter/2 + h_bearing  + h_neck;
    module blank() {
        union() {
            hull() {
                translate([0, 0, -dz_shaft]) can(d=s, h=2*bearing_wall);
                translate([dx_clamp+bearing_wall, 0, -dz_shaft]) 
                    block([2*bearing_wall, s/2, 2*bearing_wall], center=BEHIND);
            }
            hull() {
                translate([dx_clamp, 0, 0]) rotate([0, 90, 0]) can(d=s, h=2*bearing_wall);
                translate([dx_clamp+bearing_wall, 0, -dz_shaft]) 
                    block([2*bearing_wall, s/2, 2*bearing_wall], center=BEHIND);
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
        block([x_clamp_nut_block, 8, dz_clamp_screw + 4], center=ABOVE+BEHIND);
        block([3, 8, dz_clamp_screw + 4], center=ABOVE+FRONT);
        translate([dx_glides, 0, -z_traveller]) can(d=2*r_glide_mod + 2, h=10, hollow=2*r_glide_mod + 1, center=ABOVE);
        // riders on glides:
      
    }
    module clamp_screw_clearance() {
        translate([0, 0, dz_clamp_screw]) {
            rotate([0, 90, 0]) {
                hole_through("M2", $fn = 12);
            } 
            translate([-2.2, 0, 0]) rotate([0, -90, 180]) {
                nutcatch_sidecut("M2", $fn = 12, clh=.5);  
            }            
        }
    }
    module shape() {
        a_lot = 30;
        render(convexity=20) difference() {
            blank();
            
            translate([-dx_clamp_shaft, 0, 0]) can(d=od_bearing, h=z_bearing_engagement, center=ABOVE);
            ptfe_tube(as_clearance=true, h=20, clearance=ptfe_snap_clearance);
            filament(as_clearance=true); 
            ptfe_glides(orient_for_build = false, as_traveller_clearance = true, clearance=ptfe_slide_clearance); 
            clamp_screw_clearance();
            
        }
        translate([dx_glides, 0, -z_traveller]) 
            triangle_placement(r=r_glide_mod) block([1,4, 10], center=FRONT+ABOVE);  
        
        
    }    
    if (show_vitamins) {
        translate([-dx_clamp_shaft, 0, -h_bearing/2 + z_bearing_engagement]) 
            ball_bearing(BB608);
        translate([-dx_clamp_shaft, 0, z_bearing_engagement])
            slider_shaft_bearing_insert(orient_for_build=false, show_vitamins=false);
        translate([dx_clamp_bearing, 0, dz_clamp_screw]) 
            rotate([0, 90, 0]) ball_bearing(BB608);
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
        translate([70, 0, 0]) shaft_gear(orient_for_build=true, show_vitamins=false);
    } else {
        shaft_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}

if (build_prong_assembly) {
    if (orient_for_build) {
        translate([20, -20, 0]) prong_assembly(orient_for_build=true);
    } else {
        prong_assembly(locked=prong_locked, show_vitamins=show_vitamins);
    }     
}

if (build_clamp_slide) {
    if (orient_for_build) {
        translate([40, 20, 0]) clamp_slide(orient_for_build=true, show_vitamins=false);
    } else {
        clamp_slide(orient_for_build=false, show_vitamins=show_vitamins);
    }    
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






