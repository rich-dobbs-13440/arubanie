

include <logging.scad>
include <centerable.scad>
use <dupont_pins.scad>
use <shapes.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>



/* [Future Design] */

wire_diameter = 1.66; // Includes insulation
d_wire_conductor = 1.13;
exposed_wire = 2.14; 


/* [Male Pin Holder Design] */

d_pin_clearance = 0.5;
z_spring_mph = 2.;
dx_clearance_spring_mph = 1;

x_split_mph = 7; // [0 : 1 : 12]
z_split_mph = 0.5;
clearance_fraction_male_pin_holder = 0.1; //[0: 0.01: 0.20]

z_column_mph = 16;
dx_column_mph = 2.9; // [-5:0.1:5]

alpha_male_pin_holder = 1; // [0, 0.25, 0.50, 0.75, 1]

dx_male_m3_attachment = 2.25; // [-10:0.05:10]
dy_male_m3_attachment = 2.25; // [0:0.05:20]
dz_male_m3_attachment = -1.35; // [-5:0.05: 5]
t_male_pin_holder_attachment = [dx_male_m3_attachment, dy_male_m3_attachment, dz_male_m3_attachment];



/* [Jaw Yoke Design] */

x_jaw_yoke_behind = 20; // [0:1:20]
x_jaw_yoke_front = 20; // [0:1:20]
y_jaw_yoke = 10; // [0:1:10]
z_jaw_yoke = 2; // [0:0.25:4]



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
show_upper_jaw_clip = true;
show_upper_jaw_clip_rail = true;

show_pin_holder_adapter = true;


show_lower_jaw_clip = true;
show_pin_strip_carriage = true;
show_male_pin_holder = true;
show_m3_attachment = false || false;
show_retainer_washer = false || false;
show_jaw_yoke = false || false;

/* [Show Mocks] */
percent_open_jaw = 0; // [0:99.9]
show_male_pin = true;
show_lower_jaw = true;
show_upper_jaw = true;

show_lower_jaw_anvil = true;
show_upper_jaw_anvil = true;
show_lower_jaw_anvil_retainer = false ||false;


module end_of_customization() {}





/* [Pin Measurements] */

/*
    Parts of a pin as I've named them

    pin

    strike
    detent
    wire_barrel 
    wire_wrap
    insulation_wrap

*/
    d_pin = 0.50; 
    x_pin = 6.62;
    z_metal_pin = 0.2;
    // The strike is what keeps the pin from being removed from the housing 
    x_strike_mp = 3.22;
    y_strike_mp = 1.75;
    z_strike_mp = 1.80;
    // The detent is the area that can be caught by something to retain the housing 
    x_detent_mp =  0.8;
    y_detent_mp = 1.65;
    z_detent_mp = 0.56;
    x_wire_barrel_mp = 2.79;
    od_wire_barrel_mp = 1.55;
    x_wire_wrap_mp = 3.79;
    y_wire_wrap_mp = 2.00;
    z_wire_wrap_mp = 1.73;
    x_insulator_wrap_mp = 2.18;
    y_insulator_wrap_mp = 2.88;
    z_insulator_wrap_mp =  2.46;
    y_insulator_wrap_bottom_mp = 1.58;

    dx_wire_wrap_mp = x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp;
    
/* [Jaw Measurements] */
 

/* 

Origin will be at center_line of jaw at the front, with jaw being on the 
x axis, with x being positive as you go deeper into the jaw.
*/
    dy_between_jaw_sides = 4.6;
    dz_between_upper_and_lower_jaw = 10.16;
    x_jaw = 24;
    y_jaw = 2.5;
    z_jaw = 15.26;
    jaws_extent = [x_jaw, 2*y_jaw + dy_between_jaw_sides, z_jaw];
    z_jaw_front = 7.3;
    max_jaw_angle = 26;

    front_to_front_of_25 = 3.42;
    front_to_back_of_25 = 5.24;
    lower_jaw_height = 1.81;
    
 /* [Anvil Dimensions] */   
    
    x_lower_jaw_anvil = 23.4;
    y_lower_jaw_anvil =7.21;
    z_lower_jaw_anvil = 7.05;   
    lower_jaw_anvil_blank = [x_lower_jaw_anvil, y_lower_jaw_anvil, z_lower_jaw_anvil]; 
    dx_025_anvil = 3.63;
    dz_025_pin_punch_z = 5.78;
    dz_025_wire_punch_z = 5.89;     
    
    x_upper_jaw_anvil = 23.8;
    y_upper_jaw_anvil =7.13;
    z_upper_jaw_anvil = 3.06;
    upper_jaw_anvil_blank = [x_upper_jaw_anvil, y_upper_jaw_anvil, z_upper_jaw_anvil]; 
   

