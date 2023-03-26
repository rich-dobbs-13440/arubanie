/*

use <lib/dupont_pins.scad>

w_h = DUPONT_HOUSING_WIDTH();
l_hsg_std = DUPONT_HOUSING_WIDTH();
l_h_short = DUPONT_SHORT_HOUSING();

l_hdr = function DUPONT_HEADER() = 2.5; 
l_hdr_clrnc =  DUPONT_HEADER_CLEARANCE();
l_pin = function DUPONT_PIN_LENGTH();
w_pin =  DUPONT_PIN_SIZE();
d_wire = DUPONT_WIRE_DIAMETER();

dupont_connector(
    wire_color="yellow", 
    housing_color="black",         
    center=ABOVE,
    housing=DUPONT_STD_HOUSING(),
    has_pin=false);

*/
include <centerable.scad>
use <shapes.scad>


/* [Housing Length] */

housing_ = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

/* [Show] */
show_top_level = false;
show_only_one = false;
one_to_show = -10; // [-10: "Customized pin holder", -9:"9 as designed", -8, -7:" male_pin_holder(show_mock=false)", -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8]

delta_ = 10;

/* [Pin Holder Customization] */

use_default_integral_female_cph = false;
integral_female_cph_ = false; 

use_default_integral_male_cph = false;
integral_male_cph_ = false;

use_default_show_mock_cph = false;
show_mock_cph_ = true;

use_default_x_spring_cph = false;
x_spring_cph_ = 8; // [0:1:10]

use_default_z_spring_cph = false;
z_spring_cph_ = 1.5; // [0: 0.01 : 2.54]

use_default_x_stop_cph = false;
x_stop_cph_ = 0;

use_default_d_pin_dpm_clearance_cph = false;
d_pin_dpm_clearance_cph_ = 0.4; 

use_default_clearance_fraction_cph = false;
clearance_fraction_cph_ = 0.1;



use_default_color_name_cph = false;
color_name_cph_  = "orange";

use_default_alpha_cph  = false;;
alpha_cph_  = 1; 

module end_customization() {}






function DUPONT_HOUSING_WIDTH() = 2.54; // Tenth of an inch
function DUPONT_HOUSING_WALL() = 0.3;
function DUPONT_STD_HOUSING() = 14.0; //mm
function DUPONT_SHORT_HOUSING() = 12.0; // mm
function DUPONT_HEADER() = 2.5; // mm
function DUPONT_HEADER_CLEARANCE() = 0.2; // mm
function DUPONT_PIN_LENGTH() = 7.8; // mm
function DUPONT_PIN_SIZE() = 0.7; // mm
function DUPONT_WIRE_DIAMETER() = 1.0; // mm




module x_position(idx) {
    if (show_top_level) {
        if (show_only_one) {
            if (idx == one_to_show) {
                children();
            }
        } else {
            translate([delta_*idx, 0, 0]) children();
        }
    }
}

// Usage Demo:

x_position(0) dupont_connector(housing=housing_);
x_position(1) dupont_connector();
x_position(2) dupont_connector(has_pin=true);
x_position(3)  dupont_connector("chartreuse", "salmon", ABOVE, DUPONT_SHORT_HOUSING());
x_position(4) dupont_connector(
        wire_color="pink", 
        housing_color="blue",         
        center=LEFT,
        housing=DUPONT_STD_HOUSING(),
        has_pin=true);

x_position(-1) rotate([0, 0, 90]) 
    male_pin(); 

x_position(-2) rotate([0, 0, 90]) 
    male_pin(
        pin = false, 
        strike = false,
        detent = false, 
        barrel = false,
        conductor_wrap = false,
        insulation_wrap = 0, 
        strip=false); 
        
x_position(-3) rotate([0, 0, 90]) 
    male_pin(
        pin = false, 
        strike = false,
        detent = false, 
        barrel = false,
        conductor_wrap = false,
        insulation_wrap = 0.5, 
        strip=false);       
        
