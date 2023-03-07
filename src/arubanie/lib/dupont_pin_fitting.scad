include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
include <TOUL.scad>

/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 
    


/* [Show] */

//orient_for_build_ = false;
show_fitting = true;  

/* [Fitting] */


fitting_pattern = "all_pattern"; // ["all_pattern", "potentiometer_insert", "potentiometer_housing_fitting:, "test_latches", "pin_retention_key"]
mated_fitting_pattern = "None"; // ["None", "potentiometer_housing_fitting", "test_latches"]

pin_insert_thickness_ = 1; //[0: No plate, 1, 1.5, 2]

// Measured in pins
mated_y_offset = 1; // [-4: 4]

// Fractional pin length
mated_z_offset = 1; // [-1:0.25:+1]


/* [Pin Latch] */  
leading_width = 0.33; //[0: 0.05 : 0.50]
leading_height = 1; //[0: 0.05 : 2]
catch_width = 0.25; //[0: 0.05 : 0.50]
catch_height = 0.25; //[0: 0.05 : 1]


clearance = 0.2; // [0 : 0.05 : 0.5]


fraction_pin_length = 0.75; // [0 : 0.05 : 1.0]

module end_customization() {}


function dupont_pin_width() = 2.54; // Using standard dimensions, rather than measured
function dupont_pin_length() = 14.0; // Using standard dimensions, rather than measured
function dupont_wire_diameter() = 1.0 + 0.25; // measured plus allowance

if (show_fitting) {
    x_placement(4) {
        pin_fitting_for_customization();
    } 
}



potentiometer_insert = "
        ▆◐▂
        ◓╷▄
        ╶╋╴
        ▄╵◒
        ▂◑▆ 
    ";


potentiometer_housing_fitting = "
        ▆◐▁
        ◓╷▂
        ╶╋╴
        ▂╵◒
        ▁◑▆  

    ";    

        
module pin_fitting_for_customization(pin_insert_thickness) {
    all_pattern = "
        ░░░░░░░█░
        ░╋░░┃░█━█ 
        ░░░░░░░█░
        ░░░░░░░░░
        ░╬░░║░░═░
        ░░░░░░░░░
        ░┼░░│░░─░ 
        ░░░░░░░░░
        ░╴╵╶╷░░░░
        ▁▂▄▆█
        ░◐░◑░◒░◓░
    ";
   


 
    test_latches = "
        ▆◐░
        ◓╋◒
        ░◑▆
        ───
        ▆◐░
        ◓╋◒
        ░◑▆
    ";
    function match_pattern(pattern) = 
        pattern == "None" ? "" :
        pattern == "all_pattern" ? all_pattern :
        pattern == "potentiometer_insert" ? potentiometer_insert :
        pattern == "test_latches" ? test_latches :
        pattern == "pin_retention_key" ? pin_retention_key :
        assert(false, assert_msg("Unable to find pattern: ", pattern) );
        
//   module located_pin_fitting() {
//            pin_fitting(
//                pin_insert_thickness = pin_insert_thickness_,
//                pattern = match_pattern(insert_pattern));
//    }
    
    
    i
    pin_fitting(
        pin_insert_thickness = pin_insert_thickness_,
        pattern = match_pattern(pattern) ); 
    
    if (mated_fitting_pattern == "None") {
        // Do nothing
    } else {
       fitting_pattern = match_pattern(fitting_pattern);
        color("red", alpha = 0.25) 
            rotate([180, 0, 0]) 
                pin_fitting(
                    pin_insert_thickness = pin_insert_thickness,
                    pattern = fitting_pattern); 
    }
}


pin_retention_key = "      
        ▁▂▄▆█  Pin inserts with various height
        ╋      Pin and wire clearance, both directions
        ┃      Pin and wire clearance vertical
        ━      Pin and wire clearance horizontal
        ╬║═    Wire access in particular directions
        ┼│─    Wire access in particular directions
        ╴╵╶╷
        ◐◑◒◓   Latches with a particular orientation
        ░      Bare plate

     ";


