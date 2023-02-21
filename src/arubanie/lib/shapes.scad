/*

    The shapes are slightly oversized, and the placement adjusted
    so that two shapes placed next to each other will have 
    non-adjacent faces. Shaped can be ranked, so that if the
    overlap, it is definite which will win the z-ordering fight.

    This is an attempt to make the epsilon  
*/



include <centerable.scad>
include <logging.scad>
use <not_included_batteries.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.005;
infintesimal = 0.01;

/* [Visual Tests] */

show_test_rod_all_octants = false;
show_test_rod_rod_single_attribute = false;
show_visual_test_for_crank = false;
show_visual_test_for_rod_support = true;
 

// h_by_one_hundred = 1; // [0 : 1 : 99.9]
// echo("h_by_one_hundred", h_by_one_hundred);
__l = 50; // [-99.9 : 1 : 99.9]
//echo(__l);
__x_start = 10; // [-99.9 : 1 : 99.9]
__x_stop = 40; // [-99.9 : 1 : 99.9]
__support_end_start  = true;
__support_end_stop  = true;
__ends_supported = [__support_end_start, __support_end_stop];
/* 
    Block is a cube with a specific translation about the origin.

    
    Example usage:
    
    size = [10, 2, 6];
    cuboid(size); // Centered on X, Y, & Z axises
    
    block(size, center=ABOVE); // Centered on X, Y axises
    block(size, center=ABOVE+FRONT); // Centered on X
    block(size, center=ABOVE+FRONT+LEFT); // One corner is at origin
    
*/
module block(size, center=0, rank=1) { 
    function swell(w=0) = w + 2*rank*eps;
    true_size = size + [swell(0), swell(0), swell(0)];
    disp = _center_to_displacement(center, size);
    translate(disp) cube(true_size, center=true);  
}



/*
    Rod is a cylinder on its edge, with a specific translation 
    about the origin and orientation.

    Example usage:

    rod(d=10, l=20, center = FRONT);
    rod(d=10, l=20, center = SIDEWISE + FRONT + ABOVE + LEFT);

*/

module rod(d, l, center=0, hollow=false, rank=1, fa=undef) {
    function swell(w=0) = w + 2*rank*eps;
    function swell_inward(w=0) = w - 2*rank*eps;  
    $fa = is_undef(fa) ? $fa : fa;
    bv = _number_to_bitvector(center);
    is_sideways = bv[3] == 1;
    x = is_sideways ? d : l;
    y = is_sideways ? l : d;
    z = d;
    size=[x, y, z];
    disp = _center_to_displacement(center, size);
    a = is_sideways ? 90 : 0;


    translate(disp) {
        rotate([0, 0, a])
        rotate([0, 90, 0])
        if (hollow == false) {
            cylinder(d=swell(d), h=swell(l), center=true);
        } else if (is_num(hollow)) {
            render() difference() {
                cylinder(d=swell(d), h=swell(l), center=true);
                cylinder(d=swell_inward(hollow), h=2*l, center=true);  
            }
        } else {
            assert(false, str("Don't know how to handle hollow=", hollow));
        } 
    }   
}

/*
    Can  is a cylinder on its end, with a specific translation 
    about the origin.
    
*/
module can(d,h, center=0, hollow=false, taper=false, rank=1, fa=undef) {
    function swell(w=0) = w + 2*rank*eps;
    function swell_inward(w=0) = w - 2*rank*eps; 
    $fa = is_undef(fa) ? $fa : fa;
    bv = _number_to_bitvector(center);
    size = [d, d, h];
    disp = _center_to_displacement(center, size);
    translate(disp) {
        if (hollow == false) {
            if (taper == false) {
                cylinder(d=swell(d), h=swell(h), center=true); 
            } else if (is_num(taper)) {
                cylinder(d1=swell(d), d2=swell(taper), h=swell(h), center=true);
            } else {
                assert(false, str("Don't know how to handle taper=", taper));
            }
        } else if (is_num(hollow)) {
            if (taper == false) {
                render() difference() {
                    cylinder(d=swell(d), h=swell(h), center=true);
                    cylinder(d=swell_inward(hollow), h=2*h, center=true);
                }
            } else {
                assert(false, "Not implemented - hollow tapered.");
            }
        } else {
            assert(false, str("Don't know how to handle hollow=", hollow));
        }  
    }  
}

