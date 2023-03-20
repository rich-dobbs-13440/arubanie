include <logging.scad>
include <centerable.scad>
use <shapes.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

/* [Show] */

show_top_level = false;
delta_ = 10;
jaw_percent_open = 50; // [0 : 1: 99.99]

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


/* [Jaw Yoke Design] */

x_jaw_yoke_behind = 20; // [0:1:20]
x_jaw_yoke_front = 20; // [0:1:20]
y_jaw_yoke = 10; // [0:1:10]
z_jaw_yoke = 2; // [0:0.25:4]

/* [Upper Jaw Yoke Design] */
w_upper_jaw_yoke = 2;






/* [Rail Clip Design] */
x_rail_clip = 14; // [ 0:0.5:30]

module end_of_customization() {}



// Usage Demo:

y_position(0) articulate_jaws(jaw_angle=12, show_upper_jaw=true, show_upper_jaw_anvil=true);
y_position(1) articulate_jaws(jaw_percent_open=100, show_upper_jaw=true, show_upper_jaw_anvil=true) {
    
}
y_position(2) articulate_jaws(jaw_percent_open=jaw_percent_open) {
    jaw_clip(include_clip_rails=true, dz_rails=10);
    jaw_yoke();
}
y_position(3) articulate_jaws(show_lower_jaw=false) retainer_washer();

y_position(3) articulate_jaws(jaw_percent_open=jaw_percent_open) jaw_hole_clip();




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
    
    
    back_jaw_to_pivot = [12.62, 6.26, 20];
    y_pivot = 16.32;
    d_pivot = 7.92;
    
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



module y_position(idx) {
    delta = y_pivot + 10;
    if (show_top_level) {
        translate([0, delta * idx, 0]) children();
    }
}

module axle(color_name="Gray") {
    color(color_name) 
        rod(d=d_pivot, l=y_pivot, center=SIDEWISE);  
}
 
module articulate_jaws(
        jaw_angle, 
        jaw_percent_open, 
        show_lower_jaw = true, 
        show_lower_jaw_anvil = true, 
        show_upper_jaw = true, 
        show_upper_jaw_anvil = true) {
    
    angle = 
        !is_undef(jaw_angle) ? jaw_angle :
        !is_undef(jaw_percent_open) ? jaw_percent_open * max_jaw_angle / 100 :
        0;
    
    lower_jaw_child = 0;
    upper_jaw_child = 1;
    
    translation_to_pivot = [-(back_jaw_to_pivot.x + x_jaw), 0, 0];
            
    lower_assembly();
    upper_assembly(angle);        
        
    module lower_assembly() {     
        rotate([180, 0, 0]) {
            translate(-translation_to_pivot) back_jaw();
            translate([0, 0, dz_between_upper_and_lower_jaw/2]) {
                
                if (show_lower_jaw) {
                    jaw();
                }  
                if (show_lower_jaw_anvil) {
                    rotate([180, 0, 0]) lower_jaw_anvil();
                }   
                if ($children > lower_jaw_child) {
                    children(lower_jaw_child); 
                }
            }
        }
    }

    module upper_assembly(angle) {
        translate(-translation_to_pivot) { 
            
            rotate([0, angle, 0]) {
                axle();
                back_jaw();
                translate(translation_to_pivot) {
                    translate([0, 0, dz_between_upper_and_lower_jaw/2]) {
                        if (show_upper_jaw) {
                            jaw();
                        }  
                        if (show_upper_jaw_anvil) {
                            upper_jaw_anvil();
                        }
                        //
                        if ($children > upper_jaw_child) {
                            children(upper_jaw_child);
                        }
                    }
                }
                
            }
        }
    }
} 

module back_jaw(color_name="SlateGray") {
    color(color_name) {
        block(back_jaw_to_pivot, center=BEHIND+ABOVE);
    }
}

module lower_jaw_anvil(color_name="DarkSlateGray") {

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
     
    color(color_name) {
        difference() {
            block(lower_jaw_anvil_blank, center=ABOVE+FRONT);    
            pin_side_25_mold();
            wire_side_25_mold();
        }
    }

    translate([x_lower_jaw_anvil/2, 0, 0]) anvil_retainer();

    
}



module upper_jaw_anvil(color_name="DimGray") {
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
        color(color_name) {
            block(upper_jaw_anvil_blank, center=ABOVE+FRONT);    
            pin_side_25_punch();
            wire_side_25_punch();
        }
        translate([x_upper_jaw_anvil/2, 0, 0]) anvil_retainer();
    }
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

module jaw_hole_clearance() {
    translate([x_lower_jaw_anvil/2, 0, z_axis_ar]) {
        rotate([90, 0, 0]) translate([0, 0, 25]) hole_through("M4", $fn=13);
        rotate([90, 0, 0]) translate([0, 1, 25]) hole_through("M4", $fn=13);
    }
}

