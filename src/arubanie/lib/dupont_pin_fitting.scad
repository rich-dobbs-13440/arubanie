include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
//include <TOUL.scad>
use <relativity/strings.scad>
use <dupont_pins.scad>
use <dupont_pin_latch.scad>

/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 
    


/* [Show] */

//orient_for_build_ = false;

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
    
//░▒
   
function all_pattern() = "
  ;
        ░╋░░┃░━░   ;
        ░░░░░░░░░    ;
        ███    ;
        █╳██    ;
        ███    ;
        ░░░░░░░░░    ;
        ░╬░░║░░═░    ;
        ░░░░░░░░░    ;
        ░┼░░│░░─░    ;
        ░░░░░░░░░    ;
        ░╴╵╶╷░░░░    ;
        ▁▂▄▆█░░░░    ;
        ░◐░◑░◒░◓░    ;
    ";
   
function test_latches() = "
        ▆◐░    ;
        ◓╋◒    ;
        ░◑▆    ;
        ───    ;
        ▆◐░    ;
        ◓╋◒    ;
        ░◑▆    ;
    "; 
 


function potentiometer_housing_fitting() = "
        ▆◐▒▒▒◑▆  ;
        ◓╳╳╳╳╳◓ ;
        ▒╳╳╳╳╳▒  ;
        ▒╳╳╳╳╳▒  ;
        ▒╳╳╳╳╳▒  ;
        ◒╳╳╳╳╳◒  ;
        ▆◐▒▒▒◑▆ ;
    ";  
  
function all_symbols() = "█▆▄▂▁◐◑◒◓╋━┃╬═║┼─│╷╵╴╶░";   



module x_placement(index) {
    dx_spacing = 50;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}


if (show_fitting) {
    x_placement(0) {
        dupont_pin_fitting(
            pattern = pattern_,
            base_thickness = base_thickness_); 
    } 
}



if (show_mate) {
    x_placement(1) {
        dupont_pin_fitting(
            pattern = mated_pattern_, 
            base_thickness = base_thickness_); 
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
           ◑▆░▆◐ ;
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


function pin_retention_key() = "      
        ▁▂▄▆█  ; // Pin inserts with various height
        ╋      ; // Pin and wire clearance, both directions
        ┃      ; // Pin and wire clearance vertical
        ━      ; // Pin and wire clearance horizontal
        ╬║═    ; // Wire access in particular directions through full blocks
        ┼│─    ; // Wire access passing through in particular
        ╴╵╶╷   ; // Wire access in particular directions
        ◐◑◒◓   ; // Latches with a particular orientation
        ░      ; // Bare plate

     ";


module dupont_pin_fitting(
        pattern,
        base_thickness = 2,
        allowance = 0.0, 
        center=0) {
       
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
    allowances = 2* [allowance, allowance, 0];
    

    layout = pattern_to_layout(pattern);
    log_v1("layout" , layout, verbosity, DEBUG);
    //echo("len(layout)", len(layout));
    function layout_extent(layout) = 
        let ( 
            row_count = len(layout),
            col_counts = [ for (line = layout) len(line)],
            col_max_count = max(col_counts),
            last = undef
        )
        [ row_count, col_max_count ];
            
    
    layout_extent = layout_extent(layout);
    
    handle_center(center, layout_extent);
    
    module handle_center(center, layout_extent) {
        
        pin_width = dupont_pin_width();


        if (center == 0) {
            fitting_at_center();
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
        // so, align to exactly at ABOVE_RIGHT
        translate([pin_width/2, pin_width/2, pin_width/2]) 
            fitting_as_generated();
    }
  
    module fitting_as_generated() {
        render() difference() {
            union() {
                base_plate();
                pin_inserts();
            }
            clearances();
        }
    }       
    
    
    
    

    module base_plate() {
        plate_symbols = "█▆▄▂▁◐◑◒◓╋━┃╬═║┼─│╷╵╴╶▒";
        plate_map = [ for (symbol = plate_symbols) [symbol, 0] ];            
        process(layout, plate_map, map_is_full=false) {
            block([pin_width, pin_width, base_thickness] + allowances, center=BELOW);
        }
    }
    
    module pin_inserts() {
        pin_symbols = "█▆▄▂▁◐◑◒◓╋━┃╬║═";
        pin_map = [for (i = [0:len(pin_symbols)-1]) [pin_symbols[i], i]];
        
        //log_v1("map", map,verbosity, DEBUG, IMPORTANT);
        process(layout, pin_map, map_is_full=true) {
            pin(1);
            pin(3/4);
            pin(1/2);
            pin(1/4);
            pin(1/8);
            dupont_pin_latch(0.50, opening=RIGHT);
            dupont_pin_latch(0.50, opening=LEFT);
            dupont_pin_latch(0.50, opening=BEHIND);
            dupont_pin_latch(0.50, opening=FRONT);
            pin(1/2);
            pin(1/2);
            pin(1/2);
            pin(1/4);
            pin(1/4);
            pin(1/4);            
        } 
        
        module pin(fraction) {
            block([pin_width, pin_width, fraction*pin_length], center=ABOVE);
        }        
    }       

    module clearances() {
        /*    
            ╋     Pin and wire clearance, both directions
            ┃     Pin and wire clearance vertical
            ━     Pin and wire clearance horizontal
            ╬║═   Wire access in particular directions
                  through pin body
            ┼│─   Wire access in particular directions

        */

        clearance_symbols = "╳╋━┃╬═║┼─│╷╵╴╶";  // TODO:    └ ┐ ┌ └ ├ ┬ ┤ ┣ ┫ ┓ ┏ ┛ ┗ ┳ ┻
        clearance_map = [for (i = [0:len(clearance_symbols)-1]) [clearance_symbols[i], i]];
        

        PIN_PASS_THROUGH = true;
        NO_PIN_PASS_THROUGH = false;
        
        process(layout, clearance_map, map_is_full=true) {
            clearance(PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND]);
            // Clearance through pin body
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND]);
            // Clearance through pin body
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [LEFT, RIGHT]);
            clearance(NO_PIN_PASS_THROUGH, [FRONT, BEHIND]); 
            
            clearance(NO_PIN_PASS_THROUGH, [FRONT]);
            clearance(NO_PIN_PASS_THROUGH, [BEHIND]);
            clearance(NO_PIN_PASS_THROUGH, [LEFT]);
            clearance(NO_PIN_PASS_THROUGH, [RIGHT]);            
        } 
        
        module clearance(pass_through, openings) {
            if (pass_through) {
                clearance_allowances = pin /4;
                block(pin + clearance_allowances + [0, 0, 2*pin_length]);
            }
            for (opening = openings) {
                wire_clearance(opening);
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
    }

    function pattern_to_layout(pattern) =
        assert(is_string(pattern))
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
    
    module process(layout, map_cmd_to_child, missing_child_idx, map_is_full) {
        if (map_is_full) { 
            assert(len(map_cmd_to_child) == $children);
        }
        for (i = [0 : len(layout) -1]) {
            row = layout[i];
            for (j = [0 : len(row) -1]) {
                cmd = row[j];              
                found_idx = find_in_dct(map_cmd_to_child, cmd);
                idx = !is_undef(found_idx) ? found_idx : missing_child_idx;
                if (!is_undef(idx)) {
                    locate(i, j) {
                        children(idx);
                    } 
                } 
            }
        }
    }

}
