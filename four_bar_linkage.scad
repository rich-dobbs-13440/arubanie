

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Dimensions] */

o2_o4 = 20; // [ 1 : 1 : 100]
o2_a = 10; // [ 1 : 1 : 100]
a_b = 20; // [ 1 : 1 : 100]
o4_b= 20; // [ 1 : 1 : 100]

theta1 = 0; // The angle between the fixed pivots
theta2 = 90; // [ 0 : 1 : 360]

h = 2; // [ 1 : 1 : 10]
d = 1;  // [ 1 : 1 : 10]




theta3 = 10; // To be calculated!
theta4 = 280; // To be calculated

angles = [theta1, theta2, theta3, theta4];
bars = [o2_o4, o2_a, a_b, o4_b]; // Input

module pivot() {
    cylinder(d=d, h=h, center=true);
}


module link_o2_a(bars, angles) {
    theta2 = angles[1]; 
    o2_a = bars[1];
    rotate([0, 0, theta2]) {
        pivot();
        
        translate([o2_a, 0, 0]) { 
            pivot();
        }
        translate([o2_a/2, 0, 0]) cube([o2_a, 1, h], center=true);
    }
    
}

module link_ab(bars, angles) {
    theta2 = angles[1];
    theta3 = angles[2];
    a_x = cos(angles[1])*bars[1];
    a_y = sin(angles[1])*bars[1];
    hull() {
        translate([a_x, a_y, 0]) {
            pivot();    
        }
        b_x = cos(angles[2])*bars[2] + a_x;
        b_y = sin(angles[2])*bars[1] + a_y;
        translate([b_x, b_y, 0]) {
            pivot();
        }
    }
}


link_o2_a(bars, angles);
link_ab(bars, angles);

