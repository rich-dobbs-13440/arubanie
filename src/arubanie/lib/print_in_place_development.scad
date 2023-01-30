use <vector_cylinder.scad>


use <small_pivot.scad>
/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Show] */

show_pin = false;
show_bearing = false;
show_air_gap_test_array = true;
show_explore_bearing_connection = false;
show_explore_children_in_sub_modules = false;

/* [Colors] */
bearing_color = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
taper_color = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
cap_color = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
post_color = "purple"; // ["red", "blue", "green", "yellow", "orange", "purple"]

/* [Dimensions] */

r_taper = 2; // [0: 0.5 : 10]
r_axle = 1; // [0: 0.5 : 10]
r_cap = 3; // [0: 0.5 : 10]
r_post = 3; // [0: 0.5 : 10]
r_bearing = 3; // [0: 0.5 : 10]

h_taper = 1; // [0: 0.5 : 10]
h_axle = 1; // [0: 0.5 : 10]
h_cap = 1; // [0: 0.5 : 10]
h_post = 1; // [0: 0.5 : 10]

handle_length = 6; // [0: 0.5 : 15]


air_gap_cst = 0.5; // [0: 0.01 : 5]
dx_text_by_r_bearing = 1; // [-2: 0.01 : 2]
dy_text_by_r_bearing = 1; // [-2: 0.01 : 2]
dz_text_offset_bearing = -1; //[-2: 0.01 : 2]

/* [Air gap test array] */
count_agta = 4; // [1 : 1 : 6]
dx_extra_agta = 5;  // [-3: 1 : 10]
air_gap_increment = 0.05; // [0 : 0.01 : 0.5]
air_gap_zero_agta = 0.35; // [0. 3: 0.01 : 0.7]

function color_red_idx_vcf() = 0;
function color_blue_idx_vcf()  = 1;
function color_green_idx_vcf()  = 2;
function color_yellow_idx_vcf()  = 3;

// TODO: Implement look mapping from pin

function colors() = [bearing_color, taper_color, axle_color, cap_color, post_color];


* echo("colors()", colors());

function idx_of_color(color_to_match, color_range=colors(), i=0) = 
    i >= len(color_range) ? 
        undef :
        color_range[i] == color_to_match ?
            i :
            idx_of_color(color_to_match, color_range, i+1);
            
function ag(r) = r + air_gap;
columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

h_idx = 2;
function pin_data(dr) = 
[
    [ r_taper + dr,     r_axle + dr,    h_taper,   idx_of_color(taper_color) ],
    [ r_axle + dr,      r_axle + dr,    h_axle,    idx_of_color(axle_color) ],
    [ r_axle + dr,      r_cap + dr,     h_cap,     idx_of_color(cap_color) ],
    [ r_cap + dr,       r_post + dr,    h_post,    idx_of_color(post_color) ],
];


* echo("data", pin_data(0.5));

function heights() = [ for (i = [0 : len(pin_data(0.0))-1 ] ) pin_data()[i][h_idx] ]; // pin_data()[i][h_idx] ]
    
* echo("heights_vector", heights());


function total_height() = vector_sum(heights());

* echo("total_height", total_height());

module pin(dr) {

    v_conic_frustrum(
        columns, 
        pin_data(dr), 
        colors());
    
}

module bearing_label(air_gap) {
    air_gap_text = str("AG=", air_gap);
    color("black") 
    linear_extrude(1) {
        text(air_gap_text, size=6, halign=50);
    }
}

module offset_bearing_label(r_bearing, height) {
    dx_text = r_bearing * dx_text_by_r_bearing;// -r_bearin
    dy_text = r_bearing * dy_text_by_r_bearing;
    dz_text = height + dz_text_offset_bearing;
    rotate([0, 0, 90]) translate([dx_text, dy_text, dz_text]) children(); 
}

module label_bearing(air_gap, r_bearing, height, incise=false) {
    
    if (incise) {
        difference() {
            children();
            offset_bearing_label(r_bearing, height) bearing_label(air_gap);
        }
    } else {
       union() {
            children();
            offset_bearing_label(r_bearing, height) bearing_label(air_gap);
       } 
        
    }
}

module bearing(air_gap, height, r_bearing) {
    color(bearing_color, alpha=0.5)
    difference() {
        cylinder(h=height, r=r_bearing);
        pin(dr=air_gap); 
    } 
}

module bearing_handle(handle_length, h_bearing, r_bearing) {
    x = r_bearing;
    y = handle_length;
    z = h_bearing * 0.8;

    dy = y/2 + r_bearing*0.9;
    dz = z/2;
    translate([0, dy ,dz]) color("blue") cube([x, y, z], center=true); // handle to attach to bearing
        

}

