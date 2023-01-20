/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Pin Overhang] */
show_pin_overhang_for_d = false;
max_overhang = 3; // [ 1 : 0.5 : 5]
delta_overhang = 0.25; // [0.25, 0.50, 1]
pin_diameter = 3; // [1 : 1 : 10]
gap_x = 1; // [1: 5]
vertical_padding = 2;  // [1: 5]

overhangs = [ each [1 : delta_overhang: max_overhang] ];
* echo("overhangs", overhangs);
h_count = len(overhangs);
* echo("h_count", h_count);


// Cumulative sum of values in v
function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function vector_sum(v, i=0, r=0) = i<len(v) ? vector_sum(v, i+1, r+v[i]) : r;
    

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];

module pin(d, h, center=true, v=Y_ORIENTATION) {
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
} 

module base(bar_height, width) {
    y = 2; // base thickness
    x = width; // distance between pins for same diameter
    z = bar_height; //bar_height;
    dx = -x/2;
    dy = -y;
    dz = -z/2;
    translate([dx, dy, dz]) cube([x, y, z]);
}



module pin_overhang_for_d(d, overhangs, gap_x, vertical_padding) {
    bar_height = d + 1.5 * vertical_padding;
    dx = [ for (i_h = [0 : len(overhangs) - 1]) d + gap_x ];
    echo("dx", dx);  
    x = cumsum(dx);
    echo("x", x); 
    for (i_h = [0 : len(overhangs)-1])  {
        h = overhangs[i_h];
        translate([x[i_h], 0, 0]) { 
            pin(d=d, h=h, center=false);
            base(bar_height, dx[i_h]);   
        }
    }     
}


if (show_pin_overhang_for_d) {
    pin_overhang_for_d(pin_diameter, overhangs, gap_x, vertical_padding, thickness = 1);
}

module echo_3d(label, value, dx, dy, dz=0, orientation=0, thickness = 1) { 
    line = str(label, value);
    z = thickness;
    height_of_text = 3.7;
    baseline_adjust = -0.5;
    length_of_text = len(line);
    x = length_of_text * 3;
    y = height_of_text;
    dy_b = baseline_adjust;
    rz = orientation;
    translate([dx, dy, dz])  {
        rotate([0, 0, rz]) {
            translate([0, 0, z]) linear_extrude(z) text(line, size=3);
            translate([0, dy_b, 0]) cube([x, y, z]);
        }
    }
    
}

module layout(i, j, data) {
    rules = data[0];
    method = rules[0];
    echo("method", method);
    if (method == "even") {
        ax = rules[1][0];
        bx = rules[1][1];
        x = ax * i + bx;
        
        ay = rules[1][0];
        by = rules[1][1];
        y = ay * j + by;
        translate([x, y, 0]) children();
    } 
    
    
    
}


function cartesian_inner(r_i, s) = [ for (j = [0 : len(s) -1]) [r_i, s[j]] ];
function cartesian(r, s) = [ for (i = [ 0 : len(r) - 1 ]) cartesian_inner(r[i], s) ];
    

module layout_compressed_by_x_then_y(i_t, j_t, sizes) {
    echo("=====================================================");
    echo("i_t", i_t);
    echo("j_t", j_t);
    // Break down the size elements by the x and y components
    sx =
    [ for (i = [0 : len(sizes) -1]) 
        [ for (j = [0: len(sizes[i]) -1])
            sizes[i][j][0]
        ]
    ];
    echo("sx", sx);
    sy = 
    [ for (i = [0 : len(sizes) -1]) 
        [ for (j = [0: len(sizes[i]) -1])
            sizes[i][j][1]
        ]
    ];
    echo("sy", sy);    
    // On x we compress as much as possible
    dx = 
    [ for (i = [0 : len(sx) -1]) 
        cumsum(sx[i])
    ];
    echo("dx", dx);
    // For each of the y rows, we need the maximum value for the whole row.
    sy_max =  
    [ for (i = [0 : len(sy) -1])
        max(sy[i])
    ];
    echo("sy_max", sy_max);
    // Then compress down the rows as much as possible.
    dy = cumsum(sy_max);
    echo("dy", dy);
    // Finally place the target in place
    dx_i_j = dx[i_t][j_t];
    echo("dx_i_j", dx_i_j);
    dy_i = dy[i_t];
    echo("dy_i", dy_i);
    translate([dx_i_j, dy_i, 0]) children();
    echo("=====================================================");
} 



module test_layout(d, h, rules) {
    echo("d", d);
    echo("h", h);
    pad_x = 1;
    pad_y = 2;
    pad_z = 3;
    function size(d, h) = [d + pad_x, h + pad_y, d + pad_z];
    sizes = 
    [ for (i = [0 : len(d)-1]) 
        [ for (j = [0: len(h)-1])
            size(d[i], h[j])
        ]
    ];
    echo("sizes", sizes);
        
    for (i = [0 : len(d)-1]) {
        for (j = [0: len(h)-1]) {
            layout_compressed_by_x_then_y(i, j, sizes) {
                cube([d[i], h[j], d[i]]);
            } 
        }
    } 
}







gap_y = 2;
layout_rules = ["even", [5, 1], [3, 1]];

h = [1, 2, 3, 4, 5, 6, 7, 8];
d = [1,2, 3];
test_layout(d, h, layout_rules);

//d = [ each [1 : 3] ];
//h = [ each [1 : 4] ];
//function size(i, j) = i + j;

//i_r = [0, 1, 2, 3, 4];
//j_r = [0, 1, 2];
//
//f_x(i, a) = [ for (i_
//
//function a(i = [ for () size(i, j)] ]
//
//*test_layout(size);
//
//
////* dz_text = 1.5 -pin_diameter/2 - vertical_padding;
//// echo_3d("d=", pin_diameter, 3.1, -3, 0, orientation=90);
//
//
//* echo(len("This is a string"));
//
//* echo_3d("d=", pin_diameter, 0, 0, 0, orientation=90);


//
//function func(x) = x < 1 ? 0 : x + func(x - 1);
//input = [1, 3, 5, 8];
//output = [for (a = [ 0 : len(input) - 1 ]) func(input[a]) ];
//echo(output); // ECHO: [1, 6, 15, 36]
//
//
//
//
//function f_of_d(d) = [d, d, d];
//
//
//
//array = outer(d, h);
//
//
//echo("array", array);









































