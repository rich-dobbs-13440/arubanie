/* For

Best settings so far:

5 shims, tol: 0.8 for TiankongRC SG90,  Ender3v2, Sunlu PLA+, Light Gold
  
*/



build_test_fit_servo = false;

servo_shaft_diameter = 5.78; //[5.78:"Radio Shaft Standard", 4.69:"TiankongRC SG90"]

test_fit_height = 0.5; // [0.25, 1, 2.5, 4]

initial_tolerance = .1; // [-.3: .1 : 1]
step_in_tolerance = 0.2; // [0.05, .1, .2, .4]


tolerance_count = 4;
test_fit_tolerances = [for (i=[0:tolerance_count-1]) initial_tolerance + i * step_in_tolerance];
    
echo("test_fit_tolerances: ", test_fit_tolerances);

use_zero_shims = true;
use_two_shims = false;
use_three_shims = true;
use_four_shims = false;
use_five_shims = false;
use_six_shims = true;
use_seven_shims = false;

shims = [
    [0, use_zero_shims],
    [2, use_two_shims],
    [3, use_three_shims],
    [4, use_four_shims],
    [5, use_five_shims],
    [6, use_six_shims],
    [7, use_seven_shims],
];

shim_counts = [
    for (shim = shims) if (shim[1]) shim[0]
];
//
echo("shim_counts: ", shim_counts);

spacing = 3; // [1:0.5 : 5]

plot = servo_shaft_diameter + spacing;

//test_fit_tolerances = [0.4, 0.5, 0.6, 0.7]; // initial: [0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1],

module end_of_customization() {}



module horn_cavity(
    diameter,
    height,
    shim_count = 3,
    shim_width = 1,
    shim_length = .5,
) {
    e = .005678;

    difference() {
        cylinder(
            h = height,
            d = diameter
        );

        if (shim_count > 0) {
            for (i = [0 : shim_count - 1]) {
                rotate([0, 0, i * 360 / shim_count]) {
                    translate([
                        shim_width / -2,
                        diameter / 2 - shim_length,
                        -e
                    ]) {
                        cube([shim_width, shim_length, height + e * 2]);
                    }
                }
            }
        }
    }
}


if (build_test_fit_servo) {
    translate([0, -70, 0]) horn_goldilocks_array(shim_counts);
}

module horn_goldilocks_array(
        shim_counts = [0, 3, 6]) {
    
    assert(len(shim_counts) > 0);        
    difference() {
        cube([
            plot * len(test_fit_tolerances),
            plot * len(shim_counts),
            test_fit_height
        ]);

        for (i_tolerance = [0 : len(test_fit_tolerances) - 1]) {
            for (i_shim_count = [0 : len(shim_counts) - 1]) {
                translate([
                    i_tolerance * plot + plot / 2,
                    i_shim_count * plot + plot / 2,
                    0
                ]) {
                    // So now we have X and Y as tolerances[i_tolerance] and
                    // shim_counts[i_shim_count], and they can be used to make
                    // each individual test.
                    // Here, for example, they're passed as arguments to an
                    // external cavity() module.
                    translate([0, 0, -1]) horn_cavity(
                        diameter = servo_shaft_diameter
                            + test_fit_tolerances[i_tolerance] * 2,
                        shim_count = shim_counts[i_shim_count],
                        height = test_fit_height + 10
                    );
                }
            }
        }
    }
}



module horn_cavity_TiankongRC_SG90(height=4) {

    horn_cavity(
        diameter=4.69 + 2* 0.8,
        height=height,
        shim_count = 5,
        shim_width = 1,
        shim_length = .5);
    
}