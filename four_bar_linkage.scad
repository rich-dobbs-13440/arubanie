include <logging.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

/* [Dimensions] */

o2_o4 = 10; // [ 1 : 1 : 100]
o2_a = 10; // [ 1 : 1 : 100]
a_b = 10; // [ 1 : 1 : 100]
o4_b = 10; // [ 1 : 1 : 100]


theta2 = 90; // [ 0 : 1 : 360] 

h = 2; // [ 1 : 1 : 10]
d = 1;  // [ 1 : 1 : 10]


module end_of_customization() {}

theta1 = 180 ; // [ 0 : 1 : 360] 

o2_a_2 = o2_a * o2_a;
a_b_2 = a_b * a_b;
o4_b_2 = o4_b * o4_b;
o2_o4_2 = o2_o4 * o2_o4;

o4_a = sqrt(o2_o4_2 + o2_a_2 - 2 * o2_o4 * o2_a * cos(theta2));
log_s("o4_a", o4_a, verbosity, DEBUG, IMPORTANT);
o4_a_2 = o4_a * o4_a;

beta = asin((o2_a / o4_a) * sin(theta2));
log_s("beta", beta, verbosity, DEBUG, IMPORTANT);

phi = acos((a_b_2 + o4_a_2 - o4_b_2)/(2 * a_b * o4_a));
log_s("phi", phi, verbosity, DEBUG, IMPORTANT);

delta = asin((a_b/o4_b) * sin(phi));
theta3 = phi - beta;
theta4 = - (beta + delta);


angles = [theta1, theta2, theta3, theta4];
bars = [o2_o4, o2_a, a_b, o4_b]; // Input

function v_cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    


module pivot(pivot_position) {
    translate(pivot_position) {
        cylinder(d=d, h=h, center=true);
    }
}

module linkage(p1, p2) {
    hull() {
        pivot(p1);
        pivot(p2);
    }
    
}



function calc_ds(b, a) = [cos(a)*b, sin(a)*b , 0 ];


module show_linkage_chain(bars, angles) {
    ds = [ for (i = [0 : len(angles)-1]) 
        calc_ds(bars[i], angles[i])
    ];
    log_v1("ds", ds, verbosity, DEBUG);
    s = concat([[0,0,0]], v_cumsum(ds));
    log_v1("s", s, verbosity, DEBUG);
    
    for (i = [1: len(s)-1]) {
        linkage(s[i-1], s[i]);
    }
    
}

show_linkage_chain(bars, angles);


//s = [
//    [20, 0, 0],
//    [20, 10, 0],
//    [39.6962, 13.473, 0],
//    [43.1691, -6.22319, 0]
//];
//
//
//
//s_star = concat([[0,0,0]], s);
//
//log_v1("s_star", s_star, verbosity, DEBUG, IMPORTANT);






































