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

module end_customization() {}

FEMALE_BODY = 0;
FEMALE_BACK = 1;
MALE_BODY = 2;
MALE_BACK = 3;

servo_socket_dimensions = [
    [10.71, 18.00, 3.74], // female body
    [7.87, 4.88, 2.65], //female back
    [7.69, 9.41, 2.44], // male body
    [7.92, 4.86, 2.70], // male back
];

mega2560Dimensions = boardDimensions( MEGA2560 );
x_board = mega2560Dimensions[0];





servo_socket_holders();

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
    


module servo_female_socket_holder(wt=1, allowance=0.2, center=0) {
    dimensions = servo_female_socket_holder_dimensions(wt, allowance);
    holder = dimensions[SFSH_HOLDER];
    face = dimensions[SFSH_FACE];
    opening = dimensions[SFSH_OPENING];
    d_signal_wire_marker = dimensions[SFSH_SIGNAL_WIRE_MARKER_DIAMETER_];
    t_signal_wire_marker = dimensions[SFSH_SIGNAL_WIRE_MARKER_TRANSLATION];
    d_clip = dimensions[SFSH_CLIP_DIAMETER];
    l_clip = dimensions[SFSH_CLIP_LENGTH];
    t_clip = dimensions[SFSH_CLIP_TRANSLATION];
    
    lower_holder_body = [holder.x, holder.y, holder.z/2];
    upper_holder_body = [holder.x, holder.y, opening.z/2];
    extent = holder;
    center_translation(extent, center) {
        render() difference() {
            union() {
                block(lower_holder_body, center=BELOW);
                block(upper_holder_body,  center=ABOVE);
                translate([0, holder.y/2, 0]) block(face, center=LEFT);
                center_reflect([1, 0, 0]) {
                    translate(t_clip) rod(d=d_clip, l=l_clip, center=SIDEWISE+RIGHT);
                }
            }
            servo_male_plug(allowance=allowance);
            servo_female_socket(allowance=allowance);
            translate(t_signal_wire_marker) {
                rod(d=d_signal_wire_marker, l=2*wt, center=SIDEWISE+ABOVE);
            }
            can(d=0.8*holder.x, h=10);  // Just remove some unnecessary material
        }
    }
}

module servo_male_plug(center, allowance=0) {
    color("red", alpha=0.2) {
        adjustment = [2*allowance, 2*allowance, 2*allowance];
        echo("adjustment", adjustment);
        body = servo_socket_dimensions[MALE_BODY];
        dy_calc = -body.y/2 + servo_socket_dimensions[0].y/2; // servo_socket_dimensions[0].y/2;
        translate([0, dy_calc, 0]) { // Align male plug with the socke 
            block(body+adjustment);
            back = servo_socket_dimensions[MALE_BACK];
            echo(back+adjustment);
            translate([0, body.y/2, 0]) block(back+adjustment, center=RIGHT);
        }
    }
}

module servo_female_socket(center, allowance=0) {
    color("black", alpha=0.2) {
        adjustment = [2*allowance, 2*allowance, 2*allowance];
        body = servo_socket_dimensions[FEMALE_BODY];
        block(body + adjustment);
        back = servo_socket_dimensions[FEMALE_BACK];
        translate([0, -body.y/2, 0]) block(back + adjustment, center=LEFT);
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


