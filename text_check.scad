use <vector_operations.scad>
use <layout_for_3d_printing.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;
infinity = 1000;

/* [Padding] */
pad_x = 8.5; // [-5 : 0.01 : 10]
pad_y = 5; // [-5 : 0.01 : 20]
pad_z = 0; // [[-5 : 0.01 : 10]

/* [Text Checks] */
show_text_check_font_size_by_extrude_height = true;
show_bounding_box = false;

/* [X Tuning] */
dx_by_fs = 6; // [0 : 0.1 : 10]
dx_by_eh = 0; // [0 : 0.1 : 10]
c_for_x = 3;  // [0 : 0.1 : 10]

/* [Y Tuning] */
dy_by_fs = 2; // [0 : 0.1 : 10]
dy_by_eh = 0; // [0 : 0.1 : 10] 
c_for_y = 10; // [0 : 0.1 : 10]

/* [Z Tuning] */
dz_by_fs = 0; // [1 : 0.5 : 10]
dz_by_eh = 2; // [0 : 0.1 : 10]
c_for_z = 4; // [0 : 0.1 : 10]

/* [Font Range] */
min_font_size = 8; // [6 : 12]
delta_font_size = 2; // [1, 2, 3, 4, 5]
max_font_size = 10;  // [6 : 24]
font_sizes = [ each [min_font_size : delta_font_size: max_font_size] ];

/* [Extrusion Range Range] */
min_extrude_height = 1; // [0 : 0.1 : 5]
delta_extrude_height = 1; // [0.1, 0.5, 1, 2]
max_extrude_height = 3; // [0 : 0.1 : 5]
extrude_heights = [ each [min_extrude_height : delta_extrude_height: max_extrude_height] ];
 
module end_of_customization() {}

module echo_3d(label, value, dx, dy, dz=0, orientation=0, thickness = 2) { 
    line = !is_undef(value) ? str(label, value) :  label;
    font_size = 5;
    z = thickness;
    height_of_text = 1.2 * font_size;
    baseline_adjust = -0.5;
    length_of_text = len(line);
    x = length_of_text * font_size *  echo_3d_char_length_adjustment;
    y = height_of_text;
    dy_b = baseline_adjust;
    rz = orientation;
    translate([dx, dy, dz])  {
        rotate([0, 0, rz]) {
            translate([0, 0, z]) linear_extrude(1) text(line, size=font_size);
            translate([0, dy_b, 0]) cube([x, y, z]);
        }
    }
}


module text_check_font_size_by_extrude_height(
    font_sizes, extrude_heights, pad, sizing_coefficents) {
        
    sizes = layout_generate_sizes(
        outer_loop_values=font_sizes, 
        inner_loop_values=extrude_heights,
        sizing_coefficents=sizing_coefficents); 
   
    for (i = [0 : len(font_sizes)-1]) {
        for (j = [0: len(extrude_heights)-1]) {
            line = str("s=", font_sizes[i], " h=", extrude_heights[j]);
            
            layout_compressed_by_x_then_y(i, j, sizes, pad) {
                color("black") linear_extrude(
                    extrude_heights[j])  
                    text(line, 
                    size=font_sizes[i],
                    valign = "center", 
                    halign = "center"
                    );
                
                base_height = 2;
                
                bounding_box = sizes[i][j];
                base_dimension = [bounding_box.x + pad.x, bounding_box.y,  + base_height];

                dz = - base_height / 2;
                
                color("LightSkyBlue", alpha=0.5) 
                translate([0, 0, dz]) 
                cube(base_dimension, center=true); 
                if (show_bounding_box) {
                    echo("bounding_box", bounding_box);
                    color("red", alpha=0.3)  cube(bounding_box, center=true); 
                }
            } 
        }
    } 
}

if (show_text_check_font_size_by_extrude_height) {
    pad = [pad_x, pad_y, pad_z];

    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ dx_by_fs, dx_by_eh, c_for_x],
        y_sizing = [ dy_by_fs, dy_by_eh, c_for_y],
        z_sizing = [ dz_by_fs, dz_by_eh, c_for_z]
    );
    
    text_check_font_size_by_extrude_height(
        font_sizes, extrude_heights, pad, sizing_coefficents);
}

a = [1, 2, 3];

echo("a * a = ", a*a);




















