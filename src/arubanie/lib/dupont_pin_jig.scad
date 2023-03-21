include <logging.scad>
include <centerable.scad>
include <dupont_pins.scad>
include <SN_28B_pin_crimper.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>



/* [Future Design] */

wire_diameter = 1.66; // Includes insulation
d_wire_conductor = 1.13;
exposed_wire = 2.14; 


/* [Male Pin Holder Design] */

d_pin_clearance  = 0.4; // [0:0.1:1]
// This controls how strong the spring holds
z_spring_mph = 3.; // [3:0.1:5]


/* [Show] */
orient = "As assembled"; //["As designed", "As assembled", "For build"]
orient_for_build = orient == "For build";
show_pin_holder_clip = true;
show_pin_strip_carriage = false;
show_pin_strip_breaker = false;

/* [Show Mocks] */
percent_open_jaw = 0; // [0:99.9]
show_male_pin_ = true;
alpha_mp = 1; // [0, 0.25, 0.5, 0.75, 1]

show_fixed_jaw = true;
show_fixed_jaw_anvil = true;

show_moving_jaw = true;
show_moving_jaw_anvil = true;


module end_of_customization() {}

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
    } else {

        articulate_jaws(
                percent_open_jaw*max_jaw_angle/100, 
                show_fixed_jaw=show_fixed_jaw, 
                show_fixed_jaw_anvil=show_fixed_jaw_anvil, 
                show_moving_jaw=show_moving_jaw, 
                show_moving_jaw_anvil=show_moving_jaw_anvil) {
                    
            no_fixed_jaw_attachments();     
            pin_holder_clip();
        }
    } 
}


module pin_holder_clip(orient_for_build=false) {
    clearance_fraction_male_pin_holder = 0.1; //[0: 0.01: 0.20]
    x_front = dx_025_anvil-DUPONT_HOUSING_WIDTH()/2;
    
    module oriented_pin_holder() {
        dz = dz_025_wire_punch_z + z_conductor_wrap_mp/2; 
        translate([dx_025_anvil, -dx_insulation_wrap_mp, -dz]) {
            rotate([0, 180, -90]) {
                male_pin_holder(
                    z_spring = z_spring_mph,
                    clearance_fraction = clearance_fraction_male_pin_holder, 
                    x_stop = dx_insulation_wrap_mp -y_upper_jaw_anvil/2,
                    show_mock=show_male_pin_ && !orient_for_build);
            }
        }        
    }
    module clip() {
        jaw_hole_clip(upper=true, x_front=x_front, do_cap=true);
        oriented_pin_holder();
    }
    if (orient_for_build) {
        rotate([0, -90, 0]) translate([-x_front, 0, 0]) clip();
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


