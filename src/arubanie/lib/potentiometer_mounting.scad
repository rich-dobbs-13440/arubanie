/*

use <potentiometer_mounting.scad>

*/

//**************************************************************************************************
//      10        20        30        40        50        60        70        80        90       100

include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <prong_and_spring.scad>
use <dupont_connectors.scad>

/* [Logging] */

    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice);    
 

/* [Customization] */
    show_housing = true;
    show_default = false;
    allowance_ = 0.3; // [0:0.05:2]
    clip_overlap_ = 1; // [0:0.05:1]
    clip_thickness_ = 1.; // [0:0.25:4]
    count_ = 1; // [1: 10]
    spacing_ = 2; // [-3 : 1 : 20]
    show_mocks_= false;
    build_from_ = 0; //[0:Designed, 1:From face, 2:Side, 3:End]
    retain_pins_ = true;
    arrow_up_ = true;
    spring_width_ = 4.;
    socket_wall = 2; // [0: 0.25 : 10] 
    
    if (show_housing) {
        breadboard_compatible_trim_potentiometer_housing(
            count = count_, 
            spacing = spacing_, 
            allowance = allowance_,
            clip_overlap = clip_overlap_,
            clip_thickness = clip_thickness_,
            spring_width = spring_width_,
            build_from = build_from_,
            arrow_up = arrow_up_,
            show_mocks = show_mocks_,
            retain_pins = retain_pins_,
            log_verbosity=verbosity);
    }

    if (show_default) {
        breadboard_compatible_trim_potentiometer_housing();
    }

module end_of_customization() {}

// Rotations:  Move to centrable???
Z_TO_MINUS_Z = [180, 0, 0];
Z_TO_MINUS_Y = [90, 0, 0];
Z_TO_X = [0, 90, 0];
X_TO_Y = [0, 0, 90];

// Potentiometer Constants
PEDISTAL_IDX = 0;
KNOB_IDX = 1;
 
D_BASE = 0;
H_BASE = 1;
D_TAPER= 2;
D_INDICATER = 3;
H_INDICATER = 4;
 
 function breadboard_compatible_trim_potentiometer_dimensions() =
    let (
        pedistal = [9.6, 9.6, 5.0],
        knob = [7.89, 3.81, 7.48, 6.47, 1.39],
        last = undef
    )
    [ pedistal, knob ];
 
 module breadboard_compatible_trim_potentiometer(alpha=1) {
    // Center of origin at the centerline of the knob where the knob meets the base.  
    // The default orientation is for the knob to rotate along the z-axis.
    dims = breadboard_compatible_trim_potentiometer_dimensions();
    color("SteelBlue", alpha=alpha) {
        pedistal();
        knob();
    }
     
    module pedistal() {
         block(dims[PEDISTAL_IDX], center=BELOW); 
    }
    
    module arrow() {
        linear_extrude(4) {    
            text("\u2191", font="DevaVu Sans Mono", halign="center", valign="center", size = 5);
        }
    }
    module knob() {
        dim = dims[KNOB_IDX];
        can(d=dim[D_BASE], h=dim[H_BASE], taper=dim[D_TAPER], center=ABOVE);
        translate([0, 0, dim[H_BASE]]) {
            render() difference() {
                can(d=dim[D_INDICATER], h=dim[H_INDICATER], center=ABOVE);
                arrow();
            }
        }
    }
}


