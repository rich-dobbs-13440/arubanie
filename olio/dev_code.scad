/* [Test pin clearance] */
show_test_piece_pin_handle_clearance_tpc = false;
show_pin_handle_tpc = false;
air_gap_tpc = 0; // [0:0.1:5] 
angle_start_tpc = -30; // [-180:+0]
angle_stop_tpc = +90;  // [0:+180]
max_delta_angle_clearance_angle_tpc = 45;
handle_size_tpc = [1, 10, 1];


module pin_handle(air_gap, handle_size) {
    
    x = handle_size.y;
    y = handle_size.y;
    z = handle_size.z;
    dx = -x / 2;
    dy = -y;
    dz = 0; // h_total - z + 2*eps;
    translate([dx, dy, dz]) cube([x, y, z]);
}

module pin_handle_clearance_segment(a1, a2) {

    // Pair wise hulls
    hull() {
        rotate([0, 0, a1]) children();
        rotate([0, 0, a2]) children();
    }
}

module pin_handle_clearance(angle_start, angle_stop, max_delta_angle_clearance_angle=45, air_gap) {
    // to generate a cavity for the pin.  Should help with print in place

    assert(!is_undef(angle_start), "You must specify angle_start");
    assert(!is_undef(angle_stop), "You must specify angle_stop");
    assert(!is_undef(air_gap), "You must specify air_gap");
    steps = round(0.5 + (angle_stop - angle_start) / max_delta_angle_clearance_angle);
    echo("steps", steps);
    delta = (angle_stop - angle_start) / steps;
    echo("delta", delta);
    assert(delta / max_delta_angle_clearance_angle < 1.1, "Implementation error in calculating steps")
    color("turquoise") union() {
//        for (dz = [-1, air_gap]) {
//            echo("dz", dz)
//            translate([0, 0, dz]) {
                union() {
                    for (i_step = [1 : steps]) {
                        a1 = angle_start + delta * (i_step-1);
                        echo("a1", a1);
                        a2 = angle_start + delta * (i_step);
                        echo("a2", a2);
                        // Pair wise hulls
                        hull() {
                            rotate([0, 0, a1]) children();
                            rotate([0, 0, a2]) children();
                        }
                                        }
                }
//            }
//        }
    }
};

if (show_test_piece_pin_handle_clearance_tpc) {
    pin_handle_clearance(angle_start_tpc, angle_stop_tpc, max_delta_angle_clearance_angle_tpc, air_gap=air_gap_tpc) 
        pin_handle(air_gap_tpc, handle_size_tpc);
}


if (show_pin_handle_tpc) {
    pin_handle(air_gap_tpc, handle_size_tpc);
}

// z_handle = h_total/2 - 0.5 * air_gap;

//            union() {
//                sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base, air_gap=air_gap);
//                pin_handle_clearance(angle_start, angle_stop, max_delta_angle_clearance_angle, air_gap=air_gap) pin_handle();
//            }

//    union() {
//
//        pin_handle();
//    }
//                translate([1,0,0]) cube([z_handle, test_piece_handle_length, h_total/2]);
//sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base, air_gap=air_gap);

//            union() {
//                translate([1,0,0]) cube([z_handle, test_piece_handle_length, h_total/2]);
//                cylinder(h=h_total, r=test_piece_size);
//            }