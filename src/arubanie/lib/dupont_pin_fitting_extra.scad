use <dupont_pin_fitting.scad> 

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


function match_pattern(pattern_name) = 
    pattern_name == "None" ? undef :
    pattern_name == "all_symbols" ? all_symbols() :
    pattern_name == "all_pattern" ? all_pattern() :
    pattern_name == "test_latches" ? test_latches() :
    pattern_name == "pin_retention_key" ? pin_retention_key() :
    assert(false, assert_msg("Unable to find pattern: ", pattern_name) ); 
    
    

/* [4 x 4 Four Development] */
show_4x4_plug_ = true;
show_4x4_socket_for_print_ = true;
show_4x4_socket_mated_ = true;
show_4x4_mocks_ = true;

pattern_ = match_pattern(pattern__);
mated_pattern_  = match_pattern(mated_pattern__);    

base_thickness_ = 2; //[0: No plate, 1, 1.5, 2]

module end_customization() {}

// Relative strength of latch - scaled height of catch
latch_strength_ = 0.0; // [-1: 0.01 : 1]
// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]

f_ = 0; // [0:0.05:2]

function all_pattern() = "
       █░█  ;
       █╳█  ;
       ███  ;
       ███ ███ ███ ;
       █▤█ █▥█ █▦█ ;
       ███ ███ ███;;
       ;
       ▁▂▄▆█ ; 
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


        
