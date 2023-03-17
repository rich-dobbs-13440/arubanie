include <logging.scad>
include <centerable.scad>
use <dupont_pins.scad>
use <shapes.scad>
use <not_included_batteries.scad>


/* [Measurements] */

jaw_thickness = 3.04; 
h_stranded_32_gauge = 8.42;  
h_stranded_22_gauge = 10.94;
h_bottom_of_pivot = 10.33;
h_small_hole = 5.06;
h_large_hole = 5.06;

l_22_to_32_gauge  = 14.62; 
l_22_to_other_jaw = 11;
l_22_to_small_hole = 8; 
l_22_to_large_hole = 17;

d_large_hole = 4.75;

wire_diameter = 1.66; // Includes insulation
exposed_wire = 2.14; 

nut_thickness = 2.14;
nut_width = 3;

/* [Show] */
show_body = true;
show_gauge_block = true;
orient_for_build = false;

/* [Design] */

nut_cut_padding = 2.5; // [0:0.25:4]
wall = 4; // 
y_clamp = 9; // [0:20]
z_nutcatch_clamp = 5;
//d_registration_nib = 2; // [2.5:0.05:5]

dy_left_gauge_nutcatch = -3;
delta_gauge_nutcatch = 10;

y_support = 28; // [0:22]
z_support = 3; // [0:10]

x_gauge_registration = 2; // [2:5]
y_gauge_registration = 12; // [4:10]
z_gauge_registration = 4; // [0:5]

end_of_customization() {}


wire_stripper_depth_gauge(show_body, show_gauge_block, orient_for_build);  

*large_hole_bushing();

module large_hole_bushing() {
    // Fills in space around m3 nut to create a better registration
    translate([20, 0, 0]) difference() {
        can(d=d_large_hole, h=jaw_thickness);
        translate([0, 0, 25]) hole_through(name="M3");
    }
}



