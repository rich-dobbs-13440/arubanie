include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/vector_operations.scad>
use <lib/not_included_batteries.scad>
use <MCAD/boxes.scad>


build_adapter_inside_socket = true;
build_taps_holder = false;
build_socket_tester = false;



/* [Inside Socket Adapter] */

tap_idx = 0; //[0:"M2", 1:"M2.5", 2:"M3", 3:"M4", 4:"M5", 5:"M6", 6:"M8", 7:"M10", 8:"M12"]
socket_diameter_ = 4.75; // [4:0.05: 15.5]



/* [Socket Tester] */

start_st = 5.5; //[5.5:"3/16\"", 7.4:"1/4\"", 10.9:"3/8\"", 14.7:"1/2\""]
range_st = 0.5; // [.05 : 0.05 : 1]
step_st = 0.05; // [0.05, 0.1, 0.2]
dx_st = 20; //[12, 16, 20]

//smallest_socket_diameters = [2, 2.2, 2.4, 2.6, 2.8, 3., 3.2, 3.6, 3.8, 4.0];
//dx_smallest_socket_diameters = 12;

module end_of_customization() {}

IDX_D = 0;
IDX_S = 1;
IDX_L = 2;
IDX_FL = 3;
taps = [
    [2, 2.33, 42.27, 7.44], 
    [2.5, 2.26, 46.93, 7.44], 
    [3, 2.97, 50.97, 8.10], 
    [4, 3.93, 55.92, 10], 
    [5, 3.86, 62.71, 10], 
    [6, 4.68, 68.33, 10.84], 
    [8, 4.95, 70.31, 10.5], 
    [10, 6.16, 80, 10.5], 
    [12, 7.07, 87, 10.5],    
];

sockets_for_taps = [
    3/16*2.54*10, //[2, 2.33, 42.27, 7.44], 
    3/16*2.54*10, //[2.5, 2.26, 46.93, 7.44], 
    3/16*2.54*10, //[3, 2.97, 50.97, 8.10], 
    1/4*2.54*10, //[4, 3.93, 55.92, 10], 
    1/4*2.54*10, //[5, 3.86, 62.71, 10], 
    1/4*2.54*10, //[6, 4.68, 68.33, 10.84], 
    1/4*2.54*10, //[8, 4.95, 70.31, 10.5], 
    5/16*2.54*10, //[10, 6.16, 80, 10.5], 
    3/8*2.54*10, //[12, 7.07, 87, 10.5], 
];

module adapter_inside_socket(socket_diameter, tap_across_flats, tap_flat_length) {
    a_lot = 100;
    lip = 4;
    split = 0.5;
    tap_flat = [tap_across_flats, tap_across_flats, tap_flat_length];
    function tap_flat_shape(clearance, height) = [tap_across_flats + 2*clearance, tap_across_flats + 2*clearance, height]; 
    render(convexity=10) difference() {
        union() {
            can(d = socket_diameter, h = tap_flat_length, center=ABOVE, $fn=6);
            can(d = socket_diameter + 5, h = lip, center=ABOVE, $fn=6);
            //color("blue") can(d = 9, h = 6, center=ABOVE, $fn=18);  
        }
        // The basic tap holder
        block(tap_flat_shape(0, tap_flat_length), center=ABOVE, rank=2);
        // Provide an entrance to avoid problems with elephant foot:
        hull() {
            block(tap_flat_shape(0, 2), center=ABOVE, rank=2);
            block(tap_flat_shape(1.75, 0.01), center=ABOVE, rank=2);
        }
        // Split the body so that pressing into socket clamps tap
        translate([0, 0, lip]) rotate([0, 0, 45]) block([a_lot, split, tap_flat_length], center=ABOVE);
    }
     
}
if (build_adapter_inside_socket) {
    tap = taps[tap_idx];
    echo("tap", tap);
    adapter_inside_socket(
        socket_diameter = socket_diameter_, 
        tap_across_flats=tap[IDX_S], 
        tap_flat_length = tap[IDX_FL]);

}


module base_holes(padding, gap) {
    echo("len(taps)", len(taps));
    deltas = [for (tap = taps) tap[IDX_S] + gap];
    offsets = v_cumsum(deltas);
    echo("deltas", deltas); 
    for (i = [0 : len(taps) - 1]) {
        translate([offsets[i], -padding.y/2, -padding.z/2]) 
            block([taps[i][IDX_S] + padding.x, taps[i][IDX_S] + padding.y, 14 + padding.z], center=ABOVE+RIGHT);
    }
}

//base_holes();

module taps_holder(allowance=0.2) {
    difference() {
        hull() base_holes(padding = [3, 3, -2], gap=5);
        base_holes(padding = 2*[allowance, allowance, 0], gap=5);
    }
}

if (build_taps_holder) {
    taps_holder();
}

module socket_tester(socket_diameters, dx) {
    font_size = 5;
    max_d = max(socket_diameters);
    for (i = [0 : len(socket_diameters) - 1]) {
        d = socket_diameters[i];
        translate([i*dx + max_d/2, 0, 0]) {
            can(d = d, h = 3, center=ABOVE, $fn=6);
            translate([0, max_d/2, 0]) linear_extrude(1) text(str(d), size=5, valign="bottom");
        }
    }
    block([(len(socket_diameters) + 0.5) * dx, max_d, 2], center=BELOW+FRONT);
    block([(len(socket_diameters) + 0.5) * dx, max_d + font_size, 2], center=BELOW+FRONT+RIGHT);
}

if (build_socket_tester) {
    diameters = [for (d = [start_st : step_st : start_st + range_st]) d];
    socket_tester(diameters, dx_st);  
}

square_adapter = [6.7, 6.7, 21];
radius = 2;


difference() {
    translate([42.5, 18, 1.5]) {
        translate([0, 0, square_adapter.z/2])  roundedCube(square_adapter, r=radius, sidesonly=false, center=true, $fn=12);
        //block(square_adapter, center=ABOVE);
        translate([square_adapter.x/2, 0, 16]) sphere(d=2, $fn=12);
    }
    import("/home/rich/3d Printing/TAP_WRENCH_M10_5856295/files/M10HalterOval.STL", convexity=3);
    
    
}