// Housing Constants
HOUSING_COMPONENT_NAME = "breadboard_compatible_trim_potentiometer_housing_dimensions";
COMPONENT_IDX = 0;
BODY_IDX = 1;
FACE_PLATE_IDX = 2;
BACK_PLATE_IDX = 3;
HOUSING_IDX = 4;
D_KNOB_CLEARANCE_IDX = 5;
X_OFFSET_IDX = 6;
DX_IDX = 7;
SOCKET_RETENTION_IDX = 8;
MINIMUM_SOCKET_OPENING_IDX = 9;
PIN_ALLOWANCE_IDX = 10;
PRONG_IDX = 11;
PIN_WIDTH_IDX = 12;
PIN_LENGTH_IDX = 13;



 
function  breadboard_compatible_trim_potentiometer_housing_dimensions(
        wall = 2, 
        face = 0.5, 
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3, 
        clip_overlap = 1.0, 
        clip_thickness = 1.0) =
    let(
        socket_y = 17,  // Need to get from the dupont connectors
        socket_x = 17,  // Need to get from the dupont connectors
        
        dx = socket_x + spacing,
        knob_dims = breadboard_compatible_trim_potentiometer_dimensions(),
        pedistal = knob_dims[PEDISTAL_IDX],
        allowances = [2*allowance, 2*allowance, 2*allowance],
        walls = [2*wall, 2*wall, 0],
        housing = pedistal+allowances+walls,
        x = socket_x * count + spacing * (count-1) + wall,
        y = socket_y, 
        z = pedistal.z + allowance,
        
        back_plate = [x, y, back],
        body = [x, y, z],
        x_offset = -x/2 + socket_x/2 + 1, // What's with the magic 1??? may wall thickness
        
        face_plate = [body.x, body.y, face],
        pin_length = 14,
        pin_length_allowance = 0.2,
        pin_width = 2.54,
        clip_thickness = pin_width,
        knob_allowance = 0.50,
        d_knob_clearance = knob_dims[KNOB_IDX][D_BASE] + 2*knob_allowance,
        pin_insert_thickness = 2, // Allow for a pin retention insert into plug
        socket_retention = 4,
        minimum_socket_opening = [0, 10, 10], // pedistal + allowances
        pin_allowance = [0.5+pin_insert_thickness, 0.5, 0.5],
        spring_length = 13,
        spring_thickness = wall,
        spring_width = 4,
        catch_offset = 7,
        catch_length = 2,
        catch_thickness = 1,
        catch_width = spring_width,
        catch_allowance = 0.4, 
        prong = prong_dimensions(
                    spring = [spring_length, spring_thickness, spring_width],
                    catch = [catch_length, catch_thickness, catch_width], 
                    catch_offset = catch_offset,
                    catch_allowance = catch_allowance),
                
         
        last = undef
    ) 
    [
        HOUSING_COMPONENT_NAME,
        body, // Should be expanded to include the sockets!
        face_plate, 
        back_plate, 
        housing,
        d_knob_clearance,
        x_offset, 
        dx,  
        socket_retention,
        minimum_socket_opening,
        pin_allowance,
        prong,
        pin_width, 
        pin_length, 
    ];
    
