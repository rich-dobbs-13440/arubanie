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
    
function v_mul_scalar(v, s) = [ for (e = v) e * s ];

//function v_add(v1, v2) = (len(v1) == len(v2)) ? 
//        [ for (i = [0 : len(v1) - 1) v1[i] + v2[i] ] : 
//        undef;
//        
//function v_multiply(v1, v2) = (len(v1) == len(v2)) ? 
//        [ for (i = [0 : len(v1) - 1) v1[i] * v2[i] ] : 
//        undef;
         
    

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];

function layout_size_of_element(r_i, s_j, m_r, m_s, c) = 
    [
        //  might be a vector equation r_i * m_r + s_j * m_s + c !
        r_i*m_r.x + s_j*m_s.x + c.x, 
        r_i*m_r.y + s_j*m_s.y + c.y,
        r_i*m_r.z + s_j*m_s.z + c.z
    ];

function layout_generate_sizes(r, s, m_r, m_s, c) =
    [ for (i = [0 : len(r)-1]) 
        [ for (j = [0: len(s)-1])
            layout_size_of_element(r[i], s[j], m_r, m_s, c)
        ]
    ];
 
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
    sz = 
    [ for (i = [0 : len(sizes) -1]) 
        [ for (j = [0: len(sizes[i]) -1])
            sizes[i][j][2]
        ]
    ];    
    // On x,  we compress as much as possible
    dx = 
    [ for (i = [0 : len(sx) -1]) 
        offset_x(v_cumsum(v_add_scalar(sx[i], pad.x))) 
    ];
    // For each of the y rows, we need the maximum value for the whole row.
    sy_max =  
    [ for (i = [0 : len(sy) -1])
        max(sy[i])
    ];
    // Then compress down the rows as much as possible.
    dy = v_cumsum(v_add_scalar(sy_max, pad.y));
    // On Z, we the bottoms all on the build plate
    // Finally place the target in place
    dz = v_mul_scalar(sz, 0.5);
    dx_i_j = dx[i_t][j_t];
    translate([dx[i_t][j_t], dy[i_t], dz[i_t][j_t]]) children();
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
    // Draw bounding box
    color("red", alpha=0.3)  cube(size, center=true); 
    echo("In pin_element ==============================================");
}

module pin_overhang(d, h, pad, sizing_data) {

    // Match up with size of components generated!
    m_d = sizing_data[0];
    m_h = sizing_data[1];
    c = sizing_data[2];
    
    sizes = layout_generate_sizes(d, h, m_d, m_h, c); 
   
    for (i = [0 : len(d)-1]) {
        for (j = [0: len(h)-1]) {
            layout_compressed_by_x_then_y(i, j, sizes, pad) {
                
                size = layout_size_of_element(d[i], h[j], m_d, m_h, c);
                pin_element(d[i], h[j], size, sizing_data, pad);
                
            } 
        }
    } 
}

if (show_pin_overhang) {
    pad = [pad_x, pad_y, pad_z];
    
    wall_y= 2;
    wall_z = 2;
    m_d = [1,   0,      1];
    m_h = [0,   2,      0];
    c =   [0,   wall_y, wall_z];
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
    



















