module crank(size, hole=false, center=0, rotation=0, rank=1, fa=undef) {
    signature = "crank(size, hole=false, center=0, rotation=0, rank=1, fa=undef)";
    assert(is_list(size), str("Missing argument. Signature is ", signature));
    function swell(w=0) = w + 2*rank*eps;
    function swell_inward(w=0) = w - 2*rank*eps; 
    $fa = is_undef(fa) ? $fa : fa;
    hole_d = is_num(hole) ? hole : 0;
    pivot_size = [size.z, size.y, size.z];
    half_pivot = [swell(pivot_size.x/2),  swell(pivot_size.y), swell(pivot_size.z)];
    remainder =  [swell(size.x - pivot_size.x/2), swell(size.y), swell(size.z)];

    center_translation(pivot_size, center) {
        center_rotation(rotation) {
            render() difference() {
                union() {
                    block(half_pivot, center=FRONT);
                    rod(d=swell(size.z), l=swell(size.y), center=SIDEWISE);
                }
                rod(d=swell_inward(hole_d), l=2*size.y, center=SIDEWISE);
            }
            // Rest of block
            translate([pivot_size.x/2, 0, 0]) block(remainder, center=FRONT);
        }
    } 
}

module tearaway(
        support_locations, 
        d,
        l,
        z,
        center=0,
        radial_allowance=0.4, 
        overlap_multiplier=1.5,
        support_length=3) {
           
    x_offset = center==0 ? -l/2:
               center==FRONT ? 0:
               assert(false);
    z_p = z - d / 2;
    base = [support_length, 1.5*z_p, , infintesimal];
    neck = [support_length, infintesimal, infintesimal];
    z_neck = z_p + overlap_multiplier*radial_allowance;
    
    module tearaway_segment(ts_center) {
        hull() {
           block(base, center=ts_center, rank=10);
           translate([0, 0, z_neck]) block(neck, center=ts_center);
        }
    }
    for (support_location = support_locations) {
        dx = is_num(support_location) ? support_location : support_location[0];
        ts_center = is_num(support_location) ? center : support_location[1];
        translate([dx+x_offset, 0, 0]) tearaway_segment(ts_center);
    } 
} 

module _visual_test_for_crank() {

    translate([0, -80, 0]) crank([10, 4, 4], hole=2, center=BEHIND);

    translate([0, -70, 0]) crank([10, 4, 4], hole=2, center=FRONT);

    translate([0, -60, 0]) crank([10, 4, 4], hole=2, center=LEFT);

    translate([0, -50, 0]) crank([10, 4, 4], hole=2, center=RIGHT);

    translate([0, -40, 0]) crank([10, 4, 4], hole=2, center=ABOVE);

    translate([0, -30, 0]) crank([10, 4, 4], hole=2, center=BELOW);

    translate([0, -10, 0]) crank([10, 4, 4]);

    translate([0, 0, 0]) crank([10, 4, 4], hole=2);

    translate([0, 20, 0]) crank([10, 4, 4], hole=2, rotation=ABOVE);

    translate([0, 30, 0]) crank([10, 4, 4], hole=2, rotation=BELOW);

    translate([0, 40, 0]) crank([10, 4, 4], hole=2, rotation=FRONT);

    translate([0, 50, 0]) crank([10, 4, 4], hole=2, rotation=BEHIND);

    translate([0, 70, 0]) crank([10, 4, 4], hole=2, rotation=LEFT);

    translate([0, 80, 0]) crank([10, 4, 4], hole=2, rotation=RIGHT);

    translate([0, 100, 0]) crank([10, 4, 4], hole=2, rotation=ABOVE+RIGHT);
    
    
    
}

if (show_visual_test_for_crank) {
    _visual_test_for_crank();   
}


module _visual_test_rod_single_attribute(d, l, a) {
    
    color("SteelBlue", alpha = a) 
    rod(d=d, l=l, center=BEHIND); 

    color("FireBrick", alpha = a) 
    rod(d=d, l=l, center=FRONT);

    color("Lavender", alpha = a)   
    rod(d=d, l=l, center=LEFT);

    color("RosyBrown", alpha = a)        
    rod(d=d, l=l, center=RIGHT);

    color("Aqua", alpha = a)   
    rod(d=d, l=l, center=ABOVE);

    color("blue", alpha = a)        
    rod(d=d, l=l, center=BELOW);
}

if (show_test_rod_rod_single_attribute) {
    _visual_test_rod_single_attribute(10, 20, 0.5);
}

