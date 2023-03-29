include <logging.scad>
include <centerable.scad>
use <shapes.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/materials.scad>
include <SN_28B_measurements.scad>


/* [Build ] */

build_jaw_yoke_SN_28B = false;

/* [Show] */

show_top_level = false;
show_standard = true;
show_development = true;
// Check console for list of items
show_only_one = false;
one_to_show = 0; // [-20:1:20]
delta_ = 30;


/* [Customize] */
jaw_percent_open_ = 50; // [0 : 1: 99.99]
show_only_attachments_ = false;
show_fixed_jaw_ = true; 
show_fixed_jaw_anvil_ = true; 
show_fixed_jaw_screw_ = true;
fixed_jaw_screw_name_ = "M4x8";
show_moving_jaw_ = true; 
show_moving_jaw_anvil_ = true;
show_moving_jaw_screw_ = true;
moving_jaw_screw_name_ = "M4x8";
            

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
y_SN_28B_retainer_washer = 0.6; // [0:0.05:1]
// This is the thickness of the washer surface
dy_SN_28B_retainer_washer = 0.20; // [0:0.05:1]
padding_SN_28B_retainer_washer = 2;


/* [Jaw Yoke Design] */

x_front_sn28b_jk = 24; // [0:1:40]
x_behind_sn28b_jk = 20; // [0:1:24]
y_sn28b_jk = 10; // [0:1:20]
z_sn28b_jk = 2; // [0:0.25:4]
color_name_sn28b_jk = "SandyBrown";
screws_sn28b_jk = false;
        

/* [Upper Jaw Yoke Design] */
w_upper_SN_28B_jaw_yoke = 2;



/* [Rail Clip Design] */
x_rail_clip = 14; // [ 0:0.5:30]

/* [Top Attach Slider Development] */

show_slider_tas = true;
show_slider_mock_tas = true;
orient_slider_tas_ = "RIGHT"; // [RIGHT, LEFT]
orient_slider_tas = center_str_to_center(orient_slider_tas_);

/* [Top Attach Attachment Development] */

show_attachment_tas = true;
show_attachment_mock_tas = true;
orient_attachment_tas_ = "RIGHT"; // [RIGHT, LEFT]
orient_attachment_tas = center_str_to_center(orient_attachment_tas_);


module end_of_customization() {}



// Usage Demo:
y_position(1, "Default - jaw closed, no attachments") 
    SN_28B_pin_crimper();

y_position(2, "Position jaw by angle") 
    SN_28B_pin_crimper(jaw_angle=12);

y_position(3, "Jaw position by percent open") 
    SN_28B_pin_crimper(jaw_percent_open=75);

y_position(4, "Hiding jaw and anvil")
    SN_28B_pin_crimper(jaw_percent_open=100, show_fixed_jaw=false, show_moving_jaw_anvil=false);

y_position(5, "Attaching children, jaw_clip, and SN_28B_jaw_yoke, and changing jaw position by customization")  
    SN_28B_pin_crimper(jaw_percent_open=jaw_percent_open_, fixed_jaw_screw_name="M4x16") {
        SN_28B_jaw_clip(include_clip_rails=true, dz_rails=10);
        SN_28B_jaw_yoke();
    }

y_position(6, "Retainer washer")  
    SN_28B_pin_crimper(show_fixed_jaw=false) 
        SN_28B_retainer_washer(color_name = "Pink", alpha=0.75);
    
y_position(7, "Retainer washer on both sides, and dealing with no fixed children.")
    SN_28B_pin_crimper(show_moving_jaw=false, show_moving_jaw_anvil=false) {
        no_fixed_jaw_attachments();
        center_reflect([0, 1, 0]) SN_28B_retainer_washer(color_name = "Pink", alpha=1);   
    }

y_position(8, "Rotation from one jaw to another") 
    SN_28B_pin_crimper(jaw_percent_open=jaw_percent_open_, fixed_jaw_screw_name="M4x16", moving_jaw_screw_name="M4x16") {
        SN_28B_jaw_hole_clip(x_front=0);
        SN_28B_jaw_hole_clip(x_front=0);
    }

