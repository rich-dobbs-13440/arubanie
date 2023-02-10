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




include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <small_servo_cam.scad>
use <sub_micro_servo.scad>
use <9g_servo.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>


eps = 0.001;
fa_as_arg = 5;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [ Test ] */

pin_diameter = 5;
range_of_travel = 6;
radial_allowance = 0.4;
axial_allowance = 0.4;
wall_thickness = 2; // [undef, 2, 4];
bearing_width = 2;
angle = 0; // [0 : 5: 270]
support_plus_x_axle = true;
support_negative_x_axle = true;
_support_axle = [support_plus_x_axle, support_negative_x_axle];

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

module end_of_customization() {}



//***********************End of Example

function _scotch_yoke_assert_msg(name, value) = str("Invalid argument: name=", name,, " value=", value);

function scotch_yoke(
        pin_diameter, 
        range_of_travel, 
        radial_allowance, 
        axial_allowance=undef, 
        wall_thickness=undef,
        bearing_width=undef,
        angle = 0,
        support_axle=[true, true]) =
    
    assert(!is_undef(pin_diameter))
    assert(!is_undef(range_of_travel))
    assert(!is_undef(radial_allowance))
    assert(is_num(angle), _scotch_yoke_assert_msg("angle", angle))
    let(
        _axial_allowance = is_undef(axial_allowance) ? radial_allowance_val : axial_allowance,
        _wall_thickness = is_undef(wall_thickness) ? pin_diameter : wall_thickness,
        r_pin = pin_diameter / 2,
        d_slot = pin_diameter + 2 * radial_allowance,
        axle_height = range_of_travel + pin_diameter/2 + _wall_thickness,
        x_bearing = is_undef(bearing_width) ? pin_diameter : bearing_width,
        y_bearing = pin_diameter + 2 * _wall_thickness,
        pin_length = x_bearing + 2 * axial_allowance,
        dz_travel = -range_of_travel/2,

        support_x = 0.75 * r_pin,
        support_y = 0.75 * x_bearing,
        end_clearance = 0.5,
        dy_inside = y_bearing/2 + range_of_travel/2  + end_clearance,
        dy_outside = dy_inside + _wall_thickness,
        dx_inside = 1.5*x_bearing,
        dx_outside = dx_inside + _wall_thickness,
        wall_height = 2 * _wall_thickness + pin_diameter,
        dy_traveller = -sin(angle) * range_of_travel/2,
        push_rod_length = 2 * (dy_inside + 2 * _wall_thickness) + range_of_travel,
        push_rod_fin_width = pin_diameter/4,
        l_joiner = x_bearing - 2 * axial_allowance,
        crank_shaft_length = 2*dx_outside + pin_diameter,
        frame = [2 * dx_outside, 2 * dy_outside, wall_height],
        provide_x_axis_servo_mounting = support_axle[0] == "servo horn",
        _support_axle = [
            provide_x_axis_servo_mounting ? false : support_axle[0],
            support_axle[1],
        ],

        last = undef
    )
    assert(!is_undef(axle_height))
    assert(!is_undef(support_x))
    assert(!is_undef(end_clearance))
    assert(!is_undef(dy_inside))
    [
        ["pin_diameter", pin_diameter],
        ["range_of_travel", range_of_travel],
        ["radial_allowance", radial_allowance],
        ["axial_allowance", _axial_allowance],
        ["wall_thickness", _wall_thickness],
        ["angle", angle],
        ["support_axle", _support_axle],
        
        ["frame", frame],
        ["crank_shaft_length", crank_shaft_length],
        ["push_rod_length", push_rod_length],
        ["push_rod_fin_width", push_rod_fin_width],
        ["provide_x_axis_servo_mounting", provide_x_axis_servo_mounting],
        
        ["x_bearing", x_bearing],
        ["y_bearing", y_bearing],
        ["axle_height", axle_height],
        ["dz_travel", dz_travel],
        ["d_slot", d_slot],
        ["dy_inside",  dy_inside],
        ["dy_outside",  dy_outside],
        ["dx_inside", dx_inside],
        ["dx_outside", dx_outside],
        ["pin_length", pin_length],
        ["support_x", support_x],
        ["support_y", support_y],
        ["r_pin", r_pin],
        ["wall_height", wall_height],
        ["dy_traveller", dy_traveller],
        ["l_joiner", l_joiner],
        
    ];
    
    

    
