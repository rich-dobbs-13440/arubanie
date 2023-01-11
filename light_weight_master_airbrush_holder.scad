
include <master_airbrush_measurements.scad>;

$fa = 1;
$fs = 0.4;



// All dimensions are in mm!
eps = 0.05;
barrel_diameter_clearance = 0.75;
wall_thickness = 2.0;

show_yoke = true;
show_back_block = true;


barrel_diameter = measured_barrel_diameter + barrel_diameter_clearance;
trigger_pad_diameter = m_trigger_pad_diameter + 0.0;
trigger_pad_thickness = m_trigger_pad_thickness + 0.0;

yoke_depth = 50; 
yoke_length = 19; 
pivot_length = 4; 
bar_width = 2.5;
pivot_diameter = 2.5;



module barrel() {
    // Display horizontal zero 
    h = barrel_length+2/eps;
    d = barrel_diameter;
    translate([-eps, 0, 0]) rotate([0,90,0]) cylinder(h=h, d=d, center=false);
}

module air_hose_barrel() {
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    h = air_hose_barrel_length + barrel_diameter;
    translate([dx, 0, 0]) rotate([90,0,0]) cylinder(h=h, d=air_hose_diameter, center=false);
}

module brace() {
    // Entire block, before carve outs
    x = brace_length + air_hose_diameter/2;
    z = brace_height + barrel_diameter/2;
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    dz = -brace_height/2;
    translate([dx, 0, dz]) rotate([90, 0, 0]) cube([brace_length, brace_width, z]);
}

module trigger_piece(angle) {
    pivot_offset = 3; // This is a guess
    dy_pivot = m_trigger_pad_cl_to_barrel_cl_0_degrees + pivot_offset;
    translate([0, -pivot_offset, 0])
    rotate([0, 0, angle]) {
        translate([0, dy_pivot, 0]) rotate([90, 0, 0]) {
            cylinder(h=trigger_pad_thickness, d=trigger_pad_diameter, center=true);
        }
    }
}

* trigger_piece(30);

module trigger(angle) {
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    dy = m_trigger_pad_cl_to_barrel_cl_0_degrees;
    translate([dx, 0, 0]) trigger_piece(angle);
}

module air_brush(trigger_angle) {
    barrel();
    air_hose_barrel();
    brace();
    trigger(trigger_angle);
}

*air_brush(30);

module trigger_cap_clearance() {
    width = 40;
    bottom_radius = 8;
    top_radius = 22;
    height = top_radius - bottom_radius;
    dz = -width/2;
    rotate([90, 0, 0]) translate([0,0,dz])  {
        rotate_extrude(angle = 30, convexity = 2) {
           translate([bottom_radius,0,0]) square([height,width]);
        }  
    }  
}

*trigger_cap_clearance();

module air_brush_on_end() {
    rotate([-90, -90, 0]) air_brush(30); // Rotate to vertical
    // Not ready yet: trigger_cap_clearance();

}

// Try block to base of air hose
* translate([-30, 0, 0]) cube([wall_thickness, wall_thickness, 22.69]);

* air_brush_on_end();

module air_hose_bracket() {
    // bottom around air house 
    x_bah = wall_thickness;
    y_bah = barrel_diameter + 2 * air_hose_clip_length;
    z_bah = barrel_back_to_air_hose +  air_hose_diameter/2 + air_hose_clip_length;
    dx_bah = -wall_thickness/2 - barrel_diameter/2;
    dz_bah = z_bah/2;
   
    x_bah_barrel = 2*air_hose_barrel_length;
    dz_bah_barrel = air_hose_diameter / 2 + wall_thickness;
    dx_bah_barrel  = -x_bah_barrel /2 ;
    difference() {
        translate([dx_bah, 0, dz_bah]) cube([x_bah, y_bah, z_bah], center=true);
        air_brush_on_end();
    }
}



module base() {
    x = barrel_diameter + 2 * wall_thickness;
    y = barrel_diameter + 2 * wall_thickness;
    z = wall_thickness;
    //dx_trigger = barrel_diameter/2+trigger_diameter/2 - 1;
    difference() {
        translate([0, 0, z/2.]) cube([x, y, z], center=true);
        air_brush_on_end();
    }  
}

