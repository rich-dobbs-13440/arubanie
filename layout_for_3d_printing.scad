use <vector_operations.scad>
use <not_included_batteries.scad>
include <logging.scad>


/* 
    Provides a reasonably convenient and reuseable layout capability,
    targeted at creating test and calibration fixtures.  But it
    could also be used to produce a number of end use parts driven
    by parameters.
    
    Example usage:
    
        use <layout_for_3d_printing.scad>


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
                        pin_element(d[i], h[j], size, sizing_data, pad, i, j);
                        
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
            c =   [0,   label_base, wall_z];
            sizing_data = [m_d, m_h, c, wall_y, label_base];
            
            pin_overhang(diameters, overhangs, pad, sizing_data);
        }
  
        Unless specified otherwise, each element should be build
        symmetrically to the origin for x and y axises, 
        and with bottom that is parallel to the x-y plane.
        
        

  With current limitation of not being able to pass modules as variables,
  it is necessary to create a new module for each time the layout function
  is used, even though there is no additional information provided, other than
  the actual modules to us.
  
*/  

//  TODO: Create a generic working sample to show its use.

/* [Show Tests] */

show_visual_test_for_zero_padding = false;
show_visual_test_for_small_padding = false;
show_visual_variable_size_blocks = true;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);    

module end_of_customization() {}

X = 0;
Y = 1;
Z = 2;

function COMPRESS_ROWS() = "STRATEGY: COMPRESS_ROWS";
function COMPRESS_MAX_COLS() = "STRATEGY: COMPRESS_MAX_COLS";
function CONST_OFFSET_FROM_ORIGIN() = "STRATEGY: CONST_OFFSET";

function _layout_size_of_element(r_i, s_j, m_r, m_s, c) = 
    [
        r_i*m_r.x + s_j*m_s.x + c.x, 
        r_i*m_r.y + s_j*m_s.y + c.y,
        r_i*m_r.z + s_j*m_s.z + c.z
    ];

function layout_generate_sizes(row_values, column_values, sizing_coefficents) =
    let (
        m_r = sizing_coefficents[0],
        m_s = sizing_coefficents[1],
        c = sizing_coefficents[2],
        result = 
            [ for (row_value = row_values) 
                [ for (column_value = column_values)
                    _layout_size_of_element(row_value, column_value, m_r, m_s, c)
                ]
            ],
        dmy_1 = log_v1("layout_generate_sizes", result, verbosity)
    )
    result;
 

        
function layout_sizing_coefficents(
        x_sizing, // [ dx_by_r, dx_by_s, c_for_x],
        y_sizing, // [ dy_by_r, dy_by_s, c_for_y];
        z_sizing // [ dz_by_r, dz_by_s, c_for_z];
    ) = array_transpose([x_sizing, y_sizing, z_sizing]);
//      Return result is [ m_r, m_s, c] where each is [x, y, z]       
 
function _sizes_by_axis(sizes) = 
    [ for (axis_index = [0 : 2]) // x, y, z
        [ for (row = sizes) 
            [ for (col =  row) col[axis_index] ]
        ]
    ];
            
function _offset_for_first_element(stacked_displacement) = 
            stacked_displacement;
        //v_add_scalar(stacked_displacement, -stacked_displacement[0]);
            
function _displace_elements_by_stacking(
            sizes_for_axis, pad_for_axis, center_for_axis) = 
    // Note: center_for_axis ignored but it is to make function argument list common!
    let (
        result = 
            [ for (row = sizes_for_axis) 
                _offset_for_first_element(
                    v_cumsum(
                        v_add_scalar(row, pad_for_axis))
                ) 
            ],
        dummy = log_v1("_displace_elements_by_stacking", result, INFO, IMPORTANT)
    )
    assert(is_num(sizes_for_axis[0][0]), "Internal error") 
    result;

    
function _max_sizes(sizes_for_axis) = 
    [ for (row = sizes_for_axis) max(row) ]; 
    
function _displace_elements_by_stacking_after_max(
        sizes_for_axis, pad_for_axis, center_for_axis) =
    // Note: center_for_axis ignored but it is to make function argument list common!
    let (
        max_sizes_by_row = _max_sizes(sizes_for_axis),
        padded_sizes = v_add_scalar(max_sizes_by_row, pad_for_axis),
        cumulative_sizes_by_row = v_cumsum(padded_sizes),
        disp_by_row = _offset_for_first_element(cumulative_sizes_by_row) 
    )
    echo("sizes_for_axis", sizes_for_axis)
    echo("padded_sizes", padded_sizes)
    echo("cumulative_sizes", cumulative_sizes_by_row)
    [ for (ir = [0 : 1: len(sizes_for_axis)-1])
        [ for (col = sizes_for_axis[ir]) 
            disp_by_row[ir]
        ]
    ];
    // Same displayment along the row, patch so first row is centered on origin.
    
