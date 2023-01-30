use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;  // [0.001, 0.01, 0.1, 0.25, 1, 10]

infinity = 50;

// Use _q suffix to make it easy to search for global variable use in modules
/* [Show] */
show_bearing_q = true;
show_axle_q = false;
show_bushing_carve_out_q = false;
show_bushing_q = false;
show_bushing_blank_q = false;


/* [Dimensions] */

d_q = 10.1;
h_q = 10.1; 
d_ratio_q = 0.4;
h_ratio_q = 0.7;
air_gap_q = 0.5; // [0: 0.01 : 1]



/* [Colors] */
color_bushing_carve_q = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
color_bushing_q = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
shoulder_color_q = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color_q = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
clip_color_q = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]

colors_q = [shoulder_color_q, axle_color_q, clip_color_q, color_bushing_carve_q];

/* [Cross Section] */
show_cross_section_q = false;
spidge_max_explode_q = 0.01;
spidge_delta_q = spidge_max_explode_q/100;

alphas_by_index = [1, 0.7, 0.4, 0.3, 0.2,0.1];
colors_by_index = [axle_color_q, color_bushing_carve_q, color_bushing_q];

/* [Roller] */
roller_center_q = true;
right_orientation_q = false;

/* [Test Fixtures] */

show_roller_q = false;
show_handle_q = false;
show_wall_q = false;
show_floor_q = false;
show_bearing_support_q = false;
show_union_test = false;

floor_width_to_bearing_diameter_q = 1.25; // [0: 0.1 : 2]
floor_breadth_to_bearing_height_q = 1.25; // [0: 0.1 : 2]
floor_thickness_q = 0.5; // [0: 0.1 : 2]
wall_height_by_bearing_diameter_q  = 1.5; // [0: 0.1 : 2]
wall_thickness_q = 0.5; // [0: 0.1 : 2]

/* [Handle] */
bearing_support_position_q = 0; // [-0.5: 0.01 : 0.5]
bearing_support_r_q = 0.5; // [0.0 : 0.1 : 1.0]
bearing_support_h_q = 0.5; // [0 : 0.1 : 1.0]
handle_length_q = 5; // [0: 0.1 : 10]
// In mm 
handle_height_q = 2; // [0 : 0.01 : 4]


module end_of_customization () {}

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];



module roller(d, h, center=true, v=Y_ORIENTATION) {
    // A roller is a cylinder laying on its side
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
}



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
    * echo("h_ratio", h_ratio);

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
    * echo("axle_data", axle_data);
    
    
    rotate(Y_ORIENTATION) {
        color(colors[c_a])
        render()
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
       
}  



module axle(d, h, d_ratio, h_ratio, colors, air_gap) {
    d_axle = d - air_gap/2;
    translate([0, -eps, 0]) axle_shape(d_axle-eps, h+2*eps, d_ratio, h_ratio, true, colors);
}

module bushing_carve_out(d, h, d_ratio, h_ratio, colors, air_gap) {
    d_c0 = d + air_gap/2;
    
    d_neck_axle = d * d_ratio;
    d_neck_bushing = d * d_ratio + 2*air_gap;
    d_ratio_co = d_neck_bushing / d_c0;
    use_cut_for_cap = false;
    
    h_co = h;
    h_ratio_co = h_ratio;
    axle_shape(d_c0, h_co, d_ratio_co, h_ratio_co, use_cut_for_cap, colors);
}

module bushing_blank(d, h) {
    translate ([0, eps, 0]) roller(d=d+eps, h = h - 2 * eps, center=false); 
}

module bushing(d, h, d_ratio, h_ratio, colors, air_gap) {
    difference() {
        bushing_blank(d, h);
        bushing_carve_out(d, h, d_ratio, h_ratio, colors, air_gap);
    }
}

module bore_for_side_handles(d, h) {
    * echo("bore_for_side_handles - d, h", d, h);
    end_clearance = 0.05*h; 
    h_hole = h + 2 * end_clearance;
    d_hole = d - eps;
    translate([0, -end_clearance, 0]) roller(d=d_hole,h=h_hole, center=false);
}

module attach_side_handles(d, h) {
    * echo("$children", $children);
    render() {
        for (i = [0:1:$children-1]) {
             difference() {
                children(i);
                bore_for_side_handles(d, h);
            }
        }
    }
}

module std_end_handle(d, h=true, l=true) {
    * echo("std_end_handle raw l: ", l);
    * echo("std_end_handle d: ", d);
    // if l is a number, it is displacement in mm.  Could be positive or negative
    // if l is a bool, it corresponds to should the handle be of 
    // sufficient length to grab, or should it just be a mounting post.
    length = is_num(l) ? l : (is_bool(l) && l) ? 2*d : 0;
    assert(!is_undef(length), "Need to specify l parameter");
    * echo("std_end_handle length: ", length);
    // Generate the bearing end of the handle
    // if h is a number, then it directly used
    // if h is boolean, then means generate a thick handle, 
    // while false means 
    assert(!is_undef(length), "Need to specify h parameter");
    h_width = is_num(h) ? h : (is_bool(h) && h) ? d/2 : d/4;
    assert(h_width > 0, "No meaning is currently defined for negative widths for the handles");
    dy = -h_width;
    dx = length;
    
    hull() {
        translate([0, dy, 0]) roller(d, h=h_width, center=false); 
        translate([dx, dy, 0]) roller(d, h=h_width, center=false); 
    }
}

