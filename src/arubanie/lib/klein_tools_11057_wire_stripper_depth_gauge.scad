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
l__22_to_small_hole = 8; 
l__22_to_large_hole = 17;

d_large_hole = 4.57;

wire_diameter = 1.66; // Includes insulation
exposed_wire = 2.14; 

nut_thickness = 2.14;
nut_width = 3;

/* [Design] */

nut_cut_padding = 2.5; // [1:4]
wall = 4; // 
y_clamp = 9; // [0:20]
z_nutcatch_clamp = 5;
d_registration_nib = 2; // [2.5:0.05:5]

z_gauge_nutcatch = 8; // [0:0.25:10]
dy_left_gauge_nutcatch = -4;
delta_gauge_nutcatch = 14;

y_support = l__22_to_small_hole + l_22_to_32_gauge; // [0:22]
z_support = 6; // [0:10]


end_of_customization() {}

wire_stripper_depth_gauge();      

module wire_stripper_depth_gauge() {
    nutcut_width = 1.45*nut_width + 2 * nut_cut_padding;
    nutcut_thickness = nut_thickness + 2 * nut_cut_padding;
    dx_nutcatch = jaw_thickness/2 + nut_cut_padding;
    dy_hole_mid_point = (l__22_to_large_hole + l__22_to_small_hole)/2;
    dx_between_holes =  l__22_to_large_hole - l__22_to_small_hole;
    echo("dx_between_holes", dx_between_holes);
    
    module registration_nibs() {
        t_nib_small_hole = [-jaw_thickness/2, -l__22_to_small_hole, h_small_hole];
        t_nib_large_hole = [-jaw_thickness/2, -l__22_to_large_hole, h_large_hole];        
        translate(t_nib_small_hole) sphere(d=d_registration_nib, $fn=12);
        translate(t_nib_large_hole) sphere(d=d_registration_nib, $fn=12);        
    }
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
        joiner = [nutcut_thickness, l__22_to_small_hole, wall]; 
        backer = [wall, l__22_to_large_hole + d_registration_nib, nutcut_width-wall];
        backer_bottom = [nutcut_thickness, backer.y, wall];
        
        * block(joiner, center=LEFT+BELOW); 
        translate([-jaw_thickness/2, 0, 0]) {
            block(backer_bottom, center=LEFT+BELOW+BEHIND);
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
        dx = jaw_thickness/2 + nutcut_width/2;
        translate([dx, dy_left_gauge_nutcatch, z_support - nut_cut_padding]) 
            rotate([180, 0, 0]) 
                nutcatch(screw_axis = Z_AXIS, cut_axis = X_AXIS, center = CENTER);
        translate([dx, dy_left_gauge_nutcatch + delta_gauge_nutcatch, z_support - nut_cut_padding]) 
            rotate([180, 0, 0]) 
                nutcatch(screw_axis = Z_AXIS, cut_axis = X_AXIS, center = CENTER);        
    }
    

    module gauge_support() {
        module support_block() {
            base = [nutcut_width + jaw_thickness/2, y_support, wall];
            base_behind = [nutcut_thickness + jaw_thickness/2, y_support, wall];
            support = [nutcut_width, base.y, z_support];
            translate([0, -l__22_to_small_hole, 0]) {
                block(base, center=RIGHT+FRONT+BELOW);
                block(base_behind, center=RIGHT+BEHIND+BELOW);
                translate([jaw_thickness/2, 0, 0]) block(support, center=RIGHT+FRONT+ABOVE);
            }
        }
        difference() {
            support_block();
            gauge_nutcatches();
        }
    }

    clamp(y_clamp, z_nutcatch_clamp);
    clamp(-l__22_to_small_hole, h_small_hole);
    clamp(-l__22_to_large_hole, h_large_hole);
    //registration_nibs();
    registration_joiner();
    gauge_support();
    

}


