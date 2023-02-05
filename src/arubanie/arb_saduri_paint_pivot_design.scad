/* [Paint Pivot Design] */
// Relative to CL of air barrel
dx_paint_pivot_offset = 0; // [-3:0.25:+3]
// Relative to CL of main barrel
dz_paint_pivot_offset = -3; // [-5:0.05:0]

paint_pivot_h = 8; 
paint_pivot_w = 6; 
paint_pivot_inside_dy = 10; // 16.5/2;

// This controls printablity vs play in the pivot.
paint_pivot_allowance = 0.4;
paint_pivot_top_range_of_motion = 120;
paint_pivot_bottom_range_of_motion = 90;

paint_pivot_permanent_pin = false;

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