* base();

module lower_side(z1) {
    x_s = barrel_diameter + 2 * wall_thickness;
    z_s = z1;
    dx_s = -barrel_diameter/2 - wall_thickness ;
    dy_s = barrel_diameter/2;
    // dz_s = z_s / 2;
    color("red") translate([dx_s, dy_s, 0]) cube([x_s, wall_thickness, z_s]);
}

module upper_side(z1, z2) {
    x_s = barrel_diameter + wall_thickness;
    z_s = z2 - z1;
    dx_s = -barrel_diameter/2 - wall_thickness ;
    dy_s = barrel_diameter/2;
    dz_s = z1;
    color("blue") translate([dx_s, dy_s, dz_s]) cube([x_s, wall_thickness, z_s]);
}

module air_control_pivot() {
    // Air control pivot hole 
    h = 40;
    ac_pivot_diameter = 3;
    dz = 42;
    dx = -5;
    translate([dx, 0, dz]) rotate([90,0,0]) cylinder(h=h, d=ac_pivot_diameter, center=true);
}

module sides() {

    z1 = 8; // Small enough to not impact 
    z2 = 45; // Large enough to reach middle of brace
    difference () {
        union() {
            lower_side(z1);
            upper_side(z1, z2);   
            mirror([0, 1, 0]) {
                lower_side(z1);
                upper_side(z1, z2);
            }
        }
        air_control_pivot();
    }
}

module top_side(z) {
    s = 2*wall_thickness; 
    dx = barrel_diameter/2 -s;
    dy = barrel_diameter/2 -s/2;
    difference() {
        translate([dx, dy, 0]) cube([s, s, z], center=false);
        air_brush_on_end();
    } 
    dy2 = -dy-s;
    difference() {
        translate([dx, dy2, 0]) cube([s, s, z], center=false);
        air_brush_on_end();
    }
}

* top_side();
* base();


module back_block() { 
    base();
    air_hose_bracket();
    sides();
    top_side(45);
}


if (show_back_block) {
    back_block();
}

module pivot_pin(yoke_length, pivot_length, pivot_diameter, pivot_offset, pin_angle) {
        // pivot
    dx_p = yoke_length/2 ;
    h_p = pivot_length + 2.5; 
    translate ([dx_p, pivot_offset, pivot_diameter/2]) rotate([0, 180, 0]) cylinder(h=h_p, d=pivot_diameter, center=true);
}


module yoke_half(yoke_depth, yoke_length, bar_width, pivot_length, pivot_diameter, pins) {
    
    bar_height = 5;
    g = bar_width;
    // cross bar
    dx = yoke_length/2;
    dy = yoke_depth-g/2;
    z = bar_height;
    translate([0, dy, 0])  cube([dx, g, z], center=false);
    //side bar of yoke
    dx_sb = yoke_length/2;
    translate([dx_sb, -g/2, 0])  cube([g+eps, g+yoke_depth, z], center=false);


    for (pin = pins) {
        pin_offset = pin[0];
        pin_angle = pin[1];
        dx_p = yoke_length/2 + g/2;
        dy_p = pin_offset;
        dz_p = pivot_diameter/2;
        d_p = pivot_diameter;
        h_p = pivot_length;
        translate ([dx_p, dy_p, dz_p]) 
            rotate([0, pin_angle, 0]) 
                translate ([0, 0, h_p/2]) 
                  cylinder(h=h_p, d=d_p, center=true);
    }
}



module yoke(yoke_depth, yoke_length, bar_width, pivot_length, pivot_diameter, pins) {
    
    yoke_half(yoke_depth, yoke_length, bar_width, pivot_length, pivot_diameter, pins); 
    mirror([1, 0, 0]) yoke_half(yoke_depth, yoke_length, bar_width, pivot_length, pivot_diameter, pins);   
}

if (show_yoke) {
    pins = [[0,270], [12.5, 90]];
    yoke(
        yoke_depth = yoke_depth, 
        yoke_length = yoke_length, 
        pivot_length = pivot_length, 
        bar_width = bar_width, 
        pivot_diameter = pivot_diameter, 
        pins = pins
    );
}