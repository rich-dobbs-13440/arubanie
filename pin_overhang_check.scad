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

pad_x = 5; // [-5 : 0.01 : 10]
pad_y = 13; // [-5 : 0.01 : 20]
pad_z = 3; // [[-5 : 0.01 : 10]

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

module wall(size, pad, sizing_data) {
    wall_y = sizing_data[3];
    //color("blue", alpha=0.7) 
        translate([0, -wall_y/2, 0]) 
            cube([size.x+pad.x, wall_y, size.z], center=true); 
}


module label_base(size, pad, sizing_data) {
    thickness = 2;
    length = sizing_data[4];

    y = sizing_data[4];
    dy = -y/2;   
    dz = -size.z/2 + thickness/2;
    color("blue", alpha=0.7) 
        translate([0, dy, dz]) 
            cube([size.x+pad.x, y, thickness], center=true);   
}


module pin_label(d, h, size, sizing_data, is_first)  {
   
    wall_y = sizing_data[3];
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

        
module pin_element(d, h, size, sizing_data, pad, i, j) {
    // Need the i and j value to a row label
    * echo("In pin_element ==============================================");
    * echo("d", d);
    * echo("h", h);
    * echo("size", size);
    * echo("sizing_data", sizing_data);
    * echo("pad", pad);
    
    pin(d=d, h=h, center=false);
    wall(size, pad, sizing_data);
    
    is_first = (j == 0); 
    pin_label(d, h, size, sizing_data, is_first);
    
    label_base(size, pad, sizing_data);
    

    // Draw bounding box for debug purpose
    * color("red", alpha=0.3)  cube(size, center=true); 
    * echo("In pin_element ==============================================");
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



    



















































