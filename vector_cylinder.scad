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
        dz = i == 0 ? 0.0 :  h_cum[i-1];
        translate([0,0,dz]) 
        color(colors[color_offset[i]]) 
        cylinder(r1=r1[i], r2=r2[i], h=h[i]);
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
    
    //for (i = [0 : count-1])
    
    //color_idx = [for (i = [0 : count-1]) data[i][map[vcf_color_idx]]];
    //echo("color_idx", color_idx);
    
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

if (show_test_pin) {
    
}









