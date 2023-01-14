use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Show] */

show_pin = false;
show_bearing = false;
show_air_gap_test_array = true;

/* [Colors] */

axle_color = "red"; // ["red", "blue", "green", "yellow"]
taper_color = "blue"; // ["red", "blue", "green", "yellow"]
bearing_color = "green"; // ["red", "blue", "green", "yellow"]

/* [Dimensions] */
r_axle = 1; // [0: 0.5 : 10]
r_taper = 2; // [0: 0.5 : 10]
h_axle = 1; // [0: 0.5 : 10]
h_taper = 1; // [0: 0.5 : 10]

r_bearing_cst = 4; // [0: 1 : 10]
air_gap_cst = 0.5; // [0: 0.01 : 5]
dx_text_by_r_bearing = 1; // [-2: 0.01 : 2]
dy_text_by_r_bearing = 1; // [-2: 0.01 : 2]
dz_text_offset_bearing = -1; //[-2: 0.01 : 2]

/* [Air gap test array] */
count_agta = 4; // [1 : 1 : 6]
dx_extra_agta = 0;  // [-3: 1 : 10]
air_gap_increment = 0.1; // [0 : 0.01 : 0.5]
air_gap_zero_agta = 0.3; // [0. 3: 0.01 : 0.7]

function color_red_idx_vcf() = 0;
function color_blue_idx_vcf()  = 1;
function color_green_idx_vcf()  = 2;
function color_yellow_idx_vcf()  = 3;

// TODO: Implement look mapping from pin

function colors() = [axle_color, taper_color];

echo("colors()", colors());

function idx_of_color(color_to_match, color_range=colors(), i=0) = 
    i >= len(color_range) ? 
        undef :
        color_range[i] == color_to_match ?
            i :
            idx_of_color(color_to_match, color_range, i+1);
            
//function index_of(columns, idx_to_match, i=0) = 
//    i == len(columns) ?
//        undef :
//        columns[i]==idx_to_match ? 
//            i : 
//            index_of(columns, idx_to_match, i + 1);

// colors()[i] == color ? i : 
    
//;

//function idx_of_color(color, i=0) = colors()[i] == color ? i : 
//    (i >= len(colors()) ? undef : idx_of_color(color, i+1);
   


function ag(r) = r + air_gap;
columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

h_idx = 2;
function pin_data(dr) = 
[
    [ r_taper + dr, r_axle + dr, h_taper,   idx_of_color(taper_color) ],
    [ r_axle + dr,  r_axle + dr, h_axle,    idx_of_color(axle_color) ],
    //    [ag(r_base),        ag(r_base),         h_base,         color_blue_idx_vcf],
    //    [ag(r_base_inner),  ag(r_neck),         h_neck_bottom,  color_red_idx_vcf],
    //    [ag(r_neck),        ag(r_top_inner),    h_neck_top,     color_green_idx_vcf],
    //    [ag(r_top),         ag(r_top),          h_top,          color_yellow_idx_vcf],
];


echo("data", pin_data(0.5));

function heights() = [ for (i = [0 : len(pin_data(0.0))-1 ] ) pin_data()[i][h_idx] ]; // pin_data()[i][h_idx] ]
    
echo("heights_vector", heights());


function total_height() = vector_sum(heights());

echo("total_height", total_height());

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
        text(air_gap_text, size=1.5, halign=50);
    }
}

module offset_bearing_label(r_bearing, height) {
    dx_text = r_bearing * dx_text_by_r_bearing;// -r_bearin
    dy_text = r_bearing * dy_text_by_r_bearing;
    dz_text = height + dz_text_offset_bearing;
    translate([dx_text, dy_text, dz_text]) children(); 
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



if (show_pin) {
    
    pin(dr=0); 
}

if (show_bearing) {
    bearing(air_gap_cst, total_height(), r_bearing_cst);
}

module label_test(air_gap, h_bearing, r_bearing) {
    color("black") 
    offset_bearing_label(r_bearing, h_bearing) 
    linear_extrude(1) 
    text(str(air_gap), size=1.5, halign=50);
    
}

if (show_air_gap_test_array) {

    h_bearing = total_height();
    for (i = [0 : count_agta - 1]) {
        dx = i * (2 * r_bearing_cst + dx_extra_agta);
        air_gap = air_gap_zero_agta + (i)  * air_gap_increment;
        translate([dx,0,0]) {
            pin(dr=0);
            label_test(air_gap, h_bearing, r_bearing_cst);
            bearing(air_gap, h_bearing, r_bearing_cst);
            
            
            
        }
    }
    
    // Result of r_axle = 1 and airgap [0.2:0.7] was that air_gap of >= 0.5 pins fell out
    // 0.4 pushed out easily with small screw driver
    // 0.2 and smaller were fused
    // Incised text labeling didn't work.  Unreadable
}


    