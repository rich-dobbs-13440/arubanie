include <lib/logging.scad>
include <lib/not_included_batteries.scad>
 use <lib/small_pivot_vertical_rotation.scad>
include <master_airbrush_measurements.scad>
use <master_air_brush.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;
infinity = 300;
/* [Show Parts] */

build_from = "air_hose"; // ["air_hose", "base", "on_side"]

show_assembly = true;
show_barrel_clips = false;
show_air_barrel_clips = false;
show_joiners = false;
show_barrel_joiner_support = false;
// Problem with pivots creating message about  "Exported object may not be a valid 2-manifold and may need repair"
show_pivots = false; 

/* [Show Construction] */
show_air_brush = false;
show_top_of_barrel_exclusion = false;

trigger_angle = 30;

/* [Dimensions] */

barrel_fraction_t = 1.0; //[0 : 0.01 : 1]
air_barrel_fraction_t = 1.0; //[0 : 0.01 : 1]
support_fraction_t = 0.50; //[0 : 0.1 : 1]
barrel_clip_angle_t = 90; //[0:5:180]
barrel_clearance = 0.5;
air_hose_clearance = 0.25;
wall_thickness = 2; //[2, 2.5, 3.0]
/* [Pivot Dimensions] */
h_pivot_t = 4; // [2 : 5]
w_pivot_t = 4; // [2 : 5] 
pintle_length_t = 10; // [2 : 20] 
gudgeon_length_t = 10; // [2 : 20] 
allowance_pivot = 0.5;
angle_pivot_t = 0; // [-135 : 15 : 135]
pivot_offset_below_barrel_cl_t = 2; // [ 0: 0.5: 6]

barrel_air_barrel_corner = [
    -(air_hose_diameter/2 + air_hose_clearance), 
    -(measured_barrel_diameter/2 + barrel_clearance), 
    0]; 


module pivots() {
    dz = measured_barrel_diameter/2 + barrel_clearance + w_pivot_t/2;
    dy = -pivot_offset_below_barrel_cl_t;
    for (side_sign = [-1, 1] ) {
        dz_side = side_sign * dz;
        translate([0, dy, dz_side]) 
            rotate([90, 0, -90])  // Correct for orientation of rotation
                assert(!is_undef(angle_pivot_t))
                small_pivot_vertical_rotation(
                    h_pivot_t, 
                    w_pivot_t, 
                    pintle_length_t, 
                    gudgeon_length_t, 
                    allowance_pivot, 
                    angle=angle_pivot_t);
    } 
}

if (show_pivots) {
    handle_orientation(build_from) {
        pivots();
    }
}
       
joiner_max_size = [
    barrel_back_to_air_hose - air_hose_clearance - wall_thickness, 
    air_hose_barrel_length - barrel_clearance - wall_thickness, 
    wall_thickness];


if (show_air_brush) {
    handle_orientation(build_from) {
        air_brush(trigger_angle); 
    }
}


module top_of_barrel_exclusion(barrel_clip_angle) {
    
    assert(is_num(barrel_clip_angle));
    rx = 90 - barrel_clip_angle/2; 
    dx = -15;
    translate([dx, 0, 0]) {
        rotate([rx, 0, 0])
        rotate([0, 90, 0]) {
            rotate_extrude(angle = barrel_clip_angle, convexity = 2) {
                square([1.25*measured_barrel_diameter, barrel_length]);
            }
        }
    }
}


if (show_top_of_barrel_exclusion) {
    handle_orientation(build_from) {
        top_of_barrel_exclusion(barrel_clip_angle_t);
    }
}


module barrel_clip(position, barrel_clip_angle) {
    
    assert(is_num(position));
    assert(is_num(barrel_clip_angle));
    dx = barrel_air_barrel_corner.x - position*joiner_max_size.x;
    id = measured_barrel_diameter + 2 * barrel_clearance; 
    od = id + 2 * wall_thickness;

    render() difference() {
        translate([dx, 0, 0]) {
            rod(d=od, hollow=id, l=wall_thickness, center=BEHIND);
        }
        top_of_barrel_exclusion(barrel_clip_angle);
    } 
}

module support_point(barrel_fraction, air_fraction) {

    dx = -barrel_fraction*joiner_max_size.x - wall_thickness/2;  
    dy = -air_fraction*joiner_max_size.y;

	size = [
        wall_thickness,
        wall_thickness, 
        wall_thickness];

    translate([dx, dy, 0])   
        translate(barrel_air_barrel_corner)
            rotate([0, 90, 0])
                rod(d=wall_thickness, l=wall_thickness, center=LEFT); 
}  
  

module barrel_joiner_support(
    barrel_fraction, air_fraction, support_fraction) {
        
    
    hull() {
        support_point(barrel_fraction, 0);
        support_point(support_fraction, air_fraction);
    }
    hull () {    
        support_point(support_fraction, air_fraction);
        support_point(0, air_fraction);
    }
    hull () {    
        support_point(0, 0);
        support_point(0, air_fraction);
    }     
        
        
}