module scotch_yoke(
        pin_diameter, 
        range_of_travel, 
        radial_allowance, 
        axial_allowance, 
        wall_thickness,
        bearing_width,
        angle = 0,
        support_axle=[true, true]) {

    calculations_and_defaults = 
            scotch_yoke(
            pin_diameter, 
            range_of_travel, 
            radial_allowance, 
            axial_allowance, 
            wall_thickness, 
            bearing_width,
            angle,
            support_axle);
            
    _scotch_yoke_implementation(calculations_and_defaults);        
            
}

module _scotch_yoke_implementation(calculations_and_defaults) {
            
    log_v1("Calculations and defaults", calculations_and_defaults, verbosity, DEBUG);
    
    function extract(attribute) = find_in_dct(calculations_and_defaults, attribute);
    
    dct = calculations_and_defaults;
     
    pin_diameter = extract("pin_diameter");
    range_of_travel = extract("range_of_travel");
    radial_allowance = extract("radial_allowance");
    axial_allowance = extract("axial_allowance");
    wall_thickness = extract("wall_thickness");
    angle = extract("angle");
    support_axle = extract("support_axle");
    
    
    push_rod_length = extract("push_rod_length");
    push_rod_fin_width = extract("push_rod_fin_width");

    r_pin = extract("r_pin");
    d_slot = extract("d_slot");
    axle_height = extract("axle_height");
    x_bearing = extract("x_bearing");
    y_bearing = extract("y_bearing");
    pin_length = extract("pin_length");
    dz_travel = extract("dz_travel");
    support_x = extract("support_x");
    support_y = extract("support_y");
    dx_inside = extract("dx_inside");
    dy_inside = extract("dy_inside");
    dx_outside = extract("dx_outside");
    dy_outside = extract("dy_outside");
    wall_height = extract("wall_height");
    dy_traveller = extract("dy_traveller");
    l_joiner = extract("l_joiner"); 
    provide_x_axis_servo_mounting= extract("provide_x_axis_servo_mounting");
    crank_shaft_length = extract("crank_shaft_length");
    joiner_multipler = 1.5;
    d_crank_clearance = range_of_travel + joiner_multipler*pin_diameter + 2 * radial_allowance;
    
    // The frame of reference creation is with the centerline of 
    // the crankshaft.  Buf for usage convenience,
    // render it with the origin at the bottom of the 
    // frame:
    translate([0, 0, axle_height]) assembly(support_axle);
    
    if (provide_x_axis_servo_mounting) {
        
        translate([dx_outside, 0, axle_height]) {
            sub_micro_servo_mount_to_axle(
                axle_diameter=4, 
                axle_height= axle_height,
                wall_height=6,
                radial_allowance=radial_allowance, 
                axial_allowance=axial_allowance, 
                wall_thickness=wall_thickness, 
                angle=angle);
        }
        
    }
    


    module assembly(support_axle) {
        
        // Caution:  The order of assembly must be from inner 
        // to outer for z-ordering and transparency to work as 
        // expected!
        
        translate([0, dy_traveller, 0]) {
            display(push_rod_coloring) push_rod();
            display(traveller_coloring) traveller();
        } 

        rotate([angle, 0, 0]) {
            display(crank_shaft_coloring) crank_shaft();
        }
        display(bearing_coloring) bearings();
        
        rotate([angle, 0, 0]) {
            display(support_coloring) crank_shaft_support(support_axle);
        }
        
        display(wall_coloring) {
            bearing_side_walls();
            bearing_yokes();
        }

    }

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
    

    module bearing_side_walls() {
        x = wall_thickness;
        y = 2 * (dy_inside + wall_thickness);
        z = wall_height;
        center_reflect([1, 0, 0]) {
            translate([dx_inside, 0 ,0])
                bore_for_axle(10) {
                    translate([0, 0 , -axle_height]) {
                        block([x, y, z], center=ABOVE+FRONT);
                    }
                }
        }
    }
    
    module bearing_yokes() {
        x = 2 * (dx_inside + wall_thickness);
        y = wall_thickness;
        z = wall_height;
        center_reflect([0, 1, 0]) {
            bore_for_push_rod() { 
                translate([0, dy_inside, -axle_height]) {

                    block([x, y, z], center=ABOVE+RIGHT);
                }
            }
        }
    }

