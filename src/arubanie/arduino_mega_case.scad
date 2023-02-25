include <arduino.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>

/* [Show] */
show_enclosure = true;
show_bumper = true;
show_standoffs = true;
show_lid = true;
show_insert = true;

show_boards = true;

board_is_transparent = false;

z_insert_column = 10; // [0:1:20]

EXPANDED = 0 + 0;
ASSEMBLED = 1 + 0;
FOR_PRINT = 2 + 0;
layout = 0; // [0:Expanded, 1:"Assembled", 2:"For printing"]




/* [Adjust] */

allowance_=0.2; // [0 : 0.05: 0.4]
x_ = -5; // [-5: 1: 99.9]
y_ = 0; // [0: 1: 99.9]
module end_customization() {}



mega2560Dimensions = boardDimensions( MEGA2560 );
x_board = mega2560Dimensions[0];




module placement(index) {
    dx_spacing = mega2560Dimensions[0] + 20;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}


if (show_enclosure) {
    placement(2) {
        dz_expansion = [-75, -8, 0][layout];
        translate([0, 0, dz_expansion]) {
            enclosure(MEGA2560); 
        }
        mock_board();
    }

}
        
    
if (show_bumper) {
     placement(3){
        dz_expansion = [-75, -2, 0][layout];
        translate([0, 0, dz_expansion]) {
            bumper(MEGA2560);
        }
        mock_board();
    }
}


if (show_insert) {
    index = layout == FOR_PRINT ? 5 : 3;
    placement(index) {
        dz_expansion = [-75, 0, 0][layout];
        translate([0, 0, dz_expansion]) {
                prototyping_insert();
        }
    }
}


if (show_standoffs) {
    placement(4) {
        dz_expansion = [-75, -10, 0][layout];
        translate([0, 0, dz_expansion]) {
            standoffs(MEGA2560, mountType=PIN);
            boardShape(MEGA2560, offset = 3);
        }
        mock_board();
    }
}

if (show_lid) {
    
    index = layout == FOR_PRINT ? 1 : 2;
    placement(index) {
        dz_expansion = [75, 22, 0][layout];
        translate([0, 0, dz_expansion]) {
            if (layout == FOR_PRINT) {
                mirror([0, 0, 1])  enclosureLid(MEGA2560);
            } else {
                color("red", alpha=0.10) enclosureLid(MEGA2560);
            }
        }
    }  
}


*enclosureLid(MEGA2560,wall=1);

// enclosureLid(MEGA2560,wall=1);
kludge_extension_box(10, wall=1);

// End of demonstration ------------------------

module kludge_extension_box(z, wall) {
    rim();
    lip_and_prongs();
    module lip_and_prongs() {
        module lid_clearance() {
                translate([-2, -2, -wall+0.05]) block([57, 98, 100], center=FRONT+RIGHT+ABOVE);
        }
        module prong_support(side) {
            //dx 
            hull() {
                translate([0, 0, -1]) block([3.2, 5, 0.1], center=RIGHT+side+ABOVE);
                translate([0, 2.5, 5]) block([1, 0.1, 0.1], center=side+ABOVE);
            }
        }
        render() difference() {
            enclosureLid(MEGA2560,wall=wall);
            lid_clearance(); 
        }
        translate([56, 75.5, 0]) prong_support(BEHIND);
        translate([56, 21, 0]) prong_support(BEHIND);
        translate([-3, 75.5, 0]) prong_support(FRONT);
        translate([-3, 21, 0]) prong_support(FRONT);
    }
    module rim() {
        translate([0, 0, -20]) {
            difference() {
                enclosure(
                    MEGA2560,  
                    wall=wall,
                    heightExtension=100);
                translate([0, 0, 20]) plane_clearance(BELOW);
                translate([0, 0, 20+z]) plane_clearance(ABOVE);
            }
        }
    }
    module clearance() {
        eps = 0.001;
        translate([0, 0, -5]) scale([1, 1, 10]) {
            difference() {
                hull() {
                    translate([0, 0, eps]) scale([0.99, 0.99, 0.99]) rim();
                }
                rim();
            }
        }
    }
}

