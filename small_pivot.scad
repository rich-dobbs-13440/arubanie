use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

/* [Show] */
show_pin = true;
show_bearing = true;
show_bearing_connector = true;

/* [Colors] */
bearing_color = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
taper_color = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
cap_color = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
post_color = "purple"; // ["red", "blue", "green", "yellow", "orange", "purple"]


size_t = 1; // [1: 0.5 : 10]
air_gap_t = 0.45; // [0.3: 0.05 : 1]

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
function r_bearing(size) = 3 * size;

function connector_size(size) = r_axle(size, 0);

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

function colors_for_test() = [bearing_color, taper_color, axle_color, cap_color, post_color];

echo("Sample pin data for cavity", pin_data(size_t, 0.0, colors_for_test()));
echo("Sample pin data for cavity", pin_data(size_t, air_gap_t, colors_for_test()));


module pin(size, air_gap, colors) {
    echo("In pin function")
    echo("air_gap = ", air_gap);
    echo("colors = ", colors);
    
    data = pin_data(size, air_gap, colors);
    echo("pin data", data);

    v_conic_frustrum(
        columns(), 
        data, 
        colors);
    
}

module bearing(size, air_gap, colors) {
    bearing_color = colors[idx_bearing_color()];
    color(bearing_color, alpha=0.25) {
        difference() {
            cylinder(h=h_bearing(size), r=r_bearing(size));
            pin(size, air_gap, colors); 
        }
    } 
}

module bearing_connector(size, air_gap, colors, is_bearing=true) {
    echo("air_gap", air_gap);
    // External connector block
    x = connector_size(size);
    y = connector_size(size);
    z = h_total(size);
    dy = (is_bearing ? 1: -1) * (r_bearing(size) + y/2 + air_gap);
    dz = z / 2;
    translate([0, dy, dz]) cube([x, y, z], center=true);
    // Connect to bearing or post
    x_c = x;
    y_c = 0.7 * y;
    z_c = is_bearing ? h_total(size)/2 :  h_post(size);
    dy_c = (is_bearing ? 1: -1) * r_bearing(size); 
    dz_c = is_bearing ? z_c / 2 : z - z_c/2;
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
    pin(size=size_t, air_gap=0, colors=colors_for_test()); 
}

if (show_bearing) {
    bearing(size=size_t, air_gap=air_gap_t, colors=colors_for_test()); 
}

if (show_bearing_connector) {
    bearing_connector(size=size_t, air_gap=air_gap_t, colors=colors_for_test(), is_bearing=true); 
    bearing_connector(size=size_t, air_gap=air_gap_t, colors=colors_for_test(), is_bearing=false);
}