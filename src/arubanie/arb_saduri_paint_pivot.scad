/* [Paint Pivot Design] */
// Relative to CL of air barrel
dx_paint_pivot_offset = 0; // [-3:0.25:+3]
// Relative to CL of main barrel
dz_paint_pivot_offset = -3; // [-5:0.05:0]

paint_pivot_h = 10; 
paint_pivot_w = 8; 
paint_pivot_inside_dy = 11; // 16.5/2;

// This controls printablity vs play in the pivot.
paint_pivot_allowance = 0.4;
paint_pivot_top_range_of_motion = 120;
paint_pivot_bottom_range_of_motion = 90;

paint_pivot_pin = "M3 captured nut"; // ["M3 captured nut", "permanent pin"]

paint_pivot_ranges = [
    paint_pivot_top_range_of_motion, 
    paint_pivot_bottom_range_of_motion
];

paint_pivot_cl_dy = paint_pivot_inside_dy + paint_pivot_w/2;
paint_pivot_outside_dy = paint_pivot_inside_dy + paint_pivot_w;

disp_air_brush_relative_paint_pivot_cl = [
    dx_paint_pivot_offset, 
    0, 
    paint_pivot_h/2 + dz_paint_pivot_offset
];


module paint_pivot_pintle(length) {
    rotate([0, 0, 180]) { // Flip to desired orientation
        pintle(
            paint_pivot_h, 
            paint_pivot_w, 
            length, 
            paint_pivot_allowance, 
            range_of_motion=paint_pivot_ranges,
            pin=paint_pivot_pin,  
            fa=fa_as_arg);
    }
}

module paint_pivot_gudgeon(length) {
    rotate([0, 0, 180]) { // Flip to desired orientation
        gudgeon(
            paint_pivot_h, 
            paint_pivot_w, 
            length, 
            paint_pivot_allowance, 
            range_of_motion=paint_pivot_ranges,
            pin=paint_pivot_pin,
            fa=fa_as_arg);
    }
}  

module paint_pivot_pin_clearance() {
    center_reflect([0, 1, 0]) {
        translate([0, paint_pivot_cl_dy, 0]) 
            pintle(
                h=paint_pivot_h, 
                w=paint_pivot_w, 
                l=20,  // Doesn't matter for clearance!
                al=paint_pivot_allowance,
                pin=paint_pivot_pin,
                just_pin_clearance=true);
    } 
}