module mock_board() {
    if (show_boards) {
        if (layout == EXPANDED || layout == ASSEMBLED) {
            if (board_is_transparent) {
                color("SteelBlue", alpha= 0.3) arduino(MEGA2560);
            } else {
                arduino(MEGA2560);
            }
        }
    }
}

module mini_breadboard(center=0) {
    if (layout != FOR_PRINT) {
        color("red") {
            
            //mini_breadboard(center=ABOVE);
            //color("Blue") mini_breadboard(center=BELOW);
            //color("Green") mini_breadboard(center=FRONT);
            //color("Yellow") mini_breadboard(center=BEHIND);
            //color("Orange") mini_breadboard(center=RIGHT);
            //color("Indigo") mini_breadboard(center=LEFT);    
            
            //size = [33.14, 45.97, 8.06];  // Measured!
            t_offset_y = -2.75; // [-3:0.05:-2]
            x_size = 47.0; // [47: 0.05 : 48]
            size = [35, x_size, 9.5]; // Modeled
            center_translation(size, center) {
                t_offset = [2.5, t_offset_y, -4.8];
                translate(t_offset) {
                    import("resource/Mini_Breadboard.stl", convexity=3);
                }
            }
        }
    }
}





module prototyping_insert() {
    dz_top_of_board = 2;
    d_column = 4;
    
    disp_inner_hole_1 = concat(boardHoles[MEGA2560][1], [0]); 
    disp_inner_hole_2 = concat(boardHoles[MEGA2560][2], [0]);
    
    module icsp_pin_access() {
        dx = disp_inner_hole_1.x - d_column/2;
        dy = disp_inner_hole_1.y + d_column/2;;
        translate([dx, dy, 0]) {
            can(d=15, h=10);
        }
    }
   


    translate(disp_inner_hole_1) {
        can(d=2, h=6, center=ABOVE);
        translate([0, 0, dz_top_of_board]) 
            can(d=d_column, h=z_insert_column, center=ABOVE);
    }
    translate(disp_inner_hole_2) {
        can(d=2, h=6, center=ABOVE);
        translate([0, 0, dz_top_of_board]) 
            can(d=d_column, h=z_insert_column, center=ABOVE);
    } 
    
    platform = [
        disp_inner_hole_2.x - disp_inner_hole_1.x + d_column,
        disp_inner_hole_1.y + + d_column/2,
        1
    ];
    dx = disp_inner_hole_1.x - d_column/2;
    dz = dz_top_of_board + z_insert_column; 
    translate([dx, 0, dz]) {
        difference() {
            block(platform, center=BELOW+FRONT+RIGHT);
            icsp_pin_access();
        } 
    }
    *translate([dx, 0, dz]) {
        translate([-3, 15, 0]) mini_breadboard(center=FRONT+RIGHT+ABOVE);
    }
    
    front_platform = [platform.x, 10, 1];
    translate([dx, 0, dz]) block(front_platform, center=BELOW+FRONT+LEFT);
    
    
}



module servo_pin_retainer(assembly, count=1, allowance=0.4, wall_thickness=undef) {
    if (assembly=="clip") {
        clipping_retainer();
    } else if (assembly=="slide") {
        sliding_retainer();
    } else {
        assert(false);
    }
    wall_thickness_ = 
        !is_undef(wall_thickness) ?  wall_thickness :
        (assembly=="clip") ? 0.5 :
        (assembly=="slide") ? 1 :
        assert(false);

    adjustment = [2*allowance, 2*allowance, 2*allowance];
    walls = [2*wall_thickness_, 2*wall_thickness_, 2*wall_thickness_];
    pin_spacing = 2.54;
    pin_length = servo_socket_dimensions[MALE_BODY].y + servo_socket_dimensions[MALE_BACK].y;
    pins = [3*pin_spacing, 2*pin_length, pin_spacing];
    wire_clearance = [6.3, 40, 1.37];   
    blank = pins+walls+adjustment;
    module sliding_retainer() {
        dx = 
            blank.z // Because of rotation to being on edge!
            -wall_thickness_;  // To make interior walls the same thickness as exterior;
        replicate(dx) { 
            single_retainer();
        }