module pin_fitting(
        pin_insert_thickness,
        pattern,
        allowance = 0.0, 
        center=0) {
       
    assert(is_string(pattern)); 
    echo("pattern", pattern);
    assert(pattern != "");
      
       
   assert(false);  
   //assert(pattern != ""); 
//
//
//    /*
//       Key: 
//       
//        ▁▂▄▆█  Pin inserts with various height
//        ╋      Pin and wire clearance, both directions
//        ┃      Pin and wire clearance vertical
//        ━      Pin and wire clearance horizontal
//        ╬║═    Wire access in particular directions
//        ┼│─    Wire access in particular directions
//        ╴╵╶╷
//        ◐◑◒◓   Latches with a particular orientation
//        ░      Bare plate
//       
//       
//       
//       all_pattern = "░░░ ╋┃━ ░░░ ╬║═ ░░░ ▁▂▄▆█ ┼│─ "
//    */
//       
//
    pin_width = dupont_pin_width();
    pin_length = dupont_pin_length();
    pin = [pin_width, pin_width, pin_length];
    allowances = 2* [allowance, allowance, 0];
    

//    layout = split_no_separators(pattern);
//    echo("layout" , layout);
//    echo("len(layout)", len(layout));
//    function layout_extent(layout) = 
//        let ( 
//            row_count = len(layout),
//            col_counts = [ for (line = layout) len(line)],
//            col_max_count = max(col_counts),
//            last = undef
//        )
//        [ row_count, col_max_count ];
//            
//    
//    layout_extent = layout_extent(layout);
//    
//    handle_center(center, layout_extent);
//    
//    module handle_center(center, layout_extent) {
//        
//        pin_width = dupont_pin_width();
//
//
//        if (center == 0) {
//            fitting_at_center();
//        } else {
//            assert(false, "Not implemented");
//        }
//    }
//    
//    module fitting_at_center() {
//        // Translate from above
//        translation= [
//            -pin_width * layout_extent.x / 2, 
//            -pin_width * layout_extent.y / 2,  
//            -pin_length/2
//        ];
//        translate(translation) 
//            fitting_at_above_right_front();        
//    }
//    
//    module fitting_at_above_right_front() {
//        // As designed, it is ABOVE, and slightly off of RIGHT, 
//        // so, align to exactly at ABOVE_RIGHT
//        translate([pin_width/2, pin_width/2, pin_width/2]) 
//            fitting_as_generated();
//    }
//    
//   
//    module fitting_as_generated() {
//        render() difference() {
//            union() {
//                base_plate();
//                pin_inserts();
//            }
//            clearances();
//        }
//    }       
//    
//
//    
//    module base_plate() {
//        plate_map = []; // Empty map
//        process(layout, plate_map, missing_child_idx=0) {
//            block([pin_width, pin_width, pin_insert_thickness] + allowances, center=BELOW);
//        }
//    }
//    
//    
//    module pin_inserts() {
//        module pin(fraction) {
//            block([pin_width, pin_width, fraction*pin_length], center=ABOVE);
//        }
//        
//        map =  concat(
//            [
//                ["█", 0],
//                ["▆", 1],
//                ["▄", 2],
//                ["▂", 3], 
//                ["▁", 4],
//                ["╬", 0],
//                ["║", 0],
//                ["═", 0],
//                ["◐", 5],
//                ["◑", 6],
//                ["◓", 7],
//                ["◒", 8],       
//            ]
//        );
//        
//        //log_v1("map", map,verbosity, DEBUG, IMPORTANT);
//        process(layout, map) {
//            pin(1);
//            pin(3/4);
//            pin(1/2);
//            pin(1/4);
//            pin(1/8);
//            pin_latch(0.50, LEFT);
//            pin_latch(0.50, RIGHT);
//            pin_latch(0.50, BEHIND);
//            pin_latch(0.50, FRONT);
//        } 
//    }       
//    
//
//    
//    
//
//    module clearances() {
//        /*    
//            ╋     Pin and wire clearance, both directions
//            ┃     Pin and wire clearance vertical
//            ━     Pin and wire clearance horizontal
//            ╬║═   Wire access in particular directions
//                  through pin body
//            ┼│─   Wire access in particular directions
//
//        */
//        symbols = "╋━┃╬═║┼─│╷╵╴╶";
//        
//        map = [for (i = [0:len(symbols)-1]) [symbols[i], i]];
//            
//        log_v1("map", map, verbosity, DEBUG);
//        
//
//        PIN_PASS_THROUGH = true;
//        NO_PIN_PASS_THROUGH = false;
//        
//        process(layout, map) {
//            clearance(PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
//            clearance(PIN_PASS_THROUGH, [LEFT, RIGHT]);
//            clearance(PIN_PASS_THROUGH, [FRONT, BEHIND]);
//            // Clearance through pin body
//            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
//            clearance(NO_PIN_PASS_THROUGH, [LEFT, RIGHT]);
//            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND]);
//            // Clearance through pin body
//            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
//            clearance(NO_PIN_PASS_THROUGH, [LEFT, RIGHT]);
//            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND]); 
//            
//            clearance(NO_PIN_PASS_THROUGH, [FRONT]);
//            clearance(NO_PIN_PASS_THROUGH, [BEHIND]);
//            clearance(NO_PIN_PASS_THROUGH, [LEFT]);
//            clearance(NO_PIN_PASS_THROUGH, [RIGHT]);            
//        } 
//        
//        module clearance(pass_through, openings) {
//            if (pass_through) {
//                clearance_allowances = pin /4;
//                block(pin + clearance_allowances + [0, 0, 2*pin_length]);
//            }
//            for (opening = openings) {
//                wire_clearance(opening);
//            }
//        }  
//        module wire_clearance(opening) {
//            wd = dupont_wire_diameter();
//            a_lot = 4*pin_length;
//            hull() {
//                block([pin_width/2, wd, a_lot], center=opening, rank=10);
//                can(d=wd, h=a_lot, $fa=12); 
//            }
//        }        
//    }
//
    function split_no_separators(string) = 
        assert(is_string(string))
        let(a =  split(string, " ")) 
        [ for (item = a) if (item != "") item];
//    
//    
//    
//    function pattern_to_map(layout, idx)  = [
//            for (cmd = layout) if (cmd != " ") [cmd, idx]
//        ];
//
//    module locate(i, j) {
//        x = i * pin_width;
//        y = j * pin_width;
//        translate([x, y, 0]) children();
//    }
//    
//    module process(layout, map_cmd_to_child, missing_child_idx) {
//        for (i = [0 : len(layout) -1]) {
//            row = layout[i];
//            for (j = [0 : len(row) -1]) {
//                cmd = row[j];              
//                found_idx = find_in_dct(map_cmd_to_child, cmd);
//                idx = !is_undef(found_idx) ? found_idx : missing_child_idx;
//                if (!is_undef(idx)) {
//                    locate(i, j) {
//                        children(idx);
//                    } 
//                } 
//            }
//        }
//    }

}


module x_placement(index) {
    dx_spacing = 20;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

