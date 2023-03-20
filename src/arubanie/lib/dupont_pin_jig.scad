

include <logging.scad>
include <centerable.scad>
include <dupont_pins.scad>
use <shapes.scad>
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

/* [Jaw Yoke Design] */

x_jaw_yoke_behind = 20; // [0:1:20]
x_jaw_yoke_front = 20; // [0:1:20]
y_jaw_yoke = 10; // [0:1:10]
z_jaw_yoke = 2; // [0:0.25:4]

/* [Upper Jaw Yoke Design] */
w_upper_jaw_yoke = 2;



/* [Jaw Clip Design] */

// This is a Z offset, so the actual thickness of base will be less than this because of the angle.

wall_jaw_clip = 2; // [0:0.5:3]
dz_base_jaw_clip = 1.5*wall_jaw_clip; 
clearance_jaw_clip = 0.5; // // [0:0.5:2]
z_front_clip_jaw_clip = 1; // [0:0.25:2]
x_front_clip_jaw_clip = 2; // [0:0.25:2]

// The thickness of the web and flange.
        
x_rail_jaw_clip = 26; // [0: 1 : 30]
y_rail_jaw_clip = 6;
z_rail_jaw_clip = 6;
rail_jaw_clip = [x_rail_jaw_clip, y_rail_jaw_clip, z_rail_jaw_clip];
t_rail_jaw_clip = 2;
dz_rail_jaw_clip = 4;
t_rail_clearance = 0.2; // [0.15 : 0.05: 0.45]


/* [Retainer Washer Design] */
// This how thick the washer is
y_retainer_washer = 0.6; // [0:0.05:1]
// This is the thickness of the washer surface
dy_retainer_washer = 0.20; // [0:0.05:1]
padding_retainer_washer = 2;


/* [Rail Clip Design] */
x_rail_clip = 14; // [ 0:0.5:30]

/* [Show] */
orient = "For build"; //["As designed", "As assembled", "For build"]
orient_for_build = orient == "For build";
show_upper_jaw_assembly = true;
show_upper_jaw_clip = false;
show_upper_jaw_clip_rail = true;

show_pin_holder_adapter = true;
show_pin_strip_breaker = false;

show_lower_jaw_clip = false;
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



/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
l_pin_strip = 115.1;
pin_count = 20;
delta_pin_strip = l_pin_strip / (pin_count -1);    


    

    

 
if (show_upper_jaw_assembly) {
    if (orient_for_build || orient == "As designed") {
        upper_jaw_assembly();
    } else {
        articulate_jaws(percent_open_jaw*max_jaw_angle/100) {
            upper_jaw_assembly();
        }
    }
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
            if (show_upper_jaw && !orient_for_build) {
                jaw();
            }
            if (show_upper_jaw_anvil  && !orient_for_build) {
                upper_jaw_anvil();
            }
            if (show_upper_jaw_clip) {
                color("Olive") jaw_clip(show_upper_jaw_clip_rail, dz_rail_jaw_clip);
            } 
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
    mirror([0, 1, 0]) pin_holder_adapter();
    translate([dx_pha, jaws_extent.y/2, 0]) block([x_body_mpha, 20, 2], center=BELOW+RIGHT+FRONT);
}

module upper_jaw_yoke() {
    z_yoke = 16.5;
    joiner = [x_body_mpha, jaws_extent.y + 2 * w_upper_jaw_yoke, w_upper_jaw_yoke];
    side = [x_body_mpha, w_upper_jaw_yoke, z_yoke - m4_plus_padding_width]; //7]; //z_yoke-x_body_mpha
    translate([dx_pha, 0, z_yoke]) {
        block(joiner, center=BELOW+FRONT); 
        center_reflect([0, 1, 0]) translate([0, jaws_extent.y/2, 0]) block(side, center=BELOW+FRONT+RIGHT); 
    }
}


module pin_holder_adapter() {
    m4_plus_padding_width = 10;
    body = [
        x_body_mpha, 
        2, 
        z_upper_jaw_anvil + m4_plus_padding_width
    ];
    
    clip = [
        body.x,
        jaws_extent.y - y_upper_jaw_anvil,
        z_upper_jaw_anvil
    ];
    
    translation = [
        dx_pha, 
        -jaws_extent.y/2,    //dy_between_jaw_sides/2 - y_jaw, 
        -z_upper_jaw_anvil
    ]; 
    color("Wheat") difference() {
        translate(translation) {
            block(body, center=FRONT+ABOVE+LEFT);
            block(clip, center=FRONT+ABOVE); //, center=FRONT+ABOVE+LEFT);
        }
        jaw_hole_clearance();
    }
}

   
if (show_lower_jaw_clip) {
   rotation = 
        orient_for_build ? [0, 90, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 0]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, x_jaw] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [-0.5, 0, 0]: 
        assert(false);    
    color("Chocolate") 
        translate(translation) 
            rotate(rotation) 
                jaw_clip();
}  


