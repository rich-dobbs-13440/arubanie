include <master_airbrush_measurements.scad>;

$fa = 1;
$fs = 0.4;

// All dimensions in mm
eps = 0.01;

rotation_pivot_diameter = 6;
lip_dr_scale = 0.25; // lose (0.375 is tight)
air_slider_length = 20;
air_slider_width = rotation_pivot_diameter;  // long enough to figure out where pivot is!
air_slider_depth = 2.5;
axle_length = 2; // Must be sufficent to allow latching on and to clear barrel!

pin_offset = 16.45;
pin_hole_diameter = 3;

module catch_profile(pad_diameter, pad_height) {
    r_pd = pad_diameter/2;
    rim_dr = 0.5*pad_height;
    cap_dz = 0.5*pad_height;
    lip_dz = 0.5*pad_height;
    lip_dr = lip_dr_scale * pad_height;
    
    // Patch (slightly oversized) 
    square(size = [r_pd + eps, cap_dz], center = false); 
    // Annulus 
    translate([r_pd, 0, 0]) square(size = [rim_dr, pad_height+cap_dz], center = false);
    // Lip
    color("red") translate([r_pd - lip_dr, pad_height+cap_dz-eps, 0]) square(size = [lip_dr+rim_dr, lip_dz], center = false);
       
}

module half_slide(pad_diameter, pad_height, length) {
    linear_extrude(height=length, center=false, convexity = 10, twist = 0) catch_profile(pad_diameter, pad_height); 
}


*half_slide(pad_diameter, pad_height, length=10);

module pin() {
    dz = pin_offset;
    translate([0, 0, dz]) rotate([0, 90, 0]) cylinder(h=40, d=pin_hole_diameter, center=true);
}

module half_air_slider() {
    cap_dz = 0.5*pad_height;
    // axle
    dx_a = axle_length + cap_dz;
    x_a = dx_a/2 + pad_diameter/2 + 0.5*cap_dz;
    translate([x_a, 0, rotation_pivot_diameter/2]) pivot_drill(dx_a, rotation_pivot_diameter);
    // slider

    dx_s = pad_diameter/2 + dx_a;
    difference() {
        translate([dx_s, -air_slider_width/2, 0]) cube([air_slider_depth,air_slider_width,air_slider_length], center=false);
        pin();
    }

    
}

module base_trigger_catch(pad_diameter, pad_height) {
    // Cap
    rotate_extrude(angle = 180, convexity = 2) catch_profile(pad_diameter, pad_height);
    length = 0.5 * pad_diameter+eps;
    translate([-eps, eps, 0])  rotate([90,0,0]) half_slide(pad_diameter, pad_height, length);   
    mirror([eps,0,0]) translate([-eps, eps, 0]) rotate([90,0,0]) half_slide(pad_diameter, pad_height, length);
}

module pivot_drill(length, diameter) {
    // Hole for attaching yoke
    rotate([0, 90, 0]) cylinder(h=length, d=diameter, center=true);
}

module trigger_catch(pad_diameter, pad_height) {
    
    base_trigger_catch(pad_diameter, pad_height);
    half_air_slider();
    mirror([eps,0,0]) translate([-eps, eps, 0]) half_air_slider();

}

trigger_catch(pad_diameter, pad_height);
* translate([0, 10, 0]) trigger_catch(pad_diameter, pad_height);

module yoke_half() {

    // catch_clearance = 2;
    catch_clearance = 1;
    catch_depth = 0.45*pad_height;
    pivot_length = catch_clearance + catch_depth;
    pivot_clearance = 0.5;
    g = rotation_pivot_diameter-pivot_clearance;
    yoke_depth = 20;
    
    // cross bar
    lip_dr = lip_dr_scale * pad_height;
    cbl = pad_diameter/2 + catch_clearance + lip_dr;
    translate([0, yoke_depth-g/2, 0])  cube([cbl+eps,g,g], center=false);
    //side bar of yoke
    translate([cbl, -g/2, 0])  cube([g+eps,g+yoke_depth,g], center=false);
    
    translate ([cbl - pivot_length/2, 0, g/2]) pivot_drill(pivot_length+eps, g);
}

module yoke() {
    yoke_half(); 
    mirror([1, 0, 0]) yoke_half();   
}

* yoke();
