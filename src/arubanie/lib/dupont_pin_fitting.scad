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
           ◑▆░▆◐  ";
           

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
        
        Trim down adjacent walls to half width
        ▽△◁▷◊
        
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
       ' ░'    The space character only works internally.
    
TODO: Completely drive this documentation from the key!    

*/


/*
ECHO: "dupont_pin_fitting_language_key() - Language Key", "
Dupont Pin Fitting Language: 
    ▒┼─│╷╵╴╶└┐┌┘    Just plate, perhaps
                    with wire clearances.
    ▁▂▄▆█╋━┃╻╹╸╺╬═║ Dummy pins of various heights, 
                    perhaps with wire clearances.
    ◐◑◒◓            Latchs, for connecting fittings.
    ' ░'            Spacers - the space character
                    only works internally.
    ╳▽△◁▷◊          Clearances - used to pass a
                    pin or shave down walls.

"

*/



include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <relativity/strings.scad>
use <dupont_pins.scad>
use <dupont_pin_latch.scad>
use <layout_for_3d_printing.scad>

/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [Show] */

// The quickest
show_join_dev_test = true;
show_pin_fit_test = true;
 
/* [Demo] */ 

// Space to allow pins to fit between block, and for separately printed blocks to nest
pin_allowance_ = 0.3;  //[0, 0.2, 0.3, 1:"For dev"]

// Relative strength of latch - scaled height of catch
latch_strength_ = 0.0; // [-1: 0.01 : 1]

// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]

center__ = "ABOVE"; // [ABOVE, BELOW, LEFT, RIGHT, FRONT, BEHIND]

center_ = 
    center__ == "ABOVE" ? ABOVE :
    center__ == "BELOW" ? BELOW :
    center__ == "LEFT" ? LEFT :
    center__ == "RIGHT" ? RIGHT :
    center__ == "FRONT" ? BEHIND :
    assert(false); 

module end_customization() {}

dupont_pin_fitting_language_key(verbosity);

pin_width = dupont_pin_width();


module customized_pin_fitting(pattern) {

    dupont_pin_fitting(
        pattern = pattern_,
        base_thickness = base_thickness_,
        pin_allowance = pin_allowance_,
        latch_strength = latch_strength_,
        latch_clearance = latch_clearance_, 
        center = center_,
        log_verbosity = verbosity);
}

