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
echo("overhangs", overhangs);
h_count = len(overhangs);
echo("h_count", h_count);


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

module layout(i, j, arrangement) {
    x = i * 5;
    y = j * 6;
    translate([x, y, 0]) children();
}


function cartesian_inner(r_i, s) = [ for (j = [0 : len(s) -1]) [r_i, s[j]] ];
function cartesian(r, s) = [ for (i = [ 0 : len(r) - 1 ]) cartesian_inner(r[i], s) ];
    




module test_layout(d, h) {
    gap_x = 1;
    gap_y = 1;
    function calc_size(h, d) = [h + 3, d + 3]; // Return a list of [x, y]
    cartesian = cartesian(d, h);
    
    // List comprehension layed out as conventional for loops
    element_sizes =
    [ for (i = [ 0 : len(d) - 1 ])
        [ for (j = [0 : len(h) -1]) 
            calc_size(d[i], h[i]) 
        ]
    ];
    echo("element_sizes", element_sizes);   
    //x =     ];
    e_x =  
    [ for (i = [ 0 : len(d) - 1 ])
        [ for (j = [0 : len(h) -1]) 
            element_sizes[i][j][0] 
        ]
    ];
    echo("e_x", e_x);
    x =     
    [ for (i = [ 0 : len(d) - 1 ]) 
         cumsum(e_x[i])  
    ];    
    echo("x", x);   
    arrangement = [d, h, cartesian, e_x, x];
    
    echo("arrangement:", arrangement);
    for (i = [0 : len(d) -1]) {
        for (j = [0: len(h) -1]) {
            layout(i, j, arrangement) {
                cube([d[i], h[j], 1]);
            } 
        }
    } 
}



d = [ each [1 : 3] ];
h = [ each [1 : 4] ];
test_layout(d, h);


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









