    module bore_for_axle(eps_mul) {
        
        render() difference() {
            children();
            rod(d=d_slot+eps_mul * eps, l=2*x_bearing);
        }
    }
    
    module bearing() {

        bore_for_axle(0) {
            hull() {
                block([x_bearing+4*eps, y_bearing, axle_height], center=BELOW);
                rod(d=y_bearing, l=x_bearing+0.1);
            }
        }

    }
    
    module bearings() { 
        dx = dx_inside + x_bearing/2 -4 * eps; // make it definitely on the inside
        center_reflect([1, 0, 0]) {
            translate([dx, 0, -4*eps]) {
                bearing();
            }
        } 
    }
    
    module crank_shaft_support(support_axle) {
         supported_cranks();
         supported_axle(support_axle);
    }

    module crank_shaft() {
        dx = 2*x_bearing;
        l_bearing_pin = x_bearing + 4 * axial_allowance;
        translate([dx, 0, 0]) rod(d=pin_diameter, l=l_bearing_pin);
        translate([-dx, 0, 0]) rod(d=pin_diameter, l=l_bearing_pin);
        
        // Traveller pin
        translate([0, 0, -dz_travel]) rod(d=pin_diameter, l=pin_length+eps);
        
        // Joiner crank 
        dx_j = x_bearing;
        d_j =  joiner_multipler * pin_diameter;
        d_j_ex = range_of_travel/2 + joiner_multipler*pin_diameter;
        center_reflect([1, 0, 0]) {
                translate([dx_j, 0, -dz_travel/2]) rod(d=d_j_ex, l=l_joiner);
        }

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
                rod(d=1, l=l_bridge);
            translate([1.5*x_bearing + axial_allowance/4, 0, 0])
                can(d=1, h=1, center=BEHIND);
            
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

    module slot_clearance() {
        sliding_allowance = 0.1;
        d_tight_slot = pin_diameter + sliding_allowance;

        hull() {
            rod(d=d_tight_slot, l=2*x_bearing);
            translate([0, 0, -dz_travel+2*radial_allowance]) rod(d=d_slot, l=2*x_bearing);
        }
        hull() {
            rod(d=d_tight_slot, l=2*x_bearing);
            translate([0, 0, dz_travel-2*radial_allowance]) rod(d=d_tight_slot, l=2*x_bearing);
        }
        center_reflect([1, 0, 0])
            translate([x_bearing/2, 0, 0]) 
                rod(d=d_crank_clearance, l=x_bearing, center=FRONT);
        
    }

    module traveller() {
        dx = range_of_travel/2;
         difference() {
            hull() {
                translate([0, 0, dx]) rod(d=y_bearing, l=x_bearing);
                block([x_bearing, y_bearing, dx], center=ABOVE);
                block([x_bearing, y_bearing, axle_height], center=BELOW);
            }   
            slot_clearance();
        }
    }
    
    module push_rod(clearance=0) {
        x =  push_rod_fin_width + 2 * clearance; 
        y = push_rod_length;
        z = wall_thickness + pin_diameter/2;
        size_fin = [x, y, z];
        
        dz = -axle_height + 5*eps;  // Move to build plate;
        d = pin_diameter + 2 * clearance;
        dz_rod = wall_thickness - clearance; // Place at top of fin.
        
        difference() {
            translate([0, 0, dz]) {
                block(size_fin, center=ABOVE);
                translate([0, 0, dz_rod]) {
                    rod(d=d, l=y, center=SIDEWISE+ABOVE);
                }
            }
            slot_clearance();
        }

    }
    
    module bore_for_push_rod() {
        render() difference() {
            children();
            push_rod(radial_allowance);
        }    
    }
    
    module handle_blank() {
        
        hull() {
            // Around axle centerline
            rod(d=1.25*pin_diameter, l=l_joiner);

            // Support Footing
            center_reflect([0, 1, 0]) {
                translate([0, 0, -axle_height]) hull() {
                     translate([0, support_x, 0]) rod(d=r_pin, l=support_y, center=ABOVE);
                }
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
            can(d=2*radial_allowance, h=4*axial_allowance, center=BELOW+BEHIND);
            // faux bearing surface for test printing of axle.
            block([1,1, axle_height+dz], center=BELOW+FRONT);
        }
        

    }

