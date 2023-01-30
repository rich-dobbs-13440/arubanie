use <not_included_batteries.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Pin Overhang] */
show_pin_overhang = true;

min_overhang = 1; // [ 1 : 0.25 : 5]
delta_overhang = 0.25; // [0.25, 0.50, 1]
max_overhang = 3; // [ 1 : 0.25 : 5]

minimum_diameter = 3; // [1 : 1 : 10]
maximum_diameter = 7; // [1 : 1 : 10]
delta_diameter = 1; // [0.25, 0.50, 1, 2, 3, 4]

/* [X Layout Tuning] */
// vi is h, vj is d
dx_by_vi = 6; // [0 : 0.1 : 10]
dx_by_vj = 0; // [0 : 0.1 : 10]
x_c = 3;  // [0 : 0.1 : 10]
x_pad = 5; // [-5 : 0.01 : 10]

/* [Y Layout Tuning] */
// vi is h, vj is d
dy_by_vi = 2; // [0 : 0.1 : 10]
dy_by_vj = 0; // [0 : 0.1 : 10] 
y_c = 10; // [0 : 0.1 : 10]
y_pad = 13; // [-5 : 0.01 : 20]

/* [Z Layout Tuning] */
// vi is h, vj is d
dz_by_vi = 0; // [1 : 0.5 : 10]
dz_by_vj = 2; // [0 : 0.1 : 10]
z_c = 4; // [0 : 0.1 : 10]
z_pad = 3; // [[-5 : 0.01 : 10]

/* [Label] */

// x is currently ignored
x_label_base = -34;
y_label_base = 20; // [0:40]
z_label_base = 2; // [1:4]

/* [Element Data] */

wall_y = 2;

label_base_x = 25; // [10:30]
label_base_y = 15; // [1:40]

overhangs = [ each [min_overhang : delta_overhang: max_overhang] ];

diameters = [ each [minimum_diameter : delta_diameter : maximum_diameter ] ];


/* [Echo 3D] */

echo_3d_char_length_adjustment = 1; // [0 : 0.01 : 2]


* echo("overhangs", overhangs);
h_count = len(overhangs);
* echo("h_count", h_count);

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

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];


module pin(d, h, center=true, v=Y_ORIENTATION) {
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
} 

module wall(size, pad, element_parameters) {
    wall_y = find_in_dct(element_parameters, "wall_y");
    assert(!is_undef(wall_y));
    //color("blue", alpha=0.7) 
        translate([0, -wall_y/2, 0]) 
            cube([size.x+pad.x, wall_y, size.z], center=true); 
}


module label_base(size, pad, element_parameters) {
    
//    length = find_in_dct(element_parameters, "label_base_x", required=true);
//    y = find_in_dct(element_parameters, "label_base_y", required=true);
    size_label_base = find_in_dct(element_parameters, "size_label_base", required=true);
    dy = -size_label_base.y/2; // Below = 0
    dz = -size.z/2 + size_label_base.z/2; // On floor of bounding box
    connect_on_x = true; // Should be in element parameters
    //connect_on_y = false;
    x = size.x + (connect_on_x ? pad.x : 0);
    y = size_label_base.y;
    z = size_label_base.x;
    color("blue", alpha=0.7) 
        translate([0, dy, dz]) 
            cube([x, y, z], center=true);   
}


module pin_label(d, h, size, element_parameters, is_first)  {
   
    wall_y = find_in_dct(element_parameters, "wall_y");
    dx = -2.3;
    dy = -wall_y ;
    dz = -size.z/2;
   
    translate([dx, dy, dz]) {
        if (is_first) {
            text = str(" ", h, "  d=", d);   
            echo_3d(text, undef, 0, 0, orientation=-90);
        } else {    
            echo_3d(" ", h, 0, 0, orientation=-90);
        }
        
    }
 
}

        
module pin_element(d, h, size, element_parameters, pad, i, j) {
    // Need the i and j value to a row label
    * echo("In pin_element ==============================================");
    * echo("d", d);
    * echo("h", h);
    * echo("size", size);
    * echo("element_parameters", element_parameters);
    * echo("pad", pad);
    
    pin(d=d, h=h, center=false);
    wall(size, pad, element_parameters);
    
    is_first = (j == 0); 
    pin_label(d, h, size, element_parameters, is_first);
    
    label_base(size, pad, element_parameters);
    

    // Draw bounding box for debug purpose
    * color("red", alpha=0.3)  cube(size, center=true); 
    * echo("In pin_element ==============================================");
}

module pin_overhang(
        pin_diameters, 
        pin_overhangs, 
        pad, 
        sizing_coefficents, 
        element_parameters) {

    sizes = layout_generate_sizes(
        row_values=pin_diameters, 
        column_values=pin_overhangs,
        sizing_coefficents=sizing_coefficents);
    
    strategy = [
        COMPRESS_ROWS(), 
        COMPRESS_MAX_COLS(), 
        CONST_OFFSET_FROM_ORIGIN()];
    
    displacements = layout_displacements(
        sizes, 
        pad, 
        strategy);
    
    for (row = [0 : len(pin_diameters)-1]) {
        for (col = [0: len(pin_overhangs)-1]) {
            translate(displacements[row][col]) {
                
                pin_element(
                    pin_diameters[row], 
                    pin_overhangs[col], 
                    sizes[row][col], 
                    element_parameters, 
                    pad, 
                    row, 
                    col);
                
            } 
        }
    } 
}

if (show_pin_overhang) {
    pad = [x_pad, y_pad, z_pad];
    
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ dx_by_vi, dx_by_vj, x_c],
        y_sizing = [ dy_by_vi, dy_by_vj, y_c],
        z_sizing = [ dz_by_vi, dz_by_vj, z_c]
    );

    element_parameters = [
        ["wall_y", wall_y],
        ["size_label_base", [x_label_base, y_label_base, z_label_base]],
    ];

    pin_overhang(diameters, overhangs, pad, sizing_coefficents, element_parameters);
}



    



















































