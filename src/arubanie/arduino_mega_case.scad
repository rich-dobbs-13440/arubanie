include <arduino.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>

/* [Show] */
show_enclosure = true;
show_bumper = true;
show_standoffs = true;
show_lid = true;
show_insert = true;


EXPANDED = 0 + 0;
ASSEMBLED = 1 + 0;
FOR_PRINT = 2 + 0;
layout = 0; // [0:Expanded, 1:"Assembled", 2:"For printing"]

module end_customization() {}

mega2560Dimensions = boardDimensions( MEGA2560 );
x_board = mega2560Dimensions[0];


module placement(index) {
    dx_spacing = mega2560Dimensions[0] + 20;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

module mock_board() {
    if (layout == EXPANDED || layout == ASSEMBLED) {
        arduino(MEGA2560);
    }
}

if (show_insert) {
    boardShape(MEGA2560, offset = 3);
    disp_inner_hole_1 = concat(boardHoles[MEGA2560][1], [0]); 
    disp_inner_hole_2 = concat(boardHoles[MEGA2560][2], [0]); 
    
    translate(disp_inner_hole_1) can(d=1, h=10, center=ABOVE);
    translate(disp_inner_hole_2) can(d=1, h=10, center=ABOVE);
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
                color("red", alpha=0.25) enclosureLid(MEGA2560);
            }
        }
    }  
}