    module supported_axle(support_axle) {
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
        if (support_axle[1]) {
            translate([-dx_outside, 0, 0]) {
                minimal_axle_support();
            }
        }
         if (support_axle[0]) {
            mirror([1, 0, 0]) {
                translate([-dx_outside, 0, 0]) {
                    minimal_axle_support();
                }
            }
        }
    }
   
}

module scotch_yoke_mounting(
        dimensions,
        extend_left,
        extend_right,
        extra_push_rod,
        screw_mounting="M3") {
                        
                        
    function extract(attribute) = find_in_dct(dimensions, attribute);
            
    frame = extract("frame");
    wall_thickness = extract("wall_thickness");
    wall_height = extract("wall_height");


    
    if (is_num(extend_left)) {
        y_extend = extend_left;
        hub_frame = [10.25, 8.0, 6]; // TODO: fetch from sub_micro_servo
        y_servo_mount = 4;
        dx_f = frame.x/2;
        dy_f = -(frame.y/2);
        dy_extend = dy_f - y_extend;
        dx_hf = dx_f + hub_frame.x;
        
        push_rod_extension = [wall_thickness, y_extend, wall_height];
        push_rod_extension_end = [frame.x, wall_thickness, wall_height];
        hub_frame_extension = [
            wall_thickness, 
            y_extend - hub_frame.y/2 - y_servo_mount, 
            wall_height];
        hub_frame_extension_end = [hub_frame.x, wall_thickness, wall_height];
        hub_screw_plate = [
            hub_frame_extension_end.x, 
            y_extend - hub_frame.y/2, 
            wall_thickness];
        

        color("LawnGreen") { 
            center_reflect([1, 0, 0]) {
                translate([dx_f, dy_f, -3*eps]) {
                    block(push_rod_extension, center=ABOVE+LEFT+BEHIND);
                }
            }
        }
        color("ForestGreen") { 
            translate([0, dy_extend, -6*eps]) {
                block(push_rod_extension_end, center=ABOVE+RIGHT);
            }
        }
        color("Orange") { 
            translate([dx_hf, dy_extend, -3*eps]) {
                block(hub_frame_extension, center=ABOVE+RIGHT+BEHIND);
            }
        }
        color("OrangeRed") { 
            translate([dx_hf, dy_extend, -6*eps]) {
                block(hub_frame_extension_end, center=ABOVE+RIGHT+BEHIND);
            }
        }
        color("Salmon") { 
            translate([dx_hf, dy_extend, -9*eps]) {
                block(hub_screw_plate, center=ABOVE+RIGHT+BEHIND);
            }
        }
        
        if (screw_mounting=="M3") {
            // Not enough space to locate two screw holes on extended frame.
            // So only put one there.  Put screw holes on floor, with 
            // the assumption that the user will create a plate
            
      
        }
 
    }
    if (is_num(extend_right)) {
        assert(false, "Not implemented yet");
    }
            
}
//        // Provide a bar across the ends around the push rod
//        color("Coral") {
//            translate([0, dy_extend, 0]) block(size_end_bar, center=ABOVE+RIGHT);
//        }
        
        
        // 
//            translate([dx, dy_extend, 0]) {
//               block(size_screw_bar, center=ABOVE+FRONT+RIGHT);
        
//        if (screw_mounting=="M3" || extend_servo_joiner) {

//            }
//        } 
//
//        if (extend_servo_joiner) {
//            
//            dx_j = dx + 10;
//            dy_j = dy - hub_offset.y;
//            
//            color("orange") translate([dx_j, dy_j, -1*eps]) {
//                block(size_joiner_extend, center=ABOVE+LEFT+BEHIND);
//            }
//            
//        }




support_axle = ["servo horn", true];

dimensions = scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness,
    bearing_width,
    angle,
    support_axle);

log_v1("dimensions", dimensions, verbosity, DEBUG);

scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness,
    bearing_width, 
    angle,
    support_axle);
    
    
scotch_yoke_mounting(
    dimensions,
    extend_left=20,
    extend_right=false,
    extra_push_rod=5,
    screw_mounting="M3");
    