//    [ for (cumulative_size = cumulative_sizes) 
//        cumulative_size - cumulative_sizes[0]/2
//    ];
    
    
function _displace_elements_individually(
    sizes_for_axis, pad_for_axis, center_for_axis=[false, false, true]) = 
    let(
        relative_position = center_for_axis ? 0 : 0.5
    )
    a2_add_scalar(
        v_mul_scalar(sizes_for_axis, relative_position), 
        pad_for_axis);
  
function _displacement_by_axis(
    axis, sizes_for_axis, pad_for_axis, center_for_axis) =
    
    let (
        sizes_a = sizes_for_axis,
        pad_a = pad_for_axis,
        center_a = center_for_axis
    )
    
    // Hard coded at this time with strategy:
    axis == 0 ? 
        _displace_elements_by_stacking(sizes_a, pad_a, center_a) :
    axis == 1 ? 
        _displace_elements_by_stacking_after_max(sizes_a, pad_a, center_a) :
    axis == 2 ? 
        _displace_elements_individually(sizes_a, pad_a, center_a) :
       
    assert(false, "Internal error");  
  
function _displacement_by_rc(d_by_axis) =

    echo("d_by_axis", d_by_axis)

    let ( 
        row_count = len(d_by_axis[0]),
        col_count = len(d_by_axis[0][0]),
        X = 0,
        Y = 1,
        Z = 2
    ) 
    [ for (ri = [0, row_count-1])
        [for (ci = [0: col_count-1])
              [d_by_axis[X][ri][ci], d_by_axis[Y][ri][ci],  d_by_axis[Y][ri][ci]]
        ]
    ];
   
   

     
function _displacement_by_axis_row_col(sizes_by_axis, pad, center) =
    
    assert(
        len(sizes_by_axis) == 3, 
        str(
            "Internal error. Expecting len(sizes_by_axis) == 3, but had ", 
            len(sizes_by_axis)
        )
    )
    echo("sizes_by_axis", sizes_by_axis) 
    let ( 
        X = 0,
        Y = 1,
        Z = 2,
        result = 
            [ for (axis = [X, Y, Z]) 
                _displacement_by_axis(
                    axis, 
                    sizes_by_axis[axis], 
                    pad[axis],
                    center[axis])
            ]
        
     )
     result;
            
function _disp_rc_compress_row(axis, sizes_for_axis, pad_for_axis) =
    
    let (

           
        result = 
            [ for (row = sizes_for_axis)
                let (
                    padded_sizes = v_add_scalar(row, pad_for_axis),
                    edges = concat([0], v_cumsum(padded_sizes)),
                    centers = [ for (i = [0 : len(edges)-2]) (edges[i] + edges[i+1])/2 ],
                        
                    dmy_2 = log_v1("edges", edges, verbosity, DEBUG, IMPORTANT),
                    dmy_3 = log_v1("centers", centers, verbosity, DEBUG, IMPORTANT),
                    last = 1
                )
                centers     
            ],
                    
        dmy_1 = log_s("axis", axis, verbosity, DEBUG), 
        dmy_2 = log_v1("sizes_for_axis", sizes_for_axis, verbosity, DEBUG, IMPORTANT), 
        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity, DEBUG),
        dmy_65 = log_v1("_disp_rc_compress_row result", result, verbosity, DEBUG)
    )    
    result;
            
function _disp_rc_compress_max_cols(axis, sizes_for_axis, pad_for_axis) =
    let (
        padded_sizes = a2_add_scalar(sizes_for_axis, pad_for_axis),
        max_by_row = [ for (row = padded_sizes) max(row) ],
//            [ for (ci = [0 : len(sizes_for_axis[0])-1])
//                 max([ for (ri = [0 : len(sizes_for_axis)-1]) padded_sizes[ri][ci] ]) 
//            ],
        edges = concat([0], v_cumsum(max_by_row)), 
        centers = [ for (i = [0 : len(edges)-2]) (edges[i+1] + edges[i])/2 ],
        
        result = [ for (ri = [0 : len(sizes_for_axis)-1])
                      [ for (ci = [0 : len(sizes_for_axis[0])-1]) centers[ri] ]
                 ],
           
        dmy_0 = log_s("In Module: ", "In _disp_rc_compress_max_cols", verbosity, INFO, IMPORTANT),     
        dmy_1 = log_s("axis",   axis, verbosity, INFO), 
        dmy_2 = log_v1("sizes_for_axis", sizes_for_axis, verbosity),
        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity),
        dmy_4 = log_v1("padded_sizes", padded_sizes, verbosity),        
        dmy_5 = log_v1("max_by_row", max_by_row, verbosity, INFO, IMPORTANT), 
        dmy_7 = log_v1("edges", edges, verbosity, INFO, IMPORTANT),
        dmy_8 = log_v1("centers", centers, verbosity, INFO, IMPORTANT),
                
