use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;



//r_taper = 2; // [0: 0.5 : 10]
//r_axle = 1; // [0: 0.5 : 10]
//r_cap = 3; // [0: 0.5 : 10]
//r_post = 3; // [0: 0.5 : 10]
//r_bearing = 3; // [0: 0.5 : 10]
//
//h_taper = 1; // [0: 0.5 : 10]
//h_axle = 1; // [0: 0.5 : 10]
//h_cap = 1; // [0: 0.5 : 10]
//h_post = 1; // [0: 0.5 : 10]

/* [Show] */
show_pin = true;
show_bearing = false;

/* [Colors] */
bearing_color = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
taper_color = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
cap_color = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
post_color = "purple"; // ["red", "blue", "green", "yellow", "orange", "purple"]


size_t = 1; // [1: 0.5 : 10]
air_gap_t = 0.5; 

function colors() = [bearing_color, taper_color, axle_color, cap_color, post_color];

function r_taper(size, air_gap) = 2 * size + air_gap;
function r_axle(size, air_gap) = 1 * size + air_gap;
function r_cap(size, air_gap) = 3 * size + air_gap;
function r_post(size, air_gap) = 3 * size + air_gap;

function h_taper(size) = 1 * size;
function h_axle(size) = 1 * size;
function h_cap(size) = 1 * size;
function h_post(size) = 3 * size;

function idx_taper_color() = 0;
function idx_axle_color() = 1;
function idx_cap_color() = 2;
function idx_post_color() = 3;

function columns() = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

function pin_data(s, dr, colors) = 
[   
    [ r_taper(s, dr),     r_axle(s, dr),    h_taper(s),   idx_taper_color() ],
    [ r_axle(s, dr),      r_axle(s, dr),    h_axle(s),    idx_axle_color()],
    [ r_axle(s, dr),      r_cap(s, dr),     h_cap(s),     idx_cap_color() ],
    [ r_cap(s, dr),       r_post(s, dr),    h_post(s),    idx_post_color() ],
];

function colors_for_test() = [bearing_color, taper_color, axle_color, cap_color, post_color];

echo("Sample pin data for cavity", pin_data(size_t, 0.0, colors_for_test()));
echo("Sample pin data for cavity", pin_data(size_t, air_gap_t, colors_for_test()));


module pin(size, air_gap, colors) {
    echo("In pin function")
    echo("air_gap = ", air_gap);
    echo("colors = ", colors);
    
    data = pin_data(size, air_gap, colors);
    echo("pin data", pin_data);

    v_conic_frustrum(
        columns(), 
        data, 
        colors());
    
}

if (show_pin) {
    pin(size=size_t, air_gap=0, colors= colors_for_test()); 
}