y_position(9, "Default jaw_clip") 
    SN_28B_pin_crimper(jaw_percent_open=jaw_percent_open_) {
        no_fixed_jaw_attachments();
        SN_28B_jaw_hole_clip(do_cap=true, x_front=2);
    }
    
y_position(10, "Top attach_slider") 
    SN_28B_pin_crimper(jaw_percent_open=jaw_percent_open_) {
        union() {
            SN_28B_M4_rail(LEFT, x_behind = 20);
            SN_28B_M4_rail_M3_top_attach_slider(
                orient=LEFT, 
                slider_length = 10, 
                rail_clearance = 0.2, 
                color_name = "Orchid", 
                alpha = 1,
                show_mock = true);
            SN_28B_M4_rail_M3_top_attach_fitting(
                    orient=LEFT,
                    size = [10, 10, 7],
                    registration_clearance=0.2,
                    screw_name = "M3x8",
                    color_name = "Plum",
                    alpha = 1,
                    show_mock = true);
        }
    } 
y_position(10, "Customized SN_28B Jaw Yoke") 
    SN_28B_pin_crimper(jaw_percent_open=jaw_percent_open_) {
        customized_SN_28B_jaw_yoke();
        customized_SN_28B_jaw_yoke();
    }
    
y_position(-3, "Slider and fitting with crimper") {
    if (show_slider_tas) {
        SN_28B_M4_rail_M3_top_attach_slider(
            orient=orient_slider_tas, 
            slider_length = 10, 
            rail_clearance = 0.2, 
            color_name = "Orchid", 
            alpha = 1,
            show_mock = show_slider_mock_tas);
    }
    if (show_attachment_tas) {
        SN_28B_M4_rail_M3_top_attach_fitting(
            orient=orient_attachment_tas,
            size = [10, 10, 7],
            registration_clearance=0.2,
            screw_name = "M3x8",
            color_name = "Plum",
            alpha = 1,
            show_mock = show_attachment_mock_tas);
    }
}



   
//y_position(0) 
//    // Show M4 rail
//    custom_SN_28B_pin_crimper() {
//        union() {
//            SN_28B_M4_rail(LEFT, x_behind = 20);
//            SN_28B_M4_rail(RIGHT, x_behind = 20);
//            SN_28B_jaw_hole_clip(do_cap=true, x_front= -20, x_back = jaws_extent.x);
//        }
//        
//    }    
   
//y_position(-1) 
//    // Show M4 rail
//    custom_SN_28B_pin_crimper() {
//        union() {
//            //SN_28B_M4_rail(LEFT, x_behind = 20);
//            //SN_28B_M4_rail(RIGHT, x_behind = 20);
//            //SN_28B_jaw_hole_clip(do_cap=true, x_front= -20, x_back = jaws_extent.x);
//            SN_28B_M4_rail_slider(LEFT, l=25, clearance = 0.2);
//        }
//        
//    }   
    
    
module no_fixed_jaw_attachments() {}


module custom_SN_28B_pin_crimper() {
    //jaw_percent_open=jaw_percent_open, fixed_jaw_screw_name="M4x25"
    SN_28B_pin_crimper(
        //jaw_angle, 
            jaw_percent_open = jaw_percent_open_, 
            show_only_attachments = show_only_attachments_,
            show_fixed_jaw = show_fixed_jaw_, 
            show_fixed_jaw_anvil = show_fixed_jaw_anvil_, 
            show_fixed_jaw_screw = show_fixed_jaw_screw_,
            fixed_jaw_screw_name= fixed_jaw_screw_name_,  //"M4x8",
            show_moving_jaw = show_moving_jaw_, 
            show_moving_jaw_anvil = show_moving_jaw_anvil_,
            show_moving_jaw_screw = show_moving_jaw_screw_,
            moving_jaw_screw_name=moving_jaw_screw_name_) {
        if ($children > 0) {
            children(0);
        }
        if ($children > 1) {
            children(1);
        }
    }      
}
    
module y_position(idx, description) {
    function translation(idx) = let( actual_delta = y_pivot + delta_) [0, actual_delta * idx, 0];
    echo("Y position index: ", idx, "Description: ", description);
    if (show_top_level) {
        if ((show_standard && idx > 0) || (show_development && idx <= 0)) {
            translate(translation(idx)) children();
        }
        if (!show_only_one || (idx == one_to_show)) {
            translate(translation(idx)) children();
        }        
    }
}    



