include <logging.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

/* [Debuggin] */
sp_min = 0; // [ 0: 1 : 360]
sp_step = 15; // [ 0: 1 : 360]
sp_max = 360; // [ 0: 1 : 360]

/* [Example Problem Dimensions ] */

clevis_rod_length___ep_4b = 50; // [ 40: 1 : 60]
horn_height_length___ep_4b = 7; // [ 6 : 1 : 8 ]

h___ep_4b = 2; // [ 1 : 1 : 5]
d___ep_4b = 1;  // [ 1 : 1 : 5]

/* [Example Problem Angles] */

servo_position___ep_4b = 0; // [ -80 : 1 : 80] 

module end_of_customization() {}

show_name = false;
if (show_name) {
    linear_extrude(2) text("four_bar_linkage.scad", halign="center");
}

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


O2_A = 0;  
AB = 1; 
O4_B = 2;
O2_O4 = 3; 



;
    
    
// Angles Calculation


function calc_o4_a(t2, l) = sqrt(
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
    !is_num(calc_o4_a(t2, l)) ?
        [t2, undef, undef, 180] :
    !is_num(calc_beta(t2, l)) ?
        [t2, undef, undef, 180] :
    !is_num(calc_phi(t2, l)) ?
        [t2, undef, undef, 180] :
    !is_num(calc_delta(t2, l)) ?
        [t2, undef, undef, 180] :
    [t2, calc_theta3(t2, l), calc_theta4(t2, l), 180];
    
function is_valid_four_bar_angles(angles) =
        len(angles) == 4 && is_num(angles[1]) && is_num(angles[2]);
        
module articulate(lengths, angles) {
    for (i = [0 : len(angles)-1]) {
        if (!is_num(angles[i])) {
            log_v1("angles", angles, verbosity, level=INFO, IMPORTANT);
            assert(is_num(angles[i]), str("i=", i));
        }
    }
    
    function calc_ds(b, a) = [cos(a)*b, sin(a)*b , 0];
    
    ds = [ for (i = [0 : len(angles)-1]) 
        calc_ds(lengths[i], angles[i])
    ];

    s = concat([[0,0,0]], v_cumsum(ds));
           
    for (i = [0 : $children-1]) {
        if (is_num(angles[i])) { 
            translate(s[i]) rotate(angles[i]) children(i);
        } else {
            color("red", alpha=0.5) translate([lengths[i], 0, 0])  children(i);
        }
    }
}

module dump_four_bar(t2, i, angles, lengths) {
    okay_lengths = len(angles) == 4 && len(angles) == 4;
    angles_defined = len([for (a=angles) if(is_undef(a)) a]) == 0;
    lengths_defined = len([for (l=lengths) if(is_undef(l)) l]) == 0;
    importance = okay_lengths && angles_defined && lengths_defined ? INFO : IMPORTANT;
    log_v1("lengths", lengths, verbosity, level=INFO, importance);
    log_v1("angles", angles, verbosity, level=INFO, importance);    
}


module visualizer(lengths, dump_for_bad, t2_min, t2_step, t2_max) {
    module rod(l) {
        cube([l, 0.1, 0.1]);
    }
    t2 = [ each [t2_min : t2_step : t2_max ] ];
    for (i = [0:1:len(t2)-1]) {
        angles = four_bar_angles(t2[i], lengths);
        
        if (is_valid_four_bar_angles(angles)) {
            articulate(lengths, angles) {
                rod(lengths[0]);
                rod(lengths[1]);
                rod(lengths[2]);
                rod(lengths[3]);
            };
        } else {
            if (dump_for_bad) {
                dump_four_bar(t2, i, angles, lengths);
            } 
        }
    }
}

module test_problem_1() {
    module rod(l) {
        cube([l, 0.1, 0.1]);
    }
    
    lengths = [10, 10, 10, 10];
    log_v1("lengths", lengths, verbosity, level=INFO);
    
    sp = [ each [15 : 15 : 345 ] ];
    //sp = [10];
    * echo("len(sp)", len(sp));
    for (i = [0:1:len(sp)-1]) {
        angles = four_bar_angles(sp[i], lengths);
        
        if (is_valid_four_bar_angles(angles)) {
            articulate(lengths, angles) {
                rod(lengths[0]);
                rod(lengths[1]);
                rod(lengths[2]);
                rod(lengths[3]);
            };
        } else {
            dump_four_bar(angles, lengths);
        }
        
    }
}

* test_problem_1();

module test_problem_2(case) {
    module echo_limits(lengths) {
        log_v1("lengths", lengths, verbosity, level=INFO);
        
        limits_top = t2_limit_top(lengths);
        log_v1("limits_top", limits_top, verbosity, level=IMPORTANT);
        a_min = is_num(limits_top[0]) ? limits_top[0] : 0;
        a_max = is_num(limits_top[1]) ? limits_top[1] : 360;
        a_step = (a_max - a_min)/10;
        dump_for_bad = false;
        visualizer(lengths, dump_for_bad, a_min, a_step, a_max);
    }
        
    
    // Limited range of motion, should have min and maximum limits
    ls_case_1 = [10, 1, 10, 15];
    * _limits(ls_case_1);
    // Should be a crank
    ls_case_2 = [1, 10, 10, 10];
    * _limits(ls_case_2);
}

test_problem_2();

        
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





































