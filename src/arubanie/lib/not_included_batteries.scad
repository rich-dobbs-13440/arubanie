/*
     OpenSCAD does not have Python's "batteries included" philosophy.
     This is a collection point for things that help make 
     the language more productive out of the box.

     It is missing a standard library that transforms it from a 
     barebones language to a more productive, less frustrating 
     tool

     Expect that it will just use other files that do the actual
     implementation, since otherwise this will become quite bulky.
     However, will start by just implementing things here.

     Note:  This library is targeted toward use with 19.05.
     
     Usage:
     
     use <lib/not_included_batteries.scad>
*/  

include <TOUL.scad>
include <logging.scad>
use <centerable.scad>
use <vector_operations.scad>

/* [Boiler Plate] */

$fa = 5;
$fs = 0.4;
eps = 0.001;

infinity = 100;

module end_of_customization() {}

std_color_pallete = [
    "red",
    "orange",
    "yellow",
    "green",
    "blue",
    "indigo",
    "violet",
    "Crimson",
    "Coral",
    "Moccasin",
    "Medium SeaGreen",
    "SteelBlue",
    "BlueViolet",
    "Thistle",
    "IndianRed",
    "LightSalmon",
    "PeachPuff",
    "OliveDrab",
    "MediumTurquoise",
    "Plum",
    "Fushia"
];

show_name = false;
if (show_name) {
    linear_extrude(2) text("not_included_batteries.scad", halign="center");
}

function find_all_in_kv_list(list_kvp, identifier) =  
    [ for (item = list_kvp) if (item[0] == identifier) item[1] ];
        
function _dct_assert_one_and_only(matches) = 
    assert(len(matches) < 2, "Not a dictionary! Multiple matches.")
    assert(len(matches) != 0, "No match found for key")
    matches[0];       
        
function find_in_dct(dct, key, required=false) =
    required ? 
        _dct_assert_one_and_only(find_all_in_kv_list(dct, key)) :
        find_all_in_kv_list(dct, key)[0];

function in_list(list, item) = len([for (element = list) if (element == item) element]) > 0;

function find_in_set(set, key) = 
    let (
        finds = [ for (element = set) if (element==key) true]
    )
    assert(len(finds)<=1) 
    (len(finds) == 1);

function join(v_of_str, i=0) = 
    (i == len( v_of_str) - 1) ? v_of_str[i] :
    str(v_of_str[i], join(v_of_str, i+1));
        
module construct_plane(vector, orientation, extent=100) {
    axis_offset = v_o_dot(vector, orientation);
    normal = [1, 1, 1] - orientation;
    plane_size = v_mul_scalar(normal, extent) + [0.1, 0.1, 0.1];
    color("gray", alpha=0.05) translate(axis_offset) cube(plane_size, center=true);
}

module display_displacement(displacement, barb_color="black", shaft_color="black", label=undef) {
    barb_length = 3;
    barb_diameter = 0.5;
    fraction = 1-barb_length/norm(displacement);
    displacement_minus_barb = v_mul_scalar(displacement, fraction);

    color(shaft_color) hull() {
        sphere(r=0.3);
        translate(displacement_minus_barb) sphere(0.3);
    }

    color(barb_color) hull() {
        translate(displacement) sphere(eps);
        translate(displacement_minus_barb) sphere(barb_diameter);
    }
}


    module customizer_items_to_checkboxes(items, suffix="_", list_name=undef, tab_name=undef, log_verbosity=INFO) {
        
        signature = "customizer_items_to_checkboxes(items, suffix=\"_\", list_name=undef, tab_name=undef)";
        assert_msg = str("Missing or bad argument.  The usage should be:          ", signature);
        assert(is_list(items), assert_msg);
        assert(is_string(list_name), assert_msg);
        
        /* Want something like this:
        show_screw_pilot_holes_shl = false;
        show_screw_access_clearance_shl = false;
               
        new_debug_items_shl = [ 
            show_screw_pilot_holes_shl ? "screw_pilot_holes" : "",
            show_screw_access_clearance_shl ? "screw_pilot_holes" : "",
        ]; 
        */
        function indent(level) = join([ for (i = [0:level-1]) "    "]);
            
        function tab_line() = is_undef(tab_name) ? "" : ["<p>/* [ ", tab_name, " ] */</p>"];
        function show_var(option) = str(indent(1), "show_", option, suffix);
        function check_box_lines()  = [
           for (item = items) str("<p>", show_var(item), " = false;</p>")
        ];
        function start_variable_assignment() = concat([indent(1)], [list_name, suffix, " = ["]);
        function list_value_line(item) = str("<p>", indent(2), show_var(item), " ? \"", item, "\" : \"\",</p>");
        function check_box_values_to_list_value() = [
           for (item = items) list_value_line(item)
        ];
        function close_variable_assignment() = ["<p>", indent(1), "];</p>"];
        
                   
        all_lines = concat(
           ["<p>...</p><pre>"],
           tab_line(),
           check_box_lines(),
           start_variable_assignment(),
           check_box_values_to_list_value(),
           close_variable_assignment(),
           ["</pre>"],
           ["<p>...</p>"]
        );
           
        text_block = join(all_lines);  
          
        log_s("Add this to your customizer section", text_block, log_verbosity, DEBUG); 
    }