/* [Anvil Retainer Dimensions] */
    x_anvil_retainer = 17.09;
    y_anvil_retainer = 4.18;
    z_anvil_retainer = 9.6;
    anvil_retainer_extent = [x_anvil_retainer, y_anvil_retainer, z_anvil_retainer];
    w_rim_ar = 2.28; 
    d_screw_hole_ar = 5.12;
    d_rim_ar = d_screw_hole_ar + 2*w_rim_ar;
    z_axis_ar = z_anvil_retainer - w_rim_ar - d_screw_hole_ar/2;
    y_web_ar = 2.69;
    x_inset_ar = 10.88;
    y_inset_ar = (y_anvil_retainer - y_web_ar) / 2;
    
/* [Jaw Clip Calculations] */
    y_jaw_clip = 2*wall_jaw_clip + jaws_extent.y + 2*clearance_jaw_clip; 
 
module articulate_jaws(jaw_angle) {
    back_jaw_to_pivot = [12.62, 6.26, 20];
    translation = [-38, 0, -7];
    translate(-translation) { 
        rotate([0, jaw_angle, 0]) {
            rod(d=7.92, l=16.32, center=SIDEWISE); //pivot
            block(back_jaw_to_pivot, center=BEHIND+ABOVE);
            translate(translation) {
                children(0);
            }
        }
    }
} 
 
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
            
            
            dz = dz_025_wire_punch_z + z_wire_wrap_mp/2;
            translate([dx_025_anvil, -dx_wire_wrap_mp, -dz]) rotate([0, 180, -90]){
                if (show_male_pin && !orient_for_build) {
                    male_pin();  
                }
                if (show_male_pin_holder) {
                    //color("pink") 
                    male_pin_holder(clearance_fraction=clearance_fraction_male_pin_holder);
                } 
            }
            
         
        }
    }
}

module pin_strip_carriage() {
    mirror([0, 1, 0]) pin_holder_adapter();
}

module pin_holder_adapter() {
    m4_plus_padding_width = 10;
    body = [
        x_jaw/2 - dx_025_anvil + m4_plus_padding_width/2 + 2.54/2, 
        2, 
        z_upper_jaw_anvil + m4_plus_padding_width
    ];
    
