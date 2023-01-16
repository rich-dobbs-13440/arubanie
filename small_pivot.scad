use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;



/* [Show] */
show_pivot = true;
show_pivot_default_colors=false;
show_pivot_with_weird_colors = false;
show_pin = false;
show_bearing = false;
show_bearing_connector = false;
show_cap_connector = false;
show_sprue = false;
show_mounting_on_top_of_item = false;
show_bearing_attachment_revision = false;

/* [Colors] */
lcap_color_t = "Moccasin"; // ["Moccasin", "red", "blue", "green", "yellow", "orange", "purple"]
lcone_color_t = "LightBlue"; // [LightBlue, "red", "blue", "green", "yellow", "orange", "purple"]
axle_color_t = "IndianRed"; // ["IndianRed", "red", "blue", "green", "yellow", "orange", "purple"]
tcone_color_t = "Coral"; // ["Coral", "red", "blue", "green", "yellow", "orange", "purple"]
tcap_color_t = "AntiqueWhite"; // ["Coral", "red", "blue", "green", "yellow", "orange", "purple"]

bearing_color_t = "PaleGreen"; // ["PaleGreen", "red", "blue", "green", "yellow", "orange", "purple"]
bearing_post_color_t = "OrangeRed"; // ["LightSalmon", "red", "blue", "green", "yellow", "orange", "purple"]
bearing_join_color_t = "LightSalmon"; // ["LightSalmon", "red", "blue", "green", "yellow", "orange", "purple"]
cap_post_color_t = "DeepSkyBlue"; // ["DeepSkyBlue", "red", "blue", "green", "yellow", "orange", "purple"]
cap_join_color_t = "LightBlue"; // ["LightBlue", "red", "blue", "green", "yellow", "orange", "purple"]

/* [Adjustments] */

size_t = 1; // [1: 0.5 : 10]
air_gap_t = 0.45; // [0.3: 0.01 : 0.6]
angle_t = 15; // [-180 : 180]


function colors_t() = [
    lcap_color_t, 
    lcone_color_t, 
    axle_color_t, 
    tcone_color_t, 
    tcap_color_t, 
    bearing_color_t,
    bearing_join_color_t,
    cap_join_color_t,
    bearing_post_color_t,
    cap_post_color_t,
    cap_join_color_t, 
 ];

function idx_lcap_color() = 0;
function idx_lcone_color() = 1;
function idx_axle_color() = 2;
function idx_tcone_color() = 3;
function idx_tcap_color() = 4;
function idx_bearing_color() = 5;
function idx_bearing_join_color() = 6;
function idx_cap_join_color() = 7;
function idx_cap_post_color() = 8;

MAX_COLOR_IDX = 20;

// Will get rid of these
function idx_bearing_post_color() = 8;
function idx_cap_post_color() = 9;

function default_colors() = 
[ for (idx = [0:MAX_COLOR_IDX]) 
    idx == idx_bearing_join_color() ? "Plum"  :
    "SteelBlue"
];

module empty() {} // Just to hide following from customizer

BEARING = 0;
CAP = 1;

// Pivot geometry ratios to size
S_R_LCAP = 3.0;
S_R_LCONE = 3.0;
S_R_AXLE = 1.25;
S_R_TCONE = 3.0;
S_R_TCAP = 3.0;

S_R_BEARING = 3.0;

// Height rations should sum to 10 for backwards compatibility for total height.
S_H_LCAP = 2.0;
S_H_LCONE = 2.0;
S_H_AXLE = 2.0;
S_H_TCONE = 2.0;
S_H_TCAP = 2.0;

S_CONNECTOR_SIZE = 2.5;


function r_lcap(size, air_gap) = S_R_LCAP * size + air_gap;
function r_lcone(size, air_gap) = S_R_LCONE * size + air_gap;
function r_axle(size, air_gap) = S_R_AXLE * size + air_gap;
function r_tcone(size, air_gap) = S_R_TCONE * size + air_gap;
function r_tcap(size, air_gap) = S_R_TCAP * size + air_gap;
function r_bearing(size, air_gap) = S_R_BEARING * size + air_gap;