if (show_barrel_joiner_support) {
    barrel_joiner_support(
        barrel_joiner_fraction, 
        air_barrel_joiner_fraction, 
        support_fraction
        );
}

module barrel_joiner(
        barrel_joiner_fraction, 
        air_barrel_joiner_fraction, 
        support_fraction) {
            
    assert(is_num(barrel_joiner_fraction));
    assert(is_num(air_barrel_joiner_fraction));
    assert(is_num(support_fraction));
            
    x = barrel_joiner_fraction*joiner_max_size.x;
    size = [
        x + wall_thickness,
        wall_thickness,
        wall_thickness
    ];
    translate(barrel_air_barrel_corner) {
        block(size, center=LEFT+BEHIND); 
    }
    // Now need to make it printable from xz plane:
    barrel_joiner_support(
        barrel_joiner_fraction, 
        air_barrel_joiner_fraction, 
        support_fraction);
}

module barrel_clips(
    barrel_fraction, 
    air_barrel_fraction, 
    support_fraction,
    barrel_clip_angle) {
    
    assert(is_num(barrel_fraction));
    assert(is_num(air_barrel_fraction));    
    assert(is_num(support_fraction));
    assert(is_num(barrel_clip_angle));
        
    // Interferes with pivot _ barrel_clip(0, barrel_clip_angle);
    barrel_clip(barrel_fraction, barrel_clip_angle);
    barrel_joiner(
        barrel_fraction, 
        air_barrel_fraction, 
        support_fraction);
}

module pivot_section(barrel_clip_angle) {
    
    assert(is_num(barrel_clip_angle));
    dx = barrel_air_barrel_corner.x + air_hose_diameter;
    
    id = measured_barrel_diameter + 2 * barrel_clearance; 
    od = id + 2 * wall_thickness;

    render() difference() {
        translate([dx, 0, 0]) {
            rod(d=od, hollow=id, l=air_hose_diameter, center=BEHIND);
        }
        top_of_barrel_exclusion(barrel_clip_angle);
        air_brush(trigger_angle);
    } 
    
}



if (show_barrel_clips) {
    barrel_clips(
        barrel_fraction_t, 
        air_barrel_fraction_t, 
        support_fraction_t,
        barrel_clip_angle_t);
}


module air_barrel_clip(fraction) {
    dy = barrel_air_barrel_corner.y - fraction*joiner_max_size.y;
    id = air_hose_diameter + 2 * air_hose_clearance; 
    od = id + 2 * wall_thickness;
    
    //dy  = -(measured_barrel_diameter/2 + wall_thickness/2);
	  
    render() difference() {
        translate([0, dy, 0]) {
            rod(d=od, hollow=id, l=wall_thickness, center=SIDEWISE+LEFT);
        }
        air_brush(trigger_angle=0);
    } 

}


module air_barrel_joiner(air_barrel_fraction) {
	y = air_barrel_fraction*joiner_max_size.y;
	size = [
        wall_thickness,
        y + wall_thickness, 
        wall_thickness];
 
	translate(barrel_air_barrel_corner) {
        block(size, center=LEFT+ BEHIND);
    }
    // Make it printable from base
    rotate([0, 110, 0]) {
        translate(barrel_air_barrel_corner) {
            block(size, center=LEFT+ BEHIND);
        }
    }
    rotate([0, -110, 0]) {
        translate(barrel_air_barrel_corner) {
            block(size, center=LEFT+ BEHIND);
        }
    } 
}

module air_barrel_clips(air_barrel_fraction) {
    air_barrel_clip(0);
    air_barrel_clip(air_barrel_fraction);
    air_barrel_joiner(air_barrel_fraction);
}

if (show_air_barrel_clips) {
    air_barrel_clips(air_barrel_fraction_t);
}



if (show_joiners) {
    barrel_joiner(barrel_fraction_t, air_barrel_fraction_t, support_fraction_t);
    air_barrel_joiner(air_barrel_fraction_t);  
}

module master_air_brush_assembly(
        barrel_fraction,
        air_barrel_fraction,
        support_fraction, 
        barrel_clip_angle) {
            
    barrel_clips(
        barrel_fraction, 
        air_barrel_fraction, 
        support_fraction,
        barrel_clip_angle);
    
    air_barrel_clips(
        air_barrel_fraction); 
           
    // pivot_section(barrel_clip_angle); 
}

module handle_orientation(build_from) {
    if (build_from == "air_hose") {
        rotate([90, 0, 0]) children();
    } else if (build_from == "base" ) {
        rotate([0, -90, 0]) children();
    } else if (build_from == "on_side") {
        children();
    } else {
        assert(false, "Internal error");
    } 
}


if (show_assembly) {
    handle_orientation(build_from) {
        master_air_brush_assembly(
            barrel_fraction_t,
            air_barrel_fraction_t,
            support_fraction_t, 
            barrel_clip_angle_t); 
    }
}
















