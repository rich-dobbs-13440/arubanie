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
columns = ["r1", "r2", "h", "color"];
colors = ["red", "blue", "green", "yellow"];
color_red_idx = 0;
color_blue_idx = 1;
color_green_idx = 2;

r1_idx = 0;
r2_idx = 1;
h_idx = 2;
color_idx = 3;
conic_frustrum_test_data = [
    [4, 5, 3.3, color_blue_idx],
    [5, 2, 5.3, color_red_idx],
    [2, 2, 3.1, color_green_idx],
    [2, 2, 3.1, color_red_idx],
];
    
// Cumulative sum of values in v
function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function vector_sum(v, i=0, r=0) = i<len(v) ? vector_sum(v, i+1, r+v[i]) : r;

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

module v_conic_frustrum(data, colors) {
    count = len(data);
    h = [for (i = [0 : count-1]) data[i][h_idx] ];
    echo("h", h);
    h_cum = cumsum(h);
    r1 = [for (i = [0 : count-1]) data[i][r1_idx]];
    r2 = [for (i = [0 : count-1]) data[i][r2_idx]];
    color_idx = [for (i = [0 : count-1]) data[i][color_idx]];
    for(i = [0 : count-1]) {
        h_i = h[i];
        echo("h_i", h_i);
        dz = i == 0 ? 0.0 :  h_cum[i-1];
        translate([0,0,dz]) 
        color(colors[color_idx[i]]) 
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
    echo("conic_frustrum_test_data", conic_frustrum_test_data);
    element_0 = conic_frustrum_test_data[0];
    echo("element_0", element_0);
    h0 = element_0[2];
    echo("h0", h0);
    v_conic_frustrum(conic_frustrum_test_data, colors);
}








