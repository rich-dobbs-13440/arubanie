$fa = 1;
$fs = 0.4;

// All dimensions in mm
eps = 0.01;
pad_diameter = 10.74;
pad_height = 2.60;
rotation_pivot_diameter = 3;
lip_dr_scale = 0.25; // lose (0.375 is tight)


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
    dz = 0.5*pad_height + rotation_pivot_diameter/2 + eps;
    difference() {
        base_trigger_catch(pad_diameter, pad_height);
        translate([0, 0, dz]) pivot_drill(2*pad_diameter, rotation_pivot_diameter);
    }
}

translate([0, 10, 0]) trigger_catch(pad_diameter, pad_height);

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

yoke();