module wire_stripper_depth_gauge(
        show_body = true,
        show_gauge_block = true,
        orient_for_build = false) {
    

    nutcut_width = 1.45*nut_width + 2 * nut_cut_padding;
    nutcut_thickness = nut_thickness + 2 * nut_cut_padding;
    dx_nutcatch = jaw_thickness/2 + nut_cut_padding;
    dy_hole_mid_point = (l_22_to_large_hole + l_22_to_small_hole)/2;
    dx_between_holes =  l_22_to_large_hole - l_22_to_small_hole;
    dx_gauge_nutcatch = 1.5*jaw_thickness + nutcut_width/2;
    x_support = dx_gauge_nutcatch + nutcut_width/2;
            
    
    module clamp(dy, z_nutcatch) {
        body = [
            nutcut_thickness, 
            nutcut_width,
            nutcut_width,
        ];  
        bottom = [body.x, body.y, wall];
        jaw_bottom = [jaw_thickness, nutcut_width, wall];
        translate([-body.x/2-jaw_thickness/2, dy, 0]) {
            difference() {
                block(body, center=ABOVE);
                center_reflect([1, 0, 0]) {
                    translate([0, 0, z_nutcatch]) { 
                        nutcatch(screw_axis = X_AXIS, cut_axis = Z_AXIS, center = CENTER+BEHIND);
                    }
                }
            }
            block(bottom, center=BELOW);  
        }
        block(jaw_bottom, center=BELOW+RIGHT);
    }
    module registration_joiner() {
        bottom = [nutcut_thickness, l_22_to_large_hole, wall];
        translate([-jaw_thickness/2, 0, 0]) {
            block(bottom, center=LEFT+BELOW+BEHIND);
        }
    }
    
    module profile_block() {
        
        module profile(x, dy, z, center) {
            translate([jaw_thickness/2, dy, 0]) {
                block([x, 0.01, z], center = FRONT+center);
            } 
        }   
        
        #mirror([1, 0, 0]) { // Want this to be on the back side
            hull() {
                profile(wall, 0, h_stranded_22_gauge, ABOVE);
                profile(wall, l_22_to_32_gauge, h_stranded_32_gauge, ABOVE);  
            }
        } 
        
    }
    
    module gauge_nutcatches() {
        translation = [
            x_support - x_gauge_registration - nutcut_width/2,
            delta_gauge_nutcatch/2, 
            -wall + nut_cut_padding + nut_thickness/2
        ];
        translate([0, y_support/2, 0]) {
            center_reflect([0, 1, 0]) {
                translate(translation){
                    translate([0, 0, 6]) mirror([0, 0, 1]) nutcatch_parallel("M3", clh=10, clk=1);
                    center_reflect([0, 0, 1]) { // Kludge for screws both up and down
                        nutcatch(screw_axis = Z_AXIS, cut_axis = X_AXIS, center = CENTER); 
                    }
                }
            }
        }
    }
    
    module gauge_translation() {
        translate([jaw_thickness/2, -l_22_to_small_hole-3, 0]) {
            children();
        }
    }
    
    module gauge_registration() {
        gauge_registration = [
            x_gauge_registration, 
            y_support, 
            z_support + z_gauge_registration
        ];
        t_gauge_registration = [
            x_support - gauge_registration.x,
            0,
            0
        ];
        translate([x_support/2, 0, 0]) 
        //center_reflect([1, 0, 0])
        translate([x_support/2, 0, 0]) 
            block(gauge_registration, center=RIGHT+BEHIND+ABOVE);
    }
    

    module gauge_support() {
        module support_block() {
            support = [x_support, y_support, z_support];
            support_base = [x_support, y_support, wall];
            under_jaw = [jaw_thickness, y_support, wall];
            block(under_jaw, center=RIGHT+BEHIND+BELOW);
            block(support_base, center=RIGHT+FRONT+BELOW);
            block(support, center=RIGHT+FRONT+ABOVE);
        }
        difference() {
            gauge_translation() {
                difference() {
                    union() {
                        support_block();
                        gauge_registration();
                    }
                    gauge_nutcatches();
                    
                }
            }
            small_hole_hole_through();
        }
    }

    module gauge_body() {
        clamp(y_clamp, z_nutcatch_clamp);
        clamp(-l_22_to_small_hole, h_small_hole);
        clamp(-l_22_to_large_hole, h_large_hole);
        registration_joiner();
        gauge_support();
    }
    
    if (show_body) {
        gauge_body();
    }
    if (show_gauge_block) {
        if (orient_for_build) {
            translate([20, 0, -z_support-wall]) gauge_block();
        } else {
            color("orange") gauge_block();
        }
    }
    
    module small_hole_hole_through() {
        translation = [
            jaw_thickness/2 + 5, 
            -l_22_to_small_hole,
            h_small_hole
        ];
        translate(translation) {
            rotate([0, 90, 0]) { 
                translate([0, 0, 25]) hole_through("M3");
                mirror([0, 0, 1]) nutcatch_parallel("M3", clh=20, clk=1);
            }
        }
    }
    //small_hole_hole_through();
    
    module gauge_block() {
        module profile(x, dy, z) {
            profile = [
                x,
                0.01, 
                z-z_support
            ];
            translate([jaw_thickness/2, dy, z_support]) {
                block(profile, center = FRONT+ABOVE);
            } 
        }
       
       module follow_jaw_block(x) {
            hull() {
                profile(x, -14, h_stranded_22_gauge);
                profile(x, 0, h_stranded_22_gauge);
                profile(x, l_22_to_32_gauge, h_stranded_32_gauge); 
            } 
       } 
        
        x_full = x_support - x_gauge_registration;
        x_wire_stop = 3;
        x__bottom = x_wire_stop + exposed_wire;
        difference() {
            union() {
                follow_jaw_block(x__bottom);
                translate([exposed_wire, 0, 4]) follow_jaw_block(x_wire_stop);
                hull() {
                   profile(x_full, -5, 6);  
                   profile(x_full, l_22_to_32_gauge+2, 6);
                }
            }
            gauge_translation() {
                gauge_nutcatches();
            }
            small_hole_hole_through();
        }
        
    }
}


