

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]

/* [Hidden] */

CRITICAL = 50; 
FATAL = CRITICAL;
ERROR = 40; 
WARNING = 30; 
WARN = WARNING;
INFO = 20; 
DEBUG = 10; 
NOTSET = 0;

IMPORTANT = 25;

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



log_verbosity = 
    log_verbosity_choice == "WARN" ? WARN :
    log_verbosity_choice == "INFO" ? INFO : 
    log_verbosity_choice == "DEBUG" ? DEBUG : 
    NOTSET;
    

module end_of_customization() {}

function v_cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    




module log_v1(label, v1, level=INFO, important=0) {
    overridden_level = max(level, important);
    if (overridden_level >= log_verbosity) { 
        style = overridden_level >= IMPORTANT ? 
            "<b style='color:OrangeRed'><font size=\"+2\">" : 
            "";
        echo(style, "---");
        echo(style, label, "= [");
        for (v = v1) {
            echo(style, "-........", v);
        }
        echo(style, "-------]");
        echo(style, " ");
    }
} 

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

function calc_ds(b, a) = [cos(a)*b, sin(a)*b , 0 ];

module show_linkage_chain(bars, angles) {
    ds = [ for (i = [0 : len(angles)-1]) 
        calc_ds(bars[i], angles[i])
    ];
    log_v1("ds", ds, DEBUG);
    s = v_cumsum(ds);
    log_v1("s", s, DEBUG, IMPORTANT);
}

show_linkage_chain(bars, angles);









































