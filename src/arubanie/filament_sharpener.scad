include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>


show_slicer_mocks = true;
build_shaver_sharpener = false;
build_slicer_base = true;
build_slicer = true;
shaver_point_angle = 15;


wall = 2;
alpha_sharpener = 1;
clearance = 0.2; //[0.2, 0.5, 1]

/* [blade positioning design] */
blade_end_gap = 3;
dx_blade = -18; //[-18 : 0.5: 2]
dy_blade = 0.8; // [-2 : 0.1 : 2]
blade_angle = 6.4; // [0 : 0.2 : 10]
slicer_point_angle = 20;

module end_of_customization() {}

filament_diameter = 1.75;
a_lot = 100;
blade_extent = [21.75, 6.25, 0.40];
blade_edge_width = 1.57;
blade_hole_translation = [blade_extent.x/2, blade_extent.y/2 + blade_edge_width/2, 0];

/* [blade positioning calculations] */
 

module pencil_sharpener_blade(as_clearance=false, clearance=0, access_from=ABOVE) {
    actual_clearance = as_clearance ? clearance : 0;
    clearances = 2*[actual_clearance, actual_clearance, a_lot]; 
    module shape() {
        difference() {
            hull() {
                translate([0, blade_edge_width, 0]) block(blade_extent - [0, blade_edge_width, 0], center=FRONT+RIGHT+ABOVE);
                block([blade_extent.x, blade_extent.y, 0.01], center=FRONT+RIGHT+ABOVE);
            }
            translate(blade_hole_translation) can(d=3.1, h=a_lot);
        }
        translate(blade_hole_translation) {
            rotate([180, 0, 0]) {
                screw("M2x6", $fn=12);
                translate([0, 0, -4]) nut("M2", $fn=12);
            }
        }
    }
    if (as_clearance) {
        if (access_from == ABOVE) {
            translate([-clearance, -clearance, -clearance]) block(blade_extent + clearances, center=FRONT+RIGHT+ABOVE);
        } else if (access_from == BELOW) {
            translate([-clearance, -clearance, blade_extent.z + clearance]) block(blade_extent + clearances, center=FRONT+RIGHT+BELOW);
        } else if (access_from == BELOW+BEHIND) {
            translate([-clearance, -clearance, blade_extent.z + clearance]) block(blade_extent + clearances, center=FRONT+RIGHT+BELOW);
            translate([-clearance, -clearance-2, blade_extent.z + clearance]) block(blade_extent + clearances, center=FRONT+RIGHT+BELOW);
        } else {
            assert(false);
        }
        translate(blade_hole_translation + [0, 0, 25]) hole_through("M2", $fn=12);
    } else {
        color("silver") {
            shape();
        }
    }  
}


module slicer_positioned_blade(dx_blade, as_clearance=false, clearance=0, access_from=ABOVE)
{
    translate([dx_blade, dy_blade, 0]) {
        rotate([0, 0, -blade_angle]) {
            translate([-blade_end_gap, 0, 0]) {
                pencil_sharpener_blade(as_clearance=as_clearance, clearance=clearance, access_from=access_from);
            }
        }
    }
}



module filament(point_angle) {
    l_tapering = (filament_diameter/2)/tan(point_angle);
    echo("l_tapering", l_tapering);
    color("red")  {
        translate([l_tapering, 0, 0]) rod(d=filament_diameter, l=30, center=FRONT);
        rod(d=0, taper=filament_diameter, l = l_tapering, center=FRONT); 
    }

}


if (show_slicer_mocks) {
    slicer_positioned_filament(slicer_point_angle);
    slicer_positioned_blade(dx_blade=dx_blade);
}


module shaver_sharpener() {
    module shaving_clearance() {
        module shaving_clearance_cone() {  
            difference() {
                positioned_filament(point_angle);
                translate([4, 0, 0]) plane_clearance(FRONT);
            }
        }
        hull() {
            shaving_clearance_cone();
            translate([0, 0, 4]) shaving_clearance_cone();
        }
    }
    color("green", alpha=alpha_sharpener) {
        render(convexity=10) difference() {
            translate([blade_extent.x/4, blade_extent.y/2, clearance]) 
                block(blade_extent + [2*wall, 2*wall, wall], center=BELOW);
            positioned_blade(as_clearance=true, clearance=clearance);
            positioned_filament(point_angle);
            shaving_clearance();
        }
    } 
}

if (build_shaver_sharpener) {
    shaver_sharpener();
}

module slicer_positioned_filament(point_angle, as_clearance=true, clearance=0.0) {
    color("magenta") rotate([0, point_angle, 0]) rod(d=filament_diameter + 2*clearance, l=100);
}


module slicer_base() {
    module slider_clearance() {
        hull() {
            center_reflect([1, 0, 0]) 
                translate([100, 4, 0]) 
                    rotate([180, 0, 0]) {
                        hole_through("M2", $fn=12, h=3, hcld=0.8);
                        translate([0, 0, 2.5]) hole_through("M2", $fn=12, h=3, hcld=0.8);
                    }
        }
    }
    module rotator(include_front = false, include_behind = false) {
        if (include_front) {
            rotate([0, slicer_point_angle, 0]) rod(d=filament_diameter + 4, l=30, center=FRONT);
        }
        if (include_behind) {
            rotate([0, slicer_point_angle, 0]) rod(d=filament_diameter + 4, l=4, center=BEHIND);
        }
    }
    color("brown") {
        difference() {
            union() {
                translate([-15, 0, 0]) block([40, 10, 5], center=BELOW+FRONT+RIGHT);
                rotator(include_front=true, include_behind=true);
                
            }
            slicer_positioned_filament(point_angle=slicer_point_angle, as_clearance=true, clearance=0.2);
            slider_clearance();
            plane_clearance(ABOVE);
            //translate(blade_hole_translation + [0, 0, 25]) hole_through("M2", $fn=12);
        }  
     }
     
 }
 
 if (build_slicer_base) {
    slicer_base();
 }
 
 if (build_slicer) {
    color("violet", alpha=1) {
        translate([dx_blade, 0, 0]) 
            difference() {
                union() {
                    translate([-5, 2, 0]) block([30, 6, 4], center=ABOVE+FRONT+RIGHT);
                }
                plane_clearance(BELOW);
                translate([21, 3.9, 25]) hole_through("M2", $fn=12, cld=0.4);
                //translate([0, 0, 2]) plane_clearance(ABOVE);
                slicer_positioned_blade(dx_blade=0, as_clearance=true, clearance = 0.2, access_from=BELOW+BEHIND);
                // Just need a second hole, so move up and to the right
                //translate([0, 13, 5]) slicer_positioned_blade(dx_blade=0, as_clearance=true, clearance = 0.2, access_from=ABOVE); 
            }
    }
 }