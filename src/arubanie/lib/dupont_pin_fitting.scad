/* 

Provides highly customizable fittings for working with Dupont pins.  
The fittings can be either plugs or sockets, and should serve
as an effective way to assemble components, providing strain 
relief so the pins won't accidently unplug.

The 

Usage:

    use <lib/dupont_pin_fitting.scad> 


    pattern = "
           ◑▆░▆◐ ;
           ░▒▆▒░  ;
           ▒▂╷▂▒  ;
           ▆╶╳╴▆  ;
           ▒▂╵▂▒  ;
           ░▒▆▒░  ;
           ◑▆░▆◐  ;
           

    dupont_pin_fitting(
        pattern = pattern,
        base_thickness = 2,
        allowance = 0.0, 
        center=0);

Pattern Language:

        Pin inserts with various height:
        ▁▂▄▆█  
        
        Pin clearance through the base plate and adjacent dummy pins
        ╳
        
        Wire clearance through half height dummy pins:
        ╋┃━ ╸╹╺╻ 
        
        Wire clearance though quarter height dummy pins:
        ╬║═     
        
        Wire clearance though the base plate:
        ┼│─╶╵╶╷    
        
        Latches with a particular orientation:
        ◐◑◒◓  
        
        Bare plate:
        ▒
        
        Void space:
        ░      

*/

include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <relativity/strings.scad>
use <dupont_pins.scad>
use <dupont_pin_latch.scad>





/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 
    


/* [Show] */

//orient_for_build_ = false;
show_dev = true;
show_fitting = true; 
show_mate = true;
show_potentiometer_insert = true;
show_internal_entry_potentiometer_insert = true;

/* [Fitting] */
pattern__ = "all_pattern"; // ["None", all_pattern, test_latches, pin_retention_key, all_symbol]
mated_pattern__ = "None"; // ["None", all_pattern, test_latches, pin_retention_key, all_symbol]

function match_pattern(pattern_name) = 
    pattern_name == "None" ? undef :
    pattern_name == "all_symbols" ? all_symbols() :
    pattern_name == "all_pattern" ? all_pattern() :
    pattern_name == "test_latches" ? test_latches() :
    pattern_name == "pin_retention_key" ? pin_retention_key() :
    assert(false, assert_msg("Unable to find pattern: ", pattern_name) ); 
   
pattern_ = match_pattern(pattern__);
mated_pattern_  = match_pattern(mated_pattern__);    

base_thickness_ = 2; //[0: No plate, 1, 1.5, 2]


/* [4 x 4 Four Development] */
show_4x4_plug_ = true;
show_4x4_socket_for_print_ = true;
show_4x4_socket_mated_ = true;
show_4x4_mocks_ = true;
// Relative strength of latch - scaled height of catch
latch_strength_ = 0.0; // [-1: 0.01 : 1]
// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]

f_ = 0; // [0:0.05:2]

//// Measured in pins
//mated_y_offset = 1; // [-4: 4]
//
//// Fractional pin length
//mated_z_offset = 1; // [-1:0.25:+1]


///* [Pin Latch] */  
//leading_width = 0.33; //[0: 0.05 : 0.50]
//leading_height = 1; //[0: 0.05 : 2]
//catch_width = 0.25; //[0: 0.05 : 0.50]
//catch_height = 0.25; //[0: 0.05 : 1]
//
//
//clearance = 0.2; // [0 : 0.05 : 0.5]

module end_customization() {}


language_key(verbosity);

module language_key(log_verbosity) {   
    log_s("Language Key", dupont_pin_fitting_key(), log_verbosity, DEBUG);
}


   
function all_pattern() = "
       █░█  ;
       █╳█  ;
       ███  ;
       ;
       █▆▄▂▁ ;
       ;
       ◐▒◑▒◒▒◓ ;
       ;
       ▒▒▒▒▒▒  ;
       ▒▒╋┃━▒  ;
       ▒▒╬║═▒  ;
       ▒▒┼│─▒  ;
       ▒▒▒▒▒▒  ;
       ;
       ╸╹╺╻ ;
       ╴╵╶╷ ;
        ;
    ";
   
function test_latches() = "
        ▆◐▒    ;
        ◓░◒    ;
        ▒◑▆    ;
               ;
        ▆◐▒    ;
        ◓░◒    ;
        ▒◑▆    ;
    "; 
 


