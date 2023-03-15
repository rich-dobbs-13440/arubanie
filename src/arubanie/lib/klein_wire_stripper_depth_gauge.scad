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

nut_cut_padding = 2; // [1:3]
wall = 3; // 
y_clip = 5; // [0:20]
d_registration_nib = 2.5; // [3:0.05:5]
z_side_nutcatch = 8; // [0:0.25:10]


end_of_customization() {}

wire_stripper_depth_gauge();      

module wire_stripper_depth_gauge() {
    nutcut_wall = nut_width + 2 * nut_cut_padding;
    dx_nutcatch = jaw_thickness/2 + nut_cut_padding;
    module registration_body() {
        module side_body() {
            body = [
                nutcut_wall, 
                l__22_to_large_hole - l__22_to_small_hole + d_registration_nib, 
                h_bottom_of_pivot
            ];
            bottom = [body.x, body.y, wall];
            alot = 50;
            slit = [0.4, alot, alot];
            t_nib_small_hole = [-body.x/2, -body.y/2 + d_registration_nib/2, h_small_hole];
            t_nib_large_hole = [-body.x/2,  body.y/2 - d_registration_nib/2, h_small_hole];
            
            translate([body.x/2, -body.y/2, 0]) {
                difference() {
                    block(body, center=ABOVE);
                    block(slit, center=ABOVE);
                    translate([0, 0, body.z/2]) 
                        nutcatch(screw_axis = X_AXIS, cut_axis = Z_AXIS, center = CENTER);
                }
                block(bottom, center=BELOW);
                translate(t_nib_small_hole) sphere(d=d_registration_nib, $fn=12);
                translate(t_nib_large_hole) sphere(d=d_registration_nib, $fn=12);
            }
        }
        
        center_reflect([1, 0, 0]) {
            translate([jaw_thickness/2, 0, 0]) side_body();
        }

    }
    
    module gauge_nutcatches() {
        translate([5, 4, 3]) nutcatch(screw_axis = Z_AXIS, cut_axis = Z_AXIS, center = CENTER);
        translate([5, 11, 3]) nutcatch(screw_axis = Z_AXIS, cut_axis = Z_AXIS, center = CENTER);        
    }
    
    module gauge_support() {
        module profile(x, dy, z, center) {
            translate([jaw_thickness/2, dy, 0]) {
                block([x, 0.01, z], center = FRONT+center);
            } 
        }   
        dy_clip_block = y_clip + nut_width/2 + nut_cut_padding;
        profile_base = [
            jaw_thickness/2 + wall, 
            l_22_to_32_gauge, 
            wall];
        
        mirror([1, 0, 0]) { // Want this to be on the back side
            hull() {
                profile(wall, 0, h_stranded_22_gauge, ABOVE);
                profile(wall, l_22_to_32_gauge, h_stranded_32_gauge, ABOVE);  
            }
        }
        gauge_base = [nutcut_wall + jaw_thickness/2, l_22_to_32_gauge, wall];
        block(profile_base, center=RIGHT+BEHIND+BELOW);
        difference() {
            block(gauge_base, center=RIGHT+FRONT+BELOW);
            gauge_nutcatches();
        }

    }

    registration_body();
    gauge_support();
    

}