// Build orientation Constants
BUILD_UP_TO_FACE = 0; // As designed, with no rotation 
BUILD_FROM_FACE = 1;    
BUILD_FROM_SIDE = 2;
BUILD_FROM_END = 3; 
 
 module breadboard_compatible_trim_potentiometer_housing(
        wall = 2, 
        face = 0.5,
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3, 
        clip_overlap = 0.5,
        clip_thickness = 1.0,
        spring_width = 3, 
        center = 0, 
        build_from = 0,
        retain_pins = false,
        arrow_up = true,
        show_mocks = false,
        log_verbosity) {
            
          
            
    dims = breadboard_compatible_trim_potentiometer_housing_dimensions(
                wall, face, back, count, spacing, allowance, clip_overlap);
    log_v1("Dimensions:", dims, log_verbosity, DEBUG);
            
    body = dims[BODY_IDX];
    log_v1("body:", body, log_verbosity, DEBUG);            
            
    face_plate = dims[FACE_PLATE_IDX];
    log_v1("face_plate:", face_plate, log_verbosity, DEBUG);
            
    back_plate = dims[BACK_PLATE_IDX];
    log_v1("back_plate:", back_plate, log_verbosity, DEBUG);
            
    housing = dims[HOUSING_IDX]; 
    log_v1("housing:", housing, log_verbosity, DEBUG);
            
    d_knob_clearance = dims[D_KNOB_CLEARANCE_IDX];
    log_s("d_knob_clearance:", d_knob_clearance, log_verbosity, DEBUG);            

    dx = dims[DX_IDX];
    log_s("dx:", dx, log_verbosity, DEBUG);
    
    x_offset = dims[X_OFFSET_IDX]; 
    log_s("x_offset:", x_offset, log_verbosity, DEBUG);   
        
    pin_width = dims[PIN_WIDTH_IDX];
    log_s("pin_width:", pin_width, log_verbosity, DEBUG);  
    
    pin_length = dims[PIN_LENGTH_IDX];
    log_s("pin_length:", pin_length, log_verbosity, DEBUG);

    socket_retention = dims[SOCKET_RETENTION_IDX];
    log_s("socket_retention:", socket_retention, log_verbosity, DEBUG);
    
    minimum_socket_opening = dims[MINIMUM_SOCKET_OPENING_IDX];
    log_v1("minimum_socket_opening:", minimum_socket_opening, log_verbosity, DEBUG);
    
    pin_allowance = dims[PIN_ALLOWANCE_IDX];
    log_v1("pin_allowance:", pin_allowance, log_verbosity, DEBUG);
    
    prong = dims[PRONG_IDX];
    log_v1("prong:", prong, log_verbosity, DEBUG); 
 
    knob_dims =  breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = knob_dims[PEDISTAL_IDX];             
    
    orient() assembly();
    
    module assembly() {
        
        replicate() {
            if (show_mocks) {
                orient_mocks(arrow_up) {
                    breadboard_compatible_trim_potentiometer();
                    dupont_pins();
                }
            } 

            housing_lower_xz_wall();
            housing_yz_walls();
            pin_socket();
        } 
    
        render() difference() {
            block(face_plate, center=ABOVE);
            replicate() knob_clearance();
        }    
                
        render() difference() {
            block(back_plate, center=BELOW);
            replicate() pedistal_clearance();
        }
        three_d_printing_aids();
    }
    
    module pin_socket() {
        translate([0, 0, -housing.z]) {
            rotate([0, 90, 0]) {
                pin_junction(
                    3, 
                    3, 
                    part="Socket",
                    socket_retention = socket_retention,
                    wall = wall,
                    socket_wall = wall, 
                    prong_dimensions = prong,
                    minimum_socket_opening = minimum_socket_opening,
                    orient_for_build=false);  // Obsolete, must handle separately for now.
            }
        }
    }    
    
    module three_d_printing_aids() {
        if (build_from == BUILD_FROM_END) {
            build_from_end_printing_aids();
        }
    }
    
    module build_from_end_printing_aids() {
        bridging_pillar = [body.x, 2*allowance, 2*allowance];
        // Bridging supports for top of housing and retention clips
        top_wall_pillar = [body.x, wall, wall];
        center_reflect([0, 1, 0]) {
            translate([0, body.y/2, -housing.z]) block(top_wall_pillar, center=LEFT+ABOVE);
            translate([0, body.y/2, -15]) block(top_wall_pillar, center=LEFT+ABOVE);
        }     
    }

    module dupont_pins() {
        color("black") {
            translate([pin_width, 0, -pedistal.z]) 
                block([pin_width, pin_width, pin_length], center=BELOW);
        }
        color("red") {
            translate([-pin_width, 0, -pedistal.z]) 
                block([pin_width, pin_width, pin_length], center=BELOW);
        }  
        color("yellow") {
            angle = arrow_up ? 5 : 0;
            translate([0, -pin_width/2, -pedistal.z]) 
                rotate([angle, 0, 0]) 
                    block([pin_width, pin_width, pin_length], center=BELOW);
        }            
    }  

    module housing_lower_xz_wall(narrow = false) {
        xz_wall = narrow ? [housing.x, wall, wall] : [housing.x, wall, housing.z];
        translate([0, -housing.y/2, -housing.z]) block(xz_wall, center=ABOVE+RIGHT); 
    }
    
    module housing_yz_walls() {
        center_reflect([1, 0, 0]) {
            yz_wall  = [wall, housing.y, housing.z];
            translate([housing.x/2, housing.y/2, -housing.z]) 
                block(yz_wall, center=ABOVE+LEFT+BEHIND);
        }
    }

    module knob_clearance() {
        can(d=d_knob_clearance, h=20);
    }
     
    module pedistal_clearance() {
        allowances = [2*allowance, 2*allowance, 20];
        translate([0, 0, -pedistal.z/2]) block(pedistal + allowances);
    }
    
    module orient() {
        assert(build_from <=4);
        rotation = [[0, 0, 0], Z_TO_MINUS_Z, Z_TO_MINUS_Y, Z_TO_X][build_from];
        rotate(rotation) { 
            children();
        }
    } 
 
    module orient_mocks(arrow_up) {
        rotation = arrow_up ? [0, 0, 0] : [0, 0, 90];
        rotate(rotation) { 
            children();
        }
    }
    
    module replicate() {
        for (i = [0 : count-1] ) {
            translate([i * dx + x_offset, 0, 0]) {
                children();
            }
        }           
    }  
    
 }