module _visual_test_all_octants(d, l, use_sideways, alpha) {
    colors = [
        [
            ["red", "orange"],
            ["yellow", "green"]
        ],
        [
            ["IndianRed", "LightSalmon"],
            ["Khaki", "LightGreen"]
        ]
    ];
    a_sideways = use_sideways ? SIDEWISE : 0;
    
    function i_x(x) = x == BEHIND ? 0 : 1;
    function i_y(y) = y == LEFT ? 0 : 1;
    function i_z(z) = z == ABOVE ? 0 : 1;
    
    function map_to_color(x, y, z) = colors[i_x(x)][i_y(y)][i_z(z)];
    for (x_a = [BEHIND, FRONT]) {
        for (y_a = [LEFT, RIGHT]) {
            for (z_a = [ABOVE, BELOW]) {
                color(map_to_color(x_a, y_a, z_a), alpha=alpha)        
                rod(d=d, l=l, center=x_a+y_a+z_a+a_sideways);                
            }
        }
    }
    
}

if (show_test_rod_all_octants) {
    _visual_test_all_octants(10, 20, false, 0.5);
}
        
function support_locations_for_segment(
        segment,
        support_length = 3, 
        max_bridge = 10) =
    let(
        p0 = segment[0],
        p1 = segment[1],
        segment_length = abs(p0[0] - p1[0]),
        ends_supported = [p0[1], p1[1]],
        n_end_bridges = (ends_supported[0] ? 1 : 0) + (ends_supported[1] ? 1 : 0),
        n_supports_fractional = 
            (segment_length - (n_end_bridges - 1) * max_bridge) / (support_length + max_bridge),
        n_supports = ceil(n_supports_fractional),
        n_bridges = n_supports + n_end_bridges - 1, 
        bridge = (segment_length - n_supports*support_length)/n_bridges,
        last = undef
    )
    echo("segment_length", segment_length)
    echo("n_end_bridges", n_end_bridges)
    echo("n_supports_fractional", n_supports_fractional)
    echo("n_supports", n_supports)
    echo("n_bridges", n_bridges)
    echo("bridge", bridge)
    assert(bridge <= max_bridge)
    [
        for (i = [0 : 1 : n_supports-1])  
            p0[0] 
            + (ends_supported[0] ? bridge: 0)
            + i * (support_length + bridge)
    ];
        
        
function point(x, supported) = [x, supported];
        
function segment(p1, p2) = [p1, p2];
       
function segment_difference(seg_0, seg_1) = 
    let (
        p_0_s = seg_0[0],
        p_0_e = seg_0[1],
        p_1_s = seg_1[0],
        p_1_e = seg_1[1],
        x_0_s = p_0_s[0],
        x_0_e = p_0_e[0],
        x_1_s = p_1_s[0],
        x_1_e = p_1_e[0], 
        no_overlap = (x_1_e < x_0_s) || (x_1_s > x_0_e),
        contained_overlap = (x_1_s > x_0_s) && (x_1_e < x_0_e),
        start_overlap = (x_1_s <= x_0_s) && (x_0_s <= x_1_e),
        end_overlap = (x_1_s <= x_0_e) && (x_0_e <= x_1_e),
        last = undef
    )
    echo("x_0_s", x_0_s)
    echo("x_0_e", x_0_e)
    echo("x_1_s", x_1_s)
    echo("x_1_e", x_1_e)
    echo("no_overlap", no_overlap)

    [ for (i = [0, 1]) 
        if (i == 0 && no_overlap) seg_0 
        else if (i == 0 && contained_overlap) echo("case1")  segment(p_0_s, p_1_s) 
        else if (i == 1 && contained_overlap) echo("case2") segment(p_1_e, p_0_e)    
        else if (i == 0 && start_overlap && !end_overlap) echo("case3") segment(p_1_e, p_0_e)
        else if (i == 0 && end_overlap && !start_overlap) echo("case4") segment(p_0_s, p_1_s)
    ];
        
function flatten(l) = [ for (a = l) for (b = a) b ] ;
   
function overall_difference(remainder_list, take_away_list, i=0) =
    let (
        
        current_remainder = (i > len(take_away_list)-1) ? remainder_list :
            flatten(
                [ for (item = remainder_list) 
                    segment_difference(item, take_away_list[i])
                ]
            ),
        result = i < len(take_away_list) - 1 ? 
                overall_difference(current_remainder, take_away_list, i=i+1) : 
                current_remainder,
        last = undef 
    ) 
    result;
            
