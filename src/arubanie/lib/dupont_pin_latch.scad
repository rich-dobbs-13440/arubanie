include <centerable.scad>
use <dupont_pins.scad>
use <shapes.scad>



/* [Show] */ 

show_customization = true;
show_mate = true;
show_default = true;
show_mated_default = true;
/* [Pin Latch] */  

pin_width = DUPONT_HOUSING_WIDTH();
pin_length = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

// The amount of engagement in the catch as a fraction of the width
catch_width_ = 0.125; //[-.50: 0.01 : 1]

// In pin widths
catch_height_ = 0.5 ; //[0: 0.01 : 1]

// As a fraction of the width
leading_width_ = 0.33; //[0: 0.05 : 0.50]

// In pin widths
leading_height_ =  0.5; //[0: 0.05 : 2]

// Distance between parts in mm
clearance_ = 0.2; // [0 : 0.05 : 0.5]

fraction_pin_length = 0.5; // [0 : 0.125 : 1.0]

origin__ = "ABOVE"; // [CENTER, ABOVE]
origin_ = 
    origin__ == "CENTER" ? CENTER :
    origin__ == "ABOVE" ? ABOVE :
    assert(false);
     
opening__ = "FRONT"; // [LEFT, RIGHT, FRONT, BEHIND]
opening_ = center_str_to_center(opening__);

module end_customization() {}


module x_placement(index) {
    dx_spacing = 5;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}    


x_placement(0) {
    if (show_customization) {
        dupont_pin_latch(
            fraction_pin_length, 
            opening = opening_,
            origin = origin_, 
            catch_width = catch_width_,
            catch_height = catch_height_,
            leading_width = leading_width_,
            leading_height = leading_height_,
            clearance = clearance_);
        color("red", alpha=0.1) dupont_connector();
    }
}



module centered_latch(fraction_pin_length) {
    dupont_pin_latch(
        fraction_pin_length, 
        opening = opening_,
        origin = CENTER, 
        catch_width = catch_width_,
        catch_height = catch_height_,
        leading_width = leading_width_,
        leading_height = leading_height_,
        clearance = clearance_);
}
    
x_placement(1) {
    if (show_mate) {
        translate([0, 0, fraction_pin_length*pin_length]) {
            centered_latch(fraction_pin_length);
            rotate([0, 180, 0]) centered_latch(1-fraction_pin_length);
        }
        color("blue", alpha=0.25) block([pin_width, pin_width, pin_length/2], center=ABOVE);
    }
}

x_placement(2) {
    if (show_default) {
        dupont_pin_latch();
    }   
}

x_placement(3) {
    if (show_mated_default) {
        dupont_pin_latch(origin=CENTER);
        rotate([0, 180, 0]) dupont_pin_latch(origin=CENTER); 
        color("red", alpha=0.25) block([pin_width, pin_width, pin_length]);
    }   
}


module dupont_pin_latch(
        fraction_pin_length=0.5, 
        opening=FRONT, 
        origin=ABOVE,
        catch_width = 1/8, // In pin widths
        catch_height = 1/2, // In pin widths
        leading_width = 1/3, // In pin widths 
        leading_height = 1/2, // In pin widths,
        clearance = 0.2, // In mm
        width = DUPONT_HOUSING_WIDTH(),
        housing = DUPONT_STD_HOUSING()
        ) {
    pin_width = width;
    pin_length = housing;

    latch_length = fraction_pin_length*pin_length;
    
    z_translation = 
        (origin == undef || origin == ABOVE) ? latch_length :
        origin == CENTER ?  0 : //-latch_length :
        assert(false, assert_msg("Bad origin: ", origin, " Should be ABOVE or CENTER"));
    origin_translation = [0, 0, z_translation]; 
    
    opening_rotation = 
        opening == LEFT ? [0, 0, 90] :
        opening == RIGHT ? [0, 0, 270] :
        opening == FRONT ? [0, 0, 180] :
        opening == BEHIND ? [0, 0, 0] :
        
        assert(false, assert_msg("Bad opening: ", opening, " Should be LEFT, RIGHT, FRONT, or BACK"));
    
    
    translate(origin_translation) {
        rotate(opening_rotation) {
            pin_latch_as_designed();
        }
    }
    
    module pin_latch_as_designed() {
        // Origin is at mid point of the catch, opening BEHIND

        z_leading = leading_height * pin_width;
        leading = [
            leading_width * pin_width, 
            pin_width, 
            z_leading
        ];
        z_catch = catch_height*pin_width;
        catch = [
            (0.5+catch_width)*pin_width, 
            pin_width, 
            z_catch
        ];
        z_catch_complement = z_catch + z_leading + 4*clearance;
        catch_complement = [
            (0.5-catch_width)*pin_width-clearance, 
            pin_width, 
            z_catch_complement
        ];
        
        z_to_catch = fraction_pin_length*pin_length;
        z_back = z_to_catch - z_catch_complement + clearance;
        
        back = [
            pin_width,
            pin_width,
            z_back
        ];
        cleared_catch_height = catch_height*pin_width + clearance;
        
        translate([0, 0, cleared_catch_height]) {
            hull() {
                translate([pin_width/2, 0, 0]) block(leading, center=BEHIND+ABOVE);
                translate([pin_width/2, 0, 0]) block(catch, center=BEHIND+BELOW);
            }
        }
        translate([pin_width/2, 0, clearance]) block(catch_complement, center=BEHIND+BELOW);
        translate([0, 0, -z_catch_complement+clearance]) block(back, center=BELOW);
    }
}



