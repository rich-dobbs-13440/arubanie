include <logging.scad>
include <centerable.scad>
use <vector_operations.scad>
use <not_included_batteries.scad>
use <TOUL.scad>
use <shapes.scad>


/* 
    Provides a reasonably convenient and reuseable layout capability,
    targeted at creating test and calibration fixtures.  But it
    could also be used to produce a number of end use parts driven
    by parameters.
    
    Example usage:
    
        use <layout_for_3d_printing.scad>


        module just_blocks(
            row_values, 
            column_values, 
            pad, 
            sizing_coefficents) {
        
            sizes = layout_generate_sizes(
                row_values, 
                column_values,
                sizing_coefficents);
            
            strategy = [
                COMPRESS_ROWS(), 
                COMPRESS_MAX_COLS(), 
                CONST_OFFSET_FROM_ORIGIN()];
            
            displacements = layout_displacements(
                sizes, 
                pad, 
                strategy);

            for (r_idx = [0 : len(row_values)-1]) {
                for (c_idx = [0: len(column_values)-1]) {
                    translate(displacements[r_idx][c_idx]) {
                        // Make the block transparent, so that overlaps can be seen.
                        color("blue", alpha=0.5) block(sizes[r_idx][c_idx]); 
                    } 
                }
            }
        }

        if (show_this) {
            pad = [0, 0, 0]; 
            sizing_coefficents = layout_sizing_coefficents(
                x_sizing = [ 10, 10, 10],
                y_sizing = [ 10, 10, 20],
                z_sizing = [ 0, 0, 10]
            );
            r = [1, 2, 3, 4];
            s = [1, 2];
            
            just_blocks(r, s, pad, sizing_coefficents);  
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
show_morse_test = true;

/* [Logging] */

log_verbosity_choice = "WARN"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);    

module end_of_customization() {}

show_name = false;
if (show_name) {
    linear_extrude(2) text("layout_for_3d_printing.scad", halign="center");
}

// ----------- Testing ------------------------------------------------
    
module just_blocks(row_values, column_values, pad, sizing_coefficents) {
    sizes = layout_generate_sizes(
        row_values, 
        column_values,
        sizing_coefficents);
    
    strategy = [
        COMPRESS_ROWS(), 
        COMPRESS_MAX_COLS(), 
        CONST_OFFSET_FROM_ORIGIN()];
    
    displacements = layout_displacements(sizes, pad, strategy);

