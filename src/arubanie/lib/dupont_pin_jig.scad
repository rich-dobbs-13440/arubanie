include <logging.scad>
include <centerable.scad>
include <dupont_pins.scad>
include <SN_28B_measurements.scad>
use <SN_28B_pin_crimper.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>



/* [Show] */
orient = "As assembled"; //["As designed", "As assembled", "For build"]
orient_for_build = orient == "For build";

show_pin_holders_attachment = false;
show_pin_holder_clip = false;
show_pin_strip_carriage = false;
show_pin_strip_breaker = false;
show_insulator_wrap_prebender = false;
show_slider_M4_M3_rotate_or_register = true;

/* [Show Mocks] */
show_pin_crimper = true;
show_only_attachments_ = false;
show_fixed_jaw_ = true; 
show_fixed_jaw_anvil_ = true; 
show_fixed_jaw_screw_ = true;
fixed_jaw_screw_name_ = "M4x25"; //["M4x8", "M4x10", "M4x12", "M4x16", "M4x20", "M4x25"]
show_moving_jaw_ = true; 
show_moving_jaw_anvil_ = true;
show_moving_jaw_screw_ = true;
moving_jaw_screw_name_ = "M4x8"; //["M4x8", "M4x10", "M4x12", "M4x16", "M4x20", "M4x25"]

/* [Prebender Design] */
x_mold_iwp = 8; // [0:1:20] 
x_handle_iwp = 8; // [0:1:20] 
z_upper_mold_iwp = 2;// [0:.1:4]  
z_lower_mold_iwp = 2;// [0:.1:4] 
dz_cavity_iwp = 0; // [-2:0.01:+2]



/* [Male Pin Holder Design] */

d_pin_clearance  = 0.4; // [0:0.1:1]
// This controls how strong the spring holds
z_spring_mph = 3.; // [3:0.1:5]

dx_pin_slider = 4.7; // [4.7: 0.01: 4.8]

module end_of_customization() {}

/* [Mocks] */



/* [Show Mocks] */
percent_open_jaw = 0; // [0:99.9]
show_male_pin_ = true;
alpha_mp = 1; // [0, 0.25, 0.5, 0.75, 1]

/* [Future Design] */
wire_diameter = 1.66; // Includes insulation
d_wire_conductor = 1.13;
exposed_wire = 2.14; 


/* [Pin Holder Adapter Calculations] */
    
x_body_mpha = x_jaw/2 - dx_025_anvil +  2.54/2; //+ m4_plus_padding_width
dx_pha = dx_025_anvil - 2.54/2;

/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
l_pin_strip = 115.1;
pin_count = 20;
delta_pin_strip = l_pin_strip / (pin_count -1);



if (show_pin_holder_clip) {
    if (orient == "As designed") {
        pin_holder_clip();
    } else if (orient_for_build) {
        translate([100, 0,0])  pin_holder_clip(orient_for_build=true);
    }
}
if (show_pin_holders_attachment) {
    if (orient == "As designed") {
        pin_holders_attachment(orient=RIGHT, orient_for_build=false);
    } else if (orient_for_build) {
        pin_holders_attachment(orient=LEFT, orient_for_build=true);
    }
}


if (show_pin_crimper) { 
    SN_28B_pin_crimper(    
            show_only_attachments = show_only_attachments_, 
            show_fixed_jaw = show_fixed_jaw_, 
            show_fixed_jaw_anvil = show_fixed_jaw_anvil_, 
            show_fixed_jaw_screw = show_fixed_jaw_screw_,
            fixed_jaw_screw_name = fixed_jaw_screw_name_,
            show_moving_jaw = show_moving_jaw_, 
            show_moving_jaw_anvil = show_moving_jaw_anvil_,
            show_moving_jaw_screw = show_moving_jaw_screw_) {
                
        union() {        
            SN_28B_M4_rail(LEFT, x_behind = 20);
            SN_28B_M4_rail(RIGHT, x_behind = 20);
            SN_28B_jaw_hole_clip(do_cap=true, x_front= -20, x_back = jaws_extent.x);
            
            
            SN_28B_M4_rail_M3_top_attach_slider(orient=LEFT);
            //SN_28B_M4_rail_M3_top_attach_fitting(orient=RIGHT);
            //SN_28B_M4_rail_M3_top_attach_slider(orient=RIGHT);  
  
            pin_holders_attachment(orient=LEFT);
            
            //SN_28B_jaw_hole_clip(upper=false, x_front=25, do_cap=true);
        }
        union() { 
            if (show_pin_holder_clip) {
                pin_holder_clip();
            }
        }
    } 
}



