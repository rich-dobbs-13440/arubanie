include <logging.scad>
include <centerable.scad>
use <shapes.scad>
 use <not_included_batteries.scad>
use <small_servo_cam.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>


eps = 0.001;
fa_as_arg = 5;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [ Test ] */

pin_diameter = 4;
range_of_travel = 6;
radial_allowance = 0.4;
axial_allowance = 0.4;
wall_thickness = undef; // [undef, 2, 4];
angle = 0; // [-180 : 5: 180]
support_plus_x_axle = true;
support_negative_x_axle = true;
support_axle = [support_plus_x_axle, support_negative_x_axle];

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

_support_axle = ["servo horn", true];

dimensions = scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    angle,
    _support_axle);

log_v1("dimensions", dimensions, verbosity, INFO);



scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    angle,
    _support_axle);

//***********************End of Example

function scotch_yoke(
        pin_diameter, 
        range_of_travel, 
        radial_allowance, 
        axial_allowance=undef, 
        wall_thickness=undef, 
        angle = 0,
        support_axle=[true, true]) =
    
    assert(!is_undef(pin_diameter))
    assert(!is_undef(range_of_travel))
    assert(!is_undef(radial_allowance))
    let(
        _axial_allowance = is_undef(axial_allowance) ? radial_allowance_val : axial_allowance,
        _wall_thickness = is_undef(wall_thickness) ? pin_diameter : wall_thickness,
        r_pin = pin_diameter / 2,
        d_slot = pin_diameter + 2 * radial_allowance,
        axle_height = range_of_travel + pin_diameter/2 + _wall_thickness,
        x_bearing = pin_diameter,
        y_bearing = pin_diameter + 2 * _wall_thickness,
        pin_length = x_bearing + 2 * axial_allowance,
        dz_travel = -range_of_travel/2,

        support_x = 0.75 * r_pin,
        support_y = 0.75 * x_bearing,
        end_clearance = _wall_thickness/2,
        dy_inside = axle_height + end_clearance,
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
        angle = 0,
        support_axle=[true, true]) {

    calculations_and_defaults = 
            scotch_yoke(
            pin_diameter, 
            range_of_travel, 
            radial_allowance, 
            axial_allowance, 
            wall_thickness, 
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
    horn_thickness = 3;
    horn_radius = 11.0;
    horn_overlap = 0.5;
    hub_backer_l = 2;
    hub_backer_diameter = 16;
    dx_horn = horn_thickness + axial_allowance + hub_backer_l - horn_overlap;
    dx_servo_offset = 11.32; // //8.65;
    dx_servo = dx_horn +  dx_servo_offset;
    
    // The frame of reference creation is with the centerline of 
    // the crankshaft.  Buf for usage convenience,
    // render it with the origin at the bottom of the 
    // frame:
    translate([0, 0, axle_height]) assembly(support_axle);
    
    if (provide_x_axis_servo_mounting) {
        
        translate([dx_outside, 0, axle_height]) {
            rotate([angle, 0, 0]) {  // sync hub rotation to crank shaft rotation
                x_axis_servo_hub(angle);
            }
        }
        // Support horn for 3D printing
        size_support = [
            2*horn_thickness-0.2, 
            0.75*horn_radius, 
            0.25*horn_radius
        ];
        translate([dx_outside+dx_horn, 0, 0])
            block(size_support, center=ABOVE);
        
        translate([dx_outside, 0, 0]) rotary_servo_mount();
    }
    
    servo_width = 12.00;
    size_pillar = [6, 4, axle_height + servo_width/2];
    x_servo_side_wall = dx_servo - size_pillar.x;
    
    
    module servo_mounting_pillars() {
        servo_length = 24.00;
        servo_axle_x_offset = 6;
        dy_plus = servo_axle_x_offset;  // Axis differ by 90 degerees!
        dy_minus = -servo_length + servo_axle_x_offset;
        
        
        translate([dx_servo, dy_plus, 0]) {
            block(size_pillar, center=ABOVE+BEHIND+RIGHT);
        }
        translate([dx_servo, dy_minus, 0]) {
            block(size_pillar, center=ABOVE+BEHIND+LEFT);
        }
    }
    
    module servo_side_wall_extension() {
        
        side_wall = [x_servo_side_wall, wall_thickness, wall_height];
        center_reflect([0, 1, 0]) {
            translate([0, -dy_inside, 0]) { 
                block(side_wall, center=FRONT+ABOVE+LEFT);
            }
        }  
    }
    
    module servo_right_joiner() {
        y = wall_thickness + size_pillar.y;
        dx = x_servo_side_wall;
        translate([dx, dy_inside, 0])  
            block([wall_thickness, y, wall_height], center=ABOVE+FRONT);
    }
    
    module servo_left_joiner() {
        y = wall_thickness + size_pillar.y;
        dx = x_servo_side_wall;
        translate([dx, -dy_inside, 0])  
            block([wall_thickness, y, wall_height], center=ABOVE+BEHIND+LEFT);
    }
    
    module rotary_servo_mount() {
        servo_mounting_pillars();
        servo_side_wall_extension();
        servo_right_joiner();
        servo_left_joiner();

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
    
    
    module x_axis_servo_hub(angle) {

        translate([axial_allowance, 0, 0]) {
            rod(d=hub_backer_diameter, l=hub_backer_l, center=FRONT);
        }

        
        translate([dx_horn, 0, 0]) {
            rotate([45, 0, 0]) {
                rotate([0, 90, 0]) 
                    bare_hub(horn_thickness);
            }
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
        // bearing_pins
        //dx = 2 * (pin_length/2 + x_bearing/2);
        dx = 2*x_bearing;
        translate([dx, 0, 0]) rod(d=pin_diameter, l=x_bearing + pin_diameter);
        translate([-dx, 0, 0]) rod(d=pin_diameter, l=x_bearing + pin_diameter);
        
        // Traveller pin
        translate([0, 0, -dz_travel]) rod(d=pin_diameter, l=pin_length+eps);
        
        // Joiner crank 
        dx_j = x_bearing;
        d_j = 1.5 * pin_diameter;
        center_reflect([1, 0, 0]) {
            hull() {
                translate([dx_j, 0, 0]) rod(d=d_j, l=l_joiner);
                translate([dx_j, 0, -dz_travel]) rod(d=d_j, l=l_joiner);
            }
        }

    }


    module faux_support() {
        z_safe = axle_height - pin_diameter/2 - pin_diameter/4; 
        // Bearing faux support for testing as stand alone:
        translate([dx_inside, 0, -axle_height]) {
            block([1, 4, z_safe], center=ABOVE+FRONT);
            block([x_bearing, 4, 2], center=ABOVE+FRONT);
        }
        // Traveler faux support
        difference() {
            translate([x_bearing/2, 0, -axle_height]) {
                block([1, 4, z_safe], center=BEHIND+ABOVE);
                block([x_bearing, 4, 2], center=BEHIND+ABOVE);
            }
            slot_clearance();
        }
    }
    

    module bridged_support() {
        translate([0, 0, -1.5]) {
            translate([x_bearing/2, 0, 0.5]) { 
                can(d=1, h=pin_diameter, center=FRONT+BELOW);
            }
            translate([1.5*x_bearing, 0, 0])
                block([radial_allowance, 1, 1], center=BEHIND);
            translate([x_bearing, 0, 1])
                rod(l=x_bearing-axial_allowance, d=1);
        } 
    } 
    

    module supported_cranks() {
        use_bridging = true;
        if (use_bridging) {
            // Bridge from bearing to traveller, so no support to build plate.
            center_reflect([1, 0, 0]) {
                faux_support(); //  for testing as stand alone:
                r_crank = pin_diameter/2 + pin_diameter/4;
                translate([0, 0, -r_crank]) bridged_support();
            }  


        } else {
            // Design so that the support can be torn away.
            // Blocky.  
            dx = x_bearing;
            x_p = l_joiner - 2 * axial_allowance;
            y_p = pin_diameter;
            z_p = axle_height - 0.75*pin_diameter + 0.0*radial_allowance;
            dx_p = -axle_height;
            center_reflect([1, 0, 0]) {
                translate([dx, 0, 0]) {
                    translate([0, 0, dx_p]) block([x_p, y_p, z_p], center=ABOVE);
                }
            } 
        }
    }

    module slot_clearance() {
        //rod(d=d_slot, l=2*x_bearing);
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
        translate([0, 0, -pin_diameter/2 - radial_allowance]) {
            rod(d=4*radial_allowance, l=4*axial_allowance, center=BELOW);
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
    }
   
}

