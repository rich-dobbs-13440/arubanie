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
dx_clearance_spring_mph = 1;

x_split_mph = 7; // [0 : 1 : 12]
z_split_mph = 0.5;
clearance_fraction_male_pin_holder = 0.1; //[0: 0.01: 0.20]


z_column_mph = 16;
dx_column_mph = 2.9; // [-5:0.1:5]

alpha_mph = 1; // [0, 0.25, 0.50, 0.75, 1]

dx_male_m3_attachment = 2.25; // [-10:0.05:10]
dy_male_m3_attachment = 2.25; // [0:0.05:20]
dz_male_m3_attachment = -1.35; // [-5:0.05: 5]
t_male_pin_holder_attachment = [dx_male_m3_attachment, dy_male_m3_attachment, dz_male_m3_attachment];



/* [Show] */
orient = "For build"; //["As designed", "As assembled", "For build"]
orient_for_build = orient == "For build";
//show_upper_jaw_clip = false;
//show_upper_jaw_clip_rail = true;

show_pin_holder_adapter = true;
show_pin_strip_breaker = false;

//show_lower_jaw_clip = false;

show_pin_strip_carriage = true;
show_upper_jaw_yoke = true;
show_male_pin_holder = true;
show_m3_attachment = false || false;
show_retainer_washer = false || false;
show_jaw_yoke = false || false;



/* [Show Mocks] */
percent_open_jaw = 0; // [0:99.9]
show_male_pin_ = true;
alpha_mp = 1; // [0, 0.25, 0.5, 0.75, 1]
show_lower_jaw = true;
show_upper_jaw = true;

show_lower_jaw_anvil = true;
show_upper_jaw_anvil = true;
show_lower_jaw_anvil_retainer = false ||false;


module end_of_customization() {}

/* [Pin Holder Adapter Calculations] */
    
x_body_mpha = x_jaw/2 - dx_025_anvil +  2.54/2; //+ m4_plus_padding_width
dx_pha = dx_025_anvil - 2.54/2;

/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
l_pin_strip = 115.1;
pin_count = 20;
delta_pin_strip = l_pin_strip / (pin_count -1);    


 
if (orient_for_build || orient == "As designed") {
    upper_jaw_assembly();
} else {
    articulate_jaws(
            percent_open_jaw*max_jaw_angle/100, 
            show_fixed_jaw=show_lower_jaw, 
            show_fixed_jaw_anvil=show_lower_jaw_anvil, 
            show_moving_jaw=show_upper_jaw, 
            show_moving_jaw_anvil=show_lower_jaw_anvil) {
        lower_jaw_assembly();     
        upper_jaw_assembly();
    }
} 



module pin_holder_adapter() {
    jaw_hole_clip(); 
}

module upper_jaw_assembly() { 
   rotation = 
        orient_for_build ? [0, -90, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 0]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, -dx_025_anvil+2.54/2] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, dz_between_upper_and_lower_jaw]: 
        assert(false);   
    
    
    translate(translation) { 
        rotate(rotation) {
            if (show_pin_holder_adapter) {
                pin_holder_adapter(); 
            }
            if (show_pin_strip_carriage) {
                pin_strip_carriage();
            }
            if (show_upper_jaw_yoke) {
                upper_jaw_yoke();
            }
            
            
            dz = dz_025_wire_punch_z + z_conductor_wrap_mp/2;
            translate([dx_025_anvil, -dx_insulation_wrap_mp, -dz]) rotate([0, 180, -90]){
//                if (show_male_pin_ && !orient_for_build) {
//                    male_pin();  
//                }
                if (show_male_pin_holder) {
                    //color("pink") 
                    male_pin_holder(
                        z_spring = z_spring_mph,
                        clearance_fraction = clearance_fraction_male_pin_holder, 
                        z_column = z_column_mph, 
                        dx_column = dx_column_mph,
                        x_stop = dx_insulation_wrap_mp -y_upper_jaw_anvil/2,
                        show_mock=show_male_pin_ && !orient_for_build);
                } 
            }
            
         
        }
    }
}

module lower_jaw_assembly() { 
}


if (show_pin_strip_breaker) {
    pin_strip_breaker();
}

module pin_strip_breaker() {
    pins = 5;
    height = 2;
    width = 4;
    gap = 0.5;

//    translate([0, height+gap, 0]) rotate([90, 0, 180]) pin_catch(pins, height, width, true);
//    rotate([90, 0, 180]) pin_catch(pins, height, width, false);
    
    
    translate([0, 0, +gap/2]) pin_catch(pins, height, width, true, center=ABOVE);
    translate([0, 0, -gap/2]) pin_catch(pins, height, width, false, center=BELOW);
    
    //translate([0, +gap/2, -2.5])  block([(pins+1)*delta_pin_strip, 2*height+gap, 1.5], center=BELOW);


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


module pin_strip_carriage() {
    jaw_hole_clip(upper=true); // ! mirror([0, 1, 0]) pin_holder_adapter();
    translate([dx_pha, jaws_extent.y/2, 0]) block([x_body_mpha, 20, 2], center=BELOW+RIGHT+FRONT);
}





module m3_attachment() {
    difference() {
        block([8, 8, 2], center=BELOW+BEHIND+RIGHT);
        translate([-4, 4, 25]) hole_through("M3", $fn=12);
    }
}







