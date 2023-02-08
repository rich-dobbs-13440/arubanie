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
support_axle = [true, true];

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

scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    angle,
    support_axle);

dimensions = scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    angle,
    support_axle);
  
log_v1("dimensions", dimensions, verbosity, INFO);  
    
//horn_thickness = 2;
//* horn(h=horn_thickness);
//translate([horn_thickness, 0, 0]) rotate([45, 0, 0]) rotate([0, 90, 0]) bare_hub(horn_thickness=horn_thickness);

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
        ["support_axle", support_axle],
        
        ["frame", frame],
        ["crank_shaft_length", crank_shaft_length],
        ["push_rod_length", push_rod_length],
        ["push_rod_fin_width", push_rod_fin_width],
        
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
    wall_height = extract("wall_height");
    dy_traveller = extract("dy_traveller");
    l_joiner = extract("l_joiner"); 

    // The frame of reference creation is with the centerline of 
    // the crankshaft.  Buf for usage convenience,
    // render it with the origin at the bottom of the 
    // frame:
    translate([0, 0, axle_height]) assembly(support_axle);
    
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


     


    module supported_cranks() {
        dx = x_bearing;
        
        // Design so that the support can be torn away
        x_p = l_joiner - 2 * axial_allowance;
        y_p = pin_diameter;
        z_p = axle_height - 0.75*pin_diameter + 0.5*radial_allowance;
        dx_p = -axle_height;
        center_reflect([1, 0, 0]) {
            translate([dx, 0, 0]) {
                translate([0, 0, dx_p]) block([x_p, y_p, z_p], center=ABOVE);
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
    
    module support_blank() {
        
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

    module supported_axle(support_axle) {
        dx = 3 * (pin_length/2 + x_bearing/2);
        if (support_axle[0] && support_axle[1]  ) {
            center_reflect([1, 0, 0]) {
                translate([dx, 0, 0]) {
                    support_blank();
                }
            }
        } else if (support_axle[0]) {
            translate([dx, 0, 0]) {
                support_blank();
            } 
        } else if (support_axle[1]) {
            translate([-dx, 0, 0]) {
                support_blank();
            }
        } else {
            assert(false, str("Don't know how to handle 'support_axle'", support_axle));
        }
    }
   
}