module t_rail(size, thickness) {
    web = [size.x, size.y, thickness];
    flange = [size.x, thickness, size.z]; 
    block(web, center=RIGHT+FRONT);
    translate([0, size.y, 0]) block(flange, center=LEFT+FRONT);  
}


module t_rail_clip(size, thickness, dz_rails, clearance, outer_m3_attachment=false, cap_m3_attachmment=false) {
    
    inner = [
        size.x + clearance, 
        size.y - 2*clearance - thickness,  
        size.z/2 - thickness/2
    ];
    outer = [size.x + clearance, thickness, size.z + 2 * clearance]; 
    top = [size.x + clearance, size.y + thickness,thickness];
    cap = [thickness, size.y + thickness, size.z + 2 * thickness + 2 * clearance];
    module body() {
        center_reflect([0, 0, 1]) {
            translate([0, clearance, thickness/2 + clearance]) 
                block(inner, center=RIGHT+FRONT+ABOVE);
            translate([0, size.y + clearance, 0]) 
                block(outer, center=RIGHT+FRONT);  
            translate([0, clearance, size.z/2 + clearance]) 
                block(top, center=RIGHT+FRONT+ABOVE); 
        }
        translate([size.x + clearance, clearance, 0]) block(cap, center=RIGHT+FRONT);
        if (outer_m3_attachment) {
            translate([0, size.y + clearance + thickness, 0]) rotate([0, 180, 0]) m3_attachment();
        }
        if (cap_m3_attachmment) {
            translate([size.x + clearance + thickness, 0, 0]) mirror([1, 0, 0]) m3_attachment();
        }
    }
    translate([0, 0, dz_rails]) body();
}


module jaw_clip(include_clip_rails=false, dz_rails=0) {
     
    module base() {
        resize([0, y_jaw_clip,  0]) {
            center_reflect([0, 1, 0]) {
                translate([0, -dy_between_jaw_sides/2, 0]) {
                    render(convexity=10) difference() {
                        hull() translate([0, 0, clearance_jaw_clip+dz_base_jaw_clip]) jaw_side();
                        hull() translate([0, 0, clearance_jaw_clip])jaw_side();
                    }
                }
            }
        }
    }
    module side_walls() {
        center_reflect([0, 1, 0]) 
            translate([0, y_jaw_clip/2 - wall_jaw_clip/2]) 
                resize([0, wall_jaw_clip,  z_jaw+2*clearance_jaw_clip]) 
                    y_centered_jaw_side(); 
    }
    module front_wall() {
        front = [wall_jaw_clip, y_jaw_clip, z_jaw_front + clearance_jaw_clip + wall_jaw_clip];
        side = [wall_jaw_clip + clearance_jaw_clip, wall_jaw_clip, front.z];
        top = [wall_jaw_clip, front.y, wall_jaw_clip];
        front_clip = [side.x+x_front_clip_jaw_clip, front.y, z_front_clip_jaw_clip];
        front_clip_bridge_support = [1, wall_jaw_clip, z_front_clip_jaw_clip];
        
        translate([-clearance_jaw_clip, 0, 0]) block(front, center=ABOVE+BEHIND);
        center_reflect([0, 1, 0]) 
            translate([0, y_jaw_clip/2, 0]) 
                block(side, center=ABOVE+BEHIND+LEFT);
        translate([0, 0, front.z]) 
            block(top, center=BELOW+BEHIND);
        translate([x_front_clip_jaw_clip, 0, 0]) 
            block(front_clip, center=BELOW+BEHIND);
        center_reflect([0, 1, 0]) 
            translate([x_front_clip_jaw_clip, front.y/2, 0]) 
                block(front_clip_bridge_support, center=BELOW+FRONT+LEFT);
        
    }
    module clips() { 
        clip = [x_jaw/2, (y_jaw_clip-y_lower_jaw_anvil)/2, wall_jaw_clip];
        center_reflect([0, 1, 0]) {
            translate([x_jaw, y_jaw_clip/2, 0]) block(clip, center=BELOW+LEFT+BEHIND);
        }
    }
    module clip_rails() {
        web = [x_rail_jaw_clip, y_rail_jaw_clip, t_rail_jaw_clip];
        flange = [x_rail_jaw_clip, t_rail_jaw_clip, z_rail_jaw_clip]; 
        center_reflect([0, 1, 0]) { 
            translate([x_jaw, y_jaw_clip/2, dz_rails]) {
                block(web, center=ABOVE+RIGHT+BEHIND);
                translate([0, y_rail_jaw_clip, t_rail_jaw_clip/2]) 
                    block(flange, center=LEFT+BEHIND);  
            }
        }
    }
    module body() {
        base();
        side_walls();
        front_wall();
        clips();
        if (include_clip_rails) {
            clip_rails();
        }
    }
 
    difference() { 
        body();
        jaw_hole_clearance();
    }

}
    
    
if (show_lower_jaw && !orient_for_build) {
   rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 0]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, 0] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 0]: 
        assert(false);    
    translate(translation) rotate(rotation) jaw();
}

module y_centered_jaw_side() {
    translate([0, -y_jaw/2, 0]) jaw_side();
}

