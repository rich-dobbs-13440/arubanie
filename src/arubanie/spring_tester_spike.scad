/* 

All the parts in the assembly that captures the air brush to
provide a base for rotation of the trigger capture assembly

The coordinate system is based center of rotation of the paint pivot.

*/
include <nutsnbolts-master/cyl_head_bolt.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <trigger_holder.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */




infinity = 1000;


/* [Show] */

show_plate_with_screw_holes = true;
show_spring_for_testing = true;

/* [Dimensions] */


spring_length = 10; // [0:1:20]
spring_width = 4; // [0:1:10]
spring_thickness = 2; // [0:0.5:5]
spring_arch_diameter = 5; // [0:0.5:5]

spring_connection_size = 4;
press_fit_tolerance = 0.2;


module end_of_customization() {}

// TODO: Reimplement testing bridge


if (show_plate_with_screw_holes) {
    color("green") translate([20, 0, 0]) plate_with_screw_holes();
}

if (show_spring_for_testing) {
    color("blue") translate([40, 0, 0]) 
        spring_for_testing(spring_length, spring_width, spring_thickness, spring_arch_diameter);
}


module plate_with_screw_holes() {
    
    x = 4; // Sturdy enough
    y = 21; // Fit through existing gudgeon separation
    z = 8; // Match existing gudgeon
    dy_screws = 6; //hole_separation_from_cl
    cs = spring_connection_size;
    d_cs = 2*press_fit_tolerance;
    hole_through_length = 50;

    connection_block = [2*(cs+d_cs), cs+d_cs, cs+d_cs];
    difference() { 
        block([x, y, z], center=BEHIND+ABOVE);
        center_reflect([0, 1, 0]) {
            translate([hole_through_length/2, dy_screws, z/2]) 
                rotate([0, 90, 0]) 
                    hole_through(name="M3");
        }
        translate([0, 0, z/2]) block(connection_block);
    }
    
}


module spring_for_testing(
        length, width, thickness, arch_diameter, show_connection_block=true) {

    l = length;
    w = thickness;
    h = width;
    id = arch_diameter;
    od = id + 2 * w; 
    x = od;
    y = l;
    z = h;
    cs = spring_connection_size;
    connection_block = [x+3*cs, cs, cs];
    
    render() difference() {
        union() {
            block([x, y, z], center=RIGHT+ABOVE);
            translate([0, l, 0]) can(d=od, hollow=id, h=h, center=ABOVE);
            if (show_connection_block) {
                block(connection_block, center=RIGHT+ABOVE);
            }
        }
        hull() {
            translate([0, l, 0]) can(d=id, h=infinity);
            block([id, l, infinity], center=RIGHT, rank=10);
        }
    }
}