function connector_size(size) = S_CONNECTOR_SIZE * size;

function h_lcap(size) = S_H_LCAP * size;
function h_lcone(size) = S_H_LCONE * size;
function h_axle(size) = S_H_AXLE * size;
function h_tcone(size) = S_H_TCONE * size;
function h_tcap(size) = S_H_TCAP * size;

function h_bearing(size) = h_lcone(size) + h_axle(size) + h_tcone(size);
function h_total(size) = 
    h_lcap(size) + 
    h_lcone(size) + 
    h_axle(size) + 
    h_tcone(size) + 
    h_tcap(size);


function columns() = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

// TODO add a shoulder to make vertical slop less?  Or change aspect ratio?
function pin_data(s, dr, colors) = 
[   [ r_lcap(s, dr),    r_lcone(s, dr), h_lcap(s),  idx_lcap_color() ],
    [ r_lcone(s, dr),   r_axle(s, dr),  h_lcone(s), idx_lcone_color() ],
    [ r_axle(s, dr),    r_axle(s, dr),  h_axle(s),  idx_axle_color() ],
    [ r_axle(s, dr),    r_tcone(s, dr), h_tcone(s), idx_tcone_color() ],
    [ r_tcone(s, dr),   r_tcap(s, dr),  h_tcap(s),  idx_tcap_color() ],
];

// Todo make color
//bearing_color, taper_color, axle_color, cap_color, post_color];


echo("Sample pin data for cavity", pin_data(size_t, 0.0));
echo("Sample pin data for cavity", pin_data(size_t, air_gap_t));


module pin(size, air_gap, colors=default_colors()) {

    data = pin_data(size, air_gap);
    echo("In pin module: size", size, "air_gap", air_gap, "pin data", data);

    v_conic_frustrum(
        columns(), 
        data, 
        colors);
    
}

module bearing(size, air_gap, colors) {
    
    bearing_color = colors[idx_bearing_color()];
    r = r_bearing(size, air_gap);
    dz = h_lcap(size) + h_bearing(size)/2;
    color(bearing_color, alpha=0.35) {
        difference() {
            translate([0,0,dz]) cylinder(h=h_bearing(size), r=r, center=true);
            pin(size, air_gap, colors); 
        }
    } 
}

module connector_post(size, air_gap, positive_offset) {
    x = connector_size(size);
    y = connector_size(size) + r_tcone(size, air_gap);
    z = h_total(size);
    dy = (positive_offset ? 1: -1) * y/2;
    dz = z / 2;
    h_clearance = 3 * h_total(size);
    r_clearance = r_tcone(size, air_gap);
    
    difference() { 
        translate([0, dy, dz]) cube([x, y, z], center=true);
        cylinder(r=r_clearance, h=h_clearance, center=true);
    }
}

module bearing_join(size, air_gap, colors) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap);
    z = h_bearing(size);
    dy = y/2;
    dz = z / 2 + h_lcap(size);
    color(colors[idx_bearing_join_color()]) {
        difference() {
            translate([0, dy, dz]) cube([x, y, z], center=true);
            pin(size, air_gap);
        }
    }
}

module l_cap_join(size, air_gap, colors) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap) + air_gap;
    z = h_lcap(size);
    dy = -y/2;
    dz = z / 2;   
    color(colors[idx_cap_join_color()]) {
        translate([0, dy, dz]) cube([x, y, z], center=true);
    }
}

module t_cap_join(size, air_gap, colors) {
    x = connector_size(size);
    y = connector_size(size) + r_bearing(size, air_gap) + air_gap;
    z = h_tcap(size);
    dy = -y/2;
    dz = h_total(size) - z / 2;   
    color(colors[idx_cap_join_color()]) {
        translate([0, dy, dz]) cube([x, y, z], center=true);
    }
}

module external_connector(size, air_gap, colors, is_bearing=true) {
    
    if (is_bearing) {
        // Plan on eliminating this!
        //color(colors[idx_bearing_post_color()])
        //connector_post(size, air_gap, positive_offset=is_bearing);
    } else {
        color(colors[idx_cap_post_color()])
        connector_post(size, air_gap, positive_offset=is_bearing);
    }
    