/* [Jaw Clip Calculations] */
    y_jaw_clip = 2*wall_jaw_clip + jaws_extent.y + 2*clearance_jaw_clip; 


module SN_28B_upper_jaw_anvil(color_name="DimGray") {
    module punch(dx, x_base, x_top, z_top) {
        hull() {
            translate([dx, 0, z_upper_jaw_anvil]) 
                block([x_base, y_upper_jaw_anvil/2, 0.01], center=ABOVE+LEFT);
             translate([dx, 0, z_top]) 
                    block([x_top, y_upper_jaw_anvil/2, 0.01], center=ABOVE+LEFT);
        }
    }
    mirror([0, 0, 1]) {
        color(color_name) {
            block(upper_jaw_anvil_blank, center=ABOVE+FRONT); 
            
            mirror([0, 1, 0])punch(dx_025_anvil, x_b_025_pin_punch, x_t_025_pin_punch, dz_025_pin_punch_z);
            punch(dx_025_anvil, x_b_025_wire_punch, x_t_025_wire_punch, dz_025_wire_punch_z);
            
            mirror([0, 1, 0]) punch(dx_050_anvil, x_b_050_pin_punch, x_t_050_pin_punch, dz_050_pin_punch_z);
            punch(dx_050_anvil, x_b_050_wire_punch, x_t_050_wire_punch, dz_050_wire_punch_z);

            mirror([0, 1, 0]) punch(dx_100_anvil, x_b_100_pin_punch, x_t_100_pin_punch, dz_100_pin_punch_z);
            punch(dx_100_anvil, x_b_100_wire_punch, x_t_100_wire_punch, dz_100_wire_punch_z);

        }
        translate([x_upper_jaw_anvil/2, 0, 0]) SN_28B_anvil_retainer();
    }
} 


module SN_28B_back_jaw(color_name="SlateGray", center) {
    assert(is_num(center));
    color(color_name) {
        if (center == ABOVE) {
            block(back_jaw_to_pivot_moving, center=BEHIND+center);
        } else {
            block(back_jaw_to_pivot_fixed, center=BEHIND+center);
        }
    }
} 
    
    
module SN_28B_pin_crimper(
        jaw_angle, 
        jaw_percent_open, 
        show_only_attachments = false, 
        show_fixed_jaw = true, 
        show_fixed_jaw_anvil = true, 
        show_fixed_jaw_screw = true,
        fixed_jaw_screw_name="M4x8",
        show_moving_jaw = true, 
        show_moving_jaw_anvil = true,
        show_moving_jaw_screw = true,
        moving_jaw_screw_name="M4x8",
        ) {
            
    angle = 
        !is_undef(jaw_angle) ? jaw_angle :
        !is_undef(jaw_percent_open) ? jaw_percent_open * max_jaw_angle / 100 :
        0;  
   
    fixed_jaw_child = 0;
    moving_jaw_child = 1; 
    assert($children <= 2, "Too many children as attachments! Should be fixed followed by moving."); 
            
            
    translation_from_pivot() {        
        fixed_assembly(
                !show_only_attachments, 
                show_fixed_jaw_, 
                show_fixed_jaw_anvil_, 
                show_fixed_jaw_screw_, 
                fixed_jaw_screw_name) {
            if ($children > fixed_jaw_child) {
                children(fixed_jaw_child);
            }         
        }
         
        rotate([0, angle, 0]) {
            moving_assembly(
                    !show_only_attachments,
                    show_moving_jaw, 
                    show_moving_jaw_anvil, 
                    show_moving_jaw_screw, 
                    moving_jaw_screw_name) {
                if ($children > moving_jaw_child) {
                    children(moving_jaw_child);
                }             
             }
         }
     }
     
    module fixed_assembly(show_crimper, show_jaw, show_anvil, show_screw, screw_name) {
        if (show_crimper) { 
            axle();
            SN_28B_back_jaw(center=BELOW);
        }
        translation_to_pivot(fixed = true) {  
            if (show_jaw && show_crimper) {
                jaw();
            }  
            if (show_anvil && show_crimper) {
                rotate([180, 0, 0]) lower_jaw_anvil();
            }   
            if (show_screw && show_crimper) {
                SN_28B_positioned_screw(screw_name, fixed=true);
            }
            children(); 
        }
    }

    module moving_assembly(show_crimper, show_jaw, show_anvil, show_screw, screw_name) {
        if (show_crimper) { 
            axle();
            SN_28B_back_jaw(center=ABOVE);
        }
        translation_to_pivot(fixed = false) {  
            if (show_jaw && show_crimper) {
                jaw();
            }  
            if (show_anvil && show_crimper) {
                SN_28B_upper_jaw_anvil();
            }
            if (show_screw && show_crimper) {
                SN_28B_positioned_screw(screw_name, fixed=false);
            }        
            children(); 
        }
    }
    
    module translation_to_pivot(fixed) {
        assert(is_bool(fixed));
        
        rotation = fixed ? [180, 0, 0] : [0, 0, 0];
        translate(translation_jaw_to_pivot(fixed=fixed)) rotate(rotation) children();
    }

    module translation_from_pivot() {
        children();
    }    
    
    module axle(color_name="Gray") {
        color(color_name) 
            rod(d=d_pivot, l=y_pivot, center=SIDEWISE);  
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

        translate([x_lower_jaw_anvil/2, 0, 0]) SN_28B_anvil_retainer();  
    }

    module jaw(color_name="SlateGray") {
        color(color_name) {
            render(convexity = 10) difference() {        
                center_reflect([0, 1, 0]) {
                    translate([-0.5, dy_between_jaw_sides/2]) {
                        SN_28B_jaw_side();
                    }
                } 
                SN_28B_jaw_hole_clearance(loose=false);
            }
        }
    }
 }    


