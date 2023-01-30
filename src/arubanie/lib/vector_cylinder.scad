/*

    Usage:
    
    use <vector_cylinder.scad>
   
    module module_using_vector_cylinder() {
        C_A = 0 + 0;
        C_B = 1 + 0;
        C_C = 2 + 0;
        C_D = 3 + 0;
       
        d = 1;
        d_n = 2;
        d_b = 3;
        
        h_n = 3; 
        h_c = 3.3;
        h_s = 2;
        h_b = 2;

        colors =["aqua", "blue", "tomato"];

        columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];

        axle_data = 
        [   
            [ d/2,      d_n/2,  h_n, C_A ], // Tapered outward section
            [ d_n/2,    d/2,    h_c, C_B ], // Tapered inward section 
            [ d/2,      d/2,    h_s, C_C ], // Straight section 
            [ d_b/2,    d_b/2,  h_b, C_D ], // Bigger and bad color index 
        ];  

        v_conic_frustrum(
            columns,         
            axle_data, 
            colors); 
    }

    module_using_vector_cylinder();
    

*/


/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;
 

/* [Test v_cylinder initial] */
show_initial_test_vci = true;

h_vci = [5, 2.6, 3.7];
r_vci = [10, 5, 1];
colors_vci = ["red", "yellow", "blue"];

/* [Test v_conic_frustrum] */
show_v_conic_frustrum_test_vcf = false;
test_data_columns_vcf = false;
show_v_conic_frustrum_test_data_columns_dc = false; 
colors_for_test_vcf = ["red", "blue", "green", "yellow"];
/* [Hidden] */
color_red_idx_vcf = 0;
color_blue_idx_vcf = 1;
color_green_idx_vcf = 2;
color_yellow_idx_vcf = 3;

/* [Test sample_pin] */
show_test_pin_tsp = false;

r_top_tsp = 5.11; 
r_top_inner_tsp = 4.11; 
r_neck_tsp = 3.65; 
r_base_inner_tsp = 5.11; 
r_base_tsp = 5.11;
h_total_tsp = 10.11; 
h_top_tsp = 2.11; 
h_base_tsp = 2.11;

/* [Test sample pin air gap ] */
show_test_sample_pin_air_gap_spag = false;

air_gap_spag = 0; // [0:0.1:5] 
test_piece_radius_by_rbase_spag = 2; // [0.9:0.1:5]
test_piece_handle_length_spag = 5; // [0:0.1:50]
red_spag = 128; // [10:255]
blue_spag = 128; // [10:255]
green_spag = 128; // [10:255]
alpha_spag = 0.5; // [0:0.1:1]


module hide_from_customizer(){}

show_name = false;
if (show_name) {
    linear_extrude(2) text("vector_cylinder.scad", halign="center");
}

// Cumulative sum of values in v
function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function vector_sum(v, i=0, r=0) = i<len(v) ? vector_sum(v, i+1, r+v[i]) : r;

function index_of(columns, idx_to_match, i=0) = 
    i == len(columns) ?
        undef :
        columns[i]==idx_to_match ? 
            i : 
            index_of(columns, idx_to_match, i + 1);


module v_cylinder(r, h, colors) {
    count = len(h);
    h_cum = cumsum(h);
    * echo("h_cum", h_cum);
    for(i = [0 : count-1]) {
        h_i = h[i];
        * echo("h_i", h_i);
        dz = i == 0 ? 0.0 :  h_cum[i-1];
        translate([0,0,dz]) 
        color(colors[i]) cylinder(r=r[i], h=h[i]);
    }
}

// Use functions to export constants
function vcf_r1_idx() = 0;
function vcf_r2_idx() = 1;
function vcf_h_idx() = 2;
function vcf_color_idx() = 3;

module v_conic_frustrum(data_columns, data, colors) {
    
    r1_idx = index_of(data_columns, vcf_r1_idx());
    r2_idx = index_of(data_columns, vcf_r2_idx());
    color_idx = index_of(data_columns, vcf_color_idx());
    h_idx = index_of(data_columns, vcf_h_idx());
    
    count = len(data);
    if (count == 0) {
        * echo("###################### Warning:  Data is empty in v_conic_frustrum");
    } else {
        h = [for (i = [0 : count-1]) data[i][h_idx] ];
        h_cum = cumsum(h);
        r1 = [for (i = [0 : count-1]) data[i][r1_idx]];
        r2 = [for (i = [0 : count-1]) data[i][r2_idx]];
        color_offset = [for (i = [0 : count-1]) data[i][color_idx]];
        for(i = [0 : count-1]) {
            h_i = h[i];
            // Make object slightly oversized for intersection goodness,
            // and nice previews 
            dz = (i == 0 ? 0.0 :  h_cum[i-1]) -eps ; 
            translate([0,0,dz]) 
            color(colors[color_offset[i]]) 
            cylinder(r1=r1[i], r2=r2[i], h=h[i] + 2 * eps);
        }  
    }  
}

