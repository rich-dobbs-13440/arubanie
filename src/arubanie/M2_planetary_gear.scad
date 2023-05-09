include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>




orient_for_build = false;

build_planet_carrier = false;
build_planet_gears = false;
build_solar_gear = true;

show_original = false;
show_mocks = true;
show_planet_holes = true;

scale_factor = 0.6;
z_range = 2;
z_solar_gear = 5 + z_range;
wall = 2;
    
module end_of_customization() {}


r_planet = 9; // [8 : 0.05 : 10]

module original_planet_gears() {
    color("magenta") 
        import("resource/planetary_gears_5_planets.stl", convexity=10);
}

module original_solar_gear() {
    import("resource/planetary_gears_5_solar.stl", convexity=10);
}

module original_ring_gear() {
    import("resource/planetary_gears_5_ring.stl", convexity=10);
} 

if (show_original) {
    original_planet_gears();
    original_solar_gear();
    original_ring_gear();
}

if (show_mocks) {

    translate([0, 0, 7]) color("silver") screw("M2x20");
}


////planets();
//
module planet_holes(cld) {
    module hole() {
        translate([r_planet, 0, 25]) 
            hole_through("M2", cld=cld, $fn=12);
    }
    hole();
    rotate([0, 0, 120]) hole();
    rotate([0, 0, 240]) hole();
}


if (show_planet_holes) {
    planet_holes(cld=0.4);
}
////planet_holes();
//
module planet_carrier(upper=false) {
    difference() {
        block([35, 35, wall], center=BELOW);
        
        //translate([0, 0, 2]) plane_clearance(ABOVE);
        planet_holes(cld=0.4);
        translate([0, 0, 10]) hole_through("M2", cld=0.4, $fn=12); 
//        if (upper) {
//            
//        } else {
//            can(d=8 + 1, h=10);
//        }
    }
}

if (build_planet_carrier) {
    if (orient_for_build) {
        translate([30, 0, 0]) planet_carrier(upper=false);
        translate([60, 0, 0]) planet_carrier(upper=true);
    } else {
        translate([0, 0, 0]) planet_carrier(upper=false);
    }
}


module solar_gear() {
    module horizontal_scaled_gear() {
        scale([scale_factor, scale_factor, 1]) original_solar_gear();
    }
    color("green") {
        render(convexity=10) difference() {
            union() {
                horizontal_scaled_gear();
                translate([0, 0, z_range]) horizontal_scaled_gear();
            }
            translate([0, 0, 8]) hole_through("M2", cld=0.4, $fn=12);
            translate([0, 0, 2]) nutcatch_parallel("M2", clh=10);
        }
    }
          
}
if (build_planet_gears) {
    scale([scale_factor, scale_factor, 1]) original_planet_gears();
}
//
if (build_solar_gear) {
    if (orient_for_build) {
        translate([0, 0, z_solar_gear]) rotate([180, 0, 0]) 
            solar_gear();
    } else {
        solar_gear();
    }
}

//


//import("resource/solar_planetary_gears_2.stl", convexity=3);