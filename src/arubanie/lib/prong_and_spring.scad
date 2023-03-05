include <centerable.scad>
include <logging.scad>
use <not_included_batteries.scad>
use <shapes.scad>
use <MCAD/boxes.scad>

infinity = 100;

/* [Parts] */
    show_prong = false;
    show_spring_cuts = false;
    show_prong_hole_through = false;
    show_attach_prong_to_face = true;
    show_hole_in_matching_face = true;
    
    match_face_alpha_ = 0.50; // [0.1 : 0.1 : 1]
    dx_between_faces_ = 1; // [0 : 0.05 : 1]

/* [Dimensions] */
    spring_length_ = 13; // [0: 0.5 : 14]
    spring_thickness_ = 1; // [0: 0.5 : 3]
    spring_width_ = 4; // [0: 0.5 : 10]
    
    catch_offset_ = 7; // [0: 0.5 : 10]
    
    catch_length_ = 2; // [0: 0.25 : 2]
    catch_thickness = 0.5; // [0: 0.5 : 10]
    catch_width_ = spring_width_;

    catch_allowance_ = 0.4; // [0: 0.25 : 2]
    
    
module end_of_customization() {}

prong_ = prong_dimensions(
    spring = [spring_length_, spring_thickness_, spring_width_],
    catch = [catch_length_, catch_thickness, catch_width_], 
    catch_offset = catch_offset_,
    catch_allowance = catch_allowance_); 

face = [ spring_length_+ 4, spring_thickness_, 2*spring_width_];
      
if (show_prong) {
    spring_and_prong(prong_, "prong");
}

if (show_spring_cuts) {
    color("green")  spring_and_prong(prong_, "spring_cuts");
}

if (show_prong_hole_through) {
    color("blue", alpha=0.25)  spring_and_prong(prong_, "prong_hole_through");
}

if (show_attach_prong_to_face) {
    
    color("green") {
        render() difference() {
            block(face, center=RIGHT+FRONT);
            spring_and_barb(prong_, "spring_cuts");
        }
        spring_and_barb(prong_, "prong");
    } 
}

if (show_hole_in_matching_face) {
    color("orange", alpha=match_face_alpha_) {
        render() difference() {
            translate([0, -dx_between_faces_, 0]) block(face, center=LEFT+FRONT);
            spring_and_barb(prong_, "prong_hole_through");
        }
    }
}


// ********************************* Start of implementation *********************




function prong_dimensions(
        spring, 
        catch, 
        catch_offset, 
        catch_allowance, 
        window_offset,
        cut_width)  =
        
     let (
        last = undef
     )
        
     [
        ["component", "prong_dimensions"],
        ["spring", is_undef(spring) ? [15, 1, 4]: spring], 
        ["catch", is_undef(catch) ? [2, 1, 4] : catch], 
        ["catch_offset", is_undef(catch_offset) ? 7: catch_offset],
        ["catch_allowance",is_undef(catch_allowance) ? 0.4: catch_allowance], 
        ["window_offset", is_undef(window_offset) ? 2: window_offest], 
        ["cut_width", is_undef(cut_width) ? 1: cut_width], 
     ];

function prong_dimension(prong_dimensions, item) = find_in_dct(prong_dimensions, item);
    

module spring_and_barb(prong_dimensions, part, support_offset) {

    
    if (part == "prong") {
        prong();
    } else if (part == "prong_clearance") {
    } else if (part == "spring_cuts") {
        spring_cuts();
    } else if (part == "prong_hole_through") {
        prong_hole_through();         
    } else {
        assert(false, assert_msg("Unhandled part = ", str(part)));
    }
    
    COMPONENT_NAME = 0;
    SPRING_SIZE = 1;
    CATCH_SIZE = 2;
    X_OFFSET_CATCH = 3;
    CATCH_ALLOWANCE = 4;
    X_OFFSET_WINDOW = 5;
    CUT_WIDTH = 6;

    COMPONENT = "prong_dimensions";

    assert(prong_dimensions[COMPONENT_NAME][1] == COMPONENT, assert_msg("Doesn't look like a prong: ", str(prong_dimensions)));
    spring = prong_dimensions[SPRING_SIZE][1];
    catch = prong_dimensions[CATCH_SIZE][1];
    x_offset_catch = prong_dimensions[X_OFFSET_CATCH][1];
    x_offset_window = prong_dimensions[X_OFFSET_WINDOW][1];
    catch_allowance = prong_dimensions[CATCH_ALLOWANCE][1];
    cut_width = prong_dimensions[CUT_WIDTH][1];


    module prong() {
        
        module rounded_target(spring, cross_section) {
            assert(!is_undef(cross_section));
            target = cross_section ? [spring.z, spring.y, 0.01] : [spring.z, spring.y, spring.y];
            sidesOnly = cross_section;
            //block(cross_section, center=BEHIND+RIGHT);
            translate([target.z/2, target.y/2, 0]) 
                rotate([0, 90, 0]) 
                   roundedBox(target,  radius=target.y/2, sidesonly=sidesOnly, $fn=12);           
        }


        module spring_target(dx, cross_section) {
            rounded = true;
            translate([dx, 0, 0]) 
                if (rounded) {
                    rounded_target(spring, cross_section); 
                } else {
                    cross_section = [0.01, spring.y, spring.z];
                    block(cross_section, center=BEHIND+RIGHT);
                }
        }
        
        reduced_catch = catch - [0, 0, catch.y];
        
        hull() {
            spring_target(x_offset_window, cross_section=false);
            spring_target(x_offset_catch, cross_section=true);
            translate([x_offset_catch, 0, catch.y/2]) block(reduced_catch, center=BEHIND+LEFT); 
        }
        hull() {
            spring_target(x_offset_window, cross_section=false);
            spring_target(spring.x, cross_section=true);
        }
        
        printer_support(support_offset);
        // Printer Support

    }
    
    module printer_support(support_offset) {
        translate([x_offset_window, 0, -spring.z/2]) {
            hull() {
                render() difference() {
                    rod(d = spring.y, l = cut_width+0.5, center=RIGHT);
                    plane_clearance(ABOVE);
                }
                if (is_num(support_offset)) {
                    translate([0, support_offset, -abs(support_offset)])
                    rod(d = spring.y, l = cut_width+0.5, center=RIGHT);
                }
            }
        }
    }    


    module spring_cuts() {
        module cutter(dx) {
            translate([dx, 0, spring.z/2+cut_width/2]){
                rod(d=cut_width, l=10, center=SIDEWISE, $fn=12);
            }
        }
        center_reflect([0, 0, 1]) {
            hull() {
                cutter(spring.x);
                cutter(x_offset_window);
            }
        }
        hull() {
            center_reflect([0, 0, 1]) cutter(x_offset_window);
        } 
    }

    
    module prong_hole_through() {
        x = x_offset_catch - x_offset_window + 2*catch_allowance;
        z = catch.z + 2 * catch_allowance;
        hole = [x, infinity, z];
        dx = x_offset_catch + catch_allowance;
        translate([dx, 0, 0]) block(hole, center=BEHIND); 
    }    
}    