x_position(-4) rotate([0, 0, 90]) 
    male_pin(insulation_wrap=0.75);
    
x_position(-5) rotate([0, 0, 90]) 
    male_pin_holder(show_mock=true, z_spring=2);
    
x_position(-6) rotate([0, 0, 90]) 
    male_pin_holder();

x_position(-7) rotate([0, 0, 90])
    male_pin_holder(show_mock=false);
    
x_position(-9) 
    male_pin_holder();

x_position(-10) 
    // Customized pin holder
    pin_holder(
        integral_female = integral_female_cph,
        integral_male = integral_male_cph,
        show_mock = show_mock_cph,
        x_spring = x_spring_cph, 
        z_spring = z_spring_cph, 
        x_stop = x_stop_cph, 
        d_pin_dpm_clearance = d_pin_dpm_clearance_cph, 
        clearance_fraction = clearance_fraction_cph,
        color_name = color_name_cph, 
        alpha = alpha_cph);    





/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
l_pin_strip = 115.1;
pin_count = 20;
delta_pin_strip = l_pin_strip / (pin_count -1);    

/* [Pin Measurements] */

/*
    Parts of a pin as I've named them

    pin

    strike
    detent
    barrel 
    conductor_wrap
    insulation_wrap
    the strip with a hole in it.

*/

    wire_diameter = 1.66; // Includes insulation
    d_wire_conductor = 1.13;
    exposed_wire = 2.14; 
    
    
    d_pin_dpm = 0.6; 
    x_pin_dpm = 6.62;
    z_metal_dpgn = 0.2;
    // The strike is what keeps the pin from being removed from the housing 
    x_strike_dpm = 3.22;
    y_strike_dpgn = 1.75;
    z_strike_dpgn = 1.80;
    x_strike_dpf = 0.9;
    // The detent is the area that can be caught by something to retain the housing 
    x_detent_dpgn =  0.8;
    y_detent_dpgn = 1.65;
    z_detent_dpgn = 0.56;
    x_barrel_dpgn = 2.79;
    od_barrel_dpgn = 1.55;
    x_conductor_wrap_dpgn = 3.79;
    y_conductor_wrap_dpgn = 2.00;
    z_conductor_wrap_dpgn = 1.73;
    x_insulation_wrap_dpgn = 2.18;
    y_insulation_wrap_dpgn = 2.88;
    z_insulation_wrap_dpgn =  2.46;
    y_insulation_wrap_bottom_dpgn = 1.58;
    x_strip_dpgn = 2.22;
    y_strip_dpgn = delta_pin_strip;
    z_strip_dpgn = z_metal_dpgn;
    d_strip_dpgn = 1.4;
    
    dx_detent_dpgn = x_strike_dpm;
    dx_barrel_dpgn = dx_detent_dpgn + x_detent_dpgn;
    dx_conductor_wrap_dpgn = dx_barrel_dpgn + x_barrel_dpgn;
    dx_insulation_wrap_dpgn = dx_conductor_wrap_dpgn + x_conductor_wrap_dpgn;
    dx_strip_dpgn = dx_insulation_wrap_dpgn + x_insulation_wrap_dpgn;
    dx_strip_hole_dpgn = dx_strip_dpgn + x_strip_dpgn/2;
    
    x_pin_to_strip_edge = dx_strip_hole_dpgn + x_strip_dpgn;
    
    
    

