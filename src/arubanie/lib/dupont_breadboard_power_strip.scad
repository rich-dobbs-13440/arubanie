/*  

Provide a holder for a power strip section, with a socket and plug
to securely  connect dupont pins and headers.


*/ 

include <logging.scad>
include <centerable.scad>
use <not_included_batteries.scad>
use <dupont_pin_fitting.scad>
use <shapes.scad>
//use <vector_operations.scad>
use <layout_for_3d_printing.scad>

function dupont_pin_width() = 2.54; // Using standard dimensions, rather than measured
function dupont_pin_length() = 14.0; // Using standard dimensions, rather than measured
function dupont_wire_diameter() = 1.0 + 0.25; // measured plus allowance

pin_width = dupont_pin_width();
pin_length = dupont_pin_length();

/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

/* [Show] */

orient_for_build = false;

show_housing_ = true;
show_plug_ = true;
show_mock_instrument = true;

/* [Customize] */

// Relative strength of latch - scaled height of catch
latch_strength_ = 0.2; // [-1: 0.01 : 1]
// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]

/* [Fit tests] */
    gap = 2.54; // [2.54:"Header Check", 1.68:"Pin Insert Check"]

    
    min_pins = 2; // [ 1:1:20]
    delta_pins = 2; // [1, 2, 4]
    max_pins =  8; // [ 1 : 1 : 20]
    pins_in_headers = [ each [min_pins : delta_pins: max_pins] ];

    minimum_allowance = 0.0; // [0.0 : 0.05 : 1]
    delta_allowance = 0.05; // [0.05, 0.1]
    maximum_allowance = 0.35; // [0.0: 0.05 : 1]
    allowances = [ each [minimum_allowance : delta_allowance : maximum_allowance ] ];
    
/* [Layout] */
    base_thickness = 2; // [1, 2, 4]
    hole_padding = 0.25; //[0.25:0.25:10]
    
 
/* [Label Formating] */
    label_padding = 0; //[0:0.25:2]
    label_size = 2; // [1:0.25:3]
    dy_label_offset = -4; // [-30: 0.5:  30]
    min_y_in_chars = 3; // [1: 0.5:  5]
    
    x_padded_label = label_size + 2*label_padding;
    pad = [0, 0, 0];
    
end_of_customization() {}

power_strip = [9.35, 82.3, 8.52];

if (show_mock_instrument && !orient_for_build) {
    color("white")
        block(power_strip, center=BELOW);
}


dupont_pin_fitting_language_key(DEBUG);

mounting_plug_and_socket(orient_for_build, show_plug_, show_housing_); 

module mounting_plug_and_socket(orient_for_build, show_plug, show_housing) {
    pin_width = 2.54;
    pin_length = 14;
    plug_base_thickness = 2;
    wall = 2;
    clearance = 0.2;    
    socket_base_thickness = power_strip.z + clearance + wall; 
    
    color("orange") {
        if (show_plug) {
            if (orient_for_build) {
                    translate([0, 20, plug_base_thickness ])  //-plug_base_thickness
                        rotate([0, 0, -90]) 
                            plug();
            
            } else {
                translate([0, 0, pin_length]) 
                    rotate([0, 180, -90]) 
                        plug();
            }
        }
    }
    
    if (show_housing) {
        if (orient_for_build) {
            translate([0, 0, socket_base_thickness ])
                housing();            
        } else {
            housing(); 
        } 
    }
    
    module housing() {

        power_strip_clearance = [0, 0, 0];
        render() difference() {
            translate([0, 0, 0]) { 
               rotate([0, 0, 90]) 
                   socket();
            }
            block(power_strip + power_strip_clearance, center=BELOW, rank=100);
        }
    }
	
    module plug() {
    
        
        plug = "
         ◑▄┌┐▄◐ ;
         ◑▄││▄◐ ;
         ◑▄││▄◐ ;
         ◑▄││▄◐ ;
         ◑▄└┘▄◐ 
        ";        
        