module pin_holders_attachment(orient=RIGHT, orient_for_build=false, color_name="Thistle") {
    show_mock = orient_for_build ? false : true;
    SN_28B_M4_rail_M3_top_attach_fitting(
            orient=orient, 
            child_position="relative_to_jaw", 
            show_mock=show_mock) {
        
        color(color_name) {        
            orient_to_anvil(orient) { 
                center_reflect([0, 1, 0]) {
                    translate([0, -5, 0]) { 
                        difference() {
                            union() {
                                //block([12, 5-2.54/2, 2*2.54], center=BELOW+BEHIND);
                                translate([1.6, 0, 0]) block([10, 5-2.54/2, 2*2.54], center=BELOW+BEHIND+LEFT);
                            }
                            pin_holder_screws(as_hole_threaded=true, $fn=12);
                        }
                    }
                } 
            }
        }
        if (!orient_for_build) {
            translate([10, 0, 0])  oriented_pin_holder(orient=orient);
        }

    }   
}


module orient_to_anvil(orient) {
    dz = dz_025_wire_punch_z + z_conductor_wrap_mp/2; 
    rotation = 
        orient == RIGHT ? [0, 180, -90] : 
        orient == LEFT ? [0, 180, 90] : 
        assert(false);
    translation = 
        orient == RIGHT ? [0, -dx_insulation_wrap_mp, -dz] :
        orient == LEFT ? [0, dx_insulation_wrap_mp, -dz] : 
        assert(false);
    translate(translation) {
        rotate(rotation) {
            children();
        }
    }     
}


module oriented_pin_holder(orient) {
    clearance_fraction_male_pin_holder = 0.1; //[0: 0.01: 0.20]
    orient_to_anvil(orient) {
        male_pin_holder(
            z_spring = z_spring_mph,
            clearance_fraction = clearance_fraction_male_pin_holder, 
            x_stop = dx_insulation_wrap_mp -y_upper_jaw_anvil/2,
            show_mock=show_male_pin_ && !orient_for_build);
        
    }        
}

module pin_holder_clip(orient_for_build=false) {
    
    x_front = dx_025_anvil-DUPONT_HOUSING_WIDTH()/2;
    

    module brace() {
        translate([dx_025_anvil, -jaws_extent.y/2, -z_upper_jaw_anvil]) {
            hull() {
                block([2.54, 0.1, 10], center=ABOVE+LEFT);
                block([2.54, 10, 0.1], center=ABOVE+LEFT);
            }
        }
    }
    module clip() {
        SN_28B_jaw_hole_clip(upper=true, x_front=x_front, do_cap=true);
        oriented_pin_holder();
        brace();
    }
    if (orient_for_build) {
        rotate([0, -90, 0]) {
            translate([-x_front, 0, 0]) clip();
        }
    } else {
        clip();
    }
}


if (show_pin_strip_breaker) {
    pin_strip_breaker();
}


module pin_strip_breaker() {
    pins = 5;
    height = 2;
    width = 4;
    gap = 0.5;


    translate([0, 0, +gap/2]) pin_catch(pins, height, width, true, center=ABOVE);
    translate([0, 0, -gap/2]) pin_catch(pins, height, width, false, center=BELOW);
    rotate([0, 0, -90])  translate([-dx_insulation_wrap_mp, 0, 0]) male_pin_holder(show_mock=true, z_spring = z_spring_mph);
}


