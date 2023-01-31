include <logging.scad>



/* [Logging] */

log_verbosity_choice = "WARN"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

module end_of_customization() {}

show_name = false;
if (show_name) {
    linear_extrude(2) text("four_bar_classification.scad", halign="center");
}

// Classification

// From Wikipedia:
// Grashof condition 
//  The Grashof condition for a four-bar linkage states: 
//        If the sum of the shortest and longest link 
//        of a planar quadrilateral linkage is less 
//        than or equal to the sum of the remaining two links, 
//        then the shortest link can rotate fully with 
//        respect to a neighboring link. In other words,
//        the condition is satisfied if 
//                  S + L ≤ P + Q, 
//        where S is the shortest link, L is the longest,
//        and P and Q are the other links.

// These functions are for internal use only!

function s_i(ls) = min([ for (i = [0:len(ls)-1]) if (ls[i] == min(ls)) i]);
function l_i(ls) = max([ for (i = [0:len(ls)-1]) if (ls[i] == max(ls)) i]);
function not_s_or_l_indices(ls) = 
    [ for (i = [0:len(ls)-1]) 
        if ( i != s_i(ls) && i != l_i(ls)) i
    ];  
function p_i(ls) = min(not_s_or_l_indices(ls));   
function q_i(ls) = max(not_s_or_l_indices(ls));
        
function L(ls) = ls[l_i(ls)];
function S(ls) = ls[s_i(ls)];  
function P(ls) = ls[p_i(ls)]; 
function Q(ls) = ls[q_i(ls)];  
 
 // Public interface        

function grashof(ls) = S(ls) + L(ls) <= P(ls) + Q(ls);
        
//    Classification
//      The movement of a quadrilateral linkage can be classified
//      into eight cases based on the dimensions of its four links.
//      Let a, b, g and h denote the lengths of the input crank, 
//      the output crank, the ground link and floating link, 
//      respectively. Then, we can construct the three terms:
//
//    T_1 = g + h - a - b
//    T_2 = b + g - a - h
//    T_3 = b + h - a - g

//    The movement of a quadrilateral linkage can be classified 
//    into eight types based on the positive and negative values
//    for these three terms, T1, T2, and T3.[2]
//
//    T_1	T_2 T_3 Grashof condition	Input link	Output link
//    −	    −	+	Grashof	            Crank	    Crank
//    +	    +	+	Grashof	            Crank	    Rocker
//    +	    −	−	Grashof	            Rocker	    Crank
//    −	    +	−	Grashof	            Rocker	    Rocker
//    −	    −	−	Non-Grashof	        0-Rocker	0-Rocker
//    −	    +	+	Non-Grashof	        π-Rocker	π-Rocker
//    +	    −	+	Non-Grashof	        π-Rocker	0-Rocker
//    +	    +	−	Non-Grashof	        0-Rocker	π-Rocker

A = 0;  
H = 1; 
B = 2;
G = 3;

function g(ls) = ls[G];  // Ground link
function h(ls) = ls[H];  // Floating link
function a(ls) = ls[A];  // Input crank
function b(ls) = ls[B];  // Output crank 

function T_1(ls) = g(ls) + h(ls) - a(ls) - b(ls);
function T_2(ls) = b(ls) + g(ls) - a(ls) - h(ls);
function T_3(ls) = b(ls) + h(ls) - a(ls) - g(ls);

T_1_N = false;
T_1_P = true; 
T_2_N = false;
T_2_P = true; 
T_3_N = false;
T_3_P = true; 
GRASHOF = true;
NON_GRASHOF = false;

I_IDX = 0;
T_1_IDX = 1;
T_2_IDX = 2;
T_3_IDX = 3;
GRA_IDX = 4;
INPUT_TYPE_IDX = 5;
OUTPUT_TYPE_IDX = 6;

C_D = [
    [   0, T_1_N, T_2_N, T_3_P, GRASHOF,        "Crank",    "Crank"],
    [   1, T_1_P, T_2_P, T_3_P,	GRASHOF,        "Crank",    "Rocker"],
    [   2, T_1_P, T_2_N, T_3_N,	GRASHOF,        "Rocker",   "Crank"],
    [   3, T_1_N, T_2_P, T_3_N,	GRASHOF,        "Rocker",   "Rocker"],
    [   4, T_1_N, T_2_N, T_3_N,	NON_GRASHOF,    "0-Rocker",	"0-Rocker"],
    [   5, T_1_N, T_2_P, T_3_P,	NON_GRASHOF,    "π-Rocker",	"π-Rocker"],
    [   6, T_1_P, T_2_N, T_3_P,	NON_GRASHOF,    "π-Rocker",	"0-Rocker"],
    [   7, T_1_P, T_2_P, T_3_N,	NON_GRASHOF,    "0-Rocker",	"π-Rocker"],
];

function class_matches(row, ls) = 
    row[T_1_IDX] == (T_1(ls) > 0) &&
    row[T_2_IDX] == (T_2(ls) > 0) && 
    row[T_3_IDX] == (T_3(ls) > 0) &&
    row[GRA_IDX] == grashof(ls);
    
function row_matches(ls) = [ for (i = [0:1:len(C_D)]) if (class_matches(C_D[i], ls)) C_D[i]];
    
function row_match(ls) = len(row_matches(ls)) > 0 ? row_matches(ls)[0] : undef;

function t2_limit_numerator(ls, sign_b) = 
    a(ls)*a(ls)  
    + g(ls)*g(ls) 
    - (h(ls) + sign_b * b(ls))*(h(ls) + sign_b * b(ls));
    
