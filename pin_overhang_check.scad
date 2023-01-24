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
max_overhang = 3; // [ 1 : 0.5 : 5]
delta_overhang = 0.25; // [0.25, 0.50, 1]

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

/* [Expected to be constants] */

wall_y = 2;

label_base = 25; //[10:30]


overhangs = [ each [1 : delta_overhang: max_overhang] ];

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

module wall(size, pad, element_dct) {
    wall_y = find_in_dct(element_dct, "wall_y");
    assert(!is_undef(wall_y));
    //color("blue", alpha=0.7) 
        translate([0, -wall_y/2, 0]) 
            cube([size.x+pad.x, wall_y, size.z], center=true); 
}


module label_base(size, pad, element_dct) {
    thickness = 2;
    length = find_in_dct(element_dct, "label_base_length", required=true);

    y = sizing_data[4];
    dy = -y/2;   
    dz = -size.z/2 + thickness/2;
    color("blue", alpha=0.7) 
        translate([0, dy, dz]) 
            cube([size.x+pad.x, y, thickness], center=true);   
}


module pin_label(d, h, size, element_dct, is_first)  {
   
    wall_y = find_in_dct(element_dct, "wall_y");
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

        
module pin_element(d, h, size, element_dct, pad, i, j) {
    // Need the i and j value to a row label
    * echo("In pin_element ==============================================");
    * echo("d", d);
    * echo("h", h);
    * echo("size", size);
    * echo("element_dct", element_dct);
    * echo("pad", pad);
    
    pin(d=d, h=h, center=false);
    wall(size, pad, element_dct);
    
    is_first = (j == 0); 
    pin_label(d, h, size, element_dct, is_first);
    
    label_base(size, pad, element_dct);
    

    // Draw bounding box for debug purpose
    * color("red", alpha=0.3)  cube(size, center=true); 
    * echo("In pin_element ==============================================");
}

module pin_overhang(d, h, pad, sizing_coefficents, element_dct) {

    sizes = layout_generate_sizes(
        outer_loop_values=d, 
        inner_loop_values=h,
        sizing_coefficents=sizing_coefficents);
    
    for (i = [0 : len(d)-1]) {
        for (j = [0: len(h)-1]) {
            layout_compressed_by_x_then_y(i, j, sizes, pad) {
                
                pin_element(d[i], h[j], sizes[i][j], element_dct, pad, i, j);
                
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

    element_dct = [["wall_y", wall_y]];
//    echo(element_dct);
//    echo(find_in_dct(element_dct, "wall_y"));

    
    pin_overhang(diameters, overhangs, pad, sizing_coefficents, element_dct);
}



    



















