//        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity),
//        ,
//        dmy_6 = log_v1("disp_by_row", disp_by_row, verbosity),
//        dmy_4 = log_v1("max_col_by_row", max_col_by_row, verbosity), 
        dmy_12 = log_v1("_disp_rc_compress_max_cols - result", result, verbosity),
        last = 1
                
    )
    result;

            
          
function _disp_rc_element_base_level(axis, sizes, pad_for_axis) =
    [ for (row = sizes) 
        [ for (col = row)
            pad_for_axis
        ] 
    ];
           
function _disp_rc(strategy_for_axis, axis, sizes, pad) = 
    let (
        sizes_by_axis = _sizes_by_axis(sizes),
        sizes_a = sizes_by_axis[axis],
        pad_a = pad[axis],
        result = 
            strategy_for_axis == COMPRESS_ROWS() ? 
                _disp_rc_compress_row(axis, sizes_a, pad_a) : 
            strategy_for_axis == COMPRESS_MAX_COLS() ? 
                _disp_rc_compress_max_cols(axis, sizes_a, pad_a) : 
            strategy_for_axis == CONST_OFFSET_FROM_ORIGIN() ? 
                _disp_rc_element_base_level(axis, sizes_a, pad_a) : 
                assert(
                    false, 
                    strcat("The strategy ", strategy_for_axis," is not handled.")),
        context = str(
            " strategy_for_axis: ", strategy_for_axis, 
            " axis: ", axis, 
            " sizes_a: ", sizes_a, 
            " pad_a: ", pad_a,
            " result: ", result),
            
        dmy_2 = log_s("_disp_rc axis", axis, verbosity, INFO),    
        dmy_1 = log_v1("_disp_rc result", result, verbosity, INFO)
        
        
    )
    assert(
        is_list(result), 
        str("Internal error: Result must be a list", context))
    assert(
        is_list(result[0]), 
        str( "Internal error: Result must be a list of lists ", context))
    assert(
        is_num(result[0][0]), 
        str("Internal error: Result must be a list of lists...................", context))
    assert(
        len(result) == len(sizes), 
        str("Internal error: Row mismatch: ", 
            " got: ", len(result),
            " expected: ", len(sizes),
           context))  
    assert(
        len(result[0]) == len(sizes[0]), 
        str("Internal error: Column count mismatch:  ", 
            " got: ", len(result[0]), 
            " expected: ", len(sizes[0]),
            context))    
    result;
        
           
function layout_displacements(sizes, pad, strategy_by_axis) = 
    assert(len(strategy_by_axis) == 3, "Each axis must have a layout strategy!")
    let (
        dmy_ld = log_s("In Module: ", "In layout_displacements", verbosity, INFO),
        args = str(" sizes: ", sizes, " pad: ", pad, " strategy: ", strategy_by_axis),
        dmy_args = log_s("args", args, verbosity, INFO),
        
        row_count = len(sizes),
        col_count = len(sizes[0]),
        x_disp_rc = _disp_rc(strategy_by_axis[X], X, sizes, pad),
        y_disp_rc = _disp_rc(strategy_by_axis[Y], Y, sizes, pad),
        z_disp_rc = _disp_rc(strategy_by_axis[Z], Z, sizes, pad),
        context = str(
            " x_disp_rc: ", x_disp_rc, 
            " y_disp_rc: ", y_disp_rc, 
            " z_disp_rc: ", z_disp_rc, 
            " args: ", args),  
        result = 
            [ for (ri = [0 : row_count-1])
                [ for (ci = [0 : col_count-1])
                   assert(is_num(y_disp_rc[ri][ci]), "context")
                   assert(is_num(y_disp_rc[ri][ci]), "context")
                   assert(is_num(z_disp_rc[ri][ci]), "context")
                   [ x_disp_rc[ri][ci], y_disp_rc[ri][ci], z_disp_rc[ri][ci] ]
                ]
            ],
                
         dmy_result = log_v1("result", result, verbosity, IMPORTANT)       
    )
    
    result;
    
