include <logging.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

/* [Example Problem Dimensions ] */

clevis_rod_length___ep_4b = 50; // [ 40: 1 : 60]
horn_height_length___ep_4b = 7; // [ 6 : 1 : 8 ]

h___ep_4b = 2; // [ 1 : 1 : 5]
d___ep_4b = 1;  // [ 1 : 1 : 5]

/* [Example Problem Angles] */

servo_position___ep_4b = 0; // [ -80 : 1 : 80] 

module end_of_customization() {}

// TODO move this in a library!
function v_cumsum(v) = 
    [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];

//        The 4 bar kinematic equations are:

//        o2_a_2 = o2_a * o2_a;
//        a_b_2 = a_b * a_b;
//        o4_b_2 = o4_b * o4_b;
//        o2_o4_2 = o2_o4 * o2_o4;
//
//        o4_a = sqrt(o2_o4_2 + o2_a_2 - 2 * o2_o4 * o2_a * cos(theta2));
//        o4_a_2 = o4_a * o4_a;
//
//        beta = asin((o2_a / o4_a) * sin(theta2));
//
//        phi = acos((a_b_2 + o4_a_2 - o4_b_2)/(2 * a_b * o4_a));
//
//        delta = asin((a_b/o4_b) * sin(phi));
//        theta3 = phi - beta;
//        theta4 = - (beta + delta);
//
//        These are from Appendix A: Position Kinematic Analysis.  Trigonometric Method
//        Fundamentals of Machine Theory and Mechanisms
//        Antonio Simón Mata, Alex Bataller Torras, Juan Antonio Cabrera Carrillo, 
//        Francisco Ezquerro Juanco, Antonio Jesús Guerra Fernández, 
//        Fernando Nadal Martínez, Antonio Ortiz Fernández
//        https://link.springer.com/content/pdf/bbm:978-3-319-31970-4/1


O2_A = 0; //    servo_hub_radius(),
AB = 1; //    clevis_rod_length,
O4_B = 2;//    action_bar_length,
O2_O4 = 3; //    servo_to_pivot_distance

function calc_o4_a(t2, l) = 
    sqrt(
        l[O2_O4]*l[O2_O4] 
        + l[O2_A]*l[O2_A] 
        - 2 * l[O2_O4] * l[O2_A] * cos(t2)
    );

function calc_beta(t2, l) = 
    asin(
        (l[O2_A] / calc_o4_a(t2, l)) * sin(t2)
    );


function calc_phi(t2, l) = 
    acos(
            ( 
                l[AB]*l[AB] 
                + calc_o4_a(t2, l)*calc_o4_a(t2, l) 
                - l[O4_B]*l[O4_B]
            ) 
            / (2 * l[AB] * calc_o4_a(t2, l))
    );

function calc_delta(t2, l) = 
    asin((l[AB]/l[O4_B]) * sin(calc_phi(t2, l)));

function calc_theta3(t2, l) = 
    t2 >= 0 && t2 <=180 ? 
    calc_phi(t2, l) - calc_beta(t2, l) :
    - (calc_phi(t2, l) + calc_beta(t2, l));

function calc_theta4(t2, l) = 
    t2 >= 0 && t2 <=180 ? 
    - (calc_beta(t2, l) + calc_delta(t2, l)) :
    calc_delta(t2, l) - calc_beta(t2, l);

function four_bar_angles(t2, l) = 
    [t2, calc_theta3(t2, l), calc_theta4(t2, l), 180];
    
module articulate(lengths, angles) {
    
    function calc_ds(b, a) = [cos(a)*b, sin(a)*b , 0 ];
    
    ds = [ for (i = [0 : len(angles)-1]) 
        calc_ds(lengths[i], angles[i])
    ];

    s = concat([[0,0,0]], v_cumsum(ds));
           
    for (i = [0 : $children-1]) {
        translate(s[i]) rotate(angles[i]) children(i);
    }
}


module test_problem_1() {
    module rod(l) {
        cube([l, 0.1, 0.1]);
    }
    
    lengths = [10, 10, 10, 10];
    log_v1("lengths", lengths, verbosity, level=INFO);
    
    sp = concat( [ each [5 : 5 : 175 ] ], [ each [185 : 5 : 355 ] ])  ;
    //sp = [90];
    echo( len(sp) );
    for (i = [0:len(sp)-1]) {
        angles = four_bar_angles(sp[i], lengths);
        important = (!is_num(angles[1]) || !is_num(angles[2])) ? IMPORTANT : NOTSET;
        log_v1("angles", angles, verbosity, level=INFO, important);
        assert(is_num(angles[1]));
        
        articulate(lengths, angles) {
            rod(lengths[0]);
            rod(lengths[1]);
            rod(lengths[2]);
            rod(lengths[3]);
        };
    }
    
}

test_problem_1();

        
module example_problem_four_bar() {
//  Customizer configuration    
//        /* [Example Problem Dimensions ] */

      
    // Map globals to local variables
    clevis_rod_length = clevis_rod_length___ep_4b;
    horn_height = horn_height_length___ep_4b;
    
    
    h = h___ep_4b;  
    d = d___ep_4b;
    
    servo_to_pivot_distance = 50; // Hardcoded for problem
    fixed_pivot_angle = 170;
    servo_angle = 90 + servo_position___ep_4b;
    
    // Fixed distance from a library eventually
    function servo_hub_radius() = 6.94; 

    module servo_hub() {
        r=servo_hub_radius();
        difference() {
            cylinder(r=8.81, h=2);
            translate([r, 0, 0]) cylinder(d=1.29, h=5, center=true);
        }
    }

    module clevis_rod(length) {
        color("OliveDrab") cube([length, 1, 3]);
    }

    module flap_and_horn(height) {
        x = 5 * height;
        color("LightSeaGreen", alpha=0.5) cube([height, 1, 1]);
        translate([height/2, 0, 0]) cube([1, x, 1]);
    }

    module pivot_and_ground(length) {
        color("DarkKhaki", alpha=0.2) cube([length, 1, 1]);
    }

    lengths = [
        servo_hub_radius(),
        clevis_rod_length,
        horn_height,
        servo_to_pivot_distance
    ];
    log_v1("lengths", lengths, verbosity, level=INFO, IMPORTANT);

    //angles_t = four_bar_angles(fixed_pivot_angle, servo_angle, test_lengths);
    angles = four_bar_angles(servo_angle, lengths);
    log_v1("angles", angles, verbosity, level=INFO, IMPORTANT);

    articulate(lengths, angles) {
        servo_hub();
        clevis_rod(clevis_rod_length);
        flap_and_horn(horn_height);
        pivot_and_ground(servo_to_pivot_distance); 
    };
    
}

* example_problem_four_bar();





