module SN_28B_anvil_retainer() {
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


module SN_28B_jaw_side() {
    hull() {
        translate([0, 0, 0]) block([x_jaw, y_jaw, 0.01], center=ABOVE+RIGHT+FRONT);
        block([0.01, y_jaw, z_jaw_front], center=ABOVE+RIGHT+FRONT);
        translate([9, 0, 0]) block([0.01, y_jaw, 12.6], center=ABOVE+RIGHT+FRONT);
        translate([x_jaw, 0, 0]) block([0.01, y_jaw, z_jaw], center=ABOVE+RIGHT);
    }
}


module SN_28B_jaw_hole_clearance(loose=false) {
    module hole() {
        translate([x_lower_jaw_anvil/2, 0, z_axis_ar]) {
            rotate([90, 0, 0]) 
                translate([0, 0, 25]) hole_through("M4", $fn=13);
        }
    }
    hole();
    if (loose) {
        translate([0, 0, 1]) hole(); 
        translate([0, 0, -1]) hole(); 
    }
}

module SN_28B_M4_rail_locate(orient, x_behind) {
    translation = 
        orient == LEFT ? [-x_behind, jaws_extent.y/2, z_axis_ar] :
        orient == RIGHT ? [-x_behind, -jaws_extent.y/2, z_axis_ar] :
        assert(false);
    rotation = 
        orient == LEFT ? [0, 0, 0] :
        orient == RIGHT ? [180, 0, 0] :
        assert(false);

