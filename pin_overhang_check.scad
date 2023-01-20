/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Pin Overhang] */
show_pin_overhang = false;
max_overhang = 3; // [ 1 : 0.5 : 5]
delta_overhang = 0.25; // [0.25, 0.50, 1]

minimum_diameter = 3; // [1 : 1 : 10]
maximum_diameter = 7; // [1 : 1 : 10]
delta_diameter = 1; // [0.25, 0.50, 1, 2, 3, 4]

pad_x = 1; // [0 : 0.01 : 5]
pad_y = 2; // [0 : 0.01 : 5]
pad_z = 3; // [0 : 0.01 : 5]

// gap_x = 1; // [1: 5]
//vertical_padding = 2;  // [1: 5]


overhangs = [ each [1 : delta_overhang: max_overhang] ];

diameters = [ each [minimum_diameter : delta_diameter : maximum_diameter ] ];


* echo("overhangs", overhangs);
h_count = len(overhangs);
* echo("h_count", h_count);


// Cumulative sum of values in v
function v_cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function v_sum(v, i=0, r=0) = i<len(v) ? v_sum(v, i+1, r+v[i]) : r;

function v_add_scalar(v, s) = [ for (e = v) e + s ];

//function v_add(v1, v2) = (len(v1) == len(v2)) ? 
//        [ for (i = [0 : len(v1) - 1) v1[i] + v2[i] ] : 
//        undef;
//        
//function v_multiply(v1, v2) = (len(v1) == len(v2)) ? 
//        [ for (i = [0 : len(v1) - 1) v1[i] * v2[i] ] : 
//        undef;
         
    

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];



function padded_x(sx, pad_x) = [ for (sx_i = sx) sx_i + pad_x ]; 
// function offset_x(dx_padded) = [ for (dxp = dx_padded) dxp - dx_padded[0]/2 ]; 
function offset_x(dx_padded) = v_add_scalar(dx_padded, -dx_padded[0]/2);

module layout_compressed_by_x_then_y(i_t, j_t, sizes, pad) {
    // Break down the size elements by the x and y components
    sx =
    [ for (i = [0 : len(sizes) -1]) 
        [ for (j = [0: len(sizes[i]) -1])
            sizes[i][j][0]
        ]
    ];
    sy = 
    [ for (i = [0 : len(sizes) -1]) 
        [ for (j = [0: len(sizes[i]) -1])
            sizes[i][j][1]
        ]
    ];    
    // On x,  we compress as much as possible
    dx = 
    [ for (i = [0 : len(sx) -1]) 
        //offset_x(v_cumsum(padded_x(sx[i], pad.x)))
        offset_x(v_cumsum(v_add_scalar(sx[i], pad.x))) 
    ];
    // For each of the y rows, we need the maximum value for the whole row.
    sy_max =  
    [ for (i = [0 : len(sy) -1])
        max(sy[i])
    ];
    // Then compress down the rows as much as possible.
    dy = v_cumsum(v_add_scalar(sy_max, pad.y));
    // Finally place the target in place
    dx_i_j = dx[i_t][j_t];
    translate([dx[i_t][j_t], dy[i_t], 0]) children();
} 

module pin(d, h, center=true, v=Y_ORIENTATION) {
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
} 

module wall(size, pad, sizing_data) {
    wall_y = sizing_data[3];
    color("blue", alpha=0.7) 
        translate([0, -wall_y/2, 0]) 
            cube([size.x+pad.x, wall_y, size.z], center=true); 
}

module pin_element(d, h, size, sizing_data, pad) {
    echo("In pin_element ==============================================");
    echo("d", d);
    echo("h", h);
    echo("size", size);
    echo("sizing_data", sizing_data);
    echo("pad", pad);
    
    pin(d=d, h=h, center=false);
    wall(size, pad, sizing_data);
    
//    wall_y = sizing_data[3];
//    color("blue", alpha=0.7) 
//        translate([0, -wall_y/2, 0]) 
//            cube([size.x+pad.x, wall_y, size.z], center=true); 
    
    
    //* function bar_height(d) = d + 1.5 * pad_z;
    //* base(size);
    
    
    // Draw bounding box
    color("red", alpha=0.3) cube(size, center=true); 
    echo("In pin_element ==============================================");
}

function size_of_element(d, h, m_d, m_h, c) = 
    [
        d*m_d.x + h*m_h.x + c.x, 
        d*m_d.y + h*m_h.y + c.y,
        d*m_d.z + h*m_h.z + c.z
    ];

module pin_overhang(d, h, pad, sizing_data) {

    // Match up with size of components generated!
    m_d = sizing_data[0];
    m_h = sizing_data[1];
    c = sizing_data[2];
    
    sizes = 
    [ for (i = [0 : len(d)-1]) 
        [ for (j = [0: len(h)-1])
            size_of_element(d[i], h[j], m_d, m_h, c)
        ]
    ];
        
    for (i = [0 : len(d)-1]) {
        
        for (j = [0: len(h)-1]) {
            layout_compressed_by_x_then_y(i, j, sizes, pad) {
                size = size_of_element(d[i], h[j], m_d, m_h, c);
                pin_element(d[i], h[i], size, sizing_data, pad);
            } 
        }
    } 
}

if (show_pin_overhang) {
    pad = [pad_x, pad_y, pad_z];
    
    wall_y= 2;
    m_d = [1.5, 0,      1];
    m_h = [0,   1,      0];
    c =   [0,   wall_y, wall_y];
    sizing_data = [m_d, m_h, c, wall_y ];
    
    pin_overhang(diameters, overhangs, pad, sizing_data);
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



//module pin_overhang_for_d(diameters, overhangs, gap_x, vertical_padding) {
//    bar_height = d + 1.5 * vertical_padding;
//    dx = [ for (i_h = [0 : len(overhangs) - 1]) d + gap_x ];
//    echo("dx", dx);  
//    x = cumsum(dx);
//    echo("x", x); 
//    for (i_h = [0 : len(overhangs)-1])  {
//        h = overhangs[i_h];
//        translate([x[i_h], 0, 0]) { 
//            pin(d=d, h=h, center=false);
//            base(bar_height, dx[i_h]);   
//        }
//    }     
//}
//module layout(i, j, data) {
//    rules = data[0];
//    method = rules[0];
//    echo("method", method);
//    if (method == "even") {
//        ax = rules[1][0];
//        bx = rules[1][1];
//        x = ax * i + bx;
//        
//        ay = rules[1][0];
//        by = rules[1][1];
//        y = ay * j + by;
//        translate([x, y, 0]) children();
//    } 
//    
//    
//    
//}
//
//
//function cartesian_inner(r_i, s) = [ for (j = [0 : len(s) -1]) [r_i, s[j]] ];
//function cartesian(r, s) = [ for (i = [ 0 : len(r) - 1 ]) cartesian_inner(r[i], s) ];
    













//gap_y = 2;
//layout_rules = ["even", [5, 1], [3, 1]];
//
//h = [1, 2, 3, 4, 5, 6, 7, 8];
//d = [1,2, 3];
//test_layout(d, h, layout_rules);

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









