function potentiometer_housing_fitting() = "
        ▆◐▒▒▒◑▆  ;
        ◓░░░░░◓ ;
        ▒░░░░░▒  ;
        ▒╳╳╳╳╳▒  ;
        ▒╳╳╳╳╳▒  ;
        ◒╳╳╳╳╳◒  ;
        ▆◐▒▒▒◑▆ ;
    ";  
  
function all_symbols() = "█▆▄▂▁◐◑◒◓╋━┃╬═║┼─│╷╵╴╶▒░";   



module x_placement(index) {
    dx_spacing = 50;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

*bare_plug();

module bare_plug() {
    pin_width = 2.54;
    base_thickness = pin_width;
    bare_plug = "
       ▒◒◒◒◒▒  ;
       ◑░░░░◐  ;
       ◑░░░░◐  ;
       ◑░░░░◐  ;        
       ◑░░░░◐  ;
       ▒◓◓◓◓▒   ";
   
    union() {
        dupont_pin_fitting(
            pattern = bare_plug, 
            base_thickness = base_thickness);
        block([0.1, 0.1, 0.1]); 
    }
}



module check_alignments() {
    //╷╵╴╶▒
    pin_width = 2.54;
    pin_length = 14;
    color("red") block([pin_width, pin_width, pin_length], center=ABOVE); 
    v_alignment_check = "
                ▒░▒ ;
                ░░░ ;
                █╵░ ;  
                ███ "  ;
    dupont_pin_fitting(
                pattern = v_alignment_check, 
                base_thickness = 2,
                pin_allowance = 0.25, 
                center = ABOVE);   
}




if (show_dev) {
    x_placement(0) {
    }
}


if (show_fitting) {
    x_placement(0) {
        if (!is_undef(pattern_)) {
            dupont_pin_fitting(
                pattern = pattern_,
                base_thickness = base_thickness_); 
        }
    } 
}

if (show_mate) {
    x_placement(1) {
        if (!is_undef(mated_pattern_)) {
            dupont_pin_fitting(
                pattern = mated_pattern_, 
                base_thickness = base_thickness_); 
        }
    } 
}

if (show_potentiometer_insert) {
    x_placement(2) {
        pattern = "
               ░◑▆░░░░  ;
               ◒▂▂║▂░░  ;
               ▆▂▆╵▆▂░  ;
               ░═╴█╶═░  ;
               ░▂▆╷▆▂▆  ;
               ░░▂║▂▂◓  ;
               ░░░░▆◐░
            ";
        dupont_pin_fitting(
            pattern = pattern, 
            base_thickness = 2);        
    }
}
if (show_internal_entry_potentiometer_insert) {
    x_placement(3) {
        pattern = "
           
        
        
        
           ◑▆░▆◐  ;
           ░▒▆▒░  ;
           ▒▂╷▂▒  ;
           ▆╶╳╴▆  ;
           ▒▂╵▂▒  ;
           ░▒▆▒░  ;
           ◑▆░▆◐  ;
        ";
        dupont_pin_fitting(
            pattern = pattern, 
            base_thickness = 2);
    }
}

option_4 = false;
if (option_4) {
    //all_symbols() = "█▆▄▂▁◐◑◒◓╋━┃╬═║┼─│╷╵╴╶░";  ╸╹╺╻ 
    x_placement(4) {
        plug_pattern = "
            ;
           ░◒◒◒░  ;
           ◑▁╳▁◐  ;
           ◑╶┼╴◐  ;
           ◑▁╵▁◐  ;
           ░◓◓◓░   
        ";
        translate([0, 20, 0]) dupont_pin_fitting(
                pattern = plug_pattern, 
                base_thickness = 2,
                allowance=0.3);
        
        socket_pattern = "
           ▁◓◓◓▁  ;
           ◐░░░◑  ;
           ◐░░░◑  ;
           ◐░░░◑  ;
           ▁◒◒◒▁   
        ";
        difference() {
            dupont_pin_fitting(
                    pattern = socket_pattern, 
                    base_thickness = 2);
            
            block([10.1234, 10.1234, 14], center=BELOW);
        }
    }
}


        
module pin_fitting_for_customization(fitting_base_thickness) {


        
//   module located_pin_fitting() {
//            dupont_pin_fitting(
//                fitting_base_thickness = fitting_base_thickness_,
//                pattern = match_pattern(insert_pattern));
//    }
    
    

    dupont_pin_fitting(
        pattern = pattern_,
        base_thickness = base_thickness_,
        center=CENTER); 
    
