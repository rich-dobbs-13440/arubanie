/*

use <potentiometer_mounting.scad>

*/

//**************************************************************************************************
//      10        20        30        40        50        60        70        80        90       100

include <logging.scad>
use <not_included_batteries.scad>
include <centerable.scad>
use <shapes.scad>
use <prong_and_spring.scad>
use <dupont_pin_junction.scad>
use <dupont_pins.scad>

use <dupont_pin_fitting.scad>

/* [Logging] */

    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice);    
 

/* [Customization] */
    show_customized = true;
    show_mocks_ = true;
    show_housing_ = true;
    show_plugs_ = true;    
    show_default = false;
    allowance_ = 0.3; // [0:0.05:2]
    count_ = 1; // [1: 10]
    spacing_ = 2; // [-3 : 1 : 20]

    build_from_ = 0; //[0:To face, 1:From face, 2:Side, 3:End, 4:"Side, for plugs"]
    //retain_pins_ = true;
    arrow_up_ = true;
    
    
    housing_alpha_ = 1; // [0, 0.10, 0.25, 1]
    plug_alpha_ = 1; // [0, 0.10, 0.25, 1]
    
    if (show_customized) {
        breadboard_compatible_trim_potentiometer_housing(
            count = count_, 
            spacing = spacing_, 
            allowance = allowance_,
            build_from = build_from_,
            arrow_up = arrow_up_,
            show_housing = show_housing_,
            show_plugs = show_plugs_,
            show_mocks = show_mocks_,
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
Z_TO_Y = [90, 0, 0];
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

 
function  breadboard_compatible_trim_potentiometer_housing_dimensions(
        wall = 2, 
        face = 0.5, 
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3,
        pin_fitting_attachment = true) =

    let(
        pin_length = 14,
        pin_width = 2.54,

                    
        pin_insert_thickness = 2, // Allow for a pin retention insert into plug
        pin_allowance = [0.5, 0.5, 0.5],            
        socket_retention = 4,
        minimum_socket_opening = [0, 10, 10],
        socket_dims = pin_junction_dimensions(
            high_count=3, 
            wide_count=3, 
            wall=wall, 
            pin_allowance=pin_allowance,
            pin_insert_thickness = pin_insert_thickness,
            part="Socket", 
            socket_wall=wall,
            socket_retention=socket_retention,
            minimum_socket_opening=minimum_socket_opening        
        ),
        
 

    
        knob_dims = breadboard_compatible_trim_potentiometer_dimensions(),
        pedistal = knob_dims[PEDISTAL_IDX],
        knob_allowance = 0.50,
        d_knob_clearance = knob_dims[KNOB_IDX][D_BASE] + 2*knob_allowance, 
        
        allowances = [2*allowance, 2*allowance, 2*allowance],
        walls = [2*wall, 2*wall, 0],
        housing = pedistal+allowances+walls,
        socket_body = pin_junction_dimension(socket_dims, "socket_body"),
        x_socket = socket_body.z,   // Rotation to get coordinate systems to match up.
        y_socket = socket_body.y,
        z_socket = socket_body.x,     
        
        x_base = pin_fitting_attachment ? 7 * pin_width : x_socket,
        y_base = pin_fitting_attachment ? 7 * pin_width : y_socket,
        z_base = pin_fitting_attachment ? pin_width/2 : z_socket,
        
        x = x_base * count + spacing * (count-1),
        y = y_base, 
        z = pedistal.z + allowance + z_base, 
        body = [x, y, z],
        face_plate = [body.x, body.y, face],
        back_plate = [body.x, body.y, back],
        
        dx = x_base + spacing,
        x_offset = -x/2 + x_base/2, 
        HOUSING_COMPONENT_NAME = "breadboard_compatible_trim_potentiometer_housing_dimensions", 
        last = undef
    )
   assert(is_num(dx)) 
    [
        ["component", HOUSING_COMPONENT_NAME],
        ["body", body],
        ["face_plate", face_plate],
        ["back_plate", back_plate],
        ["housing", housing], 
        ["d_knob_clearance", d_knob_clearance], 
        ["x_offset", x_offset], 
        ["dx", dx],
        ["socket_retention", socket_retention],
        ["minimum_socket_opening", minimum_socket_opening],
        ["pin_allowance", pin_allowance],
        //["prong", prong],
        ["pin_width", pin_width], 
        ["pin_length", pin_length], 
    ];
    
// Build orientation Constants
BUILD_UP_TO_FACE = 0; // As designed, with no rotation 
BUILD_FROM_FACE = 1;    
BUILD_FROM_SIDE = 2;
BUILD_FROM_END = 3;
BUILD_FROM_SIDE_FOR_PLUGS = 4;
 
 module breadboard_compatible_trim_potentiometer_housing(
        wall = 2, 
        face = 0.5,
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3, 
        center = 0, 
        build_from = 0,
        show_housing = true,
        show_plugs = true,
        show_mocks = true,
        arrow_up = true,        
        log_verbosity) {
            
        
    dims = breadboard_compatible_trim_potentiometer_housing_dimensions(
                wall, face, back, count, spacing, allowance);

    function get_by_name(name) = find_in_dct(dims, name);       
           
    body = get_by_name("body");               
    face_plate = get_by_name("face_plate");      
    back_plate = get_by_name("back_plate");    
    housing = get_by_name("housing");    
    d_knob_clearance = get_by_name("d_knob_clearance");            
    dx = get_by_name("dx");  
    x_offset = get_by_name("x_offset");    
    pin_width = get_by_name("pin_width"); 
    pin_length =  get_by_name("pin_length");
    pin_insert_thickness = get_by_name("pin_insert_thickness");
    socket_retention = get_by_name("socket_retention");
    minimum_socket_opening = get_by_name("minimum_socket_opening");
    pin_allowance = get_by_name("pin_allowance");
    prong = get_by_name("prong");
 
    knob_dims =  breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = knob_dims[PEDISTAL_IDX]; 

    dump_to_log();
    check_assertions();
    
    if (show_mocks) {
        orient() mocks();
    } 
    if (show_plugs) {
        color("green", alpha=plug_alpha_) orient() plugs();
    }    
    if (show_housing) {
        color("orange", alpha=housing_alpha_) orient() housing();
    }


    
    check_assertions();
    
    module check_assertions() {
    }
   
    module dump_to_log() {
        
        log_v1("body:", body, log_verbosity, DEBUG);            
        log_v1("face_plate:", face_plate, log_verbosity, DEBUG);
        log_v1("back_plate:", back_plate, log_verbosity, DEBUG);
        log_v1("housing:", housing, log_verbosity, DEBUG);
        log_s("d_knob_clearance:", d_knob_clearance, log_verbosity, DEBUG);            
        log_s("dx:", dx, log_verbosity, DEBUG);
        log_s("x_offset:", x_offset, log_verbosity, DEBUG);   
        log_s("pin_width:", pin_width, log_verbosity, DEBUG);  
        log_s("pin_length:", pin_length, log_verbosity, DEBUG);
        log_s("socket_retention:", socket_retention, log_verbosity, DEBUG);
        log_v1("minimum_socket_opening:", minimum_socket_opening, log_verbosity, DEBUG);
        log_v1("pin_allowance:", pin_allowance, log_verbosity, DEBUG);
        log_v1("prong:", prong, log_verbosity, DEBUG);       
    } 
    
    module plugs() {
        replicate() {
            if (build_from == BUILD_FROM_SIDE_FOR_PLUGS) {
                rotate([0, 0, 90])
                    oriented_pin_junction(part="Plug");
            } else {
                oriented_pin_junction(part="Plug");
            }
        }
    }

    module mocks() {
        replicate() {
            orient_mocks(arrow_up) {
                breadboard_compatible_trim_potentiometer();
                dupont_pins();
            }
        }        
    }
    
    
    module housing(pin_fitting_attachment=true) {
        
        replicate() {
            housing_lower_xz_wall();
            housing_yz_walls();
            if (pin_fitting_attachment) {
                oriented_pin_fitting_attachment();
            } else {
                oriented_pin_junction(part="Socket");
            }
            
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
    
    module oriented_pin_fitting_attachment() {
        
        pattern = "
            ▆◐▒▒▒◑▆  ;
            ◓╳╳╳╳╳◓  ;
            ▒╳╳╳╳╳▒  ;
            ▒╳╳╳╳╳▒  ;
            ▒╳╳╳╳╳▒  ;
            ◒╳╳╳╳╳◒  ;
            ▆◐▒▒▒◑▆ ;
        "; 
        pin_fitting_base_thickness = 2;
        dz = - pin_length/4 - pedistal.x + pin_fitting_base_thickness;
        dx = + pin_width/2;  //Kludge!
        translate([dx, 0, dz]) {
            rotate([180, 0, 0]) {
                dupont_pin_fitting(
                    pattern = pattern,
                    base_thickness = pin_fitting_base_thickness,
                    allowance = 0.0);
            }
        }
    }
    
    module oriented_pin_junction(part) {
        translate([0, 0, -housing.z]) {
            rotate([0, 90, 0]) {
                pin_junction(
                    3, 
                    3, 
                    part=part,
                    pin_insert_thickness = pin_insert_thickness,
                    socket_retention = socket_retention,
                    wall = wall,
                    socket_wall = wall, 
                    minimum_socket_opening = minimum_socket_opening,
                    orient_for_build=false,
                    log_verbosity=log_verbosity);  // Obsolete, must handle separately for now.
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
        rotation = [
            [0, 0, 0], // BUILD_UP_TO_FACE
            Z_TO_MINUS_Z, // BUILD_FROM_FACE
            Z_TO_MINUS_Y, //BUILD_FROM_SIDE
            Z_TO_X, // BUILD_FROM_END
            Z_TO_MINUS_Y, // BUILD_FROM_SIDE_FOR_PLUGS
        ][build_from];
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
            x = i * dx + x_offset;
            assert(is_num(x));
            translate([x, 0, 0]) {
                children();
            }
        }           
    }  
    
 }