module pin_handle(handle_length, h_pin, h_post, r_post) {
    // handle base
    x = r_post;
    y = handle_length;
    z = h_pin - h_post;
    dy = -y/2 - r_post - 0.5;
    dz = z/2;
    translate([0, dy ,dz]) cube([x, y, z], center=true); 
    // Connector
    x_c = r_post;

    y_c =  handle_length/2 + 0.5 + 2 * r_post;
    z_c = 1.5 * h_post;
    dy_c = -y_c/2 + r_post ;
    dz_c = h_pin +z_c/2 - h_post;
    translate([0, dy_c, dz_c]) cube([x_c, y_c, z_c], center=true);
    
    
}

if (show_pin) {
    pin(dr=0); 
}

if (show_bearing) {
    bearing(air_gap_cst, total_height(), r_bearing);
}

module label_test(air_gap, h_bearing, r_bearing, handle_length) {
    pad_size = [10, 30, 2];
    dx_pad = -pad_size.x /2;
    bearing_overlap = 0.1 * r_bearing;
    real_handle_length = handle_length - bearing_overlap;
    dy_pad = r_bearing + real_handle_length;
    color("white") translate([dx_pad, dy_pad, 0]) cube(pad_size, center=false);
   
    dy_label = dy_pad + 3;
    color("black") 
        translate([0, dy_label, pad_size.z]) 
            rotate([0, 0, 90])
                linear_extrude(1) text(str("G=", air_gap), size=5, valign="center");

    
}

module assembly(h_bearing, air_gap) {
    pin(dr=0);
    h_pin = total_height();
    pin_handle(handle_length, h_pin, h_post, r_post);
    label_test(air_gap, h_bearing, r_bearing, handle_length);
    bearing(air_gap, h_bearing, r_bearing);
    bearing_handle(handle_length, h_bearing, r_bearing);    
}

if (show_air_gap_test_array) {

    h_bearing = h_taper + h_axle + h_cap;
    for (i = [0 : count_agta - 1]) {
        dx = i * (2 * r_bearing + dx_extra_agta);
        air_gap = air_gap_zero_agta + (i)  * air_gap_increment;
        translate([dx,0,0]) assembly(h_bearing, air_gap);
    }
    
    // Result of r_axle = 1 and airgap [0.2:0.7] was that air_gap of >= 0.5 pins fell out
    // 0.4 pushed out easily with small screw driver
    // 0.2 and smaller were fused
    // Incised text labeling didn't work.  Unreadable
}


module fake_bearing_attachment_target(size, air_gap, angle) {
    x = connector_size(size);
    y = connector_size(size);
    z = h_bearing(size);
    dx = x/2 + r_bearing(size);
    dz = z/2 + h_lcap(size);
    translate([dx, 0, dz]) cube([x, y, z], center=true);  
}

module sample_attachment_target() {
    r = 2;
    infinetesimal = 4;
    dx = 8;
    dy = 0;
    dz = 0 + r + 1;
    translate([dx, dy, dz]) 
     rotate([0,90, 0]) 
        cylinder(r=r, h=infinetesimal, center = true);
}

if (show_explore_bearing_connection) {
    // For bearing connection we want to combine the bearing connection pad with an arbitray item in strong fashion.
    // presume that the bearing connection pad is rectange the same height as the bearing, and
    // with the specied connector size.
    
    // Explore using hull to attach them
    
    hull() {
        fake_bearing_attachment_target(size=1, air_gap=0.35);
        sample_attachment_target();
    }  
}

module first_level() {
    * echo("$children", $children);
    second_level_using_children() {
        children();
    }
    second_level_using_loop() {
        children([0:$children-1]);
    }
    // Note: this does cause a problem to call children with an index greater than count 
    second_level_using_hand_items() {
        children(0);
        children(1);
        children(2);
        children(3);
        children(4);
        // Note: this doesn't cause a problem to call children with an index greater than count 
        // within this scope
        children(9);
    }
    
    
    second_level_using_for() {
        for (i = [0:$children-1]) {
            children(i);
        }
    }
    i = $children;
    second_level_using_if(i) {
        if (i > 0) {
            children(0);
        }
        if (i > 1) {
            children(1);
        }
        if (i > 2) {
            children(2);
        }
        if (i > 3) {
            children(3);
        }
    }
    
}

module second_level_using_if(count) {
    * echo("second_level_using_if count", count);
    * echo("second_level_using_if $children", $children);
    color("red") children(1);
    color("green") children(0);
    color("yellow") children(2);
}

module second_level_using_for() {
    * echo("second_level_using_for $children", $children);
}

module second_level_using_hand_items() {
    * echo("second_level_using_hand_items $children", $children);
}

module second_level_using_loop() {
    * echo("second_level_using_loop $children", $children);
}

module second_level_using_children() {
    * echo("second_level_using_children $children", $children);
}


if (show_explore_children_in_sub_modules) {
    first_level() {
        cube([1,1,1]);
        cylinder(r=1, h=1);
    }
}



    