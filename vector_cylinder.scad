/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Development] */
show_initial_test = true;

h_initial_test = [5, 2.6, 3.7];
r_initial_test = [10, 5, 1];
colors_initial_test = ["red", "yellow", "blue"];
//len_h_initial_test=len(h_initial_test);
//echo(h_initial_test,len_h_initial_test);
//
//array1=[1,2,3,4,5,6,7,8]; 
//len_array1=len(array1);
//echo(array1,len_array1);

module v_cylinder(r, h, colors) {
    count = len(h);
    h_cum = cumsum(h);
    for(i = [0 : count-1]) {
        h_i = h[i];
        echo("h_i", h_i);
        dz = h_cum[i-1];
        translate([0,0,dz]) 
        color(colors[i]) cylinder(r=r[i], h=h[i]);
    }
}

if (show_initial_test) {
        v_cylinder(r=r_initial_test, h=h_initial_test, colors=colors_initial_test);
}

function add(v, i=0, r=0) = i<len(v) ? add(v, i+1, r+v[i]) : r;

sum = add(h_initial_test);
echo("sum", sum, h_initial_test);

length = len(h_initial_test);
list_2 = [ for (i = [0 : 1 : length-1]) i < 2 ? h_initial_test[i] : 0 ];
echo("list_2", list_2);

// Cumulative sum of values in v
function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
echo("cumsum", h_initial_test, cumsum(h_initial_test));