    if (is_bearing) {
        bearing_join(size, air_gap, colors);  
    } else {
        l_cap_join(size, air_gap, colors); 
        t_cap_join(size, air_gap, colors); 
    }
}

module pivot(size, air_gap, angle=0, colors=default_colors(), attachments=undef, attachment_params=undef) {

    assert(!is_undef(size), "You must specify size");
    assert(!is_undef(air_gap), "You must specify air_gap");
    assert(is_num(angle), "Angle must be a number");
    assert(len(colors) >= 5,"The number of colors must be at least 5");
    
    echo("In pivot module")
    echo("size = ", size);
    echo("air_gap = ", air_gap);
    echo("angle = ", angle);
    echo("colors", colors);
    
    pin(size, 0.0, colors);
    bearing(size, air_gap, colors);
    
    external_connector(size, air_gap, colors, is_bearing=false); 
    rotate([0, 0, angle]) external_connector(size, air_gap, colors, is_bearing=true);  
}

module sprue(size, air_gap) {
    // Design tweek to help with printing
    h_sprue = 2*air_gap;
    r_sprue = air_gap;
    dy = - r_bearing(size, air_gap) - air_gap/2;
    dz = h_lcap(size) + h_sprue/2;
    translate([0, dy, dz]) cylinder(r=air_gap, h=h_sprue, center=true);
}

if (show_sprue) {
    sprue(size=size_t, air_gap=air_gap_t);
}

if (show_pin) {
    pin(size=size_t, air_gap=0, colors=colors_t()); 
}

if (show_bearing) {
    echo("air_gap", air_gap_t);
    bearing(size=size_t, air_gap=air_gap_t, colors=colors_t()); 
}

if (show_bearing_connector) {
    external_connector(size=size_t, air_gap=air_gap_t, colors=colors_t(), is_bearing=true); 
}

 if (show_cap_connector) {
    external_connector(size=size_t, air_gap=air_gap_t, colors=colors_t(), is_bearing=false);
}

if (show_pivot) {
    pivot(size_t, air_gap_t, angle_t, colors=colors_t());
} 

if (show_pivot_default_colors) {
    pivot(size_t, air_gap_t, angle_t);
} 

if (show_pivot_with_weird_colors) {
    weird_colors = ["Thistle", "Salmon", "LightSteelBlue", "PeachPuff", "MidnightBlue"];
    pivot(size_t, air_gap_t, angle_t, colors=weird_colors);
}

if (show_mounting_on_top_of_item) {
    plate_thickness = 0.5;
    plate_size = 11;
    dz = -plate_thickness/2;
    translate([0, 0, dz]) cube([plate_size, plate_size, plate_thickness], center=true);

    pivot_size = 1.;
    air_gap = 0.35;
    angle = 90;
    
    // Detemine the handle mask parameters, so that bearing handle isn't in contact with base plate
    x_hm = 2*connector_size(pivot_size);
    y_hm = 2*connector_size(pivot_size);
    z_hm = r_lcap(pivot_size, air_gap);
    dy_hm = y_hm/2 + r_lcap(pivot_size, air_gap) - air_gap;
    dz_hm = z_hm/2;

    difference() {
        color("LightSteelBlue")  pivot(pivot_size, air_gap, angle);
        translate([0, dy_hm, dz_hm]) cube([x_hm, y_hm, z_hm], center=true);
    }
    
    // Now attach a hande that rests on the build plate.
    d_hdl = h_total(pivot_size) + plate_thickness;
    h_hdl = connector_size(pivot_size);
    dy_hdl = r_lcap(pivot_size, air_gap) + d_hdl/2; 
    dz_hdl = d_hdl/2 - plate_thickness ;
    translate([0, dy_hdl, dz_hdl]) 
    rotate([0,90,0]) cylinder(d=d_hdl, h=h_hdl, center=true);  
}

if (show_bearing_attachment_revision) {
    pivot_size = 0.5;
    air_gap = 0.35;
    
    // Want the basic attachment to not go to base, but that be the default value
    pivot(pivot_size, air_gap, attachments="short",attachment_params=[BEARING, 0]);
}

