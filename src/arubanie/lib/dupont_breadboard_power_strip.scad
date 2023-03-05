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

pin_width = dupont_pin_width();
pin_length = dupont_pin_length();

//header_rows = 1;
//header_columns = 4; // [2, 4, 6, 8]

//count = 7;
//allowance_start = 0;
//allowance_delta = 0.1;

base_thickness = 1; // [1, 2, 4, 6, 8, 10]
rim = 3;

module end_of_customization() {}

header_sizes = [2, 4, 6, 8];
allowances = [0.2, 0.25, 0.30, 0.35];
allowances_labels = [".2", ".25", ".3", ".35"]; 
allowance_block(header_sizes, allowances, allowances_labels);

module allowance_block(header_sizes, allowances, allowances_labels) {
    cumulative_pins = v_cumsum(header_sizes);
    for (i = [0 : len(header_sizes)-1])  {
        header_pins = header_sizes[i];
        dy = cumulative_pins[i]* pin_width + (i-1) * rim/2;
        translate([0, dy, 0]) test_block_for_column(header_pins, allowances, allowances_labels);
    }
}


module test_block_for_column(header_pins, allowances, allowances_labels) {
    header_columns = 1;
    al_count = len(allowances);
    base = [(al_count + al_count -1) * pin_width, header_pins*pin_width, base_thickness] + 2*[rim, rim, 0];

    function header(rows, columns) = [rows*pin_width, columns*pin_width, pin_length]; 
    function allowance_size(allowance) = 2*[allowance, allowance, 0];
    //number_to_morse_shape(".45", 2);

    render() difference() {
        block(base, center=FRONT+ABOVE);
        for (i = [0:len(allowances)-1]) {
            translate([(i+0.5)*2*pin_width, 0, 0]) {
                block(header(header_columns, header_pins) + allowance_size(allowances[i]));
            }
        }
    }
}