        dupont_pin_fitting(
            pattern = plug,
            latch_strength = latch_strength_,
            latch_clearance =latch_clearance_,
            base_thickness = plug_base_thickness,
            center = ABOVE,
            log_verbosity = verbosity); 
        end_wall = [pin_width/2-0.2, 6*pin_width, pin_length + plug_base_thickness];
        *center_reflect([1, 0, 0]) 
            translate([2.5*pin_width, 0, -plug_base_thickness]) 
                block(end_wall, center = ABOVE+FRONT);
           
    } 
    module socket() {
        socket = "
           ◐▄▒▒▄◑  ;
           ◐▒▒▒▒◑  ;
           ◐▒▒▒▒◑  ;  
           ◐▒▒▒▒◑  ;
           ◐▄▒▒▄◑  "; 
        

        
        
        dupont_pin_fitting(
            pattern = socket, 
            latch_strength = latch_strength_,
            latch_clearance =latch_clearance_,        
            base_thickness = socket_base_thickness,
            center=ABOVE,
            log_verbosity = verbosity);
    }
}



    
* pin_gap_check(pins_in_headers, allowances, gap);


* pin_insert_element(slit_allowance=0.15, header_allowance= 0.2);

module pin_insert_element(slit_allowance, header_allowance) {
    a_lot = 20;
    insert_height = 6.39;
    board_height = 8.20;
    base = [3*pin_width, 8*pin_width, board_height];
    insert = [1.68, 13.66, insert_height];
    slit_allowances = 2 * [slit_allowance, slit_allowance, a_lot];
    slit = insert + slit_allowances;
    pin = [pin_width, pin_width, pin_length];
    echo("slit", slit);
    header_allowances = 2 * [header_allowance, header_allowance, a_lot];
    header = [pin_width, 7*pin_width, pin_length]; 
    header_slit = header + header_allowances;
     
    render() difference() {
        union() {
            block(base, center=BELOW);
            translate([pin_width, 0, 0]) block(base, center=BELOW);
        }
        
        *center_reflect([pin_width, 0, 0]) 
            translate([pin_width/2, 0, 0]) 
                block(slit);
        translate([1.5*pin_width, 0, 0]) color("purple") block(header_slit);
    }
    * translate([1.5*pin_width, 0, 0]) color("black") block(pin, center=BELOW);
    
    *translate([2.5*pin_width, 0, 0]) color("red") block(pin, center=BELOW);
}



module pin_gap_check(
    pins_in_headers, 
    allowances,
    gap) {
        
    x_c = gap + x_padded_label + 2*hole_padding;  
    y_c = pin_width + 2*hole_padding + 2;
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ 0,         4, x_c],
        y_sizing = [ pin_width, 0, y_c],
        z_sizing = [ 0,         0, base_thickness]
    );        
        
    element_parameters = [
    ];        

    sizes = layout_generate_sizes(
        row_values=pins_in_headers , 
        column_values=allowances,
        sizing_coefficents=sizing_coefficents);
    
    strategy = [
        COMPRESS_ROWS(), 
        COMPRESS_MAX_COLS(), 
        CONST_OFFSET_FROM_ORIGIN()];
    
    displacements = layout_displacements(
        sizes, 
        pad, 
        strategy);

    for (col = [0: len(allowances)-1]) {
        render() difference() {
            translate(displacements[0][col]) {
                allowance_label(allowances[col], sizes[0][col]);
            }
            plane_clearance(LEFT);
        }
        for (row = [0 : len(pins_in_headers)-1]) {            
            translate(displacements[row][col]) {
                gap_element(
                    pins_in_headers[row], 
                    allowances[col], 
                    sizes[row][col], 
                    element_parameters, 
                    pad, 
                    row, 
                    col);
            } 
        }
    } 
    
    module allowance_label(allowance, size) { 
        z_in_mm = base_thickness;
        min_x_in_mm = x_padded_label;
        dx_label_offset = -size.x/2 + x_padded_label/2;
        translate([dx_label_offset, dy_label_offset, 0]) {
            number_to_morse_shape(
                    allowance, size=label_size, base=[min_x_in_mm, min_y_in_chars, z_in_mm]);  
        }
    }

    module gap_element(
        pins_in_header, 
        allowance, 
        size, 
        element_parameters, 
        pad, 
        row, 
        col) {
        hole = [gap, pins_in_header*pin_width, 10] + 2 * [allowance, allowance, allowance]; 
            
        dx = -size.x/2 + x_padded_label + hole_padding;
        
        render() difference() {  
            block(size, center=BELOW);
            translate([dx, 0, 0]) {                
                block(hole, center=FRONT);
            }
        }
    }    
}

