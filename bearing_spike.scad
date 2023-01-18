use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;  // [0.001, 0.01, 0.1, 1, 10]

infinity = 50;

// Use _q suffix to make it easy to search for global variable use in modules
/* [Show] */
show_axle_q = false;
show_bearing_carve_out_q = false;
show_bearing_q = false;
show_bearing_blank_q = false;

show_cross_section_q = false;

/* [Dimensions] */

d_q = 10.1;
h_q = 10.1; 
d_ratio_q = 0.4;
h_ratio_q = 0.7;
air_gap_q = 0.5; // [0: 0.01 : 1]


/* [Colors] */
color_bearing_carve_q = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
color_bearing_q = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
shoulder_color_q = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color_q = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
clip_color_q = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]

colors_q = [shoulder_color_q, axle_color_q, clip_color_q, color_bearing_carve_q];

/* [Cross Section] */
spidge_max_explode_q = 0.01;
spidge_delta_q = spidge_max_explode_q/100;

alphas_by_index = [1, 0.7, 0.4, 0.3, 0.2,0.1];
colors_by_index = [axle_color_q, color_bearing_carve_q, color_bearing_q];

function spidge(z_index) = -spidge_max_explode_q + spidge_delta_q * z_index;

module cross_section() {
    translate([0, 0, -1]) rotate([0,0,180]) cube([infinity, infinity, infinity]);    
}

module stack_for_z(z_index) {
    translate([spidge(z_index), spidge(z_index), -spidge(z_index)]) {
        children();
    } 
}

module color_for_z(z_index, element_color) {
    color(colors_by_index[z_index-1], alpha=alphas_by_index[z_index-1]) {
        children();
    }
}

module view_cross_section(z_index, element_color) {
    if (show_cross_section_q) {
        stack_for_z(z_index) {
             color_for_z(z_index, element_color) {
                difference() {
                    children();
                    cross_section();
                }
            }
        }
    } else {
        children();
    }
}


module cut_for_cap(d, h) {
    s = infinity;

    rotate([0, 0, 90]) translate([d/2, 0, h]) translate([s/2, 0, s/2]) cube([s, s, s], center=true);
}


module axle_shape(d, h, d_ratio, h_ratio, is_axle, colors) {
    assert(is_num(h_ratio), str("h_ratio is not a number but is: ", h_ratio));
    echo("h_ratio", h_ratio);

    c_a = 0;
    c_c = 1;
    
    columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];
    
    h_n = h * h_ratio;
    d_n = d * d_ratio;
    
    h_c = h - h_n;
    
    axle_data = 
    [   
        [ d/2, d_n/2,  h_n, c_a ],
        [ d_n/2, d/2,  h_c, c_c ],
    ];
    echo("axle_data", axle_data);
    
    difference() {
        v_conic_frustrum(
            columns,         
            axle_data, 
            colors);
        if (is_axle) {
            cut_for_cap(d_n, h_n);
        }
    }
       
}  

module axle(d, h, d_ratio, h_ratio, colors, air_gap) {
    d_axle = d - air_gap/2;
    axle_shape(d_axle, h, d_ratio, h_ratio, true, colors);
}

module bearing_carve_out(d, h, d_ratio, h_ratio, colors, air_gap) {
    d_c0 = d + air_gap/2;
    
    d_neck_axle = d * d_ratio;
    d_neck_bearing = d * d_ratio + 2*air_gap;
    d_ratio_co = d_neck_bearing / d_c0;
    use_cut_for_cap = false;
    
    h_co = h;
    h_ratio_co = h_ratio;
    axle_shape(d_c0, h_co, d_ratio_co, h_ratio_co, use_cut_for_cap, colors);
}

module bearing_blank(d, h) {
    translate([0,0,h/2]) cylinder(d=d-eps, h=h-eps, center=true); 
}

module bearing(d, h, d_ratio, h_ratio, colors, air_gap) {
    difference() {
        bearing_blank(d, h);
        bearing_carve_out(d, h, d_ratio, h_ratio, colors, air_gap);
    }
}

module bearing_blank_q(z_index) {
   view_cross_section(z_index) {
       bearing_blank(d_q, h_q); 
   } 
}

module axle_q(z_index) {
   view_cross_section(z_index) {
       axle(d_q, h_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q); 
   } 
}

module bearing_carve_out_q(z_index) {
    view_cross_section(z_index) {
        bearing_carve_out(d_q, d_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q);
    }
}


module bearing_q(z_index) {
    view_cross_section(z_index) {
        bearing(d_q, d_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q);
    }
}

// Order from inner to outer for eventual rendering with alpha!

if (show_axle_q) {
   axle_q(z_index=1);    
}

if (show_bearing_carve_out_q) {
   bearing_carve_out_q(z_index=2);    
}

if (show_bearing_q) {
   bearing_q(z_index=3);    
}

if (show_bearing_blank_q) {
   bearing_blank_q(z_index=3);    
}
































    