module dupont_connector(
        wire_color = "yellow", 
        housing_color = "black",         
        center = ABOVE,
        housing = DUPONT_STD_HOUSING(),
        has_pin = false, 
        has_wire = true) {
            
    pin_cavity = [
        DUPONT_HOUSING_WIDTH() - 2*DUPONT_HOUSING_WALL() , 
        DUPONT_HOUSING_WIDTH() - 2*DUPONT_HOUSING_WALL() ,
        DUPONT_STD_HOUSING()
    ]; 
        
            
    center_rotation(center) {  
        center_rotation(BELOW) { 
            difference() {   
                union() {
                    color(housing_color) block([DUPONT_HOUSING_WIDTH(), DUPONT_HOUSING_WIDTH(), housing], center = ABOVE, rank=10);
                    if (has_wire) {
                        color(wire_color) can(d=DUPONT_WIRE_DIAMETER(), h = housing + 8, center=ABOVE, rank=-3);
                    }
                }
                if (!has_pin) {
                    can(d=DUPONT_PIN_SIZE() + 0.5, h = 0.1, taper=DUPONT_PIN_SIZE(), center=ABOVE, rank = 15);
                    can(d=d_pin_dpm + 0.3, h = x_pin + 1);
                    translate([0, 0, d_pin_dpm]) block(pin_cavity, center=ABOVE);
                }
                
            }
            
            if (has_pin) {
                // For headers should make it square!
                color("silver") can(d=DUPONT_PIN_SIZE(), h = DUPONT_PIN_LENGTH(), center=BELOW);
            }
        }
    } 
           
}

module female_pin(        
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true, 
        alpha=1) { 
    
    _generic_pin_dp(
        pin = false,
        strike = strike,
        detent = detent, 
        barrel = barrel,
        conductor_wrap = conductor_wrap,
        insulation_wrap = insulation_wrap, 
        strip = strip , 
        alpha);        
}

module male_pin(
        pin = true, 
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true, 
        alpha=1) {

    _generic_pin_dp(
        pin = pin,
        strike = strike,
        detent = detent, 
        barrel = barrel,
        conductor_wrap = conductor_wrap,
        insulation_wrap = insulation_wrap, 
        strip = strip , 
        alpha = alpha);           
}

module _generic_pin_dp(
        pin,
        strike,
        detent, 
        barrel,
        conductor_wrap,
        insulation_wrap, 
        strip, 
        alpha) {
                
            

    // Initially model pin before construction with pin on x_axis,
    // with the pin itself negative, and the parts used in assembly
    // increasing in the x domain.abs
    module wing(base, tip) {
        module bottom() {
            translate([0, base.y/2, -base.z]) rod(d=z_metal_dpgn, l=base.x); 
        }  
        module top() {
            translate([0, tip.y/2, tip.z]) rod(d = z_metal_dpgn, l = tip.x);                
        }
        translate([base.x/2, 0, 0]) {

            center_reflect([0, 1, 0]) { 
                hull() {
                    top();
                    bottom();
                }
            } 
            hull() {
                center_reflect([0, 1, 0]) bottom();  
            }
        }      
    } 
    
    module strike(is_male) {
        extent = [x_strike_dpm, y_strike_dpgn, z_strike_dpgn];
        if (is_male) {
            hull() {
                translate([x_strike_dpm/2, 0, -z_strike_dpgn/2]) 
                    block([x_strike_dpm/2, y_strike_dpgn, z_metal_dpgn], center=ABOVE+FRONT);
                rod(d=d_pin_dpm, l=0.01, center=FRONT);
                block([z_metal_dpgn, z_metal_dpgn, z_metal_dpgn], center=FRONT);
                translate([x_strike_dpm, 0, 0]) block([0.01, y_strike_dpgn, z_strike_dpgn], center=BEHIND);
            }
        } else {
            translate([dx_detent_dpgn, 0, 0])  block([x_strike_dpf, y_strike_dpgn, z_strike_dpgn], center=BEHIND);
        }
        
        //block(strike, center=FRONT);
    }
    module detent() {    
        bottom = [
            x_detent_dpgn,
            y_detent_dpgn,
            z_detent_dpgn
        ];
        
        translate([dx_detent_dpgn, 0, -y_detent_dpgn/2]) block(bottom, center=FRONT + ABOVE);
  
    }
    module barrel() {  
        translate([dx_barrel_dpgn, 0, 0])
            rod(d=od_barrel_dpgn, l=x_barrel_dpgn, hollow=od_barrel_dpgn-2*z_metal_dpgn, center=FRONT);
    }
    
    module conductor_wrap() {
        extent = [x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_conductor_wrap_dpgn];
        
        translate([dx_conductor_wrap_dpgn, 0, 0]) 
            wing(
                [x_conductor_wrap_dpgn, wire_diameter, od_barrel_dpgn/2], 
                [0.8*x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_conductor_wrap_dpgn - od_barrel_dpgn/2]); 
    }
    module insulation_wrap() {
        translate([dx_insulation_wrap_dpgn, 0, 0]) 
            wing(
                [x_insulation_wrap_dpgn, wire_diameter, od_barrel_dpgn/2], 
                [0, (1-insulation_wrap)*y_insulation_wrap_dpgn, z_insulation_wrap_dpgn - od_barrel_dpgn/2]);         
    } 
    module strip() {
        translate([dx_strip_dpgn, 0, -z_insulation_wrap_dpgn/2+2*z_metal_dpgn])
            difference() {
                block([x_strip_dpgn, y_strip_dpgn, z_metal_dpgn], center=FRONT);
                translate([x_strip_dpgn/2, 0, 0]) can(d=d_strip_dpgn, h=5);
            }
    }
    is_male = is_bool(pin) && pin;
    color("silver", alpha=alpha) {
       
        if (is_male) {
            rod(d=d_pin_dpm, l=x_pin_dpm, center=BEHIND);
        }
        if (strike) {
            strike(is_male);
        }
        if (detent) {
            detent();
        }
        if (barrel) {
            barrel();
        }
        if (is_num(conductor_wrap) || (is_bool(conductor_wrap) && conductor_wrap))  {            
            conductor_wrap();
        }
        if (is_num(insulation_wrap) || (is_bool(insulation_wrap) && insulation_wrap))  {             
            insulation_wrap(); 
        }
        if (strip) {
            strip();
        }
    }  
}


