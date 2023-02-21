/*

Usage:

use <lib/small_3d_printable_scotch_yoke.scad>

dimensions = scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness,
    bearing_width, 
    angle,
    support_axle);

log_v1("dimensions", dimensions, verbosity, INFO);

scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    bearing_width,
    angle,
    support_axle);

Notes:

Center of origin at the CL of crank shaft and the CL of push rod
at the level of the build plane.  

The crank shaft rotation is on the x axis.

The push rod translation is on the y axis.

This design assumes that the component will be built on the
printer build plate.  If placed directly on top of printed feature
the component will be froze in place.  No provision for
printable rafting of the push rod and traveller has been 
made at this time. 

At building, the angle should be zero.  The working angle range should 
be 90 - 270. (This should be revised so that the working range
is 0 to 180, with the build position being 270).

This design includes features to reduce slop, while still being
printable.  The part will need some exercise to move smoothly,
and there is a distinct transition between the sloppy top range
and the tighter bottom range.  The part in use should be 
rotated 180 degrees from as built for smallest slop.

There is still some slop in crankshaft bearing design that
should be worked up.

*** Need describe how to get the servo mounting!!!

*/

//**************************************************************************************************
//   Line Ruler   20        30        40        50        60        70        80        90       100

include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <small_servo_cam.scad>
use <sub_micro_servo.scad>
use <9g_servo.scad>
use <print_in_place_joints.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

fa_shape = 10;
$fa = fa_shape;
fa_as_arg = $fa;
fa_bearing = 1;
infintesimal = 0.01;

/* [Logging] */
log_verbosity_choice = "DEBUG"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 



/* [Test Dimensions] */
pin_diameter_ = 5;
range_of_travel_ = 6; // [0: 20]
radial_allowance_ = 0.4;
axial_allowance_ = 0.4;
wall_thickness_ = 3; // [2, 3, 4];
wall_height_ = 10; 
bearing_width_ = 4;
support_axle_ = [false, true];



/* [Mounting Test] */
show_stationary_parts_ = true;
screw_name_ = "M3"; 
frame_to_base_right_ = 26; // [0:100]
frame_to_base_left_ = 26; // [0:100]
frame_to_base_ = [frame_to_base_right_, frame_to_base_left_];

nuts_right_ = false;
nuts_left_ = true;



/* [Rotation Test] */
show_moving_parts_ = true;
angle_ = 0; // [0 : 15: 360]
extra_push_rod_right = 0; // [0:0.5:10]
extra_push_rod_left = 0; // [0:0.5:10]
extra_push_rod_=[extra_push_rod_right, extra_push_rod_left];
use_dove_tails_ = [true, false];
use_dove_tails_option_ = ["use_dove_tails", use_dove_tails_];



/* [ Visibility] */
push_rod_color = "purple";
push_rod_alpha = 1.0; // [0, 0.25, 0.5, 1]
push_rod_coloring = [push_rod_color, push_rod_alpha];

traveller_color = "blue";
traveller_alpha = 1.0; // [0, 0.25, 0.5, 1]
traveller_coloring = [traveller_color, traveller_alpha];

bearing_color = "red";
bearing_alpha = 1.0; // [0, 0.25, 0.5, 1]
bearing_coloring = [bearing_color, bearing_alpha];

crank_shaft_color = "green";
crank_shaft_alpha = 1.0; // [0, 0.25, 0.5, 1]
crank_shaft_coloring = [crank_shaft_color, crank_shaft_alpha];

support_color = "orange";
support_alpha = 1.0; // [0, 0.25, 0.5, 1]
support_coloring = [support_color, support_alpha];

wall_color = "white";
wall_alpha = 1.0; // [0, 0.25, 0.5, 1]
wall_coloring = [wall_color, wall_alpha];

servo_mount_color = "brown";
servo_mount_alpha = 1.0; // [0, 0.25, 0.5, 1]
servo_mount_coloring = [servo_mount_color, servo_mount_alpha];



module end_of_customization() {}



//=========================== Start of Example ====================================

// TODO: Move to somewhere common.

// Or separate out feature for hiding from color, to allow 
// coloring of nested parts to show through.