module generate_end_handle(end_handle, d) {
    if (is_bool(end_handle) ) {
        if (end_handle) {
            std_end_handle(d);
        } 
    } 
}

module bearing(d, h, air_gap, d_ratio=0.4, h_ratio=0.7, colors=[], end_handle=false) {
    union() {
        axle(d, h, d_ratio, h_ratio, colors, air_gap);
        bushing(d, h, d_ratio, h_ratio, colors, air_gap);
    }
    * echo("In bearing $children", $children);
    if ($children >= 1) {
        attach_side_handles(d, h) children();
    }
    generate_end_handle(end_handle, d);  
}

//--------------------------------------------- Customizer 



module bushing_blank_q(z_index) {
   view_cross_section(z_index) {
       bushing_blank(d_q, h_q); 
   } 
}

module axle_q(z_index) {
   view_cross_section(z_index) {
       axle(d_q, h_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q); 
   } 
}

module bushing_carve_out_q(z_index) {
    view_cross_section(z_index) {
        bushing_carve_out(d_q, h_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q);
    }
}


module bushing_q(z_index) {
    view_cross_section(z_index) {
        bushing(d_q, d_q, d_ratio_q, h_ratio_q, colors_q, air_gap_q);
    }
}

module bearing_q(z_index) {
   view_cross_section(z_index) {
       bearing(d_q, h_q, air_gap_q, d_ratio_q, h_ratio_q, colors_q);
   } 
}



function wall_height_q() =  wall_height_by_bearing_diameter_q * d_q;
function wall_width_q() = floor_width_to_bearing_diameter_q * d_q;

module translate_fixture_q() {
    dx = - wall_width_q() / 2;
    dy = - wall_thickness_q;
    dz = - wall_height_q() / 2;

    translate([dx, dy, dz]) {
        children();
    }
}

module wall_q() {
    y = wall_thickness_q;
    x = wall_width_q();
    z = wall_height_by_bearing_diameter_q * d_q;
    translate_fixture_q() cube([x, y, z], center=false);
}

module floor_q() {
    z = flooor_thickness_q;
    x = floor_width_to_bearing_diameter_q * d_q;
    y = floor_breadth_to_bearing_height_q * h_q;
    dz = 0;
    dy = 0;
    translate_fixture_q() cube([x, y, z], center=false);   
}

module bearing_support_q() {

    x = max(bearing_support_r_q * d_q, 3);
    y = max(bearing_support_h_q * h_q, 3);
    z = min(handle_height_q, 1);
    * echo("bearing support x, y, z", x, y, z);
    dx = wall_width_q()/2 - x/2 -bearing_support_position_q * d_q;//-bearing_support_position_q * d_q ;
    dy = -y/2 + d_q/2 + wall_thickness_q;
    dz = 0;
    translate_fixture_q() {
        
        translate([dx, dy, dz]) cube([x, y, z], center=false);  
    }    
}

// ***************************************************



module hole_for_bearing() {
    difference() {
        children([1:$children-1]);
        hull() {
            children(0);
        }
    }
}



module handle_q() {
    
    x = 3;
    y = h_q - air_gap_q;
    z = 1.1 * d_q;
    dy = y/2 + air_gap_q ;
    dx = x/2;
    hole_for_bearing() {
        bearing_q(z_index=3); 
        hull() {
            bearing_support_q();
            translate([handle_length_q, 0, 0]) bearing_support_q();
        }
        hull() {
            translate([0, 2 * air_gap_q, 0]) roller(d=d_q * 1.2 , h=0.7 * h_q, center=false);
            bearing_support_q();
        }
        
    }
}

* hole_for_bearing() {
    bushing_q(z_index=3);  
}

// Order from inner to outer for eventual rendering with alpha!

if (show_axle_q) {
   axle_q(z_index=1);    
}

if (show_bushing_carve_out_q) {
   bushing_carve_out_q(z_index=2);    
}

if (show_bushing_q) {
   bushing_q(z_index=3);    
}

if (show_bushing_blank_q) {
   bushing_blank_q(z_index=3);    
}
if (show_bearing_q) {
    bearing_q(z_index=4);
}

if (show_roller_q) {
    if (right_orientation_q) {
         roller(d_q, h_q, center=roller_center_q, v=X_ORIENTATION);
    }  else {
        roller(d_q, h_q, center=roller_center_q);
    }
}



show_simple_usage_test = true;




if (show_simple_usage_test) {
    d = 5;
    h = 5;
    handle = 15;
    air_gap = 0.5;
    
    x = handle; 
    y = 0.8*h;
    z = d;
    dx = -x/2;
    dy = h/2;
    dz = -d/2 + z/2;
    
    
    bearing(d, h, air_gap, end_handle=true) {
        union() {
            // This is the side handle!
            translate([dx, dy, dz]) {
                cube([x, y, z], center=true);
            }
            translate([-x, 3, -z/2]) cylinder(d=12, h=z); // finger pad for more leverage to try to break pivot free
        }
    } 

    translate([3*d, -1, -z/2]) cylinder(d=12, h=z); // finger pad for more leverage to try to break pivot free
}



if (show_handle_q) {
    handle_q();
}

if (show_wall_q) {
    wall_q();
}

if (show_floor_q) {
    floor_q();
}

if (show_bearing_support_q) {
    bearing_support_q();
}

if (show_union_test) {
}





























    