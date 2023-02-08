include <centerable.scad>
use <shapes.scad>
 use <not_included_batteries.scad>
use <small_servo_cam.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>


eps = 0.001;
fa_as_arg = 5;

/* [ Test ] */

pin_diameter = 4;
range_of_travel = 6;
radial_allowance = 0.4;
axial_allowance = 0.4;
wall_thickness = 2;
angle = 0; // [-180 : 5: 180]

/* [ Visibility] */

traveller_color = "blue";
traveller_alpha = 1.0; // [0, 0.25, 0.5, 1]
bearing_color = "red";
bearing_alpha = 1.0; // [0, 0.25, 0.5, 1]
crank_shaft_color = "green";
crank_shaft_alpha = 1.0; // [0, 0.25, 0.5, 1]
support_color = "orange";
support_alpha = 1.0; // [0, 0.25, 0.5, 1]
wall_color = "white";
wall_alpha = 1.0; // [0, 0.25, 0.5, 1]

scotch_yoke(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance); 
    //wall_thickness, 
    //angle,
    //support_axle=[false, true]);

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
        axle_height = range_of_travel + pin_diameter/2 + radial_allowance + _wall_thickness,
        x_bearing = pin_diameter,
        y_bearing = d_slot + 2 * _wall_thickness,
        pin_length = x_bearing + 2 * axial_allowance,
        dz_travel = -range_of_travel/2,

        support_x = 0.75 * r_pin,
        support_y = 0.75 * x_bearing,
        end_clearance = _wall_thickness/2,
        dy_inside = sqrt(axle_height*axle_height + support_x*support_x) + end_clearance,
        dx_inside = x_bearing / 2 + axial_allowance + x_bearing + axial_allowance,
        wall_height = 2 * _wall_thickness + pin_diameter + radial_allowance,
        dy_traveller = -sin(angle) * range_of_travel/2,
        push_rod_length = 2 * (dy_inside + 2 * wall_thickness) + range_of_travel
        
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
        
        ["push_rod_length", push_rod_length],
        
        
        ["x_bearing", x_bearing],
        ["y_bearing", y_bearing],
        ["axle_height", axle_height],
        ["dz_travel", dz_travel],
        ["d_slot", d_slot],
        ["dy_inside",  dy_inside],
        ["dx_inside", dx_inside],
        ["pin_length", pin_length],
        ["support_x", support_x],
        ["support_y", support_y],
        ["r_pin", r_pin],
        ["wall_height", wall_height],
        ["dy_traveller", dy_traveller],
        
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
            
    echo("calculations_and_defaults", calculations_and_defaults);
    
    function extract(attribute) = find_in_dct(calculations_and_defaults, attribute);
    
    dct = calculations_and_defaults;
     
    pin_diameter = extract("pin_diameter");
    range_of_travel = extract("range_of_travel");
    radial_allowance = extract("radial_allowance");
    axial_allowance = extract("axial_allowance");
    wall_thickness = extract("wall_thickness");
    angle = extract("angle");
    support_axle = extract("support_axle");
    
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

    assembly(support_axle);

    module assembly(support_axle) {
        
        translate([0, dy_traveller, 0]) {
            traveller();
            push_rod();
        } 

        rotate([angle, 0, 0]) {
            color(crank_shaft_color, alpha=crank_shaft_alpha)
                crank_shaft();
            color(support_color, alpha=support_alpha) 
                crank_shaft_strengthen_and_support(support_axle);
        }
        
        color(bearing_color, alpha=bearing_alpha) bearings();
        color(wall_color, alpha=wall_alpha) {
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
         {
            bore_for_axle(0) {
                bearing_blank();
            }
        }
    }
    
    module bearings() { 
        dx = 2 * (pin_length/2 + x_bearing/2) -4 * eps;
        center_reflect([1, 0, 0]) {
            translate([dx, 0, -10*eps]) {
                bearing();
            }
        } 
    }
    
    module crank_shaft_strengthen_and_support(support_axle) {
         supported_cranks();
         supported_axle(support_axle);
    }

    module crank_shaft() {
        // bearing_pins
        dx = 2 * (pin_length/2 + x_bearing/2);
        translate([dx, 0, 0]) rod(d=pin_diameter, l=pin_length + 2 * radial_allowance);
        translate([-dx, 0, 0]) rod(d=pin_diameter, l=pin_length + 2 * radial_allowance);
        
        // Traveller pin
        translate([0, 0, -dz_travel]) rod(d=pin_diameter, l=pin_length+eps);
        
        // Joiner crank 
        dx_j = pin_length/2 + x_bearing/2;
        center_reflect([1, 0, 0]) {
            hull() {
                translate([dx_j, 0, 0]) rod(d=pin_diameter, l=x_bearing);
                translate([dx_j, 0, -dz_travel]) rod(d=pin_diameter, l=x_bearing);
            }
        }

    }

    module push_rod(clearance=0) {
        x = wall_thickness + 2 * clearance; 
        
        y = push_rod_length;
        z = wall_thickness + pin_diameter/2;
        dy = y_bearing/2;
        dz = -axle_height;
        d = pin_diameter + 2 * clearance;
        
            translate([0, 0, dz]) {
                block([x, y, z], center=ABOVE);
                translate([0, 0, wall_thickness- clearance]) {
                    rod(d=d, l=y, center=SIDEWISE+ABOVE);
                }
            }

    }
    
    module bore_for_push_rod() {
        render() difference() {
            children();
            push_rod(radial_allowance);
        }    
    }
     
    module support_blank(include_top_of_travel=true) {
        hull() {
            // Around axle centerline
            rod(d=y_bearing, l=x_bearing);
            if (include_top_of_travel) {
                // Around top of travel
                translate([0, 0, -dz_travel]) rod(d=y_bearing, l=support_y);
            }

            // Support Footing
            center_reflect([0, 1, 0]) {
                translate([0, 0, -axle_height]) hull() {
                     translate([0, support_x, 0]) rod(d=r_pin, l=support_y, center=ABOVE);
                }
            }
        }
        
    }

    module supported_cranks() {
        dx = pin_length/2 + x_bearing/2;
        center_reflect([1, 0, 0]) {
            translate([dx, 0, 0]) {
                support_blank(include_top_of_travel=true);
            }
        } 
    }

    module bearing_blank() {
        hull() {
            block([x_bearing, y_bearing, axle_height], center=BELOW);
            support_blank(include_top_of_travel=false);
        }
    }

    module slot_clearance() {
        //rod(d=d_slot, l=2*x_bearing);
        sliding_allowance = 0.1;
        d_tight_slot = pin_diameter + sliding_allowance;
        hull() {
            rod(d=d_tight_slot, l=2*x_bearing);
            translate([0, 0, -dz_travel]) rod(d=d_slot, l=2*x_bearing);
        }
        hull() {
            rod(d=d_tight_slot, l=2*x_bearing);
            translate([0, 0, dz_travel]) rod(d=d_tight_slot, l=2*x_bearing);
        }
    }

    module traveller() {
        dx = range_of_travel/2;
        color(traveller_color, alpha=traveller_alpha) difference() {
            hull() {
                translate([0, 0, dx]) rod(d=y_bearing, l=x_bearing);
                block([x_bearing, y_bearing, dx], center=ABOVE);
                block([x_bearing, y_bearing, axle_height], center=BELOW);
            }   
            slot_clearance();
        }
    }

    module supported_axle(support_axle) {
        dx = 3 * (pin_length/2 + x_bearing/2);
        if (support_axle[0] && support_axle[1]  ) {
            center_reflect([1, 0, 0]) {
                translate([dx, 0, 0]) {
                    support_blank(include_top_of_travel=false);
                }
            }
        } else if (support_axle[0]) {
            translate([dx, 0, 0]) {
                support_blank(include_top_of_travel=false);
            } 
        } else if (support_axle[1]) {
            translate([-dx, 0, 0]) {
                support_blank(include_top_of_travel=false);
            }
        } else {
            assert(false, str("Don't know how to handle 'support_axle'", support_axle));
        }
    }
   
}