    difference() {
        translate(translation) {
            rotate(rotation) {
                children();
            }
        } 
        SN_28B_positioned_screw("M4x25", fixed=true, clearance=true); 
    }
}


module SN_28B_M4_rail(orient, x_behind = 20, color_name="Bisque") {
    assert(is_num(orient), assert_msg("orient: ", str(orient)));
    thickness = 6; // Large enough to take the head or shaft of an M4 Bolt
    size = [jaws_extent.x + x_behind, 12, 10];
    color(color_name) {
        SN_28B_M4_rail_locate(orient, x_behind) {
            t_rail(size, thickness);
        }
    }
}


module SN_28B_M4_rail_slider(orient, slider_length, clearance = 0.2, color_name="Peru", rail_mounting_y = 2) {
    assert(is_num(orient), assert_msg("orient: ", str(orient)));
    assert(is_num(slider_length), assert_msg("slider_length: ", str(slider_length)));
    rail_thickness = 6; // Large enough to take the head or shaft of an M4 Bolt
    slide_thickness = 2; //enough for structural purposes
    size = [slider_length, 12, 10];
    color(color_name) {
        translate([slider_length/2, 0, 0]) SN_28B_M4_rail_locate(orient, x_behind = slider_length) {
            t_rail_slide(
                rail_size = size, 
                rail_thickness = rail_thickness, 
                rail_mounting_y = rail_mounting_y, 
                clearance = clearance, 
                slide_thickness=slide_thickness);
        }
    }
}


module SN_28B_M4_rail_M3_top_attach_slider(
        orient = RIGHT, 
        slider_length = 10, 
        rail_clearance = 0.2, 
        color_name = "Orchid", 
        alpha = 1,
        show_mock = true) {
    color(color_name, alpha=alpha) {
        difference() {
            union() {
                SN_28B_M4_rail_slider(orient=orient, slider_length=slider_length, clearance = rail_clearance);
                SN_28B_M4_rail_M3_registration(
                    orient=orient, slider_length=slider_length, registration_clearance=0);
            }
            SN_28B_M4_rail_M3_screws_and_nuts(orient=orient, screw_name=undef, as_clearance=true);
        }
    }
    
    if (show_mock) { 
        SN_28B_M4_rail_M3_screws_and_nuts(orient=orient, just_nut = true);
    }
}

module SN_28B_M4_rail_position(orient, child_position) {

    if (child_position == "relative_to_rotation") {
        SN_28B_M4_rail_position_for_rotation(orient=orient) children();
    } else if (child_position == "relative_to_edge") {
        SN_28B_M4_rail_position_for_edge(orient=orient) children();
    } else if (child_position == "relative_to_jaw") {
        SN_28B_M4_rail_position_for_jaw(orient=orient) children();
    } else {
        assert(false, assert_msg("Don't know how to handle child_position: ", str(child_position)));
    }
}

module SN_28B_M4_rail_M3_top_attach_fitting_screw_blocks_clearance(size, orient) {

