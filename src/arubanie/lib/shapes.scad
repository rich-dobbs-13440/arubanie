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
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/materials.scad>

/* [Boiler Plate] */

    //$fa = 1;
    $fs = 0.4;
    eps = 0.005;
    fa_bearing = 1;
    fa_shape = 20;
    infintesimal = 0.01;
    infinity = 1000; // Bigger than the build plate

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

/* [Side Clip Development] */ 
    show_side_clip = false;
    wall = 2; // [0: 0.5: 4]
    overlap_clip = 0.5; // [0: 0.05: 2]
    h_clip = 4; // [0 : 0.5 : 4]
    w_clip = 2; // [0 : 0.5 : 4]
    if (show_side_clip) {
        color("silver") block([wall, wall, 10], center=BEHIND+LEFT);
        side_clip(wall, h_clip, w_clip, overlap_clip);
    }

module end_of_customization() {}

module plane_clearance(center) {
    block([infinity, infinity, infinity], center=center);
}

module nutcatch(screw_axis, cut_axis, center=BELOW, nut_family="M3") {
    //assert(axis == Z_AXIS, "Not implemented");
    // Get it to centered with screw axis as Z
    x = 0;
    y = 0;
    z = 1.2;
    center_rotate(from_axis=X_AXIS, to_axis=cut_axis) {
        center_rotate(from_axis=Z_AXIS, to_axis=screw_axis) {
            translate([x, y, z]) {
                hole_through(name=nut_family);
                nutcatch_sidecut(name=nut_family);
            }
        }   
    }
}

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
    assert(is_list(size), str("In module '", parent_module(0), "' size should be [x, y, z].  Did you forget the []?"));
    assert(len(size)==3, str("In module '", parent_module(0), "' size should be [x, y, z], but it is ", str(size)));
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

