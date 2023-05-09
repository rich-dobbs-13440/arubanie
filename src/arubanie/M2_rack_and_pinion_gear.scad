include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>




orient_for_build = false;

build_pinion_gear = true;
build_rack_gear = true;
show_original = false;
show_mocks = true;

horizontal_scale_factor = 1.;
z_range = 4;
z_pinion_original = 5;
z_pinion_gearing = z_pinion_original + z_range;
z_pinion_anti_elephant = 2;
z_pinion_gear = z_pinion_gearing + z_pinion_anti_elephant;
wall = 2;

dy_center_pinion = -3.8; // [-10:0.1:10]
dy_rack_mount = -9.2; // [-10: 0.1:-6]
    
module end_of_customization() {}



module original_pinion_gear() {
    color("magenta") 
        translate([0, dy_center_pinion]) 
            import("resource/M2_pinon_gear.stl", convexity=10);
}

module original_rack_gear() {
    import("resource/M2_rack_gear.stl", convexity=10);
}

if (show_original) {
    original_pinion_gear();
    original_rack_gear();
}

if (show_mocks) {
    translate([0, 0, 7]) color("silver") screw("M2x20");
}



module build_rack_gear(orient_for_build) {
    dx_rack_mount = 13;
    module shape() {
        difference() {
            union() {
                scale([horizontal_scale_factor, horizontal_scale_factor, 1]) 
                    original_rack_gear();
                translate([dx_rack_mount, dy_rack_mount, 0])  block([10, 18, 5], center=ABOVE+RIGHT+FRONT);
            }
            center_reflect([0, 1, 0])  translate([18, 3, 25]) hole_through("M2", cld=0.4, $fn=12);
        }
    }
    if (orient_for_build) {
        translate([0, 0, -dy_rack_mount]) rotate([90, 0, 0]) shape();
    } else {
        translate([0, 0, 2.5]) shape();
    }
}

if (build_rack_gear) {
    if (orient_for_build) {
         translate([0, 15, 0]) build_rack_gear(orient_for_build=true);
    } else {
        build_rack_gear(orient_for_build=false);
    }
}


module pinion_gear(orient_for_build=false) {
    module horizontal_scaled_gear() {
        scale([horizontal_scale_factor, horizontal_scale_factor, 1]) original_pinion_gear();
    }
    module located_shape() {
        render(convexity=10) difference() {
            union() {
                horizontal_scaled_gear();
                translate([0, 0, z_range]) horizontal_scaled_gear();
                translate([0, 0, z_pinion_gearing]) can(d=10, taper=9, h=z_pinion_anti_elephant, center=ABOVE);
            }
            translate([0, 0, 25]) hole_through("M2", cld=0.4, $fn=12);
            translate([0, 0, 2]) nutcatch_parallel("M2", clh=10);
            translate([0, 0, z_pinion_gear]) plane_clearance(ABOVE);
        }
    }
    if (orient_for_build) {
        translate([0, 0, z_pinion_gear]) rotate([180, 0, 0]) located_shape();
    } else { 
        color("green") located_shape();
    } 
}




if (build_pinion_gear) {
    if (orient_for_build) {
        pinion_gear(orient_for_build=true);
    } else {
        pinion_gear();
    }
}

//


//import("resource/solar_planetary_gears_2.stl", convexity=3);