module display(coloring) {
    color_name = coloring[0];
    alpha = coloring[1]; 
    if (alpha == 0) {
        // Don't process children at at all, to avoid
        // visual artifacts and use alpha values
        // to control printing.
    } else {
        color(color_name, alpha=alpha) children();
    }
} 


base_instance = scotch_yoke_create(
    pin_diameter_, 
    range_of_travel_, 
    radial_allowance_, 
    axial_allowance_, 
    wall_thickness_,
    wall_height_, 
    bearing_width_,
    support_axle_);

mounted_instance = scotch_yoke_mounting(
    base_instance,
    frame_to_base=frame_to_base_,
    screw_name= screw_name_,
    nuts=[nuts_right_, nuts_left_]);

log_v1("mounted_instance", base_instance, verbosity, DEBUG);

if (show_stationary_parts_) { 
    options = []; // ["push rod support", [-s, s]]; // undef; 
    scotch_yoke_stationary_parts(
        mounted_instance, options=options, log_verbosity=verbosity);
}

//if (show_mounting_test_) {
//    log_v1("mounted_instance", mounted_instance, verbosity, DEBUG);
//    scotch_yoke_mounting(mounted_instance);
//}

if (show_moving_parts_) { 
    options = [use_dove_tails_option_];
    scotch_yoke_moving_parts(
        mounted_instance, 
        angle_, 
        extra_push_rod=extra_push_rod_, 
        options=options,
        log_verbosity=verbosity);
}


//*********************** End of Example============================================

function default_coloring() = [
    ["push_rod",  push_rod_coloring],
    ["traveller", traveller_coloring],
    ["bearing", bearing_coloring],
    ["crank_shaft", crank_shaft_coloring],
    ["support", support_coloring],
    ["wall", wall_coloring],  
    ["servo_mount", servo_mount_coloring]
]; 


function show_only(items) = [ for (item = items) 
    let (
        default = find_in_dct(default_coloring(), item, required=true),
        // Use default color, but set alpha to 1 
        //for full visibility
        entry = [item, [default[0], 1]]
    )
    entry
];


function process_options_for_coloring(options) = 
    is_undef(options) ? default_coloring() : 
    let (
        show_only_items = find_in_dct(options, "show only"),
        result = !is_undef(show_only_items) ? show_only(show_only_items) : 
            default_coloring(),
        last = undef
    )
    result;


function _scotch_yoke_assert_msg(name, value) = 
    str("Invalid argument: name=", name," value=", value);

    
