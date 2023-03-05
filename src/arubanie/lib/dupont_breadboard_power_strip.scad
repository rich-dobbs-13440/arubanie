/*  

Provide a holder for a power strip section, with a socket and plug
to securely  connect dupont pins and headers.


*/ 
include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>
use <dupont_connectors.scad>
use <vector_operations.scad>
use <layout_for_3d_printing.scad>
use <TOUL.scad>

pin_width = dupont_pin_width();
pin_length = dupont_pin_length();

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
    echo(allowances);
    
/* [Layout] */
    base_thickness = 2; // [1, 2, 4]
    hole_padding = 1; //[0:0.25:2]
    pad = [0, 0, 0];
 
/* [Label Formating] */
    label_padding = 0; //[0:0.25:2]
    label_size = 2; // [1:0.25:3]
    extra_for_label = 0; // [0:10]
    dx_label_offset = -3; // [-20: 0.5: 20]
    dy_label_offset = -10; // [-30: 0.5:  30]
    
end_of_customization() {}
    
pin_gap_check(pins_in_headers, allowances, gap);





module pin_gap_check(
    pins_in_headers, 
    allowances,
    gap) {
        
    x_c = 2*(hole_padding+label_size + label_padding) + 3;
    sizing_coefficents = layout_sizing_coefficents(
        x_sizing = [ 0,         1, x_c],
        y_sizing = [ pin_width, 0, pin_width],
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
        translate(displacements[0][col]) {
            allowance_label(allowances[col]);
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
    
    module allowance_label(allowance) { 
        text = 
            allowance == 0 ?  "0" :
            (allowance > 0 && allowance < 1) ? substr(str(allowance), 1) :  // Trim off leading zero,
            str(allowance);
        translate([dx_label_offset, dy_label_offset, 0]) {
            number_to_morse_shape(
                    text, // Trim off leading zero, tolerances will always be less than one.
                    size=label_size, 
                    include_base=false);
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
            
        dx = 1;
        
        render() difference() {    
            color("blue") block(size);
            translate([dx, 0, 0]) {
                block(hole, center=BEHIND);
            } 
        } 
    }    
}