module pin_catch(
        pins, 
        height, 
        width, 
        bevel, 
        center=BELOW,
        d_pin_clearance = 0.6, 
        offset_from_edge = 2.5) {
    // The pin catch will take a strip of male pins and leave a set of pin tips
    // sticking out.  This will be used to capture a pin strip in a dispenser.
    dy_pin_catch = offset_from_edge;
    y_pin_catch = width;
    z_pin_catch = height;
    
    d_prime = d_pin + d_pin_clearance;
    delta_taper = min((y_pin_catch-d_prime), z_pin_catch);  
    
    body = [(pins + 1) * delta_pin_strip, y_pin_catch, z_pin_catch];
    x_offset  = -body.x/2 + delta_pin_strip ;
    
    module pin_holes() {
        for (i = [0:pins-1]) {
            translate([delta_pin_strip*i + x_offset, 0, 0]) {
                can(d=d_prime, h=100, $fn=12, rank=5);
                if (bevel) {
                    can(d=d_prime, taper=d_prime+delta_taper, h=delta_taper, center=BELOW, rank=5, $fn=12); 
                }
            } 
        }
    }
    translation = 
        center == BELOW ? [0, 0, 0] :
        center == ABOVE ? [0, 0, body.z] :
        assert(false);
    translate(translation) {
        difference() {
            translate([0, dy_pin_catch/2, 0]) block(body, center=BELOW+LEFT);
            pin_holes();
        }
    }
}



module insulator_wrap_mold_cavity() {
    module open_wrap() {
            male_pin(
            pin = false, 
            strike = false,
            detent = false, 
            barrel = false,
            conductor_wrap = false,
            insulation_wrap = 0, 
            strip=false); 
    }
    module closed_wrap() {
        male_pin(
            pin = false, 
            strike = false,
            detent = false, 
            barrel = false,
            conductor_wrap = false,
            insulation_wrap = 1, 
            strip=false); 
    }
    module strip_allowance() {
        male_pin(
            pin = false, 
            strike = false,
            detent = false, 
            barrel = false,
            conductor_wrap = false,
            insulation_wrap = false, 
            strip=true);     
    }

    translate([-10, 0, 0]) {    
        // Squeezing
        hull() {
            translate([x_mold_iwp, 0, 0]) open_wrap();
            translate([x_mold_iwp, 0, +1]) open_wrap();
            translate([100, 0, 0]) open_wrap();
            closed_wrap();
            //translate([0, 0, 1]) closed_wrap();
        } 
        // Accommodate strip
        hull () {
            translate([0, 0, 0.25]) strip_allowance();
            translate([0, 0, -0.25]) strip_allowance();
            translate([100, 0, 0.25]) strip_allowance();
            translate([100, 0, -0.25]) strip_allowance();
        }
    }
}

if (show_insulator_wrap_prebender) {
    insulator_wrap_prebender();
}

module insulator_wrap_prebender() {
    //rotate([0, 90, 0]) {  
        render(convexity=10) difference() { 
            union() {
                block([x_handle_iwp, y_strip_mp, z_upper_mold_iwp], center=BEHIND+ABOVE);
                block([x_handle_iwp, y_strip_mp, z_lower_mold_iwp], center=BEHIND+BELOW);
                block([x_mold_iwp, y_strip_mp, z_upper_mold_iwp], center=FRONT+ABOVE);
                block([x_mold_iwp, y_strip_mp, z_lower_mold_iwp], center=FRONT+BELOW);
            }
            translate([0, 0, dz_cavity_iwp]) insulator_wrap_mold_cavity();
        }
    //}
}

module positioned_insulator_wrap_prebender() {
    translate([dx_025_anvil, -dx_insulation_wrap_mp, -(dz_025_wire_punch_z + 2.54/2)]) {
        insulator_wrap_prebender();
    }
}