module pin_holder_screws(as_screw=false, as_hole_threaded=false, as_hole_through=false) {
    module process() {
        for (x = [2 : 4 : 14]) {
            translate([-x, 0, -3]) rotate([90, 0, 0]) children(); 
        }
    }
    if (as_hole_through) {
        process() translate([0, 0, 25]) hole_through("M2", cld=0.4);
    }
        
    if (as_hole_threaded) {
        process() translate([0, 0, 12.5]) hole_threaded("M2");
    }
    if (as_screw) {
        stainless() process() translate([0, 0, +2.54/2]) screw("M2x6");
    }
}

integral_female_default_cph = false;
integral_male_default_cph  = false;
show_mock_default_cph = true; 
x_spring_default_cph  = 5; 
z_spring_default_cph  = 1; 
x_stop_default_cph  = dx_barrel_dpgn;
d_pin_dpm_clearance_default_cph  = 0.4; 
clearance_fraction_default_cph = .1; 
color_name_default_cph = "orange"; 
alpha_default_cph  = 1;

integral_female_cph = use_default_integral_female_cph ? integral_female_default_cph : integral_female_cph_;
integral_male_cph = use_default_integral_male_cph ? integral_male_default_cph : integral_male_cph_;
show_mock_cph = use_default_show_mock_cph ? integral_female_default_cph : show_mock_cph_;
x_spring_cph = use_default_x_spring_cph  ?  x_spring_default_cph :  x_spring_cph_;
z_spring_cph = use_default_z_spring_cph  ?  z_spring_default_cph :  z_spring_cph_;
x_stop_cph = use_default_x_stop_cph  ?  x_stop_default_cph :  x_stop_cph_;
d_pin_dpm_clearance_cph = use_default_d_pin_dpm_clearance_cph  ?  d_pin_dpm_clearance_default_cph :  d_pin_dpm_clearance_cph_;
clearance_fraction_cph = use_default_clearance_fraction_cph  ?  clearance_fraction_default_cph :  clearance_fraction_cph_;

