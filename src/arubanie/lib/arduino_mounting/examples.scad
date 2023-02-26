include <arduino.scad>

//Arduino boards
//You can create a boxed out version of a variety of boards by calling the arduino() module
//The default board for all functions is the Uno

/* [Boiler Plate] */
eps = 0.001;

/* [Options] */
board_selection = 3; // [0:Uno, 1:Due, 2:Leonardo, 3: Mega 2560]
show_bumper = true;
show_enclosure = true;
show_shandoffs = true;
show_new_dev = true;


/* [New Dev Control] */
show_arduino = true;
include_punch_outs = true;
include_standoffs = true;
include_clip_holes = true;
include_floor = true;
height = 5; //[0:0.5:20]
vent_percent = 99.999; // [0: 0.5: 100]
vent_hole_size = 10; // [0: 0.5: 99.9]
alpha = 1; //[0.25, 0.5, 1]

module end_of_customization() {}

board = [UNO, DUE, LEONARDO, MEGA2560][board_selection]; 

module place(index) {
    dx_spacing = boardDimensions(board)[0] + 50;
    translate([index*dx_spacing, 0, 0]) children();
}

if (show_new_dev) {
    place(0) {
        if (show_arduino) {
            arduino(board);
        }
        * color("blue", alpha=alpha) {
            translate([0, 0, 0]) {
                enclosure(
                    board, 
                    height=height+eps,
                    includePunchOuts=include_punch_outs,
                    includeStandoffs=include_standoffs,
                    includeClipHoles=include_clip_holes,
                    includeFloor=include_floor);
            }
        }
        translate([0, 0, height+eps]) {  
            //color("green")  
            enclosureLid(
                board, 
                clipHeight=10, 
                ventHoles=true, 
                ventOpening=vent_percent/100,
                ventHoleSize=vent_hole_size);
            //color("pink")  enclosureLid(board, clipHeight=12.5);
            //color("red")  enclosureLid(board, clipHeight=15);
            //color("purple")  enclosureLid(board, clipHeight=17.5);
        } 
        * color("orange", alpha=1) {
            h = 15;
            translate([0, 0, -(h+0.1)]) {
                render() enclosure(
                    board, 
                    height=h,
                    includePunchOuts=false,
                    includeStandoffs=false,
                    includeClipHoles=true,
                    includeFloor=false);
            }
        }

    }
}


if (show_enclosure) {
    place(1) {
        arduino(board);
        translate([0, 0, -75]) {
            enclosure(board);
        }
        translate([0, 0, 75]) {
            enclosureLid(board);
        } 
    }
}

if (show_bumper) {
    place(2) {
        arduino(board);
        translate([0, 0, -75]) {
                bumper(board);    
        }
    }
}

if (show_shandoffs) {
    place(3) {
        arduino(board);
        translate([0, 0, -75]) {
            standoffs(board, mountType=PIN);
            boardShape(board, offset = 3);
        }
    }
}