module jaw_side() {
    hull() {
        translate([0, 0, 0]) block([x_jaw, y_jaw, 0.01], center=ABOVE+RIGHT+FRONT);
        block([0.01, y_jaw, z_jaw_front], center=ABOVE+RIGHT+FRONT);
        translate([9, 0, 0]) block([0.01, y_jaw, 12.6], center=ABOVE+RIGHT+FRONT);
        translate([x_jaw, 0, 0]) block([0.01, y_jaw, z_jaw], center=ABOVE+RIGHT);
    }
}


    
if (show_retainer_washer) {
   rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, 0, 0]: 
        assert(false, assert_msg("orient: ", orient));
    translation = 
        orient_for_build ? [0, 0, 0] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [0, -dy_between_jaw_sides/2, 0]: 
        assert(false);    
    translate(translation) rotate(rotation) retainer_washer();
}

module retainer_washer() {
    washer = [
        x_anvil_retainer + 2 * padding_retainer_washer, 
        y_retainer_washer, 
        z_anvil_retainer + padding_retainer_washer
    ];
    
    difference() {
        block(washer, center=BELOW+RIGHT, rank=-5);
        translate([0, y_anvil_retainer/2+dy_retainer_washer, 0]) anvil_retainer();
        translate([0, 0, -z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE+RIGHT);
    }
}

if (show_lower_jaw_anvil_retainer && !orient_for_build) {
    rotation = 
        orient_for_build ? [90, 0, 0] : 
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [180, 0, 90]: 
        assert(false, assert_msg("orient: ", orient));
    dy_assembly = -(x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp);
    translation = 
        orient_for_build ? [0, 0, 2.54/2] :
        orient == "As designed" ? [0, 0, 0] :
        orient == "As assembled" ? [dx_025_anvil, dy_assembly, z_lower_jaw_anvil]: 
        assert(false);
    translate(translation) rotate(rotation) anvil_retainer();
}






if (show_lower_jaw_anvil && !orient_for_build) {
    lower_jaw_anvil();
}




if (show_male_pin_ && orient == "As designed") {
    male_pin();  
}






module m3_attachment() {
    difference() {
        block([8, 8, 2], center=BELOW+BEHIND+RIGHT);
        translate([-4, 4, 25]) hole_through("M3", $fn=12);
    }
}



if (show_jaw_yoke) {
    jaw_yoke(); 
}

module jaw_yoke() {
    y_total = y_lower_jaw_anvil + 2 * y_jaw_yoke;
    yoke_behind = [x_jaw_yoke_behind, y_total, z_jaw_yoke];
    yoke_front = [x_jaw_yoke_front, y_jaw_yoke, z_jaw_yoke];
    translation_ht_front = 0.70*yoke_front;
    translation_ht_behind = [-0.8*yoke_behind.x, 0.4*yoke_behind.y, 10];
    
    difference() {
        block(yoke_behind, center=ABOVE+BEHIND);
        center_reflect([0, 1, 0]) translate(translation_ht_behind) hole_through("M3");
    }

    center_reflect([0, 1, 0]) 
        translate([0, y_lower_jaw_anvil/2, 0]) {
            difference() {
                block(yoke_front, center=ABOVE+FRONT+RIGHT);
                translate(translation_ht_front) hole_through("M3");
            }
        }
    
}

module rail_rider() {
    clearance_rail_rider = 0.2;
    x_rail_rider = 11;
    slide = [
        x_rail_rider, 
        2.9, // y_rail_jaw_clip - t_rail_jaw_clip - 2 * clearance_rail_rider,
        4]; // z_rail_jaw_clip/2 - t_rail_jaw_clip/2];
    plate = [
        10,
        t_rail_jaw_clip, //slide.y,
        10
    ];
    
    
    positioning = [
        x_jaw, 
        y_jaw_clip/2 + clearance_rail_rider, 
        t_rail_jaw_clip/2];
    
    t_z_reflection = [0, 0, t_rail_jaw_clip/2 + clearance_rail_rider];
    t_plate = [
        -(x_rail_jaw_clip + clearance_rail_rider),
        0,
        -z_rail_jaw_clip/2
    ];
    
    module rider() {
        center_reflect([0, 1, 0]) {
            translate(positioning) {
                translate(t_plate) block(plate, center=BEHIND+ABOVE+RIGHT);
                center_reflect([0, 0, 1]) {
                    translate(t_z_reflection) {
                        block(slide, center=RIGHT+BEHIND+ABOVE); 
                    }
                }
            }
        }
    }
    module nutcut() {
        h_bolt_head = 5;
        t_bolt = [
            x_lower_jaw_anvil/2, 
            -(y_jaw_clip/2 + clearance_rail_rider + plate.y + h_bolt_head), 
            z_axis_ar];
        translate(t_bolt) {
            rotate([90, 0, 0]) {
                hole_through("M4", h=h_bolt_head, $fn=12);
            }
        }
    }
    difference() {
        rider();
        nutcut();
        
    }
}