    SN_28B_M4_rail_position_for_rotation(orient=orient) {
        center_reflect([1, 0, 0]) {
            center_reflect([0, 1, 0]) { 
                translate([size.x/2, 2, 0]) {
                    rotate([0, -90, 0]) { 
                        nutcatch_sidecut("M2");
                        hole_through("M2", $fn=12);
                    }                  
                }

            }
        }
    }
}

module SN_28B_M4_rail_M3_top_attach_fitting(
        orient = RIGHT,
        child_position="relative_to_jaw",
        size = [10, 10, 7],
        registration_clearance=0.2,
        screw_name = "M3x10",
        color_name = "Plum",
        alpha = 1,
        show_mock = true) {
    assert(is_num(orient), assert_msg("orient: ", str(orient)));
            
    module screw_blocks() {
        z_offset = 2;
        difference() {
            center_reflect([1, 0, 0]) SN_28B_M4_rail_position_for_edge(orient=orient) {
                translate([size.x/2, 0, z_offset]) 
                    block([4, size.y, size.z + z_offset], center = BELOW + RIGHT +FRONT);
            }
            SN_28B_M4_rail_M3_top_attach_fitting_screw_blocks_clearance(size, orient);
        }
    }
    screw_blocks();
    
    difference() {
        union() {
            color(color_name, alpha) {
                SN_28B_M4_rail_position_for_edge(orient=orient) {
                    block(size, center=BELOW+RIGHT);
                }
            }

            if (is_list(child_position)) {
                if ($children > 0 && len(child_position) > 0) {
                    SN_28B_M4_rail_position(orient, child_position[0]) children(0);
                } 
                if ($children > 1 && len(child_position) > 1) {
                    SN_28B_M4_rail_position(orient, child_position[1]) children(1);
                }   
                if ($children > 2 && len(child_position) > 2) {
                    SN_28B_M4_rail_position(orient, child_position[2]) children(2);
                }    
                if ($children > 3 && len(child_position) > 3) {
                    SN_28B_M4_rail_position(orient, child_position[3]) children(3);
                }
            } else if (is_string(child_position)) {
               SN_28B_M4_rail_position(orient, child_position) children();
            } else {
               assert(false, assert_msg("Don't know how to handle child_position: ", str(child_position)));
            }
        }
        SN_28B_M4_rail_M3_registration(orient=orient, slider_length=size.x, registration_clearance=registration_clearance);
        SN_28B_M4_rail_M3_screws_and_nuts(orient=orient, screw_name=screw_name, as_clearance=true);
    }
    if (show_mock) {
        SN_28B_M4_rail_M3_screws_and_nuts(orient, screw_name=screw_name, just_screw=true);
    }
}


module SN_28B_M4_rail_position_for_rotation(orient) {
    if (orient == LEFT) {
        translate([0, 14, -3.5])  children();
    } else if (orient == RIGHT) {
        mirror([0, 1, 0]) translate([0, 14, -3.5])  children();
    } else {
        assert(is_num(orient), assert_msg("orient: ", str(orient)));
        assert(false);
    }
}

module SN_28B_M4_rail_position_for_edge(orient) {
    if (orient == LEFT) {
        translate([0, 9, -3])  children();
    } else if (orient == RIGHT) {
        mirror([0, 1, 0]) translate([0, 9, -3])  children();
    } else {
        assert(is_num(orient), assert_msg("orient: ", str(orient)));
        assert(false, assert_msg("Orient should be either RIGHT or LEFT but was : ", str(orient)));
    }        
}

module SN_28B_M4_rail_position_for_jaw(orient) {
    if (orient == LEFT) {
        translate([0, 0, 0])  children();
    } else if (orient == RIGHT) {
        mirror([0, 1, 0]) translate([0, 0, 0])  children();
    } else {
        assert(is_num(orient), assert_msg("orient: ", str(orient)));
        assert(false, assert_msg("Orient should be either RIGHT or LEFT but was : ", str(orient)));
    }      
}

module SN_28B_M4_rail_M3_registration(orient, slider_length, registration_clearance) {
    assert(is_num(orient), assert_msg("orient: ", str(orient)));
    function swell(dimension) = dimension + 2*registration_clearance;
    d = swell(8);
    h = swell(4);    
    SN_28B_M4_rail_position_for_rotation(orient=orient) {
        can(d=d, h=2, center=ABOVE);
        can(d=d, h=h, center=BELOW);
        block([swell(slider_length), swell(4), swell(2)], center=ABOVE);
        block([swell(slider_length), swell(4), swell(2)], center=BELOW);
        children();
    }   
}

module SN_28B_M4_rail_M3_screws_and_nuts(
        orient, 
        screw_name, 
        just_nut=false, 
        just_screw=false, 
        as_clearance=false) {
    module attachment_screw(as_clearance) {
        translation = 
            screw_name == "M3x8" ? [0, 0, -5] :
            screw_name == "M3x10" ? [0, 0, -7] :
            assert(false);
        if (as_clearance) {
            alot = 100;
            translate(translation) 
                translate([0, 0, -alot]) 
                    rotate([180, 0, 0])  
                        hole_through("M3", h=alot, l=alot, $fn=12);  //l=200, h=100,   
        } else {
            color("Silver") translate(translation) rotate([180, 0, 0]) screw(screw_name, $fn=12);
        }
    }    
    SN_28B_M4_rail_position_for_rotation(orient) {

        if (just_nut) {
            stainless() rotate([180, 0, 0]) nut("M3", $fn=12);
        } else if (just_screw) {
            attachment_screw();
        } else if (as_clearance) {
            rotate([180, 0, 0]) nutcatch_parallel("M3", clh=5);
            if (!is_undef(screw_name)) {
                attachment_screw(as_clearance=true);
            }   else {
                center_reflect([0, 0, 1]) hole_through("M3", cld=0.4, $fn=12);
            }
        } 
    }     
}





module SN_28B_positioned_screw(screw_name, fixed, clearance=false) {
    rotation = fixed ? [90, 0, 0] : [-90, 0, 0];
    nut_height = 3.2;
    head_clearance = 25;
    y_screw = 
        screw_name == "M4x8"? 8/2 :
        screw_name == "M4x10"? (10)/2 :
        screw_name == "M4x12"? (12-nut_height)/2  :
        // Not supported! screw_name == "M4x14"? (14-nut_height)/2  :
        screw_name == "M4x16"? (16-nut_height)/2  :
        // Not supported! screw_name == "M4x18"? (18-nut_height)/2  :
        screw_name == "M4x20"? (20-nut_height)/2  :
        screw_name == "M4x25"? (25-nut_height)/2  :
        assert(false);
    translation = fixed ? 
        [jaws_extent.x/2, -y_screw, z_axis_ar] : 
        [jaws_extent.x/2, y_screw, z_axis_ar];
    translate(translation) {
        rotate(rotation) { 
            if (clearance) {
                translate([0, 0, head_clearance]) 
                    hole_through("M4", l=100, h=head_clearance, $fn=12);
                translate([0, 0, -2*y_screw])nutcatch_parallel("M4", clh=10);
            } else {
                if (screw_name == "M4x8") {
                    iron() screw(screw_name);
                } else {
                    stainless() screw(screw_name);
                }
            }
        }
    }
}


module SN_28B_y_centered_jaw_side() {
    translate([0, -y_jaw/2, 0]) SN_28B_jaw_side();
}


module SN_28B_jaw_clip(include_clip_rails = false, dz_rails = 0, color_name = "Tan") {
    module base() {
        resize([0, y_jaw_clip,  0]) {
            center_reflect([0, 1, 0]) {
                translate([0, -dy_between_jaw_sides/2, 0]) {
                    render(convexity=10) difference() {
                        hull() translate([0, 0, clearance_jaw_clip+dz_base_jaw_clip]) SN_28B_jaw_side();
                        hull() translate([0, 0, clearance_jaw_clip])SN_28B_jaw_side();
                    }
                }
            }
        }
    }
    module side_walls() {
        center_reflect([0, 1, 0]) 
            translate([0, y_jaw_clip/2 - wall_jaw_clip/2]) 
                resize([0, wall_jaw_clip,  z_jaw+2*clearance_jaw_clip]) 
                    SN_28B_y_centered_jaw_side(); 
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
    color(color_name) {
        difference() { 
            body();
            SN_28B_jaw_hole_clearance(loose=true);
        }
    }

}


module SN_28B_t_rail_clip(
        size, 
        thickness, 
        dz_rails, 
        clearance, 
        outer_m3_attachment=false, 
        cap_m3_attachmment=false) {
    
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


module SN_28B_rail_rider(color_name="NavahoWhite") {
    clearance_SN_28B_rail_rider = 0.2;
    x_SN_28B_rail_rider = 11;
    slide = [
        x_SN_28B_rail_rider, 
        2.9, // y_rail_jaw_clip - t_rail_jaw_clip - 2 * clearance_SN_28B_rail_rider,
        4]; // z_rail_jaw_clip/2 - t_rail_jaw_clip/2];
    plate = [
        10,
        t_rail_jaw_clip, //slide.y,
        10
    ];
    
    
    positioning = [
        x_jaw, 
        y_jaw_clip/2 + clearance_SN_28B_rail_rider, 
        t_rail_jaw_clip/2];
    
    t_z_reflection = [0, 0, t_rail_jaw_clip/2 + clearance_SN_28B_rail_rider];
    t_plate = [
        -(x_rail_jaw_clip + clearance_SN_28B_rail_rider),
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
            -(y_jaw_clip/2 + clearance_SN_28B_rail_rider + plate.y + h_bolt_head), 
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

if (build_jaw_yoke_SN_28B) {
    customized_SN_28B_jaw_yoke();
}


module customized_SN_28B_jaw_yoke() {
    SN_28B_jaw_yoke(
        x_front = x_front_sn28b_jk,
        x_behind = x_behind_sn28b_jk,
        y = y_sn28b_jk,
        z=z_sn28b_jk,
        color_name = color_name_sn28b_jk, 
        screws = screws_sn28b_jk);
}




module SN_28B_jaw_yoke(
        x_front=5,
        x_behind = 5,
        y = 10,
        z = 1,
        color_name = "SandyBrown", 
        color_alpha = 1,
        screws = false) {
            
    y_total = y_lower_jaw_anvil + 2 * y;
    yoke_behind = [x_behind, y_total, z];
    yoke_front = [x_front, y, z];
//    translation_ht_front = [0.8*yoke_front.x, 0.9*y, 25];
//    translation_ht_behind = [-0.8*yoke_behind.x, 0.9*y, 25];
    color(color_name, alpha=color_alpha) {
        difference() {
            union() {
                block(yoke_behind, center=ABOVE+BEHIND);
                center_reflect([0, 1, 0])
                    translate([0, y_lower_jaw_anvil/2, 0])
                        block(yoke_front, center=ABOVE+FRONT+RIGHT);
            }
            fixed = true;
            translate(-translation_jaw_to_pivot(fixed)) SN_28B_back_jaw(center=BELOW);
            if (screws) {
                center_reflect([0, 1, 0]) {
                    for (dx = [2:6: x_front]) {
                        for (dy = [8:6:y_total]) {
                            translate([dx, dy, 25]) hole_through("M3", $fn=6);
                        }
                    }
                }
                center_reflect([0, 1, 0]) {
                    for (dx = [4:6: x_behind]) {
                        for (dy = [2:6:y_total]) {
                            translate([-dx, dy, 25]) hole_through("M3", $fn=6);
                        }
                    }
                }
            }
        }
    }
    
}


module SN_28B_retainer_washer(lower=true, color_name = "SaddleBrown", alpha=1) {
    washer = [
        x_anvil_retainer + 2 * padding_SN_28B_retainer_washer, 
        y_SN_28B_retainer_washer, 
        z_anvil_retainer + padding_SN_28B_retainer_washer
    ];
    module washer() {
        difference() {
            block(washer, center=BELOW+RIGHT, rank=-5);
            translate([0, y_anvil_retainer/2 + dy_SN_28B_retainer_washer, 0]) SN_28B_anvil_retainer();
            translate([0, 0, -z_axis_ar]) rod(d = d_screw_hole_ar, l = 10, center=SIDEWISE+RIGHT);
        }
    }
    z_anvil = //washer.z/2
        lower ? 0 : //z_lower_jaw_anvil : 
        asser(false);
    color(color_name, alpha=alpha) {
        translate([x_jaw/2, y_anvil_retainer/2 + dy_SN_28B_retainer_washer + 0.2, z_anvil]) {
            if (lower) {
                rotate([180, 0, 0]) washer();
            } else {
                assert(false);
            }
        }
    }
}

module SN_28B_jaw_hole_clip(
        upper = true, 
        wall = 2, 
        x_front = undef,
        x_back = undef,
        do_cap = false, 
        z_cap = 18,
        color_name= "Wheat") {
            
    m4_plus_padding_width = 10;
            
    dx_body_front = !is_undef(x_front) ? x_front : jaws_extent.x/2 - m4_plus_padding_width/2;
    dx_body_back =  !is_undef(x_back) ?  x_back :  jaws_extent.x/2 + m4_plus_padding_width/2;    
    x_body = dx_body_back - dx_body_front;      
    z_body = do_cap ? z_cap + wall : z_upper_jaw_anvil + m4_plus_padding_width;
     
    echo("dx_body_front", dx_body_front); 
    echo("dx_body_back", dx_body_back);        
    body = [
        x_body, 
        wall, 
        z_body
    ];
    
    clip = [
        body.x,
        jaws_extent.y - y_upper_jaw_anvil,
        z_upper_jaw_anvil
    ];
    cap = [
        body.x, 
        jaws_extent.y + 2*wall, 
        wall
    ];
     
    z_anvil = upper? z_upper_jaw_anvil : z_lower_jaw_anvil;
    
    module locate() {
        translate([dx_body_front, jaws_extent.y/2, -z_anvil]) {
            children();  
        }
    }
    module basic() {
        render(convexity=10) difference() {
            locate() {
                block(body, center=ABOVE+RIGHT+FRONT);
                block(clip, center=ABOVE+FRONT); 
            }
            SN_28B_jaw_hole_clearance(loose=true);
        }        
    }
    module cap() {
        locate() {
            translate([0, wall, body.z]) block(cap, center=BELOW+LEFT+FRONT);
        }
    }
    
    color(color_name) {
        if (do_cap) {
            center_reflect([0, 1, 0]) basic();
            cap();
        }
        else {
            basic();
        }
    }
}
