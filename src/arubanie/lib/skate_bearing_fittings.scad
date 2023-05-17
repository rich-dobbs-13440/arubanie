include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
include <material_colors.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>


od_bearing = 22.0 + 0;
id_bearing = 8.0 + 0;
h_bearing = 7.0 + 0;
md_bearing = 14.0 + 0;

/* [Ouput Control] */
orient_for_build = false;
build_bearing_holder = true;
build_retainer = true;
retaining_screw_holes = true;
show_mocks = true;

/* [Design] */

default_clearance = 0.3;


module end_of_customization() {}

    //translate([0*dx, 0, 0]) bearing_holder(1);  // Way too much
    //translate([1*dx, 0, 0]) bearing_holder(0.5);  // Still too much
    //translate([2*dx, 0, 0]) bearing_holder(0.2);  // Too tight
    //translate([3*dx, 0, 0]) bearing_holder(0.1);  // Too tight
    //translate([4*dx, 0, 0]) bearing_holder(bearing_clearance=0.3, h=4); 
    //translate([4*dx, 0, 0]) skate_bearing_holder(bearing_clearance=0.3, h=8, cap=true, screw_attachment=true);  
    //translate([5*dx, 0, 0]) bearing_holder(0.4); // Too loose

module screw_attachment() {
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


module skate_bearing_holder(
        bearing_clearance=0.3, 
        h=h_bearing, 
        cap=true, 
        wall = 1, 
        //include_retainer_mounting = false,
        as_clearance = false,
        as_retaining_clearance = false,
        show_mocks=false,
        color_code = "salmon") {
    
    a_lot = 100;
    id = od_bearing + 2 * bearing_clearance;
    od = id + 2 * wall;
            
    module holder() {
        color(color_code) {
            can(d = od, hollow = id, h = h, center=ABOVE);       
            if (cap) {
                translate([0, 0, h]) {
                    difference() {
                        can(d=od, h=1);
                        can(d=id, taper=id-2, h=2);
                    }
                }
            }
        }
    }

    if (as_clearance) {
        can(d = od, h = a_lot);  
    } else if(as_retaining_clearance) {
        can(d = od_bearing - 4, h = a_lot);
    } else {
        if (show_mocks) {
           translate([0, 0, h_bearing/2]) ball_bearing(BB608);
        }         
        holder();
    }
    
}


module skate_bearing_retainer(wall = 1, orient_for_build=false, color_code="Crimson", show_mock=true, as_screw_clearance=false) {
    screw_offset = 10;
    module screw_holes(as_mocks=false) {
        z_offset = as_mocks ? 0 : 25;
        center_reflect([1, 0, 0]) 
            translate([screw_offset, screw_offset, z_offset]) 
        
                if (as_mocks) {
                    color(BLACK_IRON) screw("M2x6");
                } else {
                    hole_through("M2", $fn=12); 
                }
    }
    if (show_mocks && !orient_for_build) {
        screw_holes(as_mocks=true);
    }    
    color(color_code) {
        render() difference() {
            block([25, 25, wall], center=BELOW);
            skate_bearing_holder(as_retaining_clearance=true);
            screw_holes();
        }
    }

}

if (build_bearing_holder) {
    skate_bearing_holder(cap=true, show_mocks=show_mocks);
}

if (build_retainer) {
    skate_bearing_retainer(orient_for_build = orient_for_build);
}