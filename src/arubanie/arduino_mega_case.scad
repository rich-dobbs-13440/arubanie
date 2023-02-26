include <arduino.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/servo_extension_wires.scad>

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
x_ = 27; // [-99.9: 1: 99.9]
//y_ = 0; // [-99.9: 1: 99.9]

//x_ = 27; // [-99,9: 1: 99.9]


y_ = -10; // [-15: 0.5: -5]

z_ = 5; // [-10 : 0.05: 5]

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
                mirror([0, 0, 1])  perforated_lid();
            } else {
                color("red", alpha=0.10) enclosureLid(MEGA2560);
            }
        }
    }  
}

module perforated_lid() {
    difference() {
        dx = 12;
        dy = 12;
        d = 11;
        enclosureLid(MEGA2560, wall=1);
        for (i = [1:4]) {
            for (j = [1:8]) {
                translate([(i-0.3)*dx, (j-.4)*dy, 0]) can(d=d, h=10);
            }
        }
    }  
}


//* enclosureLid(MEGA2560,wall=1);
//translate([10, 10, 10]) mirror([0, 0, 1])  clip(clipHeight = 10);
//
//// enclosureLid(MEGA2560,wall=1);
//kludge_extension_box(10, wall=1);
wall = 1;
* color("blue") clip(clipHeight = 10);

*color("green") clipHole(clipHeight = 10, holeDepth = wall + 0.2);

*servo_socket_holders(wall=1);

servo_socket_extension_box();

module servo_socket_extension_box(wall_thickness = 1) {
    
    placed_socket_holders();
    extension_box(wall=1, height=4) {
        hull() placed_socket_holders(); 
    }
    spool();
    placed_pin_retainer();

    module placed_socket_holders() {
        dy = -10.5;
        translate([27, dy, 0]) {
            servo_socket_holders(wall_thickness=wall_thickness);
        }
        translate([27, dy+19, 0]) block([60, 2, 1], center=ABOVE);
    }
    
    module spool() {
        dy = 28;
        d_spool = 12;
        translate([16, dy, 0]) {
            can(d=d_spool, hollow=d_spool-2, h=6, center=ABOVE);
            translate([0, 0, 6]) can(d=d_spool+4, hollow=d_spool-2, h=1, center=ABOVE);
        }
        translate([27, dy-d_spool/2+1, 0]) block([60, 2, 1], center=ABOVE);
        translate([27, dy+d_spool/2-1, 0]) block([60, 2, 1], center=ABOVE);
    }
     module placed_pin_retainer() { 
        dy = 55;
        translate([33, dy, 0]) { 
            rotate([0, 0, 45]) {
                translate([0, 0, 5.2]) servo_pin_retainer(assembly="slide", count=4);
                translate([0, -14, 0]) block([38, 2, 1], center=ABOVE);
            }
        }
        translate([27, dy - 22, 0]) block([60, 2, 1], center=ABOVE);
        translate([27, dy + 4, 0]) block([60, 2, 1], center=ABOVE);
        translate([27, dy + 14, 0]) block([60, 2, 1], center=ABOVE);
    }    
    

}
// End of demonstration ------------------------



module extension_box(height, wall) {
    //pcbDim = pcbDimensions(boardType);
	//enclosureWidth = pcbDim[0] + (wall + offset) * 2;
    difference() {
        union() {
            boundingBox(MEGA2560, offset = 3+wall, height = height, cornerRadius = wall, include = BOARD);
        }
        translate([0, 0, -height]) {
            boundingBox(MEGA2560, height = 4*height, offset = 3, include=BOARD, cornerRadius = wall);
        }
        *rotate([0, 0, -90]) clipHole(clipHeight = 3, holeDepth = wall + 0.2);
        children();
    }
    
}



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