    if (is_undef(mated_pattern_)) {
        // Do nothing
    } else {
        color("red", alpha = 0.25) 
            rotate([180, 0, 0]) 
                dupont_pin_fitting(
                    pattern = mated_pattern_, 
                    base_thickness = base_thickness_, 
                    center=CENTER); 
    }
}






function dupont_pin_fitting_language() = 
    let (
        // TODO:    └ ┐ ┌ └ ├ ┬ ┤ ┣ ┫┳ ┻┓ ┏ ┛ ┗ 
        // Element types
        PIN_PASS_THROUGH = "PIN_PASS_THROUGH", 
        PLATE = "PLATE", 
        PIN = "PIN",
        LATCH = "LATCH",
        SPACER = "SPACER",
        // Pin Heights
        FULL =  "FULL",
        TALL = "TALL",
        MID = "MID",
        SHORT = "SHORT",
        MINIMAL = "MINIMAL",
        element_map = [
            ["╳", [PIN_PASS_THROUGH]], 
            ["▁", [PIN, [MINIMAL]]],
            ["▂", [PIN, [SHORT]]],
            ["▄", [PIN, [MID]]],
            ["▆", [PIN, [TALL]]],
            ["█", [PIN, [FULL]]],
            ["╋", [PIN, [MID, [FRONT, BEHIND, LEFT, RIGHT]]]],
            ["━", [PIN, [MID, [LEFT, RIGHT]]]], 
            ["┃", [PIN, [MID, [FRONT, BEHIND]]]],
            ["╻", [PIN, [MID, [FRONT]]]],
            ["╹", [PIN, [MID, [BEHIND]]]],
            ["╸", [PIN, [MID, [LEFT]]]],
            ["╺", [PIN, [MID, [RIGHT]]]],
            // Clearance through pin body
            ["╬", [PIN, [SHORT, [FRONT, BEHIND, LEFT, RIGHT]]]], 
            ["═", [PIN, [SHORT, [LEFT, RIGHT]]]],
            ["║", [PIN, [SHORT, [FRONT, BEHIND]]]], 

            // Clearance through plate 
            ["▒", [PLATE]],
            ["┼", [PLATE, [FRONT, BEHIND, LEFT, RIGHT]]],
            ["─", [PLATE, [LEFT, RIGHT]]],
            ["│", [PLATE, [FRONT, BEHIND]]],
            
            ["╷", [PLATE, [FRONT]]],
            ["╵", [PLATE, [BEHIND]]], 
            ["╴", [PLATE, [LEFT]]],
            ["╶", [PLATE, [RIGHT]]],
            ["└", [PLATE, [RIGHT, BEHIND]]],
            ["┐", [PLATE, [LEFT, FRONT]]],
            ["┌", [PLATE, [RIGHT, FRONT]]], 
            ["└", [PLATE, [LEFT, BEHIND]]],

            ["◐", [LATCH, [MID, RIGHT]]],
            ["◑", [LATCH, [MID, LEFT]]],
            ["◒", [LATCH, [MID, BEHIND]]],
            ["◓", [LATCH, [MID, FRONT]]],
            
            [" ", [SPACER]], // Interior - exterior will be trimmed off
            ["░", [SPACER]],
            
        ],
        pin_pass_through_symbols = join([for (element = element_map) if (element[1][0] == PIN_PASS_THROUGH) element[0]]),
        latch_symbols = join([for (element = element_map) if (element[1][0] == LATCH) element[0]]),
        plate_symbols = join([for (element = element_map) if (element[1][0] == PLATE) element[0]]),
        pin_symbols = join([for (element = element_map) if (element[1][0] == PIN) element[0]]), 
            
        last = undef
    )
    [ 
        ["element_map", element_map],
        ["plate_symbols", plate_symbols],
        ["pin_symbols", pin_symbols],
        ["latch_symbols", latch_symbols],
        ["pin_pass_through_symbols", pin_pass_through_symbols],
        
        
    ];
        
//language = dupont_pin_fitting_language();
//log_v1("language", language, verbosity, debug);
        

        
function dpf_format_glossary(item, explanation) =
        let (
            tab = 20,
            NBSP = "\u00A0",
            indent = join([NBSP, NBSP, NBSP, NBSP]),
            current = len(indent) + len(item),
            padding =  tab > current ?  join([for (i = [current : tab -1]) NBSP]) : " ",
                
            line = join([indent, item, padding, explanation, "\n"])
        )
        line;
     
function dupont_pin_fitting_key() = 
        let (
            language = dupont_pin_fitting_language(),
            NBSP = "\u00A0",
            indent = join([NBSP, NBSP, NBSP, NBSP]),
            plate_symbols = find_in_dct(language, "plate_symbols"),
            pin_symbols = find_in_dct(language, "pin_symbols"),
            latch_symbols = find_in_dct(language, "latch_symbols"),
            pin_pass_through_symbols = find_in_dct(language, "pin_pass_through_symbols"),
            last = undef 
        )
        str(
            "\nDupont Pin Fitting Language: \n",
            
            dpf_format_glossary(plate_symbols, "Just plate, perhaps with wire clearances."), 
            dpf_format_glossary(pin_symbols, "Dummy pins of various heights, perhaps with wire clearances."),
            dpf_format_glossary(latch_symbols, "Latchs, for connecting fittings."),
            dpf_format_glossary(pin_pass_through_symbols, "Pass through for a pin into a fitting."),   
            "\n");
        
//        "  
//    
//    
//        
//        ▁▂▄▆█     ; // Pin inserts with various height
//        ╳   ; // Pin and wire clearance, both directions
//        ╬║═    ; // Wire access in particular directions through full blocks
//        ┼│─    ; // Wire access passing through in particular
//        ╴╵╶╷   ; // Wire access in particular directions
//        ◐◑◒◓   ; // Latches with a particular orientation
//        ░      ; // Bare plate
//
//     "; 


module dupont_pin_fitting(
        pattern,
        base_thickness = 2,
        pin_allowance = 0.0,
        latch_strength = 1,
        latch_clearance = 0.1, 
        center=0,
        log_verbosity = INFO) {
       
    assert(is_string(pattern)); 
    assert(pattern != "");
      
       
   assert(pattern != ""); 


    /*
       Key: 
       
        ▁▂▄▆█  Pin inserts with various height
        ╋      Pin and wire clearance, both directions
        ┃      Pin and wire clearance vertical
        ━      Pin and wire clearance horizontal
        ╬║═    Wire access in particular directions
        ┼│─    Wire access in particular directions
        ╴╵╶╷
        ◐◑◒◓   Latches with a particular orientation
        ░      Bare plate
       
       
       

    */
       

    pin_width = dupont_pin_width();
    pin_length = dupont_pin_length();
    pin = [pin_width, pin_width, pin_length];
    pin_allowances = 2* [pin_allowance, pin_allowance, 0];
    

    layout = pattern_to_layout(pattern);
    log_v1("layout" , layout, log_verbosity, INFO);
    function layout_extent(layout) = 
        let ( 
            row_count = len(layout),
            col_counts = [ for (line = layout) len(line)],
            col_max_count = max(col_counts),
            last = undef
        )
        [ row_count, col_max_count ];
            
    
    layout_extent = layout_extent(layout);
    log_s("layout_extent" , layout_extent, log_verbosity, INFO);
    
    handle_center(center, layout_extent);
    
    module handle_center(center, layout_extent) {
        
        pin_width = dupont_pin_width();


        if (center == 0) {
            fitting_at_center();
        } else if (center == ABOVE) {
            translate([0, 0, pin_length/2]) {
                fitting_at_center();
            }
        } else if (center == ABOVE+RIGHT+FRONT) {
            fitting_at_above_right_front();
        } else {
            assert(false, "Not implemented");
        }
    }
 
    module fitting_at_center() {
        // Translate from above
        translation= [
            -pin_width * layout_extent.x / 2, 
            -pin_width * layout_extent.y / 2,  
            -pin_length/2
        ];
        translate(translation) 
            fitting_at_above_right_front();        
    }
    
    module fitting_at_above_right_front() {
        // As designed, it is ABOVE, and slightly off of RIGHT, 
        // so, align to exactly at ABOVE+RIGHT+FRONT.
        // The origin is at the bottom of the pin, 
        // with the base plate BELOW the origin.
        translate([pin_width/2, pin_width/2, 0]) 
            fitting_as_generated();
    }
  
    module fitting_as_generated() {
        render(convexity=20) difference() {
            process("shapes");
            process("pin_passthrough");
        }
    }       
    
    module pin_latch(opening) {
        leading_height = 0.50;
        catch_height = 0.50;
        module backer() {
            backer_cs = [pin_width, pin_width/2-pin_allowance, 0];
            z_backer = [0, 0, 0.5*pin_length + leading_height*pin_width  + catch_height*pin_width +  4*latch_clearance];
            translate([0, pin_width/2, 0]) {
               block(backer_cs + z_backer, center=ABOVE+RIGHT);
               block(backer_cs + [0, 0, base_thickness], center = BELOW + RIGHT); 
            }
        }
        
        dupont_pin_latch(
            fraction_pin_length = 0.50, 
            opening=opening,
            catch_width = latch_strength * (1/16),
            catch_height = catch_height,
            leading_width = 0,
            leading_height = leading_height,
            clearance = latch_clearance);
        // Provide extra support for the pin latch
        rotation = 
            opening == LEFT ? [0, 0, 0] :
            opening == RIGHT ? [0, 0, 180] :
            opening == FRONT ? [0, 0, 90] :
            opening == BEHIND ? [0, 0, -90] :
            assert(false);
        rotate(rotation) backer();
    }
    
    function pin_fraction_from_pin_height(height) = 
        height == "FULL" ? 1 :
        height == "TALL" ? 0.75 :
        height == "MID" ? 0.50 :
        height == "SHORT" ? 0.25 :
        height == "MINIMAL" ? 0.125 :
        assert(false);
    
       
    module wire_clearances(openings) {
        if (!is_undef(openings)) { 
            for (opening = openings) {
                wire_clearance(opening);
            }
        }
    }
    
    module wire_clearance(opening) {
        wd = dupont_wire_diameter();
        a_lot = 4*pin_length;
        hull() {
            block([pin_width/2, wd, a_lot], center=opening, rank=10);
            can(d=wd, h=a_lot, $fa=12); 
        }
    }  
 
    module produce_pin(aspect, element_features) {
        
        if (aspect == "shapes") {
            height = element_features[0];
            openings = element_features[1];
            // TODO Change to to ABOVE+CENTER+RIGHT  -
           fraction = pin_fraction_from_pin_height(height); 
            difference() {
                union() {
                    block([pin_width, pin_width, fraction*pin_length], center=ABOVE); 
                    block([pin_width, pin_width, base_thickness], center=BELOW);
                }
                wire_clearances(openings);
            } 
        }
    }
    
    module produce_plate(aspect, element_features) {
        if (aspect == "shapes") {
            openings = element_features;
            difference() {
                block([pin_width, pin_width, base_thickness], center=BELOW);
                wire_clearances(openings);
            } 
        }
    }
    
    module produce_pin_pass_through(aspect, element_features) {
        if (aspect == "pin_passthrough") {
            z_alot = [0, 0, 4*pin_length];
            wd = dupont_wire_diameter();
            central_wire_clearance = [wd, wd, 0]; 
            clearance_allowances = pin  - central_wire_clearance;
            block(pin + clearance_allowances + z_alot);            
        }
    }
    
    module  produce_latch(aspect, element_features) {
        if (aspect == "shapes") {        
            height = element_features[0];
            opening = element_features[1];
            pin_latch(opening);
            block([pin_width, pin_width, base_thickness], center=BELOW);
        }
    }

    module produce(element, aspect) {
        
        element_type = element[0];
        element_features = element[1];
        if (element_type == "PLATE") {
            produce_plate(aspect, element_features);
        } else if (element_type == "PIN") {
            produce_pin(aspect, element_features);
        } else if (element_type == "LATCH") {
            produce_latch(aspect, element_features);            
        } else if (element_type == "PIN_PASS_THROUGH") {
            produce_pin_pass_through(aspect, element_features);
        } else if (element_type == "SPACER") {
            // Do nothing
        } else {
            echo("element_type", element_type);
            assert(false);
        }
    }


    module process(aspect) {
        
        language = dupont_pin_fitting_language();
        log_v1("language", language, log_verbosity, DEBUG);
        
        element_map = find_in_dct(language, "element_map");
        log_v1("element_map", element_map, log_verbosity, DEBUG);
        for (i = [0 : len(layout) -1]) {
            row = layout[i];
            for (j = [0 : len(row) -1]) {
                cmd = row[j];              
                element = find_in_dct(element_map, cmd);
                if (!is_undef(element)) {
                    locate(i, j) {
                        produce(element, aspect);
                    } 
                } 
            }
        }
    }
        
    function pattern_to_layout(pattern) =
        assert(is_string(pattern), assert_msg("pattern : ", str(pattern)) )
        let(
            lines =  split(pattern, ";"),
            trimmed_lines = [ for (line = lines) trim(line)],
            last = undef
        ) 
        trimmed_lines;       

    function pattern_to_map(layout, idx)  = [
            for (cmd = layout) if (cmd != " ") [cmd, idx]
        ];

    module locate(i, j) {
        x = i * pin_width;
        y = j * pin_width;
        translate([x, y, 0]) children();
    }

}

