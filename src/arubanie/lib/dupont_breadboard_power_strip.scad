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

/* [Customization] */
    base_thickness = 1; // [1, 2, 4, 6, 8, 10]

    
    allowances = [0.2, 0.25, 0.30, 0.35];
    header_sizes = [2, 4, 8];    
    
/* [Layout Formating] */
    overlap = 0; // [0:0.25:5]
    
    
    pins_for_gap = 2;
    pins_for_rim = 2;
    pins_for_base_width = 3.5;
    hole_padding = 0.5; //[0:0.25:2]
    
/* [Label Formating] */
    label_padding = 0; //[0:0.25:2]
    label_size = 2; // [1:0.25:3]
    extra_for_label = 0; // [0:10]






header_fit_blocks(allowances, header_sizes, base_thickness, label_size, extra_for_label);


module header_fit_blocks(allowances, header_sizes, base_thickness, label_size, extra_for_label) {
    for (j = [0 : len(allowances) - 1]) {
        dx = j * (pins_for_base_width * pin_width - overlap);
        translate([dx, 0, 0]) {
            header_fit_block(
                allowances[j], 
                header_sizes, 
                base_thickness, 
                label_size, 
                extra_for_label=extra_for_label);
        }
    }
}



function header_fit_block_blank(header_sizes, base_thickness, extra_for_label)  = 
    let (
       total_header_pins = v_sum(header_sizes),
       extra_pin_spaces = pins_for_gap*(len(header_sizes) - 1) + 2 * pins_for_rim + extra_for_label, // For gaps and at each end
       total_pins = total_header_pins + extra_pin_spaces,
       last = undef
    )
    [pins_for_base_width*pin_width, total_pins*pin_width, base_thickness]; 

module header_fit_block(allowance, header_sizes, base_thickness, label_size, extra_for_label=0) {
    header_rows = 1; 
    translate([label_size/2 + label_padding, 0, 0]) 
        number_to_morse_shape(
            substr(str(allowance), 1), // Trim off leading zero, tolerances will always be less than one.
            size=label_size, 
            include_base=false);
    
    dx = label_size + 2 * label_padding + hole_padding; 
    
    cumulative_pins = v_cumsum(header_sizes);
 
    render() difference() {
        base();
        for (i = [0:len(header_sizes)-1]) {
            pin_position = pins_for_rim + cumulative_pins[i] + pins_for_gap*(i); // - cumulative_pins[0] + pins_for_gap*(i-1)
            dy = pin_position * pin_width;
            size = header(header_rows, header_sizes[i]);
            allowance_size = 2*[allowance, allowance, 0];
            translate([dx, dy, 0]) { 
                block(size + allowance_size, center=LEFT+FRONT);
            }
        }
    }
    
    module base() {
        size = header_fit_block_blank(header_sizes, base_thickness, extra_for_label);
        block(size, center=RIGHT+FRONT+BELOW);
    }
    function header(rows, columns) = [rows*pin_width, columns*pin_width, pin_length];
}


