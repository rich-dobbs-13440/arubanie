/*  

Provide a holder for a power strip section, with a socket and plug
to securely  connect dupont pins and headers.


*/ 

include <logging.scad>
include <centerable.scad>
use <not_included_batteries.scad>
use <dupont_pins.scad>
use <dupont_pin_fitting.scad>

use <shapes.scad>
use <layout_for_3d_printing.scad>




/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice);

/* [Show] */

orient_for_build = false;

show_housing_ = true;
show_mock_instrument_ = true;
show_pin_clip_ = true;

/*
⏺
[Customize] */
housing_ = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]
pin_width = 2.54 + 0; //

pin_allowance_ = 0.3; // [0:0.05: 0.5]
// Relative strength of latch - scaled height of catch
latch_strength_ = 0.2; // [-1: 0.01 : 1]
// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]
power_strip_clearance_ = 0.4; // [0: 0.05 : 1]
pin_clip_looseness_percent_ = 9; // [0: 1: 9]

use_plug_1_ = true;

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

if (show_mock_instrument_ && !orient_for_build) {
    color("white")
        block(power_strip, center=BELOW);
    translate([DUPONT_HOUSING_WIDTH()/2, 0, 0]) dupont_connector();
}


dupont_pin_fitting_language_key(DEBUG);


mounting_plug_and_socket(
    power_strip_clearance_, 
    orient_for_build, 
    show_housing_, 
    show_pin_clip_,
    pin_clip_looseness_percent_,
    housing_); 

module mounting_plug_and_socket(
        power_strip_clearance, 
        orient_for_build, 
        show_housing, 
        show_pin_clip, 
        pin_clip_looseness_percent=10,
        housing=14,
        housing_width=2.54) {
            
    pin_width = housing_width;
    pin_length = housing;
    plug_base_thickness = 2;
    wall = pin_width;
    clearance = 0.2;    
    socket_base_thickness = power_strip.z + clearance + wall; 
    
    color("salmon") {
        if (show_pin_clip) {
            if (orient_for_build) {
                translate([0, 40, 0 ]) {        
                    pin_clip();
                }
            }
            else {
                translate([0, 0, pin_length/2]) pin_clip();
            }
        }
    }
    
    
    color("olive") {
        if (show_housing) {
            if (orient_for_build) {
                translate([0, 0, 2.5*pin_width]) //   //socket_base_thickness ])
                    rotate([90, 0, 0])
                        housing();            
            } else {
                housing(); 
            } 
        }
    }
    
    module strip_clip(pin_count) {
        power_strip_clearances = [2*power_strip_clearance, 0, 2*power_strip_clearance];
        walls = [2*wall, 0, wall];
        power_strip_segment = [power_strip.x, pin_count*pin_width, power_strip.z];
        strip_clip = power_strip_segment + power_strip_clearances + walls;
        difference() {
            block(strip_clip, center=BELOW);
            block(power_strip + power_strip_clearances, center=BELOW, rank=3);
        }
    }    
    
    module housing() {
        strip_clip(5);
        translate([0, 0, pin_length]) rotate([180, 0, 0]) pin_retainer();
        pin_retention_posts(); 
    }
	
    module pin_retainer() { 
     
        retainer = "
            ▁▁▁▁▁ ;
            ▁▁▁▁▁ ;
            ────╴ ;
            ────╴ ;
            ▁▁▁▁▁ ;
            ▁▁▁▁▁ ";


        dupont_pin_fitting(
            pattern = retainer,
            base_thickness = plug_base_thickness,
            center = ABOVE,
            log_verbosity = verbosity);
        
    } 
    
    module pin_retention_posts() {      
        posts = "
            ▄▄▄▄▄ ;
            █████ ;      
            ░░░░░ ;
            ░░░░░ ;        
            █████ ;
            ▄▄▄▄▄  "; 
       
        dupont_pin_fitting(
            pattern = posts,        
            base_thickness = 0,
            pin_allowance = pin_allowance_,
            housing = housing,
            center=ABOVE,
            log_verbosity = verbosity);   
    }
    
    module pin_clip() {
        clip = "
            ▷▁▁▁▁▁▁▁◁ ;
            ▷▁     ▁◁ ;
            ▷▁     ▁◁ ;
            ▷▁     ▁◁ ;       
            ▷▁     ▁◁ ;
            ▷▁▁▁▁▁▁▁◁ ";
        
        pin_clip_scale = 1 + pin_clip_looseness_percent/100;
        
        pin_clip_base_thickness = 1;
        label_translation = [
            2.5*pin_width,
            -12.5, 
            pin_clip_base_thickness + 0.5
            
        ];        
        
        
        scale([pin_clip_scale, pin_clip_scale, 1]) {

            translate(label_translation) {
                number_to_morse_shape(number=pin_clip_looseness_percent, size=2.2, base=false);
            }
            
            dupont_pin_fitting(
                pattern = clip,        
                base_thickness = pin_clip_base_thickness,
                pin_allowance = pin_allowance_,
                housing = housing,
                center=ABOVE,
                log_verbosity = verbosity);  
        }       
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