module visualize_segment(segment, color_name) {
    s_segment = segment[1][0] - segment[0][0];
    color(color_name, alpha=0.25)
        translate([segment[0][0], 0, 0]) block([s_segment, 10, 10], center=FRONT);
}

function support_rod(d, l, z, bridges, supports, center=0) = 
    let (
        segment_all = segment(point(0, false), point(l, false)),
        bridge_segments = [ 
            for (bridge = bridges) 
                segment(point(bridge[0], false), point(bridge[1], false))
        ],
        support_segments = [ 
            for (support = supports) 
                segment(point(support[0], true), point(support[1], true))
        ],
        segments_to_support = overall_difference(
                    [segment_all], 
                    concat(bridge_segments, support_segments)),
        last = undef
    )
    [
        ["segment_all", segment_all],
        ["bridge_segments", bridge_segments],
        ["support_segments", support_segments],
        ["segments_to_support", segments_to_support],
    ];
    


module support_rod(d, l, z, bridges, supports, center=0) {
    segments_dct = support_rod(d, l, z, bridges, supports, center);
    segments_to_support = find_in_dct(segments_dct, "segments_to_support");

    for (segment = segments_to_support) {
        support_locations = support_locations_for_segment(segment);
        echo("support_locations", support_locations);
        tearaway(
            support_locations, 
            d, 
            l,
            z,
            center);
    }
}


module __visual_tests_for_rod_support(d, l, z, bridges, supports, center=0, dy=0) {
    translate([0, dy, 0]) {
        support_rod(d, l, z, bridges, supports, center=center);
        
        translate([0, 0, z]) rod(d, l, center=center); 
        segments_dct = support_rod(d, l, z, bridges, supports, center);
        bridge_segments = find_in_dct(segments_dct, "bridge_segments");
        for (segment = bridge_segments) {
            visualize_segment(segment, "blue");
        }
        support_segments = find_in_dct(segments_dct, "support_segments");
        for (segment = support_segments) {
            visualize_segment(segment, "red");
        }
    }
}

module _visual_tests_for_rod_support() {
    z = 5;
    d = 5;
    l = __l;
    center = FRONT;
    module a_test(bridges, supports, dy) {
        __visual_tests_for_rod_support(d, l, z, bridges, supports, center, dy);
    }
    a_test(bridges=[], supports=[], dy=20);
    a_test(bridges=[], supports=[[0, 10]], dy=40);
    a_test(bridges=[[30, 40]], supports=[[0, 10]], dy=60);
    a_test(bridges=[[30, 40],[50, 60]], supports=[[0, 10]], dy=80);
    a_test(bridges=[[30, 40],[40, 50]], supports=[[0, 10]], dy=100);
    a_test(bridges=[[30, 40],[40, 50]], supports=[[0, 10], [__l, __l]], dy=120);
}
        
//module _visual_test_for_rod_support_development() {
//    z = 5;
//    d = 5;
//    l = __l;
//    // [__x_start, min(__x_stop, l)]
//
//    p_0 = point(0, false);
//    p_l = point(__l, false);
//    seg_all = segment(p_0, p_l);
//    
//    p_start = point(__x_start, true);
//    p_stop =  point(__x_stop, true);
//
//    seg1 = segment(p_start, p_stop);
//    seg2 = segment(point(40, false), point(60, false));
//    seg3 = segment(point(60, false), point(70, false));
//    
//    
////    segments_from_segment_difference = segment_difference(seg_all, seg);
////    log_v1("segments_from_segment_difference", segments_from_segment_difference, DEBUG, IMPORTANT);
//    segments = overall_difference([seg_all], [seg1, seg2, seg3]);
//    log_v1("segments", segments, DEBUG, IMPORTANT);
//    
//    for (segment = segments) {
//        support_locations = support_locations_for_segment(segment);
//        echo("support_locations", support_locations);
//        tearaway(
//            support_locations, 
//            d, 
//            l,
//            z,
//            center);
//    }
//    center=FRONT;
//    translate([0, 0, z]) rod(d, l, center=center);
//    //sx = __x_stop - __x_start;
//    //color("red", alpha=0.25) translate([__x_start, 0, 0]) block([sx, 10, 10], center=FRONT);
//    visualize_segment(seg1, "red");
//    visualize_segment(seg2, "blue");
//    visualize_segment(seg3, "green");
//    
//} 

if (show_visual_test_for_rod_support) {
    _visual_tests_for_rod_support();  
}


