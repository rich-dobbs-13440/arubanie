use <small_pivot_vertical_rotation.scad>

/* [Show] */
show_pivot = true;
show_pintle_assembly = false;
show_gudgeon_assembly = false;
show_cutout_for_rotation_stop = false;

/* [Dimensions] */
top_range = 135; // [20 : 170]
bottom_range = 135; // [60 : 170]

allowance = 0.35; // [0.3 : 0.05 : 0.5]
height = 4; // [2:1:10]
width = 4; // [2:1:10]
length_gudgeon = 10; //[0:0.5:10]
length_pintle = 10; //[0:0.5:10]
angle = 0; // [-180 : +180]

pintle_stop_1 = 90; // [-180 : +180]
pintle_stop_2 = -90; // [-180 : +180]
pintle_stops = [pintle_stop_1, pintle_stop_2];

gudgeon_stop_1 = 90; // [-180 : +180]
gudgeon_stop_2 = -90; // [-180 : +180]
gudgeon_stops = [gudgeon_stop_1, gudgeon_stop_2];



range = [top_range, bottom_range];


if (show_pintle_assembly) {
    rotate([0, angle, 0]) 
    color("blue", alpha =0.25) 
    pintle(height, width, length_pintle, allowance, pintle_stops);
}


if (show_gudgeon_assembly) {
    gudgeon(height, width, length_gudgeon, allowance, gudgeon_stops);
}


if (show_pivot) {
    small_pivot_vertical_rotation(
        height, width, length_pintle, length_gudgeon, allowance, range, angle);
}


if (show_cutout_for_rotation_stop) {
    color("red", alpha=0.25)
    cutout_for_rotation_stops(height, width, length_gudgeon, allowance, pintle_stops);
}

*small_pivot_vertical_rotation(5, 10, 20, 30, 0.3, angle=90);