    clip = [
        body.x,
        jaws_extent.y - y_upper_jaw_anvil,
        z_upper_jaw_anvil
    ];
    translation = [
        dx_025_anvil - 2.54/2, 
        -dy_between_jaw_sides/2 - y_jaw, 
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

module jaw_hole_clearance() {
    translate([x_lower_jaw_anvil/2, 0, z_axis_ar]) {
        rotate([90, 0, 0]) translate([0, 0, 25]) hole_through("M4", $fn=13);
        rotate([90, 0, 0]) translate([0, 1, 25]) hole_through("M4", $fn=13);
    }
}

module jaw() {
    color("SlateGray") {
        render(convexity = 10) difference() {        
            center_reflect([0, 1, 0]) {
                translate([-0.5, dy_between_jaw_sides/2]) {
                    jaw_side();
                }
            } 
            jaw_hole_clearance();
        }
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

module anvil_retainer() {
    color("SlateGray") {
        render(convexity=10) difference() {
            hull() {
                block([x_anvil_retainer, y_anvil_retainer, 0.01], center=BELOW);
                translate([0, 0, -z_axis_ar]) rod(d=d_rim_ar, l=y_anvil_retainer, center=SIDEWISE);
            }
            translate([0, 0, -z_axis_ar]) rod(d=d_screw_hole_ar, l=10, center=SIDEWISE);
            center_reflect([0, 1, 0]) {
                translate([0, y_web_ar/2, 0]) {
                    hull() {
                        block([x_inset_ar, 10, 0.01], center=BELOW+RIGHT, rank=5);
                        translate([0, 0, -z_axis_ar]) 
                            rod(d=d_screw_hole_ar, l=10, center=SIDEWISE+RIGHT);
                    }
                }
            }
        }
    }
}



module upper_jaw_anvil() {
    module pin_side_25_punch() {
        hull() {
            translate([dx_025_anvil, 0, z_upper_jaw_anvil]) 
                block([1.82, y_upper_jaw_anvil/2, 0.01], center=ABOVE+LEFT);
            translate([dx_025_anvil, 0, dz_025_pin_punch_z]) 
                block([1.6, y_upper_jaw_anvil/2, 0.01], center=ABOVE+LEFT);
        }
    }
    module wire_side_25_punch() {      
        hull() {
            translate([dx_025_anvil, 0, z_upper_jaw_anvil]) 
                block([2.06, y_upper_jaw_anvil/2, 0.01], center=ABOVE+RIGHT);
            translate([dx_025_anvil, 0, dz_025_wire_punch_z]) 
                block([2.05, y_upper_jaw_anvil/2, 0.01], center=ABOVE+RIGHT);
        }
    }
    mirror([0, 0, 1]) {
        color("DimGray") {
            block(upper_jaw_anvil_blank, center=ABOVE+FRONT);    
            pin_side_25_punch();
            wire_side_25_punch();
        }
        translate([x_upper_jaw_anvil/2, 0, 0]) anvil_retainer();
    }
}

if (show_lower_jaw_anvil && !orient_for_build) {
    lower_jaw_anvil();
}


module lower_jaw_anvil() {

    module pin_side_25_mold() {
        hull() {
            translate([dx_025_anvil, 0, z_lower_jaw_anvil]) 
                block([2.71, 20, 0.01], center=ABOVE+LEFT);
            translate([dx_025_anvil, 0, 4.81]) 
                block([1.70, 20, 0.01], center=ABOVE+LEFT);
        }
    }
    module wire_side_25_mold() {       
        hull() {
            translate([dx_025_anvil, 0, z_lower_jaw_anvil]) 
                block([3.08, 20, 0.01], center=ABOVE+RIGHT);
            translate([dx_025_anvil, 0, 3.89]) 
                block([2.60, 20, 0.01], center=ABOVE+RIGHT);
        }
    }
    color("DarkSlateGray") {
        difference() {
            block(lower_jaw_anvil_blank, center=ABOVE+FRONT);    
            pin_side_25_mold();
            wire_side_25_mold();
        }
    }
    translate([x_lower_jaw_anvil/2, 0, 0]) anvil_retainer();
    
}

if (show_male_pin && orient == "As designed") {
    male_pin();  
}

module male_pin() {
    // Initially model pin before construction with pin on x_axis,
    // with the pin itself negative, and the parts used in assembly
    // increasing in the x domain.abs
    module strike() {
        strike = [x_strike_mp, y_strike_mp, z_strike_mp];
        block(strike, center=FRONT);
    }
    module detent() {    
        bottom = [
            x_detent_mp,
            y_detent_mp,
            z_detent_mp
        ];
        
        translate([x_strike_mp, 0, -y_detent_mp/2]) block(bottom, center=FRONT + ABOVE);
  
    }
    module wire_barrel() {
        dx = x_strike_mp + x_detent_mp;
        translate([dx, 0, 0])
            rod(d=od_wire_barrel_mp, l=x_wire_barrel_mp, hollow=d_wire_conductor, center=FRONT);
    }
    
    module wire_wrap() {
        dx = x_strike_mp + x_detent_mp + x_wire_barrel_mp;
        extent = [x_wire_wrap_mp, y_wire_wrap_mp, z_wire_wrap_mp];
        translate([dx, 0, 0]) {
            block(extent, center=FRONT);
        }
        
    }
    module insulator_wrap() {
        dx = x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp ;
        translate([dx, 0, 2*z_metal_pin]) {
            center_reflect([0, 1, 0]) hull() {
                translate([0, y_insulator_wrap_mp/2, z_insulator_wrap_mp/2]) 
                    rod(d=z_metal_pin, l=x_insulator_wrap_mp, center=FRONT);
                translate([0, y_insulator_wrap_bottom_mp/2, -z_insulator_wrap_mp/2]) 
                    rod(d=z_metal_pin, l=x_insulator_wrap_mp, center=FRONT);
            }
            translate([0, 0, -z_insulator_wrap_mp/2]) 
                block([x_insulator_wrap_mp, y_insulator_wrap_bottom_mp, z_metal_pin], center=FRONT);
        }
    }    
    color("silver") {
        rod(d=d_pin, l=x_pin, center=BEHIND);
        strike();
        detent();
        wire_barrel();
        wire_wrap();
        insulator_wrap(); 
    }  
}




module m3_attachment() {
    difference() {
        block([8, 8, 2], center=BELOW+BEHIND+RIGHT);
        translate([-4, 4, 25]) hole_through("M3", $fn=12);
    }
}

//module oriented_male_pin_holder() {
//    rotation = 
//        orient_for_build ? [90, 0, 90] : 
//        orient == "As designed" ? [0, 0, 0] :
//        orient == "As assembled" ? [180, 0, 90]: 
//        assert(false, assert_msg("orient: ", orient));
//    dy_assembly = -(x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp);
//    translation = 
//        orient_for_build ? [25, 25, 2.54/2] :
//        orient == "As designed" ? [0, 0, 0] :
//        orient == "As assembled" ? [dx_025_anvil, dy_assembly, z_upper_jaw_anvil+1]: 
//        assert(false);
//    translate(translation) rotate(rotation) {
//       if (show_male_pin && !orient_for_build) {
//            male_pin();  
//        }
//        male_pin_holder(clearance_fraction=clearance_fraction_male_pin_holder); 
//        if (show_m3_attachment) {
//            translate([t_male_pin_holder_attachment.x, -2.54/2, t_male_pin_holder_attachment.z]) 
//                block([8, t_male_pin_holder_attachment.y+2.54/2, 2], center=BELOW+BEHIND+RIGHT);
//            translate(t_male_pin_holder_attachment) {
//                m3_attachment();
//            }
//        }
//    } 
//}

module male_pin_holder(clearance_fraction=.2) {
    body = [14, 2.54, 2.54];

    x_stop = x_strike_mp + x_detent_mp + x_wire_barrel_mp + x_wire_wrap_mp - y_upper_jaw_anvil/2;
    latch_x = x_detent_mp * (1-clearance_fraction);
    latch_dx = (x_detent_mp * clearance_fraction)/2;
    latch = [latch_x, body.y, body.z/2 + z_spring_mph];
    spring = [
        body.x + x_strike_mp + x_detent_mp,
        body.y,
        z_spring_mph];
    
    lower_spring_backer = [body.x + x_stop, body.y, body.z];

    split = [x_split_mph, 10, z_split_mph];
    split_front = [1, 10, body.z/2 + z_split_mph];
    column = [body.y, body.y, z_column_mph];

    color("orange", alpha_male_pin_holder) {
        difference() {
            union() {
                block(body, center=BEHIND);
                translate([-body.x, 0, body.z/2])block(spring, center=ABOVE+FRONT);
                translate([-body.x, 0, -body.z/2]) block(lower_spring_backer, center=BELOW+FRONT);
                translate([x_strike_mp + latch_dx, 0, 0]) block(latch, center=ABOVE+FRONT);
                translate([dx_column_mph, -body.y/2, -body.z/2]) block(column, center=RIGHT+FRONT+BELOW);
            }
            translate([1, 0, 0]) rod(d=d_pin+d_pin_clearance, l=x_pin+2, center=BEHIND, $fn=12);
            translate([1, 0, 2]) block(split, center=BEHIND+BELOW);
            block(split_front, center=FRONT+ABOVE);
        }
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


   //********************************************************************************************************
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