module jaw(color_name="SlateGray") {
    color(color_name) {
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

module jaw_side() {
    hull() {
        translate([0, 0, 0]) block([x_jaw, y_jaw, 0.01], center=ABOVE+RIGHT+FRONT);
        block([0.01, y_jaw, z_jaw_front], center=ABOVE+RIGHT+FRONT);
        translate([9, 0, 0]) block([0.01, y_jaw, 12.6], center=ABOVE+RIGHT+FRONT);
        translate([x_jaw, 0, 0]) block([0.01, y_jaw, z_jaw], center=ABOVE+RIGHT);
    }
}

module y_centered_jaw_side() {
    translate([0, -y_jaw/2, 0]) jaw_side();
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


module rail_rider(color_name="NavahoWhite") {
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
    color(color_name) {
        difference() {
            rider();
            nutcut();
            
        }
    }
}



module jaw_yoke(color_name="SandyBrown") {
    y_total = y_lower_jaw_anvil + 2 * y_jaw_yoke;
    yoke_behind = [x_jaw_yoke_behind, y_total, z_jaw_yoke];
    yoke_front = [x_jaw_yoke_front, y_jaw_yoke, z_jaw_yoke];
    translation_ht_front = 0.70*yoke_front;
    translation_ht_behind = [-0.8*yoke_behind.x, 0.4*yoke_behind.y, 10];
    color(color_name) {
        difference() {
            block(yoke_behind, center=ABOVE+BEHIND);
            center_reflect([0, 1, 0]) translate(translation_ht_behind) hole_through("M3");
        }

        center_reflect([0, 1, 0]) {
            translate([0, y_lower_jaw_anvil/2, 0]) {
                difference() {
                    block(yoke_front, center=ABOVE+FRONT+RIGHT);
                    translate(translation_ht_front) hole_through("M3");
                }
            }
        }
    }
    
}

//if (show_retainer_washer) {
//   rotation = 
//        orient_for_build ? [90, 0, 0] : 
//        orient == "As designed" ? [0, 0, 0] :
//        orient == "As assembled" ? [0, 0, 0]: 
//        assert(false, assert_msg("orient: ", orient));
//    translation = 
//        orient_for_build ? [0, 0, 0] :
//        orient == "As designed" ? [0, 0, 0] :
//        orient == "As assembled" ? [0, -dy_between_jaw_sides/2, 0]: 
//        assert(false);    
//    translate(translation) rotate(rotation) retainer_washer();
//}

module retainer_washer(color_name = "BlanchedAlmond", lower=true) {
    washer = [
        x_anvil_retainer + 2 * padding_retainer_washer, 
        y_retainer_washer, 
        z_anvil_retainer + padding_retainer_washer
    ];
    module washer() {
        difference() {
            block(washer, center=BELOW+RIGHT, rank=-5);
            translate([0, y_anvil_retainer/2 + dy_retainer_washer, 0]) anvil_retainer();
            translate([0, 0, -z_axis_ar]) rod(d = d_screw_hole_ar, l = 10, center=SIDEWISE+RIGHT);
        }
    }
    z_anvil = //washer.z/2
        lower ? 0 : //z_lower_jaw_anvil : 
        asser(false);
    color(color_name, alpha=0.25) {
        translate([x_jaw/2, y_anvil_retainer/2 + dy_retainer_washer + 0.2, z_anvil]) {
            if (lower) {
                rotate([180, 0, 0]) washer();
            } else {
                assert(false);
            }
        }
    }
}

module jaw_hole_clip(upper=true, wall=2, dx=0) { // dx == dx_pha
    m4_plus_padding_width = 10;
    body = [
        m4_plus_padding_width, 
        wall, 
        z_upper_jaw_anvil + m4_plus_padding_width
    ];
    
    clip = [
        m4_plus_padding_width,
        jaws_extent.y - y_upper_jaw_anvil,
        z_upper_jaw_anvil
    ];
    
    translation = [
        0,
        jaws_extent.y/2,  
        z_upper_jaw_anvil
    ]; 
    z_anvil = upper? z_upper_jaw_anvil : z_lower_jaw_anvil;
    #color("Wheat") {
        render(convexity=10) difference() {
            translate([jaws_extent.x/2, jaws_extent.y/2, -z_anvil]) {
                block(body, center=ABOVE+RIGHT);
                block(clip, center=ABOVE); //, center=FRONT+ABOVE+LEFT);
            }
            jaw_hole_clearance();
        }
    }
    color("hotpink") {
        upper_jaw_yoke(dx=0);
    }
}

module upper_jaw_yoke(color_name="blue", dx=0) { //dx_pha
    assert(is_num(dx));
    m4_plus_padding_width = 10;
    z_yoke = 16.5;
    joiner =  [m4_plus_padding_width, jaws_extent.y + 2 * w_upper_jaw_yoke, w_upper_jaw_yoke];
            // [x_body_mpha, jaws_extent.y + 2 * w_upper_jaw_yoke, w_upper_jaw_yoke];
    side = [m4_plus_padding_width, w_upper_jaw_yoke, z_yoke - m4_plus_padding_width]; //7]; //z_yoke-x_body_mpha
    color(color_name) {
        translate([dx, 0, z_yoke]) {
            block(joiner, center=BELOW+FRONT); 
            center_reflect([0, 1, 0]) translate([0, jaws_extent.y/2, 0]) block(side, center=BELOW+FRONT+RIGHT); 
        }
    }
}





