use <vector_operations.scad>



// Example usage:
//
//
//            module pin_overhang(d, h, pad, sizing_data) {
//
//                // Match up with size of components generated!
//                m_d = sizing_data[0];
//                m_h = sizing_data[1];
//                c = sizing_data[2];
//                
//                sizes = layout_generate_sizes(d, h, m_d, m_h, c); 
//               
//                for (i = [0 : len(d)-1]) {
//                    for (j = [0: len(h)-1]) {
//                        layout_compressed_by_x_then_y(i, j, sizes, pad) {
//                            
//                            size = layout_size_of_element(d[i], h[j], m_d, m_h, c);
//                            pin_element(d[i], h[j], size, sizing_data, pad, i, j);
//                            
//                        } 
//                    }
//                } 
//            }
//
// 
//            if (show_pin_overhang) {
//                pad = [pad_x, pad_y, pad_z];
//                
//                wall_y= 2;
//                wall_z = 2;
//                
//                m_d = [1,   0,      1];
//                m_h = [0,   2,      0];
//                c =   [0,   label_base, wall_z];
//                sizing_data = [m_d, m_h, c, wall_y, label_base];
//                
//                pin_overhang(diameters, overhangs, pad, sizing_data);
//            }
//  

//
//  With current limitation of not being able to pass modules as variables,
//  it is necessary to create a new module for each time the layout function
//  is used, even though there is no additional information provided, other than
//  the actual modules to us.

//  TODO: Create a generic working sample to show its use.




function layout_size_of_element(r_i, s_j, m_r, m_s, c) = 
    [
        //  might be a vector equation r_i * m_r + s_j * m_s + c !
        r_i*m_r.x + s_j*m_s.x + c.x, 
        r_i*m_r.y + s_j*m_s.y + c.y,
        r_i*m_r.z + s_j*m_s.z + c.z
    ];

function layout_generate_sizes(
    outer_loop_values, inner_loop_values, sizing_coefficents) =
    let (
        r = outer_loop_values,
        s = inner_loop_values,
        m_r = sizing_coefficents[0],
        m_s = sizing_coefficents[1],
        c = sizing_coefficents[2]
    )
     
    [ for (i = [0 : len(r)-1]) 
        [ for (j = [0: len(s)-1])
            layout_size_of_element(r[i], s[j], m_r, m_s, c)
        ]
    ];
 

        
function layout_sizing_coefficents(
        x_sizing, // [ dx_by_r, dx_by_s, c_for_x],
        y_sizing, // [ dy_by_r, dy_by_s, c_for_y];
        z_sizing // [ dz_by_r, dz_by_s, c_for_z];
    ) = array_transpose([x_sizing, y_sizing, z_sizing]);
//      Return result is [ m_r, m_s, c] where each is [x, y, z]       
    

module layout_compressed_by_x_then_y(i_t, j_t, sizes, pad) {
    function offset_x(dx_padded) = 
        v_add_scalar(dx_padded, -dx_padded[0]/2);
    
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
    assert(is_num(dx_i_j), str("i=", i_t, " j=", j_t) );
    translate([dx[i_t][j_t], dy[i_t], dz[i_t][j_t]]) children();
} 