        module single_retainer() {
            rotate([0, -90, 0]) {
                difference() {
                    block(blank);
                    clearance();
                }
            }
        }
        
        module clearance() {
            block(pins+adjustment);
            block(wire_clearance+adjustment);
            translate([wire_clearance.x/2, 0, 0]) plane_clearance(FRONT);
        }        
    }

    module clipping_retainer() {
        dx = blank.x - wall_thickness_;
        replicate(dx) {
            single_retainer();
        }
        
        module single_retainer() {
            difference() {
                block(blank);
                clearance();
            }
        }
        module clearance() {
            wire_clip_clearance = [5, 30, 10];
            assembly_clearance = [30, 10, 30];
            dy_clip = 2;
            clip_overlap=[0.1, 0.1, 0.1];            
            
            block(pins+adjustment);
            center_reflect([0, 1, 0]) translate([0, dy_clip, 1]) {
                block(assembly_clearance, center=ABOVE+RIGHT);
            }
            block(wire_clearance);
            block(wire_clip_clearance, center=ABOVE);
            translate([0, 0, pin_spacing/2]) block(pins-clip_overlap, center=ABOVE);            
        }
    }
    
    module replicate(dx) {
        offset = count/2-0.5;
        for (i = [0: count-1]) {
            translate([(i-offset)*dx, 0, 0]) children(); 
        }
    }
}




module servo_socket_holders() {
    holder_dimensions = servo_female_socket_holder_dimensions(allowance=allowance_);
    dx = holder_dimensions[SFSH_HOLDER].x;
    rotate([0, 0, 180]) {
        for (i = [0:3]) {
            translate([(i-2)*dx, 0, 0]) 
                servo_female_socket_holder(allowance=allowance_, center=ABOVE+FRONT+LEFT);    
        }
    }
}


* color("green") servo_female_socket_holder(allowance_, center=RIGHT);
* color("blue") servo_female_socket_holder(allowance_, center=LEFT);
* color("yellow") servo_female_socket_holder(allowance_, center=FRONT);
* color("orange") servo_female_socket_holder(allowance_, center=BEHIND);
* color("indigo") servo_female_socket_holder(allowance_, center=ABOVE);
* color("lime") servo_female_socket_holder(allowance_, center=BELOW);

SFSH_HOLDER = 0;
SFSH_FACE = 1;
SFSH_OPENING = 2;
SFSH_SIGNAL_WIRE_MARKER_DIAMETER_ = 3;
SFSH_SIGNAL_WIRE_MARKER_TRANSLATION = 4;
SFSH_CLIP_DIAMETER = 5;
SFSH_CLIP_LENGTH = 6;
SFSH_CLIP_TRANSLATION = 7;

function servo_female_socket_holder_dimensions(wt=1, allowance=0.2) = 
    let(
        wall = [2*wt, 2*wt, 2*wt],
        adjustment = [2*allowance, 2*allowance, 2*allowance],
        body = servo_socket_dimensions[FEMALE_BODY],
        holder = body + wall + adjustment,
        face = [holder.x, 3*wt, holder.z],
        opening = servo_socket_dimensions[MALE_BACK],
        d_signal_wire_marker = 1.4,
        t_signal_wire_marker = [
            -(opening.x/2 + allowance),
            holder.y/2, 
            -opening.z/2 + allowance
        ],
        d_clip = 2,
        l_clip = wt,
        t_clip = [
            opening.x/2 + allowance + d_clip/4,
            -holder.y/2, 
            opening.z/2 + allowance
        ],
        last = undef
    )
    [
        holder,
        face,
        opening,
        d_signal_wire_marker,
        t_signal_wire_marker, 
        d_clip,
        l_clip,
        t_clip,
    ];
    