if (show_initial_test_vci) {
    length = len(h_vci);
    list_2 = [ for (i = [0 : 1 : length-1]) i < 2 ? h_vci[i] : 0 ];
    * echo("list_2", list_2);
    
    sum = vector_sum(h_vci);
    * echo("vector_sum", sum, h_vci);
    * echo("cumsum", h_vci, cumsum(h_vci));
    v_cylinder(r=r_vci, h=h_vci, colors=colors_vci);
}


if (show_v_conic_frustrum_test_vcf) {
    columns = [vcf_r1_idx, vcf_r2_idx, vcf_h_idx, vcf_color_idx];
    conic_frustrum_test_data = [
        [4, 5, 3.3, color_blue_idx_vcf],
        [5, 2, 5.3, color_red_idx_vcf],
        [2, 2, 3.1, color_green_idx_vcf],
        [2, 2, 3.1, color_red_idx_vcf],
    ];
    
    * echo("conic_frustrum_test_data", conic_frustrum_test_data);
    element_0 = conic_frustrum_test_data[0];
    * echo("element_0", element_0);
    h0 = element_0[2];
    * echo("h0", h0);
    v_conic_frustrum(columns, conic_frustrum_test_data, colors_for_test_vcf);
}


if (show_v_conic_frustrum_test_data_columns_dc) {
    
    data_columns_changed = [vcf_color_idx, vcf_r1_idx, vcf_r2_idx, vcf_h_idx];
    conic_frustrum_test_data_changed_column_ordering = [
        [color_blue_idx_vcf,  4, 5, 3.3],
        [color_red_idx_vcf,   5, 2, 5.3],
        [color_green_idx_vcf, 2, 2, 3.1],
        [color_red_idx_vcf,   2, 2, 3.1],
    ];
    map = [1, 2, 3, 0];
    count = 4;
    * echo("color idx", map[vcf_color_idx]);
    * echo("r1 idx", map[vcf_r1_idx]);
    * echo("r2 idx", map[vcf_r2_idx]);
    * echo("h idx", map[vcf_h_idx]);
    * echo("data_column", data_columns_changed);
    * echo("map", map);
    * echo("vcf_h_idx", vcf_h_idx);
    
    map_trial = [
        index_of(data_columns_changed, 0),
        index_of(data_columns_changed, 1), 
        index_of(data_columns_changed, 2), 
        index_of(data_columns_changed, 3)]; 
    * echo("map_trial", map_trial);
    assert(is_undef(index_of(data_columns_changed, 99)));
    
    v_conic_frustrum(
        data_columns_changed, 
        conic_frustrum_test_data_changed_column_ordering, 
        colors_for_test_vcf);
    
}


module sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base, air_gap=0) {
    
    // air_gap provides an ability to scale up the pin, to allow using intersection 
    // to generate a cavity for the pin.  Should help with print in place
    assert(!is_undef(r_top), "You must specify r_top");
    assert(!is_undef(r_top_inner), "You must specify r_top_inner");
    assert(!is_undef(r_neck), "You must specify r_neck");
    assert(!is_undef(r_base_inner), "You must specify r_base_inner");
    assert(!is_undef(r_base), "You must specify r_base");
    assert(!is_undef(h_total), "You must specify h_total");
    assert(!is_undef(h_top), "You must specify h_top");
    assert(!is_undef(h_base), "You must specify h_base");
    
    assert(air_gap >= 0, "air_gap must >= zero");
    
    function ag(r) = r + air_gap;
    
    columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];
    h_neck = h_total - h_top - h_base;
    h_neck_bottom = h_neck/2;
    h_neck_top = h_neck/2;
    data = [
        [ag(r_base),        ag(r_base),         h_base,         color_blue_idx_vcf],
        [ag(r_base_inner),  ag(r_neck),         h_neck_bottom,  color_red_idx_vcf],
        [ag(r_neck),        ag(r_top_inner),    h_neck_top,     color_green_idx_vcf],
        [ag(r_top),         ag(r_top),          h_top,          color_yellow_idx_vcf],
    ];    
    v_conic_frustrum(
        columns, 
        data, 
        colors_for_test_vcf);
}


if (show_test_pin_tsp) {
    sample_pin(r_top_tsp, r_top_inner_tsp, r_neck_tsp, r_base_inner_tsp, r_base_tsp, h_total_tsp, h_top_tsp, h_base_tsp);
}


if (show_test_sample_pin_air_gap_spag) {
    sample_pin(
        r_top_tsp, r_top_inner_tsp, r_neck_tsp, r_base_inner_tsp, 
        r_base_tsp, h_total_tsp, h_top_tsp, h_base_tsp);

    test_piece_size = r_base_tsp*test_piece_radius_by_rbase_spag;
    color([red_spag/255, green_spag /255, blue_spag/255], alpha=alpha_spag) {
        difference() {
            cylinder(h=h_total_tsp, r=test_piece_size);
            sample_pin(
                r_top_tsp, r_top_inner_tsp, r_neck_tsp, r_base_inner_tsp, 
                r_base_tsp, h_total_tsp, h_top_tsp, h_base_tsp, air_gap=air_gap_spag);     
        }
    }
}











