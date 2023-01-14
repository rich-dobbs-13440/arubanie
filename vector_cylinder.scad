/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Test v_cylinder initial] */
show_initial_test = true;

h_initial_test = [5, 2.6, 3.7];
r_initial_test = [10, 5, 1];
colors_initial_test = ["red", "yellow", "blue"];

/* [Test v_conic_frustrum] */
show_v_conic_frustrum_test = false;
colors_for_test_vcf = ["red", "blue", "green", "yellow"];
show_v_conic_frustrum_test_data_columns = false;

/* [Hidden] */
color_red_idx = 0;
color_blue_idx = 1;
color_green_idx = 2;
color_yellow_idx = 3;

/* [Test sample_pin] */
show_test_pin = false;
r_top = 5; 
r_top_inner = 4; 
r_neck = 3; 
r_base_inner = 5; 
r_base = 5;
h_total = 10; 
h_top = 2; 
h_base = 2;

/* [Test opacity] */
show_test_opacity = false;
air_gap = 0; // [0:0.1:5] 
test_piece_radius_by_rbase = 2; // [0.9:0.1:5]
test_piece_handle_length = 5; // [0:0.1:50]
red_test_opacity = 128; // [10:255]
blue_test_opacity = 128; // [10:255]
green_test_opacity = 128; // [10:255]
alpha_for_opacity = 1; // [0:0.1:1]

module hide_from_customizer(){}




    
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
    echo("h_cum", h_cum);
    for(i = [0 : count-1]) {
        h_i = h[i];
        echo("h_i", h_i);
        dz = i == 0 ? 0.0 :  h_cum[i-1];
        translate([0,0,dz]) 
        color(colors[i]) cylinder(r=r[i], h=h[i]);
    }
}


vcf_r1_idx = 0;
vcf_r2_idx = 1;
vcf_h_idx = 2;
vcf_color_idx = 3;

module v_conic_frustrum(data_columns, data, colors) {
    
    r1_idx = index_of(data_columns, vcf_r1_idx);
    r2_idx = index_of(data_columns, vcf_r2_idx);
    color_idx = index_of(data_columns, vcf_color_idx);
    h_idx = index_of(data_columns, vcf_h_idx);
    
    count = len(data);
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

if (show_initial_test) {
    length = len(h_initial_test);
    list_2 = [ for (i = [0 : 1 : length-1]) i < 2 ? h_initial_test[i] : 0 ];
    echo("list_2", list_2);
    
    sum = vector_sum(h_initial_test);
    echo("vector_sum", sum, h_initial_test);
    echo("cumsum", h_initial_test, cumsum(h_initial_test));
    v_cylinder(r=r_initial_test, h=h_initial_test, colors=colors_initial_test);
}


if (show_v_conic_frustrum_test) {
    

    
    columns = [vcf_r1_idx, vcf_r2_idx, vcf_h_idx, vcf_color_idx];
    conic_frustrum_test_data = [
        [4, 5, 3.3, color_blue_idx],
        [5, 2, 5.3, color_red_idx],
        [2, 2, 3.1, color_green_idx],
        [2, 2, 3.1, color_red_idx],
    ];
    
    echo("conic_frustrum_test_data", conic_frustrum_test_data);
    element_0 = conic_frustrum_test_data[0];
    echo("element_0", element_0);
    h0 = element_0[2];
    echo("h0", h0);
    v_conic_frustrum(columns, conic_frustrum_test_data, colors_for_test_vcf);
}

if (show_v_conic_frustrum_test_data_columns) {
    
    data_columns_changed = [vcf_color_idx, vcf_r1_idx, vcf_r2_idx, vcf_h_idx];
    conic_frustrum_test_data_changed_column_ordering = [
        [color_blue_idx,  4, 5, 3.3],
        [color_red_idx,   5, 2, 5.3],
        [color_green_idx, 2, 2, 3.1],
        [color_red_idx,   2, 2, 3.1],
    ];
    map = [1, 2, 3, 0];
    count = 4;
    echo("color idx", map[vcf_color_idx]);
    echo("r1 idx", map[vcf_r1_idx]);
    echo("r2 idx", map[vcf_r2_idx]);
    echo("h idx", map[vcf_h_idx]);
    echo("data_column", data_columns_changed);
    echo("map", map);
    echo("vcf_h_idx", vcf_h_idx);
    
    map_trial = [
        index_of(data_columns_changed, 0),
        index_of(data_columns_changed, 1), 
        index_of(data_columns_changed, 2), 
        index_of(data_columns_changed, 3)]; 
    echo("map_trial", map_trial);
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
    
    columns = [vcf_r1_idx, vcf_r2_idx, vcf_h_idx, vcf_color_idx];
    h_neck = h_total - h_top - h_base;
    h_neck_bottom = h_neck/2;
    h_neck_top = h_neck/2;
    data = [
        [ag(r_base),        ag(r_base),         h_base,         color_blue_idx],
        [ag(r_base_inner),  ag(r_neck),         h_neck_bottom,  color_red_idx],
        [ag(r_neck),        ag(r_top_inner),    h_neck_top,     color_green_idx],
        [ag(r_top),         ag(r_top),          h_top,          color_yellow_idx],
    ];    
    v_conic_frustrum(
        columns, 
        data, 
        colors_for_test_vcf);
}

if (show_test_pin) {
    sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base);
}

if (show_test_opacity) {
    sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base);
    test_piece_size = r_base*test_piece_radius_by_rbase;
    color([red_test_opacity/255, green_test_opacity /255, blue_test_opacity/255], alpha=alpha_for_opacity) {
        difference() {
            union() {
                cube([5, test_piece_handle_length, h_total]);
                cylinder(h=h_total, r=test_piece_size);
            }
    
            sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base, air_gap=air_gap);
        }
    }
    //sample_pin(r_top, r_top_inner, r_neck, r_base_inner, r_base, h_total, h_top, h_base, air_gap=air_gap);

}











