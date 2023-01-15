use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

/* [Show] */
show_pivot = true;
show_pin = false;
show_bearing = false;
show_bearing_connector = false;

use_default_colors = false;

/* [Colors] */
bearing_color = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
taper_color = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
cap_color = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
post_color = "purple"; // ["red", "blue", "green", "yellow", "orange", "purple"]


size_t = 1; // [1: 0.5 : 10]
air_gap_t = 0.45; // [0.3: 0.01 : 1]
angle_t = 15; // [-180 : 180]

//function colors() = [taper_color, axle_color, cap_color, post_color, bearing_color];

function idx_taper_color() = 0;
function idx_axle_color() = 1;
function idx_cap_color() = 2;
function idx_post_color() = 3;
function idx_bearing_color() = 4;

function r_taper(size, air_gap) = 2 * size + air_gap;
function r_axle(size, air_gap) = 1.25 * size + air_gap;
function r_cap(size, air_gap) = 3 * size + air_gap;
function r_post(size, air_gap) = 3 * size + air_gap;
function r_bearing(size, air_gap) = 3 * size;

function connector_size(size) = 2*r_axle(size, 0);

function h_taper(size) = 1 * size;
function h_axle(size) = 1 * size;
function h_cap(size) = 2 * size;
function h_post(size) = 3 * size;
function h_bearing(size) = h_taper(size) + h_axle(size) + h_cap(size);
function h_total(size) = h_taper(size) + h_axle(size) + h_cap(size) + h_post(size);


function columns() = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

function pin_data(s, dr, colors) = 
[   
    [ r_taper(s, dr),     r_axle(s, dr),    h_taper(s),   idx_taper_color() ],
    [ r_axle(s, dr),      r_axle(s, dr),    h_axle(s),    idx_axle_color()],
    [ r_axle(s, dr),      r_cap(s, dr),     h_cap(s),     idx_cap_color() ],
    [ r_cap(s, dr),       r_post(s, dr),    h_post(s),    idx_post_color() ],
];


function default_colors() = [bearing_color, taper_color, axle_color, cap_color, post_color];

echo("Sample pin data for cavity", pin_data(size_t, 0.0, default_colors()));
echo("Sample pin data for cavity", pin_data(size_t, air_gap_t, default_colors()));


module pin(size, air_gap, colors) {


    data = pin_data(size, air_gap, colors);
    echo("In pin module: size", size, "air_gap", air_gap, "pin data", data);

    v_conic_frustrum(
        columns(), 
        data, 
        colors);
    
}

module bearing(size, air_gap, colors) {
    
    echo("In bearing, air_gap = ", air_gap);
    bearing_color = colors[idx_bearing_color()];
    r = r_bearing(size, air_gap);
    echo("In bearing, r_bearing = ", r);
    color(bearing_color, alpha=0.35) {
        difference() {
            cylinder(h=h_bearing(size), r=r);
            pin(size, air_gap, colors); 
        }
    } 
}

module bearing_connector(size, air_gap, colors, is_bearing=true) {

    // External connector block
    x = connector_size(size);
    y = connector_size(size);
    z = h_total(size);
    dy = (is_bearing ? 1: -1) * (r_bearing(size, air_gap) + y/2 + air_gap);
    dz = z / 2;
    translate([0, dy, dz]) cube([x, y, z], center=true);
    // Connect to bearing or post
    x_c = x;
    y_c = 0.7 * y;
    z_c = is_bearing ? h_total(size)/2 :  h_post(size);
    dy_c = (is_bearing ? 1: -1) * r_bearing(size, air_gap); 
    dz_c = is_bearing ? z_c / 2 : z - z_c/2 + 0.1;
    if (is_bearing) {
        difference() { 
            translate([0, dy_c, dz_c]) cube([x_c, y_c, z_c], center=true);
            pin(size, air_gap, colors);
        }
    } else {
        translate([0, dy_c, dz_c]) cube([x_c, y_c, z_c], center=true);
    }
    //color("magenta", alpha = 0.1) pin(size, air_gap, colors);
}

if (show_pin) {
    pin(size=size_t, air_gap=0, colors=default_colors()); 
}

if (show_bearing) {
    echo("air_gap", air_gap_t);
    bearing(size=size_t, air_gap=air_gap_t, colors=default_colors()); 
}

if (show_bearing_connector) {
    bearing_connector(size=size_t, air_gap=air_gap_t, colors=default_colors(), is_bearing=true); 
    bearing_connector(size=size_t, air_gap=air_gap_t, colors=default_colors(), is_bearing=false);
}

module pivot(size, air_gap, angle, colors=default_colors()) {
    echo("In pivot module")
    echo("size = ", size);
    echo("air_gap = ", air_gap);
    echo("angle = ", angle);
    echo("colors", colors);
    assert(len(colors) >= 5,"The number of colors must be at least 5");
    
    pin(size, 0.0, colors);
    bearing(size, air_gap, colors);
    
    bearing_connector(size, air_gap, colors, is_bearing=true); 
    rotate([0, 0, angle]) bearing_connector(size, air_gap, colors, is_bearing=false);
    
}

if (show_pivot) {
    if (use_default_colors) {
        pivot(size_t, air_gap_t, angle_t);
    } else {
        my_colors = ["Thistle", "Salmon", "LightSteelBlue", "PeachPuff", "MidnightBlue"];
        pivot(size_t, air_gap_t, angle_t, colors=my_colors);
    }
}