module x_placement(index) {
    dx_spacing = 50;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

if (show_join_dev_test) {
    test = "
        ▒▒▒ ;
        ▒░▒ ;    
        ▒▒▒ ";
    base_thickness = 1;
    dupont_pin_fitting(
        pattern = test,
        base_thickness = base_thickness,
        pin_allowance = pin_allowance_,
        center = ABOVE,
        log_verbosity = verbosity);     
}

if (show_pin_fit_test) {
    pin_fit_test = "
            ▒▒▂▂  ;
            ▒ ▒▂ ;
            ▒▒▂▂ ";
    
    nest_test = "
        ▒▒▒▒▒▒ ;
        ▒    ▒ ;
        ▒    ▒ ;
        ▒    ▒ ;
        ▒▒▒▒▒▒ ";
    
    pin_allowances = [0.5] ; //[each [0:0.1:0.5]];
    base_thickness = 1;
    delta = 6 * pin_width;
    label_size = 2;
    dy_j = 5 * pin_width;
    
    joiner = [delta, label_size, base_thickness];
        
    for (i = [0 : len(pin_allowances)-1]) {
        echo("i", i);
        dx = i * delta; 
        translate([dx, 0, 0]) {
            number_to_morse_shape(number=pin_allowances[i], size=label_size, base=true);
            translate([0, dy_j, 0])block(joiner, center=BELOW+FRONT);
            dupont_pin_fitting(
                pattern = pin_fit_test,
                base_thickness = base_thickness,
                pin_allowance = pin_allowances[i],
                center = ABOVE,
                log_verbosity = verbosity); 
            dupont_pin_fitting(
                pattern = nest_test,
                base_thickness = base_thickness,
                pin_allowance = pin_allowances[i],
                center = ABOVE,
                log_verbosity = verbosity);
        }
    } 
    
}






module dupont_pin_fitting_language_key(log_verbosity) {   
    log_s("Language Key", dupont_pin_fitting_key(), log_verbosity, DEBUG);
}
   

module dupont_pin_fitting(
        pattern,
        base_thickness = 2,
        pin_allowance = 0.3,
        latch_strength = 1,
        latch_clearance = 0.1, 
        center = 0,
        log_verbosity = INFO) {
       
    assert(is_string(pattern)); 
    assert(pattern != "");
      
       
    assert(pattern != ""); 


       

    pin_width = dupont_pin_width();
    pin_length = dupont_pin_length();
    pin = [pin_width, pin_width, pin_length];
    pin_allowances = 2* [pin_allowance, pin_allowance, 0];
    z_alot = [0, 0, 100];
    

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
        render(convexity=10) difference() {
            process("shapes");
            process("clearances");
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
 
    module produce_pin(aspect, element_features, i, j) {
        
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
    
    
    
    module joined_block(directions, plate_thickness, pin_height) {
        function reduced_block(z) = [pin_width, pin_width, z] - pin_allowances;        
        displacement_size =  pin_allowances;
        for (direction = directions) {
            if (!is_undef(direction)) {
                center_translation(displacement_size, center=direction) {
                    block(reduced_block(plate_thickness) , center=direction);
                    block(reduced_block(pin_height), center=direction);
                }
            }
        }
    }
    
    function join_left(i, j) = 
        let (
            last_element = find_element_in_layout(i, j-1),
            last = undef
        )
        echo("i", i, "j", j, "last_element", last_element)
        is_undef(last_element) ? undef :
        last_element[0] == "SPACER" ? undef :
        LEFT;
    
    function join_bottom(i, j) = 
        let (
            last_element = find_element_in_layout(i-1, j),
            last = undef
        )
        echo("i", i, "j", j, "last_element", last_element)    
        is_undef(last_element) ? undef :
        last_element[0] == "SPACER" ? undef :
        BEHIND;
    
    
    function join_right(i, j) = 
        let (
            next_element = find_element_in_layout(i, j+1),
            last = undef
        )
        echo("i", i, "j", j, "next_element", next_element)
        is_undef(next_element) ? undef :
        next_element[0] == "SPACER" ? undef :
        //j == layout_extent[1]-1 ? undef :
        j == 0 && layout_extent[1] == 1 ? undef :
        RIGHT;
    
    function join_top(i, j) = 
        let (
            next_element = find_element_in_layout(i + 1, j),
            last = undef
        )
        echo("i", i, "j", j, "next_element", next_element)
        is_undef(next_element) ? undef :
        next_element[0] == "SPACER" ? undef :
        //j == layout_extent[1]-1 ? undef :
        i == 0 && layout_extent[0] == 1 ? undef :
        FRONT;
    
    function join_directions(i, j) = [
        0, 
        join_left(i, j),
        join_right(i, j),
        join_bottom(i, j),
        join_top(i, j),
    ];
        
    
    
    module produce_plate(aspect, element_features, i, j) {
        if (aspect == "shapes") {
            openings = element_features;
            difference() {
                joined_block(join_directions(i, j), plate_thickness=base_thickness, pin_height=0);
                wire_clearances(openings);
            } 
        }
    }
    
    module produce_half_clearance(aspect, element_features) {
        
        if (aspect == "clearances") {
            openings = element_features[1];
            delta = pin_width/2 - pin_allowance; 
            for (opening = openings) {
                translation = 
                    opening == FRONT ? [delta, 0, 0] :
                    opening == BEHIND ? [-delta, 0, 0] :
                    opening == LEFT ? [0, -delta, 0] :
                    opening == RIGHT ? [0, delta, 0] :
                    assert(false);
                translate(translation) block(pin + z_alot);
                block(pin + z_alot);
            }
        }
        
    }
    
    module produce_clearance(aspect, element_features, i, j) {
        //echo("aspect", aspect);
        //echo("element_features", element_features);
        if (aspect == "clearances") {
            if (element_features[0] == "PIN_PASS_THROUGH") {
                produce_pin_pass_through(aspect, element_features);
            } else if (element_features[0] == "HALF") {
                produce_half_clearance(aspect, element_features); 
                
            } else {
                assert(false);
            }
        }
        
    }
    
    module produce_pin_pass_through(aspect, element_features, i, j) {
        if (aspect == "clearances") {
            z_alot = [0, 0, 4*pin_length];
            wd = dupont_wire_diameter();
            central_wire_clearance = [wd, wd, 0]; 
            clearance_allowances = pin  - central_wire_clearance;
            block(pin + clearance_allowances + z_alot);            
        }
    }
    
    module  produce_latch(aspect, element_features, i, j) {
        if (aspect == "shapes") {        
            height = element_features[0];
            opening = element_features[1];
            pin_latch(opening);
            block([pin_width, pin_width, base_thickness], center=BELOW);
        }
    }

    module produce(element, aspect, i, j) {
        
        element_type = element[0];
        element_features = element[1];
        if (element_type == "PLATE") {
            produce_plate(aspect, element_features, i, j);
        } else if (element_type == "PIN") {
            produce_pin(aspect, element_features, i, j);
        } else if (element_type == "LATCH") {
            produce_latch(aspect, element_features, i, j);            
        } else if (element_type == "CLEARANCE") {
            produce_clearance(aspect, element_features, i, j);
        } else if (element_type == "SPACER") {
            // Do nothing
        } else {
            assert(false, assert_msg("element_type", element_type));
        }
    }

    
    
    language = dupont_pin_fitting_language();
    //log_v1("language", language, log_verbosity, );
    
    element_map = find_in_dct(language, "element_map");   
    //log_v1("element_map", element_map, log_verbosity, DEBUG);
    
    function find_element_in_layout(i, j)  = find_in_dct(element_map, layout[i][j]); 

    module process(aspect) {
        for (i = [0 : len(layout) -1]) {
            row = layout[i];
            for (j = [0 : len(row) -1]) {            
                element = find_element_in_layout(i, j);
                if (!is_undef(element)) {
                    locate(i, j) {
                        produce(element, aspect, i, j);
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


function dupont_pin_fitting_language() = 
    let (
        // TODO:    └ ┐ ┌ └ ├ ┬ ┤ ┣ ┫┳ ┻┓ ┏ ┛ ┗ 
        // Element types
        CLEARANCE = "CLEARANCE",
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
        // Clearance types
        PIN_PASS_THROUGH = "PIN_PASS_THROUGH", 
        HALF = "HALF",
        
        element_map = [
            ["╳", [CLEARANCE, [PIN_PASS_THROUGH]]], 
            ["▽", [CLEARANCE, [HALF, [FRONT]]]],
            ["△", [CLEARANCE, [HALF, [BEHIND]]]],
            ["◁", [CLEARANCE, [HALF, [LEFT]]]],
            ["▷", [CLEARANCE, [HALF, [RIGHT]]]],            
            ["◊", [CLEARANCE, [HALF, [LEFT, RIGHT, FRONT, BEHIND]]]],
            ["▁", [PIN, [MINIMAL]]],
            ["▂", [PIN, [SHORT]]],
            ["▄", [PIN, [MID]]],
            ["▆", [PIN, [TALL]]],
            ["█", [PIN, [FULL]]],
            ["╋", [PIN, [MID, [FRONT, BEHIND, LEFT, RIGHT]]]],
            ["┃", [PIN, [MID, [FRONT, BEHIND]]]],
            ["━", [PIN, [MID, [LEFT, RIGHT]]]], 
            ["╻", [PIN, [MID, [FRONT]]]],
            ["╹", [PIN, [MID, [BEHIND]]]],
            ["╸", [PIN, [MID, [LEFT]]]],
            ["╺", [PIN, [MID, [RIGHT]]]],
            // Clearance through pin body
            ["╬", [PIN, [SHORT, [FRONT, BEHIND, LEFT, RIGHT]]]], 
            ["║", [PIN, [SHORT, [FRONT, BEHIND]]]], 
            ["═", [PIN, [SHORT, [LEFT, RIGHT]]]],
            // Clearance through plate 
            ["▒", [PLATE]],
            ["┼", [PLATE, [FRONT, BEHIND, LEFT, RIGHT]]],
            ["─", [PLATE, [LEFT, RIGHT]]],
            ["│", [PLATE, [FRONT, BEHIND]]],
            
            ["╷", [PLATE, [FRONT]]],
            ["╵", [PLATE, [BEHIND]]], 
            ["╴", [PLATE, [LEFT]]],
            ["╶", [PLATE, [RIGHT]]],
            ["┌", [PLATE, [RIGHT, FRONT]]],
            ["┐", [PLATE, [LEFT, FRONT]]],
            ["└", [PLATE, [RIGHT, BEHIND]]],
            ["┘", [PLATE, [LEFT, BEHIND]]],

            ["◐", [LATCH, [MID, RIGHT]]],
            ["◑", [LATCH, [MID, LEFT]]],
            ["◒", [LATCH, [MID, BEHIND]]],
            ["◓", [LATCH, [MID, FRONT]]],
            
            [" ", [SPACER]], // Interior - exterior will be trimmed off
            ["░", [SPACER]],
            
        ],
        clearance_symbols = join([for (element = element_map) if (element[1][0] == CLEARANCE) element[0]]),
        latch_symbols = join([for (element = element_map) if (element[1][0] == LATCH) element[0]]),
        plate_symbols = join([for (element = element_map) if (element[1][0] == PLATE) element[0]]),
        pin_symbols = join([for (element = element_map) if (element[1][0] == PIN) element[0]]), 
        spacer_symbols = join([for (element = element_map) if (element[1][0] == SPACER) element[0]]),
            
        last = undef
    )
    [ 
        ["element_map", element_map],
        ["plate_symbols", plate_symbols],
        ["pin_symbols", pin_symbols],
        ["latch_symbols", latch_symbols],
        ["spacer_symbols", spacer_symbols],
        ["clearance_symbols", clearance_symbols],
        
        
    ];
        
        

        
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
            clearance_symbols = find_in_dct(language, "clearance_symbols"),
            spacer_symbols = find_in_dct(language, "spacer_symbols"),
            last = undef 
        )
        str(
            "\nDupont Pin Fitting Language: \n",
            
            dpf_format_glossary(plate_symbols, "Just plate, perhaps"),
            dpf_format_glossary("", "with wire clearances."), 
            dpf_format_glossary(pin_symbols, "Dummy pins of various heights, "),
            dpf_format_glossary("", "perhaps with wire clearances."),
            dpf_format_glossary(latch_symbols, "Latchs, for connecting fittings."),
            dpf_format_glossary(join(["'", spacer_symbols, "'"]), "Spacers - the space character"), 
            dpf_format_glossary("", "only works internally."),
            dpf_format_glossary(clearance_symbols, "Clearances - used to pass a"),
            dpf_format_glossary("", "pin or shave down walls."),    
            "\n");
        

/*
ECHO: "dupont_pin_fitting_language_key() - Language Key", "
Dupont Pin Fitting Language: 
    ▒┼─│╷╵╴╶└┐┌┘    Just plate, perhaps
                    with wire clearances.
    ▁▂▄▆█╋━┃╻╹╸╺╬═║ Dummy pins of various heights, 
                    perhaps with wire clearances.
    ◐◑◒◓            Latchs, for connecting fittings.
    ' ░'            Spacers - the space character
                    only works internally.
    ╳▽△◁▷◊          Clearances - used to pass a
                    pin or shave down walls.

"

*/

//        "  
//    
//    Next Goal for key:
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

/*

Long form of output desired:


Pattern Language:  

        Pin inserts with various height:
        ▁▂▄▆█  
        
        Pin clearance through the base plate and adjacent dummy pins
        ╳
        
        Trim down adjacent walls to half width
        ▽△◁▷◊
        
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
       ' ░'    The space character only works internally.

*/