module rod(d, l, center=0, hollow=false, taper=false, rank=1, fa=undef) {
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
            if (!taper) {
                cylinder(d=swell(d), h=swell(l), center=true);
            } else if (is_num(taper)) {
                cylinder(d1=swell(d), d2=swell(taper), h=swell(l), center=true);
            } else {
                assert(false, str("Don't know how to handle taper=", taper));  
            }
        } else if (is_num(hollow)) {
            if (is_num(taper)) {
                assert(false, "Hollow and tapered not implement");  
            }
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
module can(d, h, center=0, hollow=false, taper=false, rank=1, fa=undef) {
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
    
    fa_ = is_undef(fa) ? fa_shape : fa;
    hole_d = is_num(hole) ? hole : 0;
    pivot_size = [size.z, size.y, size.z];
    half_pivot = [swell(pivot_size.x/2),  swell(pivot_size.y), swell(pivot_size.z)];
    remainder =  [swell(size.x - pivot_size.x/2), swell(size.y), swell(size.z)];

    center_translation(pivot_size, center) {
        center_rotation(rotation) {
            render() difference() {
                union() {
                    block(half_pivot, center=FRONT, rank=rank+1);
                    rod(d=swell(size.z), l=swell(size.y), center=SIDEWISE, fa=fa_shape);
                }
                rod(d=swell_inward(hole_d), l=2*size.y, center=SIDEWISE, fa=fa_bearing);
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

    translate([0, -80, 0]) crank([10, 4, 4], hole=2, center=BEHIND, fa=fa_shape);

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
//    echo("segment_length", segment_length)
//    echo("n_end_bridges", n_end_bridges)
//    echo("n_supports_fractional", n_supports_fractional)
//    echo("n_supports", n_supports)
//    echo("n_bridges", n_bridges)
//    echo("bridge", bridge)
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
//    echo("x_0_s", x_0_s)
//    echo("x_0_e", x_0_e)
//    echo("x_1_s", x_1_s)
//    echo("x_1_e", x_1_e)
//    echo("no_overlap", no_overlap)

    [ for (i = [0, 1]) 
        if (i == 0 && no_overlap) seg_0 
        else if (i == 0 && contained_overlap) 
                //echo("case1")  
                segment(p_0_s, p_1_s) 
        else if (i == 1 && contained_overlap) 
                //echo("case2") 
                segment(p_1_e, p_0_e)    
        else if (i == 0 && start_overlap && !end_overlap) 
                //echo("case3") 
                segment(p_1_e, p_0_e)
        else if (i == 0 && end_overlap && !start_overlap) 
                //echo("case4") 
                segment(p_0_s, p_1_s)
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
        //echo("support_locations", support_locations);
        tearaway(
            support_locations, 
            d, 
            l,
            z,
            center);
    }
}




module side_clip(wall, h, w, overlap) {
    assert(is_num(wall));
    assert(is_num(h));
    assert(is_num(w));
    assert(is_num(overlap));
    hull() {
        translate([0, -w/4, 0]) block([w, w/4, h], center=LEFT+FRONT); // body
        block([0.01, overlap, h], center=RIGHT+FRONT); // clip
        block([0.01, wall, h+2*w], center=LEFT+FRONT); // Vertical printing support.
    }
}


module corner_retention_block(wall, overlap, h_clip = 0.5, h_slope = 0.5, h_alignment = 0.5, shelf=0.20, allowance=0.4) {

    h_total = h_clip + h_slope + h_alignment;
    CORNER = ABOVE+FRONT+RIGHT;
    
    // Want the  center of origin at the corner of the wall
    // For now, just rotate it for position as being used
    rotate([180, 0, 270]) {
            clip();
            mirror([-1, 1, 0]) clip();
    }
    
    module clip() {
        translate([0, -wall, 0]) {
            clip_shape();
        }
    }

    module clip_shape() {

        l_aligner = wall;
        aligner = [
            l_aligner, 
            wall, 
            h_clip + h_slope + h_alignment];
        sloper =  [
            aligner.x + h_alignment, 
            wall, 
            h_clip + h_slope];
        clipper = [
            sloper.x + h_slope, 
            wall+overlap,
            h_clip
        ];
        print_supporter = [clipper.x + h_clip, wall, 0.01];

        hull() {
            block(aligner, center=CORNER);
            block(print_supporter, center=CORNER);
        }
        hull() {
            block(clipper, center=CORNER);
            translate([0, shelf, 0]) block(sloper, center=CORNER);
            block(print_supporter, center=CORNER);
            
        } 
    }
}

module t_rail(size, thickness) {
    web = [size.x, size.y, thickness];
    flange = [size.x, thickness, size.z]; 
    block(web, center=RIGHT+FRONT);
    translate([0, size.y, 0]) block(flange, center=LEFT+FRONT);  
}

size = [20, 10, 12];
thickness = 2;
clearance = 1;

t_rail_slide(size, thickness, clearance);

module t_rail_slide(rail_size, rail_thickness, rail_mounting_y, clearance, slide_thickness) {
    inner = [
        rail_size.x, 
        rail_size.y - 2*clearance - rail_thickness - rail_mounting_y,  
        rail_size.z/2 - rail_thickness/2
    ];
    outer = [rail_size.x, slide_thickness, rail_size.z + 2 * clearance]; 
    top = [rail_size.x, rail_size.y + slide_thickness - rail_mounting_y, slide_thickness];
    //cap = [rail_thickness, rail_size.y + slide_thickness, rail_size.z + 2 * slide_thickness + 2 * clearance];
    module body() {
        center_reflect([0, 0, 1]) {
            translate([0, rail_mounting_y + clearance, rail_thickness/2 + clearance]) 
                block(inner, center=RIGHT+FRONT+ABOVE);
            translate([0, rail_size.y + clearance, 0]) 
                block(outer, center=RIGHT+FRONT);  
            translate([0, rail_mounting_y + clearance, rail_size.z/2 + clearance]) 
                block(top, center=RIGHT+FRONT+ABOVE); 
        }
    }
    body();
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