color_name_cph = use_default_color_name_cph  ?  color_name_default_cph :  color_name_cph_;
alpha_cph = use_default_alpha_cph  ?  alpha_default_cph :  alpha_cph_;


module pin_latch(
        width, z_clearance = 1, color_name = "FireBrick", color_alpha = 1, show_mock = true, mock_is_male = true) {
            
            
    s = DUPONT_HOUSING_WIDTH(); 
    body = [2*s, width, 2*s];
    dx = (dx_detent_dpgn + dx_barrel_dpgn)/2;  // Center over detent
    dz_release = body.z/2 + s/2 + z_clearance;
    color(color_name, color_alpha) {
        
        difference() {
            union() {
                translate([dx, 0, dz_release]) block(body);
                translate([0, 0, dz_release]) block(body, center=FRONT);
                hull() {
                    translate([dx, 0, s/2]) block([x_detent_dpgn, width, z_clearance], center=ABOVE);
                    translate([dx, 0, -.25]) block([x_detent_dpgn/2, width, s/2 + 0.25 ], center=ABOVE); 
                }
            }
            translate([dx, -25, dz_release]) rotate([90, 0, 0]) hole_through("M2", cld=0.4);
            // bevel to make it easier for pin to enter
            translate([dx, 0, 0]) rod(d=d_pin_dpm+0.5, taper=d_pin_dpm+1.5, l=1, $fn=12, center=CENTER);
        }

    }
    if (show_mock) { 
        if (mock_is_male) {
            male_pin();
        } else {
            female_pin();
        }
    }
}    
    

    

module pin_holder(
        integral_female = integral_female_default_cph,
        integral_male = integral_male_default_cph,
        show_mock = show_mock_default_cph,
        mock_is_male=true,
        x_spring = x_spring_default_cph, 
        z_spring = z_spring_default_cph, 
        z_pin_catch = 0.2,
        x_stop = x_stop_default_cph, 
        d_pin_dpm_clearance, 
        clearance_fraction = d_pin_dpm_clearance_default_cph, 
        color_name = color_name_cph, 
        alpha = alpha_default_cph) { 
            
    if (show_mock) {
        dupont_connector(center=BEHIND, has_pin=true);
    }     
    
    s = DUPONT_HOUSING_WIDTH(); 
    hsg_l = DUPONT_STD_HOUSING();
    wall = 1;    
    width = s + wall;     
    
    housing_std_dpg = [hsg_l, s, s];
    walls = 2*[wall, wall, wall];
    housing_clearance = 0.2;
    housing_clearances = 2*[housing_clearance, housing_clearance, housing_clearance];
    body = housing_std_dpg + housing_clearances + walls; 
    alot = 10;
    d_pin_catch = wall + z_pin_catch;
            
    spring = [x_spring, body.y, z_spring];
            
    spring_gap = 1;        
    pin_latch(width = body.y, z_clearance = body.z/2 - s/2 + spring_gap, show_mock = false, mock_is_male=mock_is_male);
            
    color("green") translate([0, 0, body.z/2 + spring_gap])  block(spring, center=ABOVE+BEHIND);  
    color("blue") translate([-x_spring, 0, body.z/2])  block([2, spring.y, spring.z+spring_gap], center=ABOVE+BEHIND);      
    difference() {
        color("yellow", alpha=0.25) { 
            translate([wall, 0, 0]) block(body, center = BEHIND);  
        }
        block(housing_std_dpg + housing_clearances + [alot, 0, 0], center = BEHIND);
        block(.9*housing_std_dpg);
    }
    
    translate([-hsg_l - 2*housing_clearance, 0, s/2 + housing_clearance]) { // s/2 - wall]
        difference() {
            color("pink") rod(d=d_pin_catch, l=body.y, center=SIDEWISE, rank=5);
            plane_clearance(FRONT+BELOW);
        }
    }
    

        


    
}


