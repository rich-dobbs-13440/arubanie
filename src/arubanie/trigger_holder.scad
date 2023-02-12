/*

Usage:

    use <trigger_holder.scad>
    
    
    master_air_brush_trigger_catch();
    
    Orientation:  
    
    The origin is at the top of the cap, at the centerline of the trigger. 

*/ 

include <lib/centerable.scad>
use <lib/shapes.scad>
use <master_air_brush.scad>
/* [Boiler Plate] */

$fa = 5;
$fs = 0.8;
eps = 0.001;

infinity = 100;

/* [Show] */
show_half_slide = false;
show_trigger_catch = true;


module end_of_customization() {}

module catch_profile(pad_diameter, pad_height, lip_dr_scale) {
    r_pd = pad_diameter/2;


    rim_dr = 0.5*pad_height;
    cap_dz = 0.5*pad_height;
    lip_dz = 0.5*pad_height;
    lip_dr = lip_dr_scale * pad_height;
    assert(!is_undef(lip_dr));
    
    // Patch (slightly oversized) 
    square(size = [r_pd + eps, cap_dz], center = false); 
    // Annulus 
    translate([r_pd, 0, 0]) square(size = [rim_dr, pad_height+cap_dz], center = false);
    // Lip
    size_lip = [lip_dr+rim_dr, lip_dz];
    trans_lip = [r_pd - lip_dr, pad_height+cap_dz-eps, 0];
    translate(trans_lip) square(size_lip, center=false);
      
}

module half_slide(pad_diameter, pad_height, length, lip_dr_scale) {
    linear_extrude(height=length, center=false, convexity = 10, twist = 0) {
        catch_profile(pad_diameter, pad_height, lip_dr_scale); 
    }
}

if (show_half_slide) {
    lip_dr_scale = 0.25; // lose (0.375 is tight)
    pad_diameter = master_air_brush("trigger pad diameter");
    pad_height = master_air_brush("trigger pad thickness");
    half_slide(pad_diameter, pad_height, length=10, lip_dr_scale=lip_dr_scale);
}

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

module trigger_catch(pad_diameter, pad_height, lip_dr_scale) {
    // Cap
    rotate_extrude(angle = 180, convexity = 2) 
        catch_profile(pad_diameter, pad_height, lip_dr_scale);
    length = 0.5 * pad_diameter+eps;
    translate([-eps, eps, 0])  
        rotate([90,0,0]) 
            half_slide(pad_diameter, pad_height, length, lip_dr_scale);   
    mirror([eps,0,0]) 
        translate([-eps, eps, 0]) 
            rotate([90,0,0]) 
                half_slide(pad_diameter, pad_height, length, lip_dr_scale);
}

module master_air_brush_trigger_catch() {
    lip_dr_scale = 0.25; // lose (0.375 is tight)
    pad_diameter = master_air_brush("trigger pad diameter");
    pad_height = master_air_brush("trigger pad thickness");
    trigger_catch(pad_diameter, pad_height, lip_dr_scale);
}    


if (show_trigger_catch) {
    master_air_brush_trigger_catch();
}



