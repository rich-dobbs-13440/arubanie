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
show_cap_connector = false;
show_sprue = false;

/* [Colors] */

use_default_colors = false;

bearing_color = "PaleGreen"; // ["PaleGreen", "red", "blue", "green", "yellow", "orange", "purple"]
base_color = "Moccasin"; // ["Moccasin", "red", "blue", "green", "yellow", "orange", "purple"]
taper_color = "LightBlue"; // [LightBlue, "red", "blue", "green", "yellow", "orange", "purple"]
axle_color = "IndianRed"; // ["IndianRed", "red", "blue", "green", "yellow", "orange", "purple"]
cap_color = "Coral"; // ["Coral", "red", "blue", "green", "yellow", "orange", "purple"]
post_color = "AntiqueWhite"; // ["Coral", "red", "blue", "green", "yellow", "orange", "purple"]
bearing_post_color = "OrangeRed"; // ["LightSalmon", "red", "blue", "green", "yellow", "orange", "purple"]
bearing_join_color = "LightSalmon"; // ["LightSalmon", "red", "blue", "green", "yellow", "orange", "purple"]
cap_post_color = "DeepSkyBlue"; // ["DeepSkyBlue", "red", "blue", "green", "yellow", "orange", "purple", ]
cap_join_color = "LightBlue"; // ["LightBlue", "red", "blue", "green", "yellow", "orange", "purple", ]

/* [Adjustments] */

size_t = 1; // [1: 0.5 : 10]
air_gap_t = 0.45; // [0.3: 0.01 : 0.6]
angle_t = 15; // [-180 : 180]

//function colors() = [taper_color, axle_color, cap_color, post_color, bearing_color];

function idx_base_color() = 0;
function idx_taper_color() = 1;
function idx_axle_color() = 2;
function idx_cap_color() = 3;
function idx_post_color() = 4;
function idx_bearing_color() = 5;

function r_base(size, air_gap) = 3 * size + air_gap;
function r_taper(size, air_gap) = 3 * size + air_gap;
function r_axle(size, air_gap) = 1.25 * size + air_gap;
function r_cap(size, air_gap) = 3 * size + air_gap;
function r_post(size, air_gap) = 3 * size + air_gap;
function r_bearing(size, air_gap) = 3 * size;

function connector_size(size) = 2*r_axle(size, 0);

function h_base(size) = 2 * size;
function h_taper(size) = 2 * size;
function h_axle(size) = 1 * size;
function h_cap(size) = 2 * size;
function h_tcap(size) = 2 * size;
function h_bearing(size) = h_taper(size) + h_axle(size) + h_cap(size);
function h_total(size) = 
    h_base(size) + 
    h_taper(size) + 
    h_axle(size) + 
    h_cap(size) + 
    h_tcap(size);


function columns() = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

function pin_data(s, dr, colors) = 
[   [ r_base(s, dr),    r_taper(s, dr),   h_base(s),    idx_base_color() ],
    [ r_taper(s, dr),   r_axle(s, dr),    h_taper(s),   idx_taper_color() ],
    [ r_axle(s, dr),    r_axle(s, dr),    h_axle(s),    idx_axle_color() ],
    [ r_axle(s, dr),    r_cap(s, dr),     h_cap(s),     idx_cap_color() ],
    [ r_cap(s, dr),     r_post(s, dr),    h_tcap(s),    idx_post_color() ],
];


function default_colors() = [bearing_color, taper_color, axle_color, cap_color, post_color];

echo("Sample pin data for cavity", pin_data(size_t, 0.0));
echo("Sample pin data for cavity", pin_data(size_t, air_gap_t));


module pin(size, air_gap, colors) {

    data = pin_data(size, air_gap);
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
    dz = h_base(size) + h_bearing(size)/2;
    echo("In bearing, r_bearing = ", r);
    color(bearing_color, alpha=0.35) {
        difference() {
            translate([0,0,dz]) cylinder(h=h_bearing(size), r=r, center=true);
            pin(size, air_gap, colors); 
        }
    } 
}

module connector_post(size, air_gap, positive_offset) {
    x = connector_size(size);
    y = connector_size(size) + r_cap(size, air_gap);
    z = h_total(size);
    dy = (positive_offset ? 1: -1) * y/2;
    dz = z / 2;
    h_clearance = 3 * h_total(size);
    r_clearance = r_cap(size, air_gap);
    
    difference() { 
        translate([0, dy, dz]) cube([x, y, z], center=true);
        cylinder(r=r_clearance, h=h_clearance, center=true);
    }
}

module bearing_join(size, air_gap) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap);
    z = h_bearing(size);
    dy = y/2;
    dz = z / 2 + h_base(size);
    color(bearing_join_color) {
        difference() {
            translate([0, dy, dz]) cube([x, y, z], center=true);
            pin(size, air_gap, default_colors());
        }
    }
}

module l_cap_join(size, air_gap) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap) + air_gap;
    z = h_base(size);
    dy = -y/2;
    dz = z / 2;   
    color(cap_join_color) {
        translate([0, dy, dz]) cube([x, y, z], center=true);
    }
}

module t_cap_join(size, air_gap) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap) + air_gap;
    z = h_tcap(size);
    dy = -y/2;
    dz = h_total(size) - z / 2;   
    color(cap_join_color) {
        translate([0, dy, dz]) cube([x, y, z], center=true);
    }
}



module external_connector(size, air_gap, colors, is_bearing=true) {

    color(is_bearing ? bearing_post_color: cap_post_color) {
        connector_post(size, air_gap, positive_offset=is_bearing);
    }
    if (is_bearing) {
        bearing_join(size, air_gap);  
    } else {
        l_cap_join(size, air_gap); 
        t_cap_join(size, air_gap); 
    }
}

module sprue(size, air_gap) {
    // Design tweek to help with printing
    h_sprue = 2*air_gap;
    r_sprue = air_gap;
    dy = - r_bearing(size, air_gap) - air_gap/2;
    dz = h_base(size) + h_sprue/2;
    translate([0, dy, dz]) cylinder(r=air_gap, h=h_sprue, center=true);
}

if (show_sprue) {
    sprue(size=size_t, air_gap=air_gap_t);
}

if (show_pin) {
    pin(size=size_t, air_gap=0, colors=default_colors()); 
}

if (show_bearing) {
    echo("air_gap", air_gap_t);
    bearing(size=size_t, air_gap=air_gap_t, colors=default_colors()); 
}

if (show_bearing_connector) {
    external_connector(size=size_t, air_gap=air_gap_t, colors=default_colors(), is_bearing=true); 
}

 if (show_cap_connector) {
    external_connector(size=size_t, air_gap=air_gap_t, colors=default_colors(), is_bearing=false);
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
    
    external_connector(size, air_gap, colors, is_bearing=true); 
    rotate([0, 0, angle]) external_connector(size, air_gap, colors, is_bearing=false);
    
}

if (show_pivot) {
    if (use_default_colors) {
        pivot(size_t, air_gap_t, angle_t);
    } else {
        my_colors = ["Thistle", "Salmon", "LightSteelBlue", "PeachPuff", "MidnightBlue"];
        pivot(size_t, air_gap_t, angle_t, colors=my_colors);
    }
}