function t2_limit_top(ls) = 
    [ for (sign_b = [-1, +1]) 
        acos(t2_limit_numerator(ls, sign_b) / (2 * a(ls) * g(ls)))
    ];
    
function diagnose_get_ranges(ls) = [for (dummy = [0]) 
        let (
            class = row_match(ls),
            base_limit = t2_limit_top(ls),
            input_type = class[INPUT_TYPE_IDX]
        )
        if (input_type == "0-Rocker") 
            [class, base_limit]
        
];
    
function get_theta_2_ranges_array(ls) = [
    for (dummy = [0:1])
    let (
        class = row_match(ls),
        base_limit = t2_limit_top(ls),
        input_type = class[INPUT_TYPE_IDX]
    ) 
    if (input_type == "Crank") 
        let (
            range = [[0, 360]]
        )
        range
    else if (input_type == "Rocker")
        let (
            range = [
                [base_limit[0], base_limit[1]], 
                [360-base_limit[1], 360-base_limit[0]]
            ]
        )
        range
    else if (input_type == "0-Rocker") 
        let (
            range = [
                [0, base_limit[1]], 
                [360-base_limit[1], 360]]
        )
        range
    else if (input_type == "π-Rocker") 
        let (
            range = [[base_limit[0], 360-base_limit[0]]]
        )
        range
    else if (base_limit == [0, 180]) 
        let (
            range = [[0, 360]]
        )
        range
    else
        assert(false, "Case not handled")
];
    
function get_theta_2_ranges(ls) = 
    // Unpack the outer list, which is just created because 
    // weirdness with using if statements in functions.
    get_theta_2_ranges_array(ls)[0];
    
    
module dev(ls) {


    log_s("T_1(ls)", T_1(ls), verbosity);
    log_s("T_2(ls)", T_2(ls), verbosity);
    log_s("T_3(ls)", T_3(ls), verbosity);
    log_s("grashof(ls)", grashof(ls), verbosity);

    for (i = [0:1:len(C_D)]) {
        log_s("class_matches i", class_matches(C_D[i], ls), verbosity); 
    }
    class = row_match(ls);
    log_s("class", class, verbosity, IMPORTANT);
    input_type =  class[INPUT_TYPE_IDX];
    base_limit = t2_limit_top(ls); 
    log_v1("base_limit", base_limit, verbosity);
    if (input_type == "Crank") {
        range = [[0, 360]];
        log_v1("range", range, verbosity);
    } else if (input_type == "Rocker") {  
        range = [
            [base_limit[0], base_limit[1]], 
            [360-base_limit[1], 360-base_limit[0]
        ]];
        log_v1("range", range, verbosity, IMPORTANT);
    } else if (input_type == "0-Rocker") {
        range = [[0, base_limit[1]], [360-base_limit[1], 360]];
        log_v1("range", range, verbosity);
    } else if (input_type == "π-Rocker") {
        // min angle is base_limit[0], max is 180
        range = [[base_limit[0], 360-base_limit[0]]];
        log_v1("range", range, verbosity, IMPORTANT);
    } else {
        if (base_limit == [0, 180]) {
            range = [[0, 360]];
            log_v1("range", range, verbosity);
        } else {
            assert(false, "Case not identified yet");
        }
//        if (base_limit == [0, 180]) {
//            range = [[0, 360];
//            log_v1("range", range, verbosity);


    }
    theta_2_ranges = get_theta_2_ranges(ls);
    log_v1("theta_2_ranges", theta_2_ranges, verbosity, IMPORTANT);  
}


// Should be a crank
* echo("In case 2");
ls_case_2 = [1, 10, 10, 10];
* dev(ls_case_2);
// Parellogram 
* echo("In case 3");
ls_case_3 = [10, 1, 10, 1];
* dev(ls_case_3);
// "0-Rocker", "π-Rocker"
* echo("In case 4");
ls_case_4 = [1, 8.5, 1, 10];
* dev(ls_case_4);
// "Rocker", "Crank"
* echo("In case 5");
ls_case_5 = [5, 5, 1, 7];
*dev(ls_case_5);

// π-Rocker 0-Rocker
// This would a long floating link compared to the ground link
// with short input and output cranks 
* echo("In case 6");
ls_case_6 = [1, 6.5, 1, 5];
*dev(ls_case_6);

// π-Rocker	π-Rocker
// Input crank long compared to ground link
// Floating link long compare to ouput crank
* echo("In case 7");
ls_case_7 = [1, 0.5, 5.7, 5];
dev(ls_case_7);

// From the classication, need to determine the limits on the 
// input crank angle 
//    T_1	T_2 T_3 Grashof condition	Input link	Output link   Assumed Range
//    −	    −	+	Grashof	            Crank	    Crank         0 - 360
//    +	    +	+	Grashof	            Crank	    Rocker        0 - 360
//    +	    −	−	Grashof	            Rocker	    Crank         l - u + reflection
//    −	    +	−	Grashof	            Rocker	    Rocker        l - u + reflection
//    −	    −	−	Non-Grashof	        0-Rocker	0-Rocker      -u - + u (include 0!) 
//    −	    +	+	Non-Grashof	        π-Rocker	π-Rocker      l - π + reflection (include π-) 
//    +	    −	+	Non-Grashof	        π-Rocker	0-Rocker      l - π + reflection (include π-)
//    +	    +	−	Non-Grashof	        0-Rocker	π-Rocker      -u - + u (include 0!)

// Crank means that the link can rotate all the way around
// Rocker means that it can reach either 0 or π, but it is limited between them
// 0-Rocker is a limited range of motion that includes 0 degree
// π-Rocker is a limited range of motion that includes 180 degrees.
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