function layout_displacements_compressed_by_x_then_y(
    sizes, pad, center=[true, true, true]) = 
        
    let (
        sizes_by_axis =_sizes_by_axis(sizes),

        displacements = _displacement_by_rc(
            _displacement_by_axis_row_col (
                sizes_by_axis, pad, center
            ) 
        ),
        dummy = log_v1("_displacement_by_rc", displacements, INFO, IMPORTANT)
    )
    assert(len(displacements) == len(sizes), "Internal Error")
    displacements ;
    
    
    
    
    
    
module just_blocks_noveau(row_values, column_values, pad, sizing_coefficents) {
    sizes = layout_generate_sizes(
        row_values, 
        column_values,
        sizing_coefficents);
    
    strategy = [
        COMPRESS_ROWS(), 
        COMPRESS_MAX_COLS(), 
        CONST_OFFSET_FROM_ORIGIN()];
    displacements = layout_displacements(sizes, pad, strategy);
//    log_v1("displacements", displacements, INFO, IMPORTANT);
//
    for (r_idx = [0 : len(row_values)-1]) {
        for (c_idx = [0: len(column_values)-1]) {
            disp = displacements[r_idx][c_idx];
            translate([disp.x, disp.y, disp.z]) {
                // Make the block transparent, so that overlaps can be seen.
                color("blue", alpha=0.5) block(sizes[r_idx][c_idx]); 
            } 
        }
    }
}
    
        
module layout_compressed_by_x_then_y(
    i_t, j_t, sizes, pad, is_build_plate_on_bottom = false) {

    // Break down the size elements by the x, y, and z components
    // sizes is structured to be indexed as [i][j][axis]
    // but for layout calculations we need [axis][i][j]
    sizes_by_axis = _sizes_by_axis(sizes); 
    dx = _displace_elements_by_stacking(sizes_by_axis.x, pad.x);
    echo("dx", dx);
    dy =  _displace_elements_by_stacking_after_max(sizes_by_axis.y, pad.y, false);
    echo("dy", dy);
    // If the elements are constructed to have build plate parallel,
    // then the z axis is not translated
    //relative_location_z = is_build_plate_on_bottom ? 0.5 : 0;
    dz = _displace_elements_individually(
        sizes_by_axis.z, pad.z, !is_build_plate_on_bottom);
    echo("dz", dz);
    //echo("relative_location_z", relative_location_z);
//    echo("v_mul_scalar(sizes_for_axis, relative_location)", 
//        v_mul_scalar(sizes_by_axis.z, relative_location_z));    

    
    dx_i_j = dx[i_t][j_t];
    assert(is_num(dx_i_j), str("i=", i_t, " j=", j_t) );
    translate([dx[i_t][j_t], dy[i_t][j_t], dz[i_t][j_t]]) children();
} 

module just_blocks(row_values, column_values, pad, sizing_coefficents) {

    sizes = layout_generate_sizes(
        row_values=row_values, 
        column_values=column_values,
        sizing_coefficents=sizing_coefficents);
    
    for (r_idx = [0 : len(row_values)-1]) {
        for (c_idx = [0: len(column_values)-1]) {
            layout_compressed_by_x_then_y(r_idx, c_idx, sizes, pad) {
                // Make the block transparent, so that overlaps can be seen.
                color("red", alpha=0.5) block(sizes[r_idx][c_idx]); 
            } 
        }
    }
}

if (show_visual_test_for_zero_padding) {
    pad = [0, 0, 0]; 
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ 0, 0, 10],
        y_sizing = [ 0, 0, 10],
        z_sizing = [ 0, 0, 1]
    );
    r = [1, 2, 3];
    s = [1, 2];
    // Run the test
    just_blocks(r, s, pad, sizing_coefficents); 
}

if (show_visual_test_for_small_padding) {
    pad = [1, 2, 3]; 
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ 0, 0, 10],
        y_sizing = [ 0, 0, 10],
        z_sizing = [ 0, 0, 1]
    );
    r = [1, 2, 3];
    s = [1, 2];
    // Run the test
    just_blocks(r, s, pad, sizing_coefficents);  
}

echo("concat", concat([0], [1, 2, 3]));

if (show_visual_variable_size_blocks) {
    pad = [0, 0, 0]; 
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ 10, 10, 10],
        y_sizing = [ 10, 10, 20],
        z_sizing = [ 0, 0, 10]
    );
    r = [1, 2, 3, 4];
    s = [1, 2];
    // Run the test
    * just_blocks(r, s, pad, sizing_coefficents);  
    
    just_blocks_noveau(r, s, pad, sizing_coefficents);
}