module old_pin_dpm_holder(
        integral_female = integral_female_default_cph,
        integral_male = integral_male_default_cph,
        show_mock = show_mock_default_cph,
        x_spring = z_spring_default_cph, 
        z_spring = z_spring_default_cph, 
        x_stop = x_stop_default_cph, 
        d_pin_dpm_clearance = d_pin_dpm_clearance_default_cph, 
        clearance_fraction = d_pin_dpm_clearance_default_cph, 
        color_name = color_name_cph, 
        alpha = alpha_default_cph) {
    
//    assert(!is_undef(x_stop));
//    assert(!is_undef(z_spring));
//    assert(!is_undef(show_mock));
//            
//    external_pin = !integral_female && !integral_male;
//    assert(!(integral_female && integral_male), 
//            assert_msg(
//                "Can't be both male and female at the same time.", 
//                " integral_female: ", str(integral_female), 
//                " integral_male: ", str(integral_male)));
//    
//    wall = 1;
//    housing_clearance = external_pin ? 0.2 : 0;     
//    body_x = external_pin ? 18: DUPONT_SHORT_HOUSING();
//    body_y = DUPONT_HOUSING_WIDTH() + (external_pin ? 2*wall + 2* housing_clearance : 0);
//    body_z =  DUPONT_HOUSING_WIDTH();
//    body = [body_x, body_y, body_z];
//    spring = [x_spring, body.y, z_spring];
//    translation_spring = [0, 0, body.z/2+0.5];
//    stop_body = [x_stop, body.y, body.z];
//    
//    screw_body = [body.x, body.y, 1.5*body.z - housing_clearance]; 
//    
//    shelf = [x_strike_dpf, body.y, body.z/2 - od_barrel_dpgn/2 + 1.5* DUPONT_HOUSING_WIDTH() ];
//    base = [body.x-spring.x, 1, 2*translation_spring.z+2];
//    
//    module pin_clearance() {
//        rod(d=d_pin_dpm+d_pin_dpm_clearance, l=100, $fn=12); 
//    }
//    
//
//    module colorize(detailed=true) {
//        if (detailed) {
//            children();
//        } else {
//            color(color_name, alpha) {
//                children();
//            }
//        }
//    }
//
//    colorize() {
//        difference() {
//            union() {
//                color("pink") latch();
//                
//                color("brown") 
//                    translate([0, 0, -od_barrel_dpgn/2]) 
//                        block(shelf, center=FRONT+BELOW);
//                
//                color("violet") 
//                    translate(translation_spring) { 
//                        block(spring, center=BEHIND+ABOVE);
//                        translate([-2, 0, 0]) block(spring, center=BEHIND+ABOVE);
//                    }
//                
//                color("blue") 
//                    translate([0, 0, -2*body.z]) 
//                        block(screw_body, center=ABOVE+BEHIND);
//                
//                color("green")
//                    translate([0, 0, -body.z/2]) 
//                        block(stop_body, center=BELOW+FRONT); 
//                
//                if (!external_pin) {
//                    dupont_connector( 
//                        housing = DUPONT_SHORT_HOUSING(), 
//                        center=BEHIND, 
//                        has_wire=false);
//                }
//                
//                color("tomato")
//                    translate([-spring.x, -body.y/2, 0]) 
//                        block(base, center=BEHIND+RIGHT);  
//              
//                 color("salmon")
//                    translate([-spring.x, -body.y/2, base.z/2])
//                        block([base.x, body.y, wall], 
//                        center=BEHIND+RIGHT+BELOW);
//                
//            }
//            if (external_pin) {
//                // If external pin, create a slot for the wire at the back of the pin
//                hull() {
//                    translate([-10, 0, 0]) rod(d=DUPONT_WIRE_DIAMETER(), l=body.x+5, center=BEHIND);
//                    translate([-10, 5, 0])rod(d=DUPONT_WIRE_DIAMETER(), l=body.x+5, center=BEHIND);
//                } 
//            } else {
//                rod(d=d_pin_dpm, taper=d_pin_dpm+1, l=1, $fn=12, center=FRONT);
//            }
//
//            
//            
//            
//            pin_holder_screws(as_hole_through=true);
//        }
//
//    }
//    if (show_mock) {
//        //male_pin();
//        if (external_pin) {
//            dupont_connector(housing_color="Lime", center=BEHIND, has_pin=true);
//        }
//        pin_holder_screws(as_screw=true);
//    }    
}





