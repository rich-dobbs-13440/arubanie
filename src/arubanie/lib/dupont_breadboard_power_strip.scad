/*  

Provide a holder for a power strip section, with a socket and plug
to securely  connect dupont pins and headers.


*/ 
include <centerable.scad>
use <breadboard.scad>
use <shapes.scad>
use <dupont_connectors.scad>

dy = -2; //[-5: 0.05: 5]
pw = dupont_pin_width();
pl = dupont_pin_length();

board_height = 10;

basic_lower();
translate([0, -4.5*pw, 0]) header_1x8();

module lower() {
    render() difference() {
        basic_lower();
        
    }
    
}


module basic_lower() {
    
    allowance = 0.2;
    ss_allowances = [allowance, allowance, 0];
    wall = 1;
    ss_walls = [wall, wall, 0];
    header_1x8 = [1*pw, 8*pw, pl];
    header_2x8 = [2*pw, 8*pw, board_height];
    left_body_behind = header_2x8 + ss_allowances + ss_walls;
    ty = 4.5 * pw;
    // Make it centered on y axis
    translate([0, -ty, 0]) {
        render() difference() {
            block(header_1x8 + ss_allowances + ss_walls, center=BELOW+FRONT+RIGHT);
            header_1x8();
        }
        
        render() difference() {
            block(left_body_behind, center=BELOW+BEHIND+RIGHT);
            block(header_2x8, center=BELOW+BEHIND+RIGHT);
        } 
        power_strip(pins=8);
        block([header_2x8.x, 0, board_height] + ss_allowances + ss_walls, center=BELOW+BEHIND+LEFT);
        block([header_1x8.x, 0, pl] + ss_allowances + ss_walls, center=BELOW+FRONT+LEFT);
    }
}

//power_strip(pins=8);

module header_1x8() {
    header = [1*pw, 8*pw, pl];
    color("black") {
        block(header, center=BELOW+FRONT+RIGHT);
    }
}

module power_strip(pins) {
    render() difference() {
        raw_power_strip();
        plane_clearance(LEFT);
        translate([0, pins*pw, 0]) plane_clearance(RIGHT);
    } 
}


module raw_power_strip() {
    dy = -3.54 - pw;
    translate([0, dy, -board_height]) { 
        render() difference() {
            breadboard(
                rows = 16,
                columns = 1,
                pinSpacing = dupont_pin_width(),
                pinDiameter = 1.0,
                pinsPerGroup = 5,
                pinGroupSpacing = 3,
                pinBevelEnabled = true,
                pinBevelAmount = 0.3,
                pinBevelSteepness = 1,
                powerLeftEnabled = true,
                powerRightEnabled = true,
                pinsPerPowerGroup = 12,
                pinPowerGroupSpacing = 2,
                powerGroupPinOffsetTop = 2,
                powerGroupPinOffsetBottom = 2,
                horizontalBorderWidth = 0.5, // Maybe adjust this to get other pins to line up exactly???
                verticalBorderWidth = 0,
                boardHeight = board_height,  //Measured : 8.44
                wiringSectionEnabled = true,
                wiringSectionTollerance = 0,
                wallThickness = 1.2,
                faceThickness = 1.0
            );
            plane_clearance(FRONT);
        }
    }
}