    for (r_idx = [0 : len(row_values)-1]) {
        for (c_idx = [0: len(column_values)-1]) {
            translate(displacements[r_idx][c_idx]) {
                // Make the block transparent, so that overlaps can be seen.
                color("blue", alpha=0.5) block(sizes[r_idx][c_idx]); 
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

* echo("concat", concat([0], [1, 2, 3]));

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
    just_blocks(r, s, pad, sizing_coefficents);  
}



if (show_morse_test) {
    morse_test();
}

module morse_test() {
    // Character tests
    locate(0) number_to_morse_shape(number="0", size=2, base=true);
    locate(1) number_to_morse_shape(number=1, size=2, base=true);
    locate(2) number_to_morse_shape(number=2, size=2, base=true);
    locate(3) number_to_morse_shape(number=3, size=2, base=true);
    locate(4) number_to_morse_shape(number=4, size=2, base=true);
    locate(5) number_to_morse_shape(number=5, size=2, base=true);
    locate(6) number_to_morse_shape(number=6, size=2, base=true);
    locate(7) number_to_morse_shape(number=7, size=2, base=true);
    locate(8) number_to_morse_shape(number=8, size=2, base=true);
    locate(9) number_to_morse_shape(number=9, size=2, base=true);    
    locate(10) number_to_morse_shape(number=".", size=2, base=true); 
    locate(11) number_to_morse_shape(number="-", size=2, base=true); 
    locate(12) number_to_morse_shape(number=" ", size=2, base=true); // Any non digit just shows base
    
    locate(20) number_to_morse_shape(number=0, size=2, base=true);
    locate(21)  number_to_morse_shape(number=1, size=2, base=true);
    locate(22)  number_to_morse_shape(number=2.1, size=2, base=true);
    locate(23)  number_to_morse_shape(number=0.5, size=2, base=true);
    locate(24)  number_to_morse_shape(number=-5, size=2, base=true); 
    
 
  
    locate(30) number_to_morse_shape(number=1, size=2, base=0);
    locate(31) number_to_morse_shape(number=1, size=2, base=1);
    locate(32) number_to_morse_shape(number=2, size=2, base=2);
    locate(33) number_to_morse_shape(number=3, size=2, base=4);
   
    min_x_in_mm = 4;
    min_y_in_chars = 5;
    z_in_mm = 10;
    locate(40) number_to_morse_shape(number="0", size=2, base=[min_x_in_mm, min_y_in_chars, z_in_mm]);
    
    test();
    module test() {
        label_size = 2;
        min_x_in_mm = 0;
        min_y_in_chars = 0;
        z_in_mm = 4;
        locate(50) number_to_morse_shape(
            ".", size=label_size, base=[min_x_in_mm, min_y_in_chars, z_in_mm]);  
    }
    
    module locate(pos) {
        dx = 4;
        translate([pos*dx, 0, 0]) children();
    }
}

// --------------------------------- Start of implemention ----------------------------

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
            
    
function _max_sizes(sizes_for_axis) = 
    [ for (row = sizes_for_axis) max(row) ]; 
    
    function _displace_elements_individually(
    sizes_for_axis, pad_for_axis, center_for_axis=[false, false, true]) = 
    let(
        relative_position = center_for_axis ? 0 : 0.5
    )
    a2_add_scalar(
        v_mul_scalar(sizes_for_axis, relative_position), 
        pad_for_axis);
  
         
function _disp_rc_compress_row(axis, sizes_for_axis, pad_for_axis) =
    
    let (

           
        result = 
            [ for (row = sizes_for_axis)
                let (
                    padded_sizes = v_add_scalar(row, pad_for_axis),
                    edges = concat([0], v_cumsum(padded_sizes)),
                    centers = [ for (i = [0 : len(edges)-2]) (edges[i] + edges[i+1])/2 ],
                        
                    dmy_2 = log_v1("edges", edges, verbosity, DEBUG),
                    dmy_3 = log_v1("centers", centers, verbosity, DEBUG),
                    last = 1
                )
                centers     
            ],
                    
        dmy_1 = log_s("axis", axis, verbosity), 
        dmy_2 = log_v1("sizes_for_axis", sizes_for_axis, verbosity), 
        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity),
        dmy_65 = log_v1("_disp_rc_compress_row result", result, verbosity)
    )    
    result;
            
function _disp_rc_compress_max_cols(axis, sizes_for_axis, pad_for_axis) =
    let (
        padded_sizes = a2_add_scalar(sizes_for_axis, pad_for_axis),
        max_by_row = [ for (row = padded_sizes) max(row) ],
        edges = concat([0], v_cumsum(max_by_row)), 
        centers = [ for (i = [0 : len(edges)-2]) (edges[i+1] + edges[i])/2 ],
        
        result = [ for (ri = [0 : len(sizes_for_axis)-1])
                      [ for (ci = [0 : len(sizes_for_axis[0])-1]) centers[ri] ]
                 ],
           
        dmy_0 = log_s("In Module: ", 
                      "In _disp_rc_compress_max_cols", 
                      verbosity, INFO),
                      
//        dmy_1 = log_s("axis",   axis, verbosity, INFO), 
//        dmy_2 = log_v1("sizes_for_axis", sizes_for_axis, verbosity),
//        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity),
//        dmy_4 = log_v1("padded_sizes", padded_sizes, verbosity),        
//        dmy_5 = log_v1("max_by_row", max_by_row, verbosity, INFO, IMPORTANT), 
//        dmy_7 = log_v1("edges", edges, verbosity, INFO, IMPORTANT),
//        dmy_8 = log_v1("centers", centers, verbosity, INFO, IMPORTANT),
                
//        dmy_3 = log_s("pad_for_axis", pad_for_axis, verbosity),
//        ,
//        dmy_6 = log_v1("disp_by_row", disp_by_row, verbosity),
//        dmy_4 = log_v1("max_col_by_row", max_col_by_row, verbosity), 
                      
        dmy_12 = log_v1("_disp_rc_compress_max_cols - result", result, verbosity, INFO),
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
        dmy_ld = log_s("In function: ", "layout_displacements", verbosity, INFO),
        args = str(" sizes: ", sizes, " pad: ", pad, " strategy: ", strategy_by_axis),
        dmy_args = log_s("args", args, verbosity, DEBUG),
        
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
                
         dmy_result = log_v1("layout_displacements result", result, verbosity),
         dmy_lv = log_s("Leaving function: ", "layout_displacements", verbosity, INFO)       
    )
    result;




module number_to_morse_shape(number, size, base=true) {
    shape_width = is_num(size) ? size : size[0];
    shape_height = is_num(size) ? 1 : size[1];
    shape_spacing = is_num(size) ? 1 : size[2];
    number_str = is_string(number) ? number : condensed_num_to_str(number);
    
    function condensed_num_to_str(number) = 
        (number == 0) ? " 0" :
        ((number > 0) && (number < 1)) ? substr(str(number), 1) :  // Trim off leading zero,
        str(number);

    morse = [
        ["1", "●▌▌▌▌"],
        ["2", "●●▌▌▌"],
        ["3", "●●●▌▌"],
        ["4", "●●●●▌"],
        ["5", "●●●●●"],
        ["6", "▌●●●●"],
        ["7", "▌▌●●●"],
        ["8", "▌▌▌●●"],
        ["9", "▌▌▌▌●"],
        ["0", "    ▌"],
        [".", "    ●"],
        ["-", "█████   "],
    ];
    
    

    base_for_shape(len(number_str), base);
     
    
    for (i = [0:len(number_str)-1]) {
        code = find_in_dct(morse, number_str[i]);
        //echo("code", code);
        if (!is_undef(code)) {
            for (j = [0:len(code)-1]) {
                locate(i, j) morse_shape(code[j]);
            }
        }
    }


    module morse_shape(character) {
        if (character == "●") {
            can(d=shape_width, h=shape_height, center=ABOVE);
        } else if (character == "▌") {
            block([shape_width, shape_width, shape_height], center=ABOVE);   
        } else if (character == "█") {
            block([shape_width, shape_width+shape_spacing, shape_height], center=ABOVE); 
        }
    }
    
    function position_in_mm(i, j) = let( cell = (i)*6 + j + 2) cell * (shape_width + shape_spacing);
    
    module locate(i, j) {
        t = [0, position_in_mm(i, j), 0];
        translate(t) children();
    }
    
    module base_for_shape(char_count, base) {
        if (is_bool(base) && !base) {
            // No base
        } else {
            min_x_in_mm = is_list(base) ? base.x : shape_width;
            min_y_in_chars = is_list(base) ? base.y: 0;
            z_in_mm = 
                is_list(base) ? base.z : 
                is_num(base) ? base :
                shape_height ; 

            x_in_mm = max(min_x_in_mm, shape_width);
            chars = max(min_y_in_chars, char_count);
            y_in_mm = position_in_mm(chars, 0);
            block([x_in_mm, y_in_mm, z_in_mm], center=BELOW+RIGHT);
        }
    }
    
}