module scotch_yoke_moving_parts(
        self, angle, extra_push_rod, options, log_verbosity=INFO) {
    function coloring(item) = 
        let(
            feature_coloring = process_options_for_coloring(options),
            value = find_in_dct(feature_coloring, item)
        )
        !is_undef(value) ? value : ["black", 0];
    
    function member(name) = scotch_yoke_attribute(self, name);
            
    use_dove_tails_option = find_in_dct(options, "use_dove_tails");
    use_dove_tails = is_list(use_dove_tails_option) ? 
                        use_dove_tails_option : [false, false];
    
    range_of_travel = member("range_of_travel");
    y_bearing = member("y_bearing");
    axle_height = member("axle_height");
    wall_thickness = member("wall_thickness");
    pin_diameter = member("pin_diameter");
    x_bearing = member("x_bearing");
    radial_allowance = member("radial_allowance");
    dz_travel = member("dz_travel");
    joiner_multiplier = member("joiner_multiplier");
    axial_allowance = member("axial_allowance");
    pin_length = member("pin_length");
    l_joiner = member("l_joiner");
    dy_push_rod = member("dy_push_rod");
    frame_to_base = member("frame_to_base"); 
    push_rod_height = member("push_rod_height");
    provide_x_axis_servo_mounting = member("provide_x_axis_servo_mounting");

    
    d_crank_clearance = 
        range_of_travel + joiner_multiplier*pin_diameter + 2 * radial_allowance;
    
    dy_traveller = -sin(angle) * range_of_travel/2;
    
    dz = axle_height;
    translate([0, dy_traveller, 0]) {
        display(coloring("push_rod")) push_rod();
        display(coloring("traveller")) translate([0, 0, dz]) traveller();
        push_rod_extension(0);
        push_rod_extension(1);
    }
   
    translate([0, 0, dz]) {
        rotate([angle, 0, 0]) {
            display(coloring("crank_shaft")) crank_shaft();
        }
    } 
    
    if (provide_x_axis_servo_mounting) {
        scotch_yoke_servo_mounting(self, angle, options);
    }
    

    module traveller() {
        dx = range_of_travel/2;
         difference() {
            hull() {
                translate([0, 0, dx]) rod(d=y_bearing, l=x_bearing, fa=fa_shape);
                block([x_bearing, y_bearing, dx], center=ABOVE);
                block([x_bearing, y_bearing, axle_height], center=BELOW);
            }   
            slot_clearance();
        }
    }
    
    module slot_clearance() {
        sliding_allowance = 0.1;
        d_tight_slot = pin_diameter + sliding_allowance;
        tr_plus = [0, 0, -dz_travel+3*radial_allowance];
        tr_minus = [0, 0, dz_travel-3*radial_allowance];


        translate(tr_plus) rod(d=pin_diameter+3*radial_allowance, l=2*x_bearing, fa=fa_shape);
        hull() {
            translate(tr_plus) rod(d=d_tight_slot, l=2*x_bearing, fa=fa_bearing);
            translate(tr_minus) rod(d=d_tight_slot, l=2*x_bearing, fa=fa_bearing);
        }
        center_reflect([1, 0, 0])
            translate([x_bearing/2, 0, 0]) 
                rod(d=d_crank_clearance, l=x_bearing, center=FRONT, fa=fa_bearing);
        
    }
    
    module push_rod(clearance=0, fin=true, options=undef) {
        assert(is_num(clearance), str(clearance));
        
        y =  y_bearing/2;
        z = member("push_rod_height");
        dy = y_bearing/2;
        dz = z - pin_diameter/2; 
        d = pin_diameter + 2 * clearance;
        translate([0, dy, dz]) rod(d, l=y, center=RIGHT+SIDEWISE+ABOVE);  
        translate([0, -dy, dz])rod(d, l=y, center=LEFT+SIDEWISE+ABOVE);

    }
    
    module push_rod_extension(i) {
        side_sign = [1, -1][i];
        hand = [RIGHT, LEFT][i];
        extra = 
            frame_to_base[i]
            - dy_push_rod
            + range_of_travel/2
            + max(extra_push_rod[i], axial_allowance); // What extra the user wants!
        dy = side_sign * dy_push_rod;
        dz = push_rod_height - pin_diameter/2;
        color("cyan") 
            if (use_dove_tails[i]) {
                translate([0, dy, dz]) {
                    sidewise_rod_with_dove_tail_ends(
                        d=pin_diameter, l=extra, center=hand, rank=3);
                }
            } else {
                translate([0, dy, dz]) 
                    rod(d=pin_diameter, l=extra, center=hand+SIDEWISE+ABOVE, rank=3);
            }
    }
    

    module crank_shaft() {
        dx = 2*x_bearing;
        l_bearing_pin = x_bearing + 4 * axial_allowance;
        translate([dx, 0, 0]) rod(d=pin_diameter, l=l_bearing_pin, fa=fa_bearing);
        translate([-dx, 0, 0]) rod(d=pin_diameter, l=l_bearing_pin, fa=fa_bearing);
        
        // Traveller pin
        translate([0, 0, -dz_travel]) rod(d=pin_diameter, l=pin_length);
        
        // Joiner crank 
        dx_j = x_bearing;
        d_j =  joiner_multiplier * pin_diameter;
        d_j_ex = range_of_travel/2 + joiner_multiplier*pin_diameter;
        center_reflect([1, 0, 0]) {
                translate([dx_j, 0, -dz_travel/2]) {
                    rod(d=d_j_ex, l=l_joiner, fa=fa_shape);
                }
        }
    }
    
    module handle_blank() {
        
        hull() {
            // Around axle centerline
            rod(d=1.25*pin_diameter, l=l_joiner, fa=fa_shape);

            // Support Footing
            center_reflect([0, 1, 0]) {
                translate([0, 0, -axle_height]) hull() {
                     translate([0, support_x, 0]) {
                        rod(d=r_pin, l=support_y, center=ABOVE, fa=fa_shape);
                     }
                }
            }
        }
    }
    
    module attach_handles(support_axle) {
        dx = 3 * (pin_length/2 + x_bearing/2);
        if (support_axle[0] == "handle") {
            translate([dx, 0, 0]) {
                handle_blank();
            } 
        } 
        if (support_axle[1] == "handle") {
            translate([-dx, 0, 0]) {
                handle_blank();
            }
        }
    }
} 

module scotch_yoke_servo_mounting(self, angle, options, log_verbosity) {
    
    function coloring(item) = 
        let(
            feature_coloring = process_options_for_coloring(options),
            value = find_in_dct(feature_coloring, item)
        )
        !is_undef(value) ? value : ["black", 0];
    
    function member(name) = scotch_yoke_attribute(self, name);
    
    dx_bearing_outside = member("dx_bearing_outside");
    axle_height = member("axle_height");
    pin_diameter = member("pin_diameter");
    wall_height = member("wall_height");
    radial_allowance = member("radial_allowance");
    axial_allowance = member("axial_allowance");
    wall_thickness = member("wall_thickness");

    display(coloring("servo_mount")) {
        translate([dx_bearing_outside, 0, axle_height]) {
            sub_micro_servo__mount_to_axle(
                axle_diameter=pin_diameter, 
                axle_height=axle_height,
                wall_height=wall_height,
                radial_allowance=radial_allowance, 
                axial_allowance=axial_allowance, 
                wall_thickness=wall_thickness, 
                angle=angle, 
                log_verbosity=log_verbosity);
        }
        
    } 

}


function scotch_yoke_create(
        pin_diameter, 
        range_of_travel, 
        radial_allowance, 
        axial_allowance=undef, 
        wall_thickness=undef,
        wall_height=undef,
        bearing_width=undef,
        support_axle=[false, true]) = 
    
    assert(!is_undef(pin_diameter))
    assert(!is_undef(range_of_travel))
    assert(!is_undef(radial_allowance))
    let(
        _axial_allowance = is_undef(axial_allowance) ? 
            radial_allowance_val : 
            axial_allowance,
        _wall_thickness = is_undef(wall_thickness) ? pin_diameter : wall_thickness,
        r_pin = pin_diameter / 2,
        d_slot = pin_diameter + 2 * radial_allowance,
        axle_height = max(range_of_travel + pin_diameter/2 + _wall_thickness, 1.5*pin_diameter),
        x_bearing = is_undef(bearing_width) ? pin_diameter : bearing_width,
        y_bearing = 3 * pin_diameter,
        pin_length = x_bearing + 2 * axial_allowance,
        dz_travel = -range_of_travel/2,

        support_x = 0.75 * r_pin,
        support_y = 0.75 * x_bearing,
        dy_inside = y_bearing/2 + range_of_travel/2,
        //dy_outside = dy_inside + _wall_thickness,
        dx_inside = 1.5*x_bearing,
        dx_outside = dx_inside + _wall_thickness,
        dx_bearing_outside = dx_inside + x_bearing,
        _wall_height = is_undef( wall_thickness) ? 2 * _wall_thickness + pin_diameter : wall_height,
        
        dy_push_rod = y_bearing/2 + range_of_travel/2,
        push_rod_fin_width = pin_diameter/4,
        push_rod_height = _wall_thickness + pin_diameter/2,
        push_rod_bore = pin_diameter + 2 * _axial_allowance,
        
        l_joiner = x_bearing - 2 * _axial_allowance,
        crank_shaft_length = 2*dx_outside + pin_diameter,
        //frame = [2 * dx_outside, 2 * dy_outside, wall_height],
        provide_x_axis_servo_mounting = true,
        joiner_multiplier = 1.5,
        last = undef
    )
    [
        ["axial_allowance", _axial_allowance],
        ["axle_height", axle_height],
        ["crank_shaft_length", crank_shaft_length],
        ["dx_inside", dx_inside],
        ["dx_outside", dx_outside],
        ["dx_bearing_outside", dx_bearing_outside],
        ["dy_inside",  dy_inside],
        ["dy_push_rod", dy_push_rod],
        ["dz_travel", dz_travel],
        ["d_slot", d_slot],
        ["joiner_multiplier", joiner_multiplier],
        ["l_joiner", l_joiner],
        ["pin_diameter", pin_diameter],
        ["pin_length", pin_length],
        ["provide_x_axis_servo_mounting", provide_x_axis_servo_mounting],
        ["push_rod_fin_width", push_rod_fin_width],
        ["push_rod_height", push_rod_height],
        ["push_rod_bore", push_rod_bore],
        ["range_of_travel", range_of_travel],
        ["radial_allowance", radial_allowance],
        ["r_pin", r_pin],
        ["support_axle", support_axle],
        ["support_x", support_x],
        ["support_y", support_y],
        ["wall_thickness", _wall_thickness],
        ["wall_height", _wall_height],
        ["x_bearing", x_bearing],
        ["y_bearing", y_bearing],  
    ];


function scotch_yoke_attribute(self, attribute) = find_in_dct(self, attribute);


module scotch_yoke_stationary_parts(self, options, log_verbosity=INFO) {

    scotch_yoke_bearings(self, options, log_verbosity);
    scotch_yoke_frame(self, log_verbosity);
    scotch_yoke_printing_support(self, options, log_verbosity) ;
}

module scotch_yoke_bearings(self, options, log_verbosity=INFO) {
    
    function coloring(item) = 
        let(
            feature_coloring = process_options_for_coloring(options),
            value = find_in_dct(feature_coloring, item)
        )
        !is_undef(value) ? value : ["black", 0];
            
    log_v1("self", self, log_verbosity, DEBUG);
    
    function member(name) = scotch_yoke_attribute(self, name);
    
    pin_diameter = member("pin_diameter");
    range_of_travel = member("range_of_travel");
    radial_allowance = member("radial_allowance");
    axial_allowance = member("axial_allowance");
    wall_thickness = member("wall_thickness");
    support_axle = member("support_axle");

    r_pin = member("r_pin");
    d_slot = member("d_slot");
    axle_height = member("axle_height");
    x_bearing = member("x_bearing");
    y_bearing = member("y_bearing");
    pin_length = member("pin_length");
    dz_travel = member("dz_travel");
    support_x = member("support_x");
    support_y = member("support_y");
    dx_inside = member("dx_inside");
    dy_inside = member("dy_inside");
    dx_outside = member("dx_outside");
    dy_outside = member("dy_outside");
    dx_bearing_outside =member("dx_bearing_outside");
    wall_height = member("wall_height");
    dy_traveller = member("dy_traveller");
    
    l_joiner = member("l_joiner"); 
    
    crank_shaft_length = member("crank_shaft_length");
    
    
    
    // The frame of reference creation is with the centerline of 
    // the crankshaft.  Buf for usage convenience,
    // show it with the origin at the bottom of the 
    // frame:
    
        
    translate([0, 0, axle_height]) {
        display(coloring("bearing")) bearings(); 
    }

    module bore_for_axle() {
        difference() {
            children();
            rod(d=d_slot, l=2*x_bearing, fa=fa_bearing); 
        }
    }
    
    module bearing() {
        bore_for_axle() {
            hull() {
                block([x_bearing, y_bearing, axle_height], center=BELOW, rank=4);
                if (axle_height < wall_height) {
                    block([x_bearing, y_bearing, wall_height-axle_height], center=ABOVE, rank=3);
                }
                rod(d=y_bearing, l=x_bearing, fa=fa_shape, rank=5);
            }
        }

    }
    
    module bearings() { 
        dx = dx_inside + x_bearing/2; 
        center_reflect([1, 0, 0]) {
            translate([dx, 0, 0]) {
                bearing();
            }
        } 
    }
  
}


module scotch_yoke_printing_support(self, options, log_verbosity) {
    
    function coloring(item) = 
        let(
            feature_coloring = process_options_for_coloring(options),
            value = find_in_dct(feature_coloring, item)
        )
        !is_undef(value) ? value : ["black", 0];
    
    function member(name) = scotch_yoke_attribute(self, name);
    
    support_axle = member("support_axle");
    pin_diameter = member("pin_diameter");
    axle_height = member("axle_height");
    dx_inside = member("dx_inside");
    x_bearing = member("x_bearing");
    axial_allowance = member("axial_allowance");
    radial_allowance = member("radial_allowance");
    dx_bearing_outside = member("dx_bearing_outside");
    y_bearing = member("y_bearing");
    push_rod_height = member("push_rod_height");
    dy_inside_plate = member("dy_inside_plate");
    
    support_locations = 
        is_list(options) ? find_in_dct(options, "push rod support") : undef;

    
    display(coloring("support")) {
        translate([0, 0, axle_height]) {
            crank_shaft_support(support_axle);
            

        }
        if (is_list(support_locations)) {
            support_push_rod(support_locations);
        }
        autogenerate_push_rod_support();
    }
    
    module crank_shaft_support(support_axle) {
         supported_cranks();
         supported_axle(support_axle);
    }

    
    module faux_support() {
        z_safe = axle_height - pin_diameter/2 - pin_diameter/4; 
        // Bearing faux support for testing as stand alone:
        translate([dx_inside, 0, -axle_height]) {
            block([1, 4, z_safe], center=ABOVE+FRONT);
            block([x_bearing, 4, 2], center=ABOVE+FRONT);
        }
    }
    

    module bridged_support() {
        
        l_bridge = 3*x_bearing - axial_allowance;
        translate([0, 0, -1.5]) {
            translate([0, 0, 1])
                rod(d=1, l=l_bridge, fa=fa_shape);
            translate([1.5*x_bearing + axial_allowance/4, 0, 0])
                can(d=1, h=1, center=BEHIND, fa=fa_shape);
            
        } 
    } 
    
    module supported_cranks() {
        use_bridging = true;
        if (use_bridging) {
            r_crank = pin_diameter/2 + pin_diameter/4;
            // Bridge from bearing to bearing, so no support to build plate.
            center_reflect([1, 0, 0]) {
                faux_support(); //  for testing as stand alone:
                
                translate([0, 0, -r_crank]) bridged_support();
            } 
        } 
    }
    
    module minimal_axle_support() {
        // Small cone.  Should break easily
        translate([0, 0, 0]) {
            rotate([0, -90, 0]) 
                cylinder(
                    d1 = pin_diameter - radial_allowance, 
                    d2 = pin_diameter + 4*radial_allowance,
                    h = 2 * axial_allowance,
                    $fn = 24);
            
        }
        // Support cone at bottom
        dz = -pin_diameter/2 - 1.5*axial_allowance;
        translate([0, 0, dz]) {
            can(
                d=2*radial_allowance, 
                h=4*axial_allowance, 
                center=BELOW+BEHIND, 
                fa=fa_shape);
            // faux bearing surface for test printing of axle.
            block([1,1, axle_height+dz], center=BELOW+FRONT);
        }
    }

    module supported_axle(support_axle) {
        if (support_axle[1]) {
            translate([-dx_bearing_outside, 0, 0]) {
                minimal_axle_support();
            }
        }

        if (support_axle[0]) {
            assert(false);
            mirror([1, 0, 0]) {
                translate([-dx_outside, 0, 0]) {
                    minimal_axle_support();
                }
            }
        }
    }
    
    function flexible_range(start, stop, increment) =
        increment < 0 ? 
            [ for (minus_l = [-start : -increment : -stop]) -minus_l ] :
            [ for (l = [start : increment : stop]) l ];

    
    module autogenerate_push_rod_support() {
        s_l = 3;
        gap = 5;
        increment = (s_l + gap);
        
        for (i = [0, 1]) {
            side_sign = [1, -1][i];
            start = dy_inside_plate[i] + 2*axial_allowance - s_l;
            stop = y_bearing/2 + 2*axial_allowance;
            auto_locations = flexible_range(side_sign*start, side_sign*stop, -side_sign * increment);
            
            log_s("start", start, log_verbosity, IMPORTANT);
            log_s("stop", stop, log_verbosity, IMPORTANT);
            log_s("increment", increment, log_verbosity, IMPORTANT);
            log_v1("auto_locations", auto_locations, log_verbosity, IMPORTANT);
            
            support_push_rod(auto_locations);
        }
    }
    
    module support_push_rod(support_locations) {
        log_v1("support_locations", support_locations, log_verbosity, IMPORTANT);
        
        reduced_locations = [
            for (location = support_locations) 
                if (abs(location) > y_bearing/2 + 2 * axial_allowance) location 
        ];
        log_v1("reduced_locations", reduced_locations, log_verbosity, IMPORTANT);
        tearaway(
            reduced_locations, 
            d=pin_diameter, 
            h=push_rod_height, 
            radial_allowance=radial_allowance,
            center=ABOVE,
            overlap_multiplier=1);
            
    }
    
 
    module tearaway(
            support_locations, 
            d, 
            h, 
            radial_allowance, 
            center, 
            overlap_multiplier,
            support_length=3) {
                
        z_p = h - d / 2;
        base = [1.5*z_p, support_length, infintesimal];
        neck = [infintesimal, support_length, infintesimal];
        z_neck = z_p + overlap_multiplier*radial_allowance;
        
        module tearaway_segment() {
            hull() {
               block(base, center=center, rank=10);
               translate([0, 0, z_neck]) block(neck, center=center);
            }
        }
        for (dy = support_locations) {
            translate([0, dy, 0]) tearaway_segment();
        } 
    }  
}


function scotch_yoke_mounting(
    base_instance,
    frame_to_base,
    screw_name=undef,
    nuts=undef,
    extra_push_rod=undef,
    log_verbosity=INFO) =
    
    let (
        dx_bearing_outside = scotch_yoke_attribute(base_instance, "dx_bearing_outside"),
        dy_inside = scotch_yoke_attribute(base_instance, "dy_inside"),
        wall_height = scotch_yoke_attribute(base_instance, "wall_height"),
        wall_thickness = scotch_yoke_attribute(base_instance, "wall_thickness"),
        
        use_nuts = is_undef(nuts) ? [false, false] : nuts,
        //Enough for the nut catchs (should depend on screw name!)
        plate_thickness = 
            [ for (i = [0, 1])  use_nuts[i] ? 7 : wall_thickness ],
        y_servo = 24,
        y_servo_offset = 6,
        y_servo_pillar = 4,
        y_servo_cl_to_pillar_outside = [
            y_servo_offset + y_servo_pillar, 
            y_servo - y_servo_offset + y_servo_pillar
        ],

        hub_clearance = 14,
        _frame_to_base = 
            [ for (i = [0, 1]) 
                max(frame_to_base[i], 
                    y_servo_cl_to_pillar_outside[i] + plate_thickness[i],
                    hub_clearance + plate_thickness[i],
                    dy_inside + plate_thickness[i])
            ],
            
        dy_inside_plate = _frame_to_base - plate_thickness,
        y_servo_wall = _frame_to_base - plate_thickness - y_servo_cl_to_pillar_outside,
        x_servo_pillar = 5,
        x_hub_frame = 17,
        x_servo_mount = dx_bearing_outside + x_hub_frame, 

        servo_wall = 
            [ for (i = [0, 1]) 
                [x_servo_pillar, y_servo_wall[i], wall_height]
            ],

        self = [
            ["scotch_yoke_mounting attributes", "-------------------------"],
            ["dy_inside_plate", dy_inside_plate],
            ["extra_push_rod", extra_push_rod],
            ["frame_to_base", _frame_to_base],
            ["nuts", nuts],
            ["plate_thickness", plate_thickness],
            ["screw_name", screw_name],
            ["servo_wall", servo_wall],
            ["use_nuts", use_nuts],
            ["y_servo_cl_to_pillar_outside", y_servo_cl_to_pillar_outside],
            ["y_servo_wall", y_servo_wall],
            ["x_servo_mount", x_servo_mount],
            ["x_servo_pillar", x_servo_pillar],
        ]
    )
    concat(base_instance, self);
            
            

    

module scotch_yoke_frame(self, log_verbosity=INFO) {
                        
    function plate_thickness_for_screw(screw_name) = screw_name=="M3" ? 7 : assert(false); 
    function member(name) = find_in_dct(self, name);
         
    frame = member("frame");
    wall_thickness = member("wall_thickness");
    wall_height = member("wall_height");
    dx_bearing_outside = member("dx_bearing_outside");
    dy_inside = member("dy_inside");
    pin_diameter = member("pin_diameter");
    y_bearing = member("y_bearing");
    push_rod_height = member("push_rod_height");
    push_rod_bore = member("push_rod_bore"); 
    frame_to_base = member("frame_to_base");
    use_nuts = member("use_nuts"); 
    plate_thickness = member("plate_thickness");        
    screw_name = member("screw_name"); 
    servo_wall = member("servo_wall");
    y_servo_cl_to_pillar_outside = member("y_servo_cl_to_pillar_outside");
    y_servo_wall = member("y_servo_wall");
    x_servo_pillar = member("x_servo_pillar");
    x_servo_mount = member("x_servo_mount");

    // Logic is to keep it consistent with the old yoke for now
    // in which dx was 6.
    shaft_clearance = max(6 - pin_diameter/2, 3.5);  
    screw_offset = pin_diameter/2 + shaft_clearance;
    x_plate_minus = screw_offset  + shaft_clearance + wall_thickness;

    for (i = [0, 1]) {
        if (frame_to_base[i] > 0) {
            base(i);
            bearing_wall(i); 
            servo_wall(i);
        }
    }
   
    module base(i) {
        side_sign = [1, -1][i];
        hand = [LEFT, RIGHT][i];
        x_b = x_plate_minus;
        x_f = x_servo_mount;
        y = plate_thickness[i];
        z = wall_height;
        
        translate([0, side_sign*frame_to_base[i], 0]) {
            bore_for_nuts_and_push_rod(use_nuts[i]) {
                color("lime") block([x_b, y, z], center=ABOVE+hand+BEHIND, rank=8);
                color("yellow") block([x_f, y, z], center=ABOVE+hand+FRONT, rank=8);
            }
        }
    }
    
    module bearing_wall(i) {
        side_sign = [1, -1][i];
        hand = [RIGHT, LEFT][i];
        dx = dx_bearing_outside;
        dy = y_bearing/2;
        color("gray") { 
            y_bearing_wall = frame_to_base[i] - plate_thickness[i] - y_bearing/2;
            size = [wall_thickness, y_bearing_wall, wall_height];
            center_reflect([1, 0, 0]) {
                translate([dx, side_sign * dy, 0]) {
                    block(size, center=ABOVE+hand+BEHIND, rank=3+10);
                }
            }
        }
    }
    
    module servo_wall(i) {
        color("orange") { 
            side_sign = [1, -1][i];
            hand = [RIGHT, LEFT][i];
            dx = x_servo_mount;
            dy = side_sign * y_servo_cl_to_pillar_outside[i];
            translate([dx, dy, 0]) {
                block(servo_wall[i], center=ABOVE+hand+BEHIND, rank=3);
            }
        }
    }

    module nutcatch_clearance() {
        nut_thickness = 2.18; // TODO extract for family
        
        y = plate_thickness_for_screw(screw_name);
        dz_hole = y; // different coordinate systems
        log_verbosity = INFO;
        dx = screw_offset;
        dy = y/2 - nut_thickness/2;
        dz = wall_height/2;
        center_reflect([1, 0, 0]) {
            translate([dx, dy, dz]) {
                rotate([90, -90, 0]) {
                    nutcatch_sidecut(name=screw_name);
                    translate([0, 0, dz_hole]) hole_through(name=screw_name);
                }
            }
        }
    }
    
    module push_rod_clearance() {
        translate([0, 0, push_rod_height]) {
            rod(d=push_rod_bore, l=50, center=SIDEWISE);
        }
    }
    
    module bore_for_nuts_and_push_rod(screw_name, nuts=true) {
        difference() {
            children();
            if (nuts) {
                nutcatch_clearance();
            }
            push_rod_clearance();
        }

    }
           
}


module sidewise_rod_with_dove_tail_ends(d, l, center, rank=1) {
    assert(is_num(d));
    a = center==RIGHT ? 90 : 
        center==LEFT ? -90: 
        assert(false, "Only LEFT or RIGHT supported");
    translate([0, 0, d/2]) {
        rotate([0, 180, a]) {
            translate([-l, 0, 0]) { // This should get it to the back
                rod_to_block_dove_tail_connection(
                        plate_side=false, diameter=d, slide_allowance=0.2) {
                    rod(d=d, l=l, center=FRONT, fa=fa_bearing, rank=rank);
                }
            }
        }
    }
}

    















