include <not_included_batteries.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Pin Bridge] */
show_pin_bridge = true;
show_bounding_box = false;

min_bridge = 8; // [ 1 : 1 : 20]
delta_bridge = 1; // [1, 2]
max_bridge =  10; // [ 1 : 1 : 20]
bridges = [ each [min_bridge : delta_bridge: max_bridge] ];

minimum_diameter = 1; // [1 : 1 : 10]
delta_diameter = 2; // [0.25, 0.50, 1, 2, 3, 4]
maximum_diameter = 5; // [1 : 1 : 10]
diameters = [ each [minimum_diameter : delta_diameter : maximum_diameter ] ];

/* [Element Data] */
wall_y = 2;


/* [X Layout Tuning] */
// vi is d, vj is b
dx_by_vi = 0; // [0 : 0.1 : 10]
dx_by_vj = 1; // [0 : 0.1 : 10]
x_c = 4;  // [-20 : 0.1 : 10]
x_pad = 0; // [-5 : 0.01 : 10]

/* [Y Layout Tuning] */
// vi is d, vj is b
dy_by_vi = 1; // [0 : 0.1 : 10]
dy_by_vj = 0; // [0 : 0.1 : 10] 
y_c = 15; // [-20 : 0.5 : 20]
y_pad = 0; // [-5 : 0.01 : 20]

/* [Z Layout Tuning] */
// vi is d, vj is b
dz_by_vi = 2; // [-5 : 0.5 : 5]
dz_by_vj = 0; // [0 : 0.1 : 10]
z_c = 6; // [-20 : 0.5 : 20]
z_pad = 0; // [[-10 : .5 : 10]

/* [Label] */

//// x is currently ignored
//x_label_base = -34;
//y_label_base = 20; // [0:40]
//z_label_base = 2; // [1:4]

module end_of_customization() {}

module label(line, base_thickness) {
    label_size = [12, 5, base_thickness];
    block(label_size, center=BELOW);
    color("black") 
    linear_extrude(1)  
    text(line, 
        size=4,
        valign = "center", 
        halign = "center"
    );
}


module pin_element(d, b, size, element_parameters, pad, i, j) {
    bt = 2;
    wt = 2;
    label_offset = 5; 
    dz_rod = 3;
    
    dy_label = d/2 + label_offset;
    
    b_line = strcat(["b ", str(b)]);
    translate([0, dy_label , 0])
    label(b_line, base_thickness=bt);

    d_line = strcat(["d ", str(d)]);
    translate([0, -dy_label, 0])
    label(d_line, base_thickness=bt);    

    l_rod = b;
    translate([0, 0, dz_rod])
    rod(d=d, l=l_rod, center=ABOVE);
    
    pillar_size = [min(d/2, wt), wt, dz_rod + d/2];
    color("Orange")
    translate([-b/2, 0, 0]) 
    block(pillar_size, center=ABOVE+BEHIND);
    
    color("Blue")
    translate([b/2, 0, 0]) 
    block(pillar_size, center=ABOVE+FRONT);
    
    
    joiner_size = [wt, 2*dy_label, bt];
    color("Yellow")
    translate([-b/2, 0, 0])
    block(joiner_size, center=BELOW+BEHIND);
    

    color("Green")
    translate([b/2, 0, 0])
    block(joiner_size, center=BELOW+FRONT);
    
    if (show_bounding_box) {
        // Draw bounding box for debug purpose
        color("red", alpha=0.3)  cube(size, center=true); 
    }

//    
//    
//    label_size = [l_rod, label_z, label_z];
//    
//    color("Purple")
//    translate([label_y, -d/2, label_z-base_z])
//    block(label_size, center=BELOW+LEFT);
//    
//    color("Purple")
//    translate([0, +d/2 , 0])
//    block(label_size, center=BELOW+RIGHT);
    
    
    
    
//    // Need the i and j value to a row label
//    * echo("In pin_element ==============================================");
//    * echo("d", d);
//    * echo("h", h);
//    * echo("size", size);
//    * echo("element_parameters", element_parameters);
//    * echo("pad", pad);
//    
//    pin(d=d, h=h, center=false);
//    wall(size, pad, element_parameters);
//    
//    is_first = (j == 0); 
//    pin_label(d, h, size, element_parameters, is_first);
//    
//    label_base(size, pad, element_parameters);
//    

}

module pin_bridge(d, b, pad, sizing_coefficents, element_parameters) {

    sizes = layout_generate_sizes(
        outer_loop_values=d, 
        inner_loop_values=b,
        sizing_coefficents=sizing_coefficents);
    
    for (i = [0 : len(d)-1]) {
        for (j = [0: len(b)-1]) {
            layout_compressed_by_x_then_y(i, j, sizes, pad) {
                
                pin_element(d[i], b[j], sizes[i][j], element_parameters, pad, i, j);
                
            } 
        }
    } 
}


if (show_pin_bridge) {
    
    pad = [x_pad, y_pad, z_pad];
    
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ dx_by_vi, dx_by_vj, x_c],
        y_sizing = [ dy_by_vi, dy_by_vj, y_c],
        z_sizing = [ dz_by_vi, dz_by_vj, z_c]
    );

    element_parameters = [
//        ["wall_y", wall_y],
//        ["size_label_base", [x_label_base, y_label_base, z_label_base]],
    ];

    pin_bridge(diameters, bridges, pad, sizing_coefficents, element_parameters);
}