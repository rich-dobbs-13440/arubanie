include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <MCAD/servos.scad>
use <PolyGear/PolyGear.scad>
//use <lib/ptfe_tubing.scad>

d_filament = 1.75 + 0.;
od_ptfe_tube = 4 + 0;

/* [Output Control] */

orient_for_build = false;

show_vitamins = true;
show_cross_section = false;

build_end_caps = true;
build_both_end_caps = true;
build_ptfe_glides = true;
build_shaft = true;
build_shaft_gear = true;
build_traveller = true;
build_clamp_gear = true;

alpha_clamp_gear = 1; // [0.25 : transparent, 1: solid]
clamping_lift = 0; // [-0.2: 0.1: 1]

/* [Clearances] */ 
ptfe_slide_clearance = 0.5; // [0.5:Actual, 1:test]
ptfe_snap_clearance = 0.2;
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

/* [Gear Design] */
gear_height = 5;
gear_diameter = 26.5;
hub_height = 4.6;
hub_diameter = 12.5;
z_gear_clearance = 1;
h_traveller_glide = 8;

s_slider = 6;


/* [Clamp Shaft Design] */
r_shaft_end = 0.5;
r_shaft = 2.5;
gear_filament_clearance = 6;
dx_clamp_shaft = gear_diameter/2 + d_filament/2 + gear_filament_clearance;
d_shaft_clearance = 2 * (r_shaft + r_shaft_end + shaft_clearance);

/* [End Cap Design] */
end_cap_pad = 4;
dx_end_cap = -dx_clamp_shaft - gear_diameter/2 - end_cap_pad; 
x_end_cap = dx_glides  + r_glide + dx_clamp_shaft + gear_diameter/2 + od_ptfe_tube/2 + 2 * end_cap_pad; // [1:0.1:40]
y_end_cap = max(d_shaft_clearance, 2*dx_glides); 
z_end_cap = 6; // [1:0.1:20]

end_cap = [x_end_cap, y_end_cap, z_end_cap];


/* [Traveller Design] */

traveller = [x_end_cap, y_end_cap, 2];
dx_traveller = dx_end_cap;

module end_of_customization() {}

module filament(as_clearance) {
    d = as_clearance ? 2.0 : d_filament;
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
    a_lot = 50;
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
            render(convexity=10) difference() { 
                blank();
                if (show_cross_section) {
                    plane_clearance(ABOVE);
                }
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

module base_gear() {
    translate([0, 0, 1.2]) 
        bevel_gear(
          n = 14,  // number of teeth
          m = 1.7,   // module
          w = 7,   // tooth width
          cone_angle     = 45,
          pressure_angle = 25,
          helix_angle    = -45,   // the sign gives the handiness
          backlash       = 0.1);
} 

module shaft_gear(orient_for_build, show_vitamins) {
    translation = orient_for_build ? [0, 0, 0] : [-dx_clamp_shaft, 0, 0];
    module glides(as_clearance, clearance) {
        dz = 3;
        r = 0.95*r_shaft + od_ptfe_tube/2 - ptfe_slide_clearance;
        rotate([0, 0, 60]) 
            translate([0, 0, hub_height + h_traveller_glide/2 + 1])
                triangle_placement(r=r) 
                    ptfe_tube(as_clearance=as_clearance, h=h_traveller_glide, clearance=clearance);
    }
    module shape() {
        render(convexity=20) difference() {
            base_gear();
            slider_shaft(as_gear_clearance=true, clearance=ptfe_slide_clearance);
        }
        render() difference() {
            translate([0, 0, hub_height]) can(d=hub_diameter, h=h_traveller_glide, center=ABOVE);
            slider_shaft(as_gear_clearance=true, clearance=ptfe_slide_clearance);
            glides(as_clearance=true, clearance=ptfe_snap_clearance);
        }
    }
    
    if (show_vitamins) {
        translate(translation ) glides(as_clearance=false, clearance=0);
    }
    color("pink") {
        if (orient_for_build) {
            translate([0, 0, 0]) shape();
        } else {
            translate(translation) shape();
        } 
    }   
}


module clamp_gear(orient_for_build, show_vitamins) {
    dx = gear_filament_clearance + d_filament/2;
    translation = [-dx, 0, gear_diameter/2];
    s = s_slider + 2 * slider_clearance;
    a_lot = 100;
    module shape() {
        render(convexity=20) difference() {
            base_gear();
            block([s, s, a_lot]);
        }
    }
    if (show_vitamins) {
        translate(translation) {
            rotate([0, -90, 0]) {
                translate([0, 0, 1.5+clamping_lift]) screw("M2x8");
                translate([0, 0, 0+clamping_lift]) nut("M2");
                // Stationary nut
                translate([0, 0, -3]) nut("M2");
            }
        }
    }
    color("violet", alpha=alpha_clamp_gear) {
        if (orient_for_build) {
            translate([0, 0, 0]) shape();
        } else {
            translate(translation) rotate([0, -90, 0])  shape();
        } 
    }     
}

module traveller(orient_for_build, show_vitamins) {
    //translation = orient_for_build ? [0, 0, 0] : [-dx_clamp_shaft, 0, 0];
    r_glide_mod = r_glide + od_ptfe_tube/2 + ptfe_slide_clearance;
    module blank() {
        translate([dx_traveller, 0, 0]) block(traveller, center=BELOW+FRONT);
        block([5.5, 8, gear_diameter/2 + 4], center=ABOVE+BEHIND);
        block([3, 8, gear_diameter/2 + 4], center=ABOVE+FRONT);
        translate([dx_glides, 0, -traveller.z]) can(d=2*r_glide_mod + 2, h=10, hollow=2*r_glide_mod + 1, center=ABOVE);
        // riders on glides:
      
    }
    module clamp_screw_clearance() {
        translate([0, 0, gear_diameter/2]) {
            rotate([0, 90, 0]) {
                hole_through("M2", $fn = 12);
            } 
            translate([-2.2, 0, 0]) rotate([0, -90, 180]) {
                nutcatch_sidecut("M2", $fn = 12);
            }            
        }
    }
    module shape() {
        a_lot = 30;
        render(convexity=20) difference() {
            blank();
            
            translate([-dx_clamp_shaft, 0, 0]) can(d=d_shaft_clearance, h=a_lot);
            ptfe_tube(as_clearance=true, h=20, clearance=ptfe_snap_clearance);
            filament(as_clearance=true); 
            ptfe_glides(orient_for_build = false, as_traveller_clearance = true, clearance=ptfe_slide_clearance); 
            clamp_screw_clearance();
            
        }
        translate([dx_glides, 0, -traveller.z]) 
            triangle_placement(r=r_glide_mod) block([1,4, 10], center=FRONT+ABOVE);  
        
        
    }    
    if (show_vitamins) {
        //translate(translation ) glides(as_clearance=false, clearance=0);
    }
    color("orange") {
        if (orient_for_build) {
            translate([0, 0, traveller.z]) shape();
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
        translate([60, 0, 0]) shaft_gear(orient_for_build=true, show_vitamins=false);
    } else {
        shaft_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}

if (build_clamp_gear) {
    if (orient_for_build) {
        translate([60, 30, 0]) clamp_gear(orient_for_build=true, show_vitamins=false);
    } else {
        clamp_gear(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}

if (build_traveller) {
    if (orient_for_build) {
        translate([0, -20, 0]) traveller(orient_for_build=true, show_vitamins=false);
    } else {
        traveller(orient_for_build=false, show_vitamins=show_vitamins);
    }    
}






