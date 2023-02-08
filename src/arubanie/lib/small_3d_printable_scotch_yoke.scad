include <centerable.scad>
use <shapes.scad>
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

crank_box(pin_diameter, range_of_travel, radial_allowance, axial_allowance, wall_thickness, angle);
    
module crank_box(
    pin_diameter, 
    range_of_travel, 
    radial_allowance, 
    axial_allowance, 
    wall_thickness, 
    angle) {

    r_pin = pin_diameter / 2;
    d_slot = pin_diameter + 2 * radial_allowance;
    axle_height = range_of_travel + pin_diameter/2 + radial_allowance + wall_thickness;
    echo("axle_height", axle_height);
    x_bearing = pin_diameter;
    y_bearing = d_slot + 2 * wall_thickness;

    pin_length = x_bearing + 2 * axial_allowance;
    dz_travel = -range_of_travel/2;

    support_x = 0.75 * r_pin;
    support_y = 0.75 * x_bearing;
    end_clearance = wall_thickness/2;
    dy_inside = sqrt(axle_height*axle_height + support_x*support_x) + end_clearance;
    dx_inside = x_bearing / 2 + axial_allowance + x_bearing + axial_allowance;
    wall_height = 2 * wall_thickness + pin_diameter + radial_allowance;

    assembly();
        

    
    module assembly() {
        dy_traveller = -sin(angle) * range_of_travel/2;
        translate([0, dy_traveller, 0]) {
            traveller();
            push_rod();
        } 

        rotate([angle, 0, 0]) {
            color(crank_shaft_color, alpha=crank_shaft_alpha)
                crank_shaft();
            color(support_color, alpha=support_alpha) 
                crank_shaft_strengthen_and_support();
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
    
    module crank_shaft_strengthen_and_support() {
         supported_cranks();
         supported_axle();
    }

    module crank_shaft() {
        // bearing_pins
        dx = 2 * (pin_length/2 + x_bearing/2);
        translate([dx, 0, 0]) rod(d=pin_diameter, l=pin_length+eps);
        translate([-dx, 0, 0]) rod(d=pin_diameter, l=pin_length+eps);
        
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
        y = 2 * (dy_inside + 2 * wall_thickness) + range_of_travel;
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


    module supported_axle() {
        dx = 3 * (pin_length/2 + x_bearing/2);
        center_reflect([1, 0, 0]) {
            translate([dx, 0, 0]) {
                support_blank(include_top_of_travel=false);
            }
        } 
    }
   
}