module male_pin_holder(
        show_mock=true, 
        z_spring = 2.54, 
        x_stop = dx_barrel_dpgn, 
        d_pin_dpm_clearance = 0.4, 
        clearance_fraction=.1, 
        z_column=0, 
        dx_column=0, 
        latch_release_diameter = 2,
        external_pin = true, 
        latch_release_height = 2,
        color_name="orange", 
        alpha=1) {
//    
//    assert(!is_undef(z_column));
//    assert(!is_undef(x_stop));
//    assert(!is_undef(z_spring));
//    assert(!is_undef(show_mock));
//    
//    body = [16, 2.54, 2.54];
//    pin_body = [14, 2.54, 2.54];       
//    x_split = 7;
//    z_split = 0.0;
//
//    latch_x = x_detent_dpgn * (1-clearance_fraction);
//    latch_dx = (x_detent_dpgn * clearance_fraction)/2;
//    latch = [latch_x, body.y, body.z/2 + z_spring];
//    spring = [
//        body.x + x_strike_dpf + x_detent_dpgn,
//        body.y,
//        z_spring];
//            
//    split = [x_split, 10, z_split];
//    split_front = [1, 10, body.z/2 + z_split];
//    
//    stop_body = [x_stop, body.y, body.z];
//    screw_body = [body.x, body.y, 2*body.z]; 
//    column = [body.y, body.y, z_column];
//    
//    
//    module pin_clearance() {
//        rod(d=d_pin_dpm+d_pin_dpm_clearance, l=100, $fn=12); 
//    }
//
//    color(color_name, alpha) {
//        //render(convexity=10) 
//        difference() {
//            union() {
//                block(body, center=BEHIND);
//                shelf = [x_strike_dpf, body.y, 2.54/2-od_barrel_dpgn];
//                block(shelf, center=FRONT);
//                
//                translate([-body.x, 0, body.z/2]) 
//                    block(spring, center=ABOVE+FRONT);
//                
//                translate([0.75*x_strike_dpf, 0, 0.75*body.z]) 
//                    rod(
//                        d=latch_release_diameter, 
//                        l = body.y/2 + latch_release_height, 
//                        center=SIDEWISE+RIGHT+ABOVE, 
//                        $fn=12);
//                
//                translate([x_strike_dpf + latch_dx, 0, 0]) 
//                    block(latch, center=ABOVE+FRONT);
//                     
//                block(screw_body, center=BELOW+BEHIND);
//                
//                translate([0, 0, -body.z/2]) 
//                    block(stop_body, center=BELOW+FRONT);                 
//                
//                translate([dx_column, -body.y/2, -body.z/2]) 
//                    block(column, center=RIGHT+FRONT+BELOW);
//                
//            }
//            if (external_pin) {
//                block(pin_body, center=BEHIND);
//            } else {
//                pin_clearance();
//                
//                // Bevel to make entrance easier!
//                rod(d=d_pin_dpm, taper=d_pin_dpm+1, l=1, $fn=12, center=BEHIND);
//            }
//            
//            translate([1, 0, 2]) block(split, center=BEHIND+BELOW);
//            block(split_front, center=FRONT+ABOVE);
//            
//            pin_holder_screws(as_hole_through=true);
//        }
//
//    }
//    if (show_mock) {
//        //male_pin();
//        //translate([-14, 0, 0]) rotate([0, 90, 0]) 
//        //dupont_connector(housing_color="Lime", center);
//        pin_holder_screws(as_screw=true);
//    }
}

