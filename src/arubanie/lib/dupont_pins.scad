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
include <small_pivot.scad>




/* [Show] */
show_top_level = false;
show_only_one = false;
one_to_show = -10; // [-13:"customized_pin_holder_slide", -17:"customized wire holders", -7: "Customized pin holder", -4:"male_pin(insulation_wrap=0.75, orient=RIGHT)", -3:"Isolate insulation wrap - half closed", -2:"Isolate insulation wrap - closed", -1:" male_pin(orient=LEFT)", 0:"Selectable housing lengths for dupont connector", 1:"default dupont_connector()", 2:"dupont_connector(has_pin=true)",  4:"Custom colors for dupont connector", 7:"Male pin orientation", 10:"Female pin orientation"]

delta_ = 10; // [10:10:100]

/* [Lifter Design] */

z_offset_handle_screw = 8; // [0:0.5: 20]


/* [Wire Holder Design] */
z_pivot_dpwh = 6; // [4:0.5:8]

show_mock_dpwh = true;
show_body_dpwh = true;
show_clamp_dpwh = true;
orient_for_build_dpwh = false;
clamp_angle_dpwh = 0; // [0:5:90]




/* [Housing Length] */

housing_ = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]


/* [Pin Holder Customization] */
orient_for_build_cph = false; 
use_default_values_cph = false;
//This is how strong the spring should be.
z_spring_cph = 2.; // [0: 0.25 : 3]
// The housing catch is at the back of the holder and keeps the housing from going backward.
z_housing_catch_cph = 0.1; // [0: 0.01 : .2]


// Adjusted lift screw the correct amount
dz_lifter_center_of_rotation_cph = 4.2; //[0:0.1:10]

// Cut groves for sliders into the part itself.  Doesn't seem to be necessary.
slider_cph = false;
// These are the screws under the fitting.  Obsolete now.
include_screw_holes_cph = false;
include_post_body_cph = false;
show_mock_cph = true;
mock_is_male_cph = true;
color_name_cph = "orange";  
color_alpha_cph = 1; // [0:0.1:1]
show_part_colors_cph = false;
lifter_angle_cph = 0; // [0: 1 : 99.9]
latch_is_open_cph = false;

use_default_z_spring_cph = use_default_values_cph; 
use_default_z_housing_catch_cph = use_default_values_cph;
use_default_slider_cph = use_default_values_cph;
use_default_include_screw_holes_cph = use_default_values_cph;

use_default_include_post_body = use_default_values_cph;
use_default_show_part_colors_cph = use_default_values_cph;
use_default_latch_is_open_cph = use_default_values_cph;
use_default_lifter_angle_cph = use_default_values_cph;
use_default_show_mock_cph = use_default_values_cph;
use_default_mock_is_male_cph = use_default_values_cph;
use_default_color_name_cph = use_default_values_cph;  
use_default_alpha_cph = use_default_values_cph;
use_default_orient_for_build = use_default_values_cph;

/* [Customize pin_holder_slide] */ 


length_phs = 40; // [0:1:99.9]
slide_clearance_phs = 0.1; // [0:0.01: 0.5]
show_mocks_phs = true;
orient_for_build_phs = false;
color_name_phs = "BurlyWood";
show_part_colors_phs = false;
color_alpha_phs = 1; // [0:0.1:1]


/* [Develop Pin Strip Clamp] */ 
show_pin_strip_clamp_development = false;
show_mock_psc = false;
allowance_psc = 0.4;

/* [Develop Pivot]*/ 

show_pivot_development = false;
pivot_size = 0.5; // [

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

module colorize(show_part_colors, color_name, color_alpha) {
    if (show_part_colors) {
        children();
    } else {
        color(color_name, color_alpha) {
            children();
        }
    }
}

module x_position(idx, description) {
    
    // Goal is to be able to up date drop
    echo(str(idx, ":\"", description, "\",\n                           "));
    // 

    
    
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
x_position(0, "Selectable housing lengths for dupont connector") 
    dupont_connector(housing=housing_);


x_position(1, "default dupont_connector()") dupont_connector();

x_position(2, "dupont_connector(has_pin=true)") dupont_connector(has_pin=true);

x_position(3, "Short housing, custom colors")  dupont_connector("chartreuse", "salmon", ABOVE, DUPONT_SHORT_HOUSING());

x_position(4, "Custom colors for dupont connector") dupont_connector(
        wire_color="pink", 
        housing_color="blue",         
        center=LEFT,
        housing=DUPONT_STD_HOUSING(),
        has_pin=true);


x_position(7, "Male pin orientation") {
    color("red") male_pin(ABOVE);
    color("orange") male_pin(BELOW);
    color("yellow") male_pin(FRONT);
    color("green") male_pin(BEHIND);
    color("blue") male_pin(RIGHT);
    color("violet") male_pin(LEFT);
}

x_position(10, "Female pin orientation") {
    color("red") female_pin(orient=ABOVE);
    color("orange") female_pin(orient=BELOW);
    color("yellow") female_pin(orient=FRONT);
    color("green") female_pin(orient=BEHIND);
    color("blue") female_pin(orient=RIGHT);
    color("violet") female_pin(orient=LEFT);
}

x_position(-1, "male_pin(orient=LEFT)" ) male_pin(orient=LEFT); 


x_position(-2, "Isolate insulation wrap - closed") rotate([0, 0, 90]) 
    male_pin(
        pin = false, 
        strike = false,
        detent = false, 
        barrel = false,
        conductor_wrap = false,
        insulation_wrap = 0, 
        strip=false); 
  
x_position(-3, "Isolate insulation wrap - half closed") 
    rotate([0, 0, 90]) 
        male_pin(
            pin = false, 
            strike = false,
            detent = false, 
            barrel = false,
            conductor_wrap = false,
            insulation_wrap = 0.5, 
            strip=false);       
       
x_position(-4, "Male pin - insulation_wrap=0.75" ) 
    male_pin(insulation_wrap=0.75, orient=RIGHT);


x_position(-7, "customized_pin_holder();" ) 
    customized_pin_holder();
 

x_position(-17, "customized wire holders") 
    customized_wire_holders();
    

x_position(-13, "customized_pin_holder_slide") 
    customized_pin_holder_slide();    


/* [Pin Strip Measurements] */    

// Measure from the holes beneath the pins
    l_pin_strip_dps = 115.1;
    pin_count_dps = 20;
    delta_pin_strip_dps = l_pin_strip_dps / (pin_count_dps -1);    

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
    z_insulation_wrap_dpgn =  2.6;
    y_insulation_wrap_bottom_dpgn = 1.58;
    x_strip_dpgn = 2.22;
    y_strip_dpgn = delta_pin_strip_dps;
    z_strip_dpgn = z_metal_dpgn;
    d_strip_dpgn = 1.4;
    
    dx_detent_dpgn = x_strike_dpm;
    dx_barrel_dpgn = dx_detent_dpgn + x_detent_dpgn;
    dx_conductor_wrap_dpgn = dx_barrel_dpgn + x_barrel_dpgn;
    dx_insulation_wrap_dpgn = dx_conductor_wrap_dpgn + x_conductor_wrap_dpgn;
    dx_strip_dpgn = dx_insulation_wrap_dpgn + x_insulation_wrap_dpgn;
    dx_strip_hole_dpgn = dx_strip_dpgn + x_strip_dpgn/2;
    dx_center_of_detent = (dx_detent_dpgn + dx_barrel_dpgn)/2;
    
    x_pin_to_strip_edge = dx_strip_hole_dpgn + x_strip_dpgn; 
    

module dupont_connector(
        wire_color = "yellow", 
        housing_color = "black",         
        center = ABOVE,
        housing = DUPONT_STD_HOUSING(),
        has_pin = false, 
        has_wire = true,
        color_alpha = 1) {
            
    pin_cavity = [
        DUPONT_HOUSING_WIDTH() - 2*DUPONT_HOUSING_WALL() , 
        DUPONT_HOUSING_WIDTH() - 2*DUPONT_HOUSING_WALL() ,
        DUPONT_STD_HOUSING()
    ];
    housing_extent = [DUPONT_HOUSING_WIDTH(), DUPONT_HOUSING_WIDTH(), housing]; 
        
    // center_orient(orient, BELOW)        
    center_rotation(center) {  
        center_rotation(BELOW) { 
            if (has_wire) {
                color(wire_color) can(d=DUPONT_WIRE_DIAMETER(), h = housing + 8, center=ABOVE, rank=-3);
            }
            if (has_pin) {
                // For headers should make it square!
                //color("silver") can(d=DUPONT_PIN_SIZE(), h = DUPONT_PIN_LENGTH(), center=BELOW);
                male_pin(orient=ABOVE, insulation_wrap=1, conductor_wrap=1, strip=false);
            } else {
                female_pin(orient=ABOVE, insulation_wrap=1, conductor_wrap=1, strip=false);
            }
            difference() {   
                color(housing_color, color_alpha) 
                    block(housing_extent, center = ABOVE, rank=10);
                
                if (!has_pin) {
                    can(d=DUPONT_PIN_SIZE() + 0.5, h = 0.1, taper=DUPONT_PIN_SIZE(), center=ABOVE, rank = 15);
                    can(d=d_pin_dpm + 0.3, h = x_pin_dpm + 1);
                    translate([0, 0, d_pin_dpm]) block(pin_cavity, center=ABOVE);
                } 
            }

        }
    } 
           
}

module female_pin( 
        orient = FRONT,
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true,
        alpha=1) { 

            
    _generic_pin_dp(
        is_male=false,
        orient = orient,
        pin = false,          
        strike = strike,
        detent = detent, 
        barrel = barrel,
        conductor_wrap = conductor_wrap,
        insulation_wrap = insulation_wrap, 
        strip = strip, 
        alpha = alpha);        
}

module male_pin(
        orient = FRONT,
        pin = true, 
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true,
        alpha=1) {

    _generic_pin_dp(
        is_male = true,
        orient = orient,             
        pin = pin,
        strike = strike,
        detent = detent, 
        barrel = barrel,
        conductor_wrap = conductor_wrap,
        insulation_wrap = insulation_wrap, 
        strip = strip,
        alpha = alpha);           
}

module _generic_pin_dp(
        is_male,
        orient, 
        pin,
        strike,
        detent, 
        barrel,
        conductor_wrap,
        insulation_wrap, 
        strip,
        alpha) {
            
    //echo("orient: ", orient);

    center_orient(orient, FRONT) pin(); 

    module pin() {

        color("silver", alpha=alpha) {
           
            if (is_male && pin) {
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
    
    // Initially model pin before construction with pin on x_axis,
    // with the pin itself negative, and the parts used in assembly
    // increasing in the x domain.abs
    module wing(base, tip) {
        module bottom() {
            translate([0, base.y/2, -base.z]) rod(d=z_metal_dpgn, l=base.x, center=ABOVE); 
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
                translate([x_strike_dpm/2, 0, -od_barrel_dpgn/2]) 
                    block([x_strike_dpm/2, y_strike_dpgn, z_metal_dpgn], center=ABOVE+FRONT);
                rod(d=d_pin_dpm, l=0.01, center=FRONT);
                block([z_metal_dpgn, z_metal_dpgn, z_metal_dpgn], center=FRONT);
                translate([x_strike_dpm, 0, -od_barrel_dpgn/2]) block([0.01, y_strike_dpgn, z_strike_dpgn], center=BEHIND+ABOVE);
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
        
        translate([dx_detent_dpgn, 0, -od_barrel_dpgn/2]) block(bottom, center=FRONT + ABOVE);
  
    }
    module barrel() {  
        translate([dx_barrel_dpgn, 0, 0])
            rod(d=od_barrel_dpgn, l=x_barrel_dpgn, hollow=od_barrel_dpgn-2*z_metal_dpgn, center=FRONT);
    }
    
    module conductor_wrap() {
        z_factor = conductor_wrap < 0.5 ? 1 : 1.5 - conductor_wrap;
        extent = [x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_conductor_wrap_dpgn];
        translate([dx_conductor_wrap_dpgn, 0, 0]) 
            wing(
                [x_conductor_wrap_dpgn, wire_diameter, od_barrel_dpgn/2], 
                [0.8*x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_factor*(z_conductor_wrap_dpgn - od_barrel_dpgn/2)]); 
    }
    module insulation_wrap() {
        z_factor = insulation_wrap < 0.5 ? 1 : 1.5 - insulation_wrap;
        translate([dx_insulation_wrap_dpgn, 0, -od_barrel_dpgn/2]) 
            wing(
                [x_insulation_wrap_dpgn, wire_diameter, 0], //od_barrel_dpgn/2], 
                [0, (1-insulation_wrap)*y_insulation_wrap_dpgn, z_factor*(z_insulation_wrap_dpgn)]);         
    } 
    module strip() {
        translate([dx_strip_dpgn, 0, -od_barrel_dpgn/2]) //        -z_insulation_wrap_dpgn/2+2*z_metal_dpgn])
            difference() {
                block([x_strip_dpgn, y_strip_dpgn, z_metal_dpgn], center=FRONT+ABOVE);
                translate([x_strip_dpgn/2, 0, 0]) can(d=d_strip_dpgn, h=5);
            }
    }
 
}

module male_pin_strip(orient) {
    male_pin(orient);
    translate([0, delta_pin_strip_dps, 0]) male_pin(orient);
}


module pin_holder_screws(
        as_screw = false, 
        as_hole_threaded = false, 
        as_hole_through = false,
        as_nutcatch_sidecut = false) {
    module process() {
        for (x = [0 : 6 : 18]) {
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
        stainless() process() translate([0, 0, +2.54/2]) screw("M2x8");
    }
    if (as_nutcatch_sidecut) {
        process() translate([0, 0, 2]) rotate([0, 0, 90]) nutcatch_sidecut(name = "M2", clh=0.3);
    }
}

//slider_rail(size=[40, 6, 5], depth=1, flat=1, as_clearance=false);

module slider_rail(y, size, depth=1, flat=1, as_clearance=true) {
    if (as_clearance) {
        assert(!is_undef(y));
    } else {
        assert(!is_undef(size));
    }

    module shape(in=true) {
        x = in ? 100 : size.x;
        rotation = in ? [0, 0, 0] : [180, 0, 0];
        rotate(rotation) {
            hull() {
                block([x, depth, flat], center=LEFT);
                block([x, 0.01, flat+0.5*depth]);
            }
        }
    }
    if (!as_clearance) {
        translate([0,  size.y/2, 0 ]) shape(in=false); 
        difference() {
            block(size);
            //mirror([0, 1, 0]) translate([0,  size.y/2, 0 ]) shape(in=true);
        }
        
    } else{
        center_reflect([0, 1, 0]) {
            translate([0,  y/2, 0 ]) {
                shape(in=true); 
            } 
        }
    }
}


module pin_latch(
        width, 
        z_clearance = 1.0, 
        color_name = "FireBrick", 
        color_alpha = 1,
        latch_is_open = false,
        show_mock = true, 
        mock_is_male = true) {
    latch_percent = 0.75;        
    latch_width = latch_percent * width;
    latch_offset = (latch_width-width)/2; 
            
 
    d_pivot = 3;    
    s = DUPONT_HOUSING_WIDTH(); 
    
    
     
    dx_hole = 2;
    dz_release =  s/2 + z_clearance + d_pivot/2;
            
    latch_position = latch_is_open ? [0, 0, z_strike_dpgn/2] : [0, 0, 0];            
    
    t_build_plate_detent = [dx_center_of_detent, -latch_offset, 0];      
            
    module latch() {
        hull() {
            translate(t_build_plate_detent + [0, 0, s/2]) block([x_detent_dpgn, latch_width, z_clearance], center=ABOVE);
            translate(t_build_plate_detent) block([x_detent_dpgn/2, latch_width, 1 ], center=BELOW);
        }            
    }
    module latch_support() {
        hull() {
           translate(t_build_plate_detent + [0, 0, s/2]) {
                block([x_detent_dpgn, latch_width, z_clearance], center=ABOVE); 
           }
           translate(t_build_plate_detent + [0, 0, dz_release]) {
                rod(d=d_pivot, l=latch_width, center=SIDEWISE);
           } 
        }        
    }
    
    module spring_target() {
        hull() {        
           translate(t_build_plate_detent + [0, 0, dz_release]) {
                rod(d=d_pivot, l=latch_width, center=SIDEWISE);
           }
           translate([0, -latch_offset, dz_release]) {
                rod(d=d_pivot, l=latch_width, center=SIDEWISE);
           }           
       }
    }
 
    color(color_name, color_alpha) {
        translate(latch_position) {
            latch();
            latch_support();
            spring_target();
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



module latch_lifter(
        lift,
        y_spring,
        allowable_cut = 0.5, 
        handle = [4, 1, 10],
        lifter_angle = use_default_lifter_angle_cph ? default_lifter_angle_cph : lifter_angle_cph,
        as_clearance = false,  
        color_name = "cyan", // use_default_color_name_ll ? default_color_name_ll : color_name_ll,
        color_alpha = 1,
        orient_for_build) { // = // use_default_alpha_ll ? default_color_alpha_ll : color_alpha_ll); 
           
            
    d_lifter = handle.x;
    d_rim = d_lifter  + 2 * allowable_cut;
    dy_edge = 0.8;
    y_gutter = 0.8;
    delta = d_rim -d_lifter; 
    if (orient_for_build) {
        rotate([90, 0, 0]) translate([0, y_spring+handle.y, 0]) assembly();
    } else {        
        translate([0, 0, d_lifter/2]) {    
            rotate([0, -lifter_angle, 0]) {
                assembly();
            }
        }
    }

    module handle_and_outer_rim() {
        translate([0, -y_spring]) {
            block(handle, center=ABOVE+LEFT);
            rod(d = d_rim, l=handle.y, center=SIDEWISE+LEFT);
        }     
    }
    
    module lift_clearances() {
        if (!as_clearance) {
            translate([0, 0, d_lifter/2 - 2]) plane_clearance(ABOVE);
            translate([lift, 0, 0])plane_clearance(FRONT); 
        }           
    }
    
    module lifter() {
        translate([0, -dy_edge, 0]) {
            difference() {
                rod(d = d_lifter, l= y_spring -  dy_edge, center=SIDEWISE+LEFT);  // l=handle.y
                lift_clearances();
            } 
        } 
     
    }
    
    module inner_rim() {
        translate([0, -dy_edge, 0]) {
            difference() {
                hull() {
                    rod(d = d_rim, l=y_gutter, center=SIDEWISE+LEFT);
                    rod(d = d_lifter, l=y_gutter + delta/2, center=SIDEWISE+LEFT);
                }
                lift_clearances();
            }
        }
    }    
            
    module assembly() {   
        handle_and_outer_rim();
        lifter();
        inner_rim(); 

    }
}  




module customized_pin_holder_slide() {
    pin_holder_slide(
        length = length_phs,
        slide_clearance = slide_clearance_phs,
        show_mocks = show_mocks_phs,
        orient_for_build = orient_for_build_phs,
        show_part_colors = show_part_colors_phs,
        color_name = color_name_phs,
        color_alpha = color_alpha_phs);
}


module pin_holder_slide(
        length, 
        slide_clearance = 0.1, 
        show_mocks = true, 
        orient_for_build = false,
        color_name = "BurlyWood", 
        color_alpha = 1, 
        show_part_colors = true) {
            
    if (show_mocks && ! orient_for_build) {
        translate([0, 0, 3])customized_pin_holder();
    }
    colorize(show_part_colors=show_part_colors, color_name=color_name, color_alpha=color_alpha) {
        assembly();
    }
    pin_holder_width = 6;
    base = [length, 18, 2];
    slot_length = length - 8;
    wall = 2;
    holder_overlap = 1; 
    
    left_wall = [length, wall, pin_holder_width];
    right_wall = [length, wall, pin_holder_width + 2 * slide_clearance];
    right_retainer = [length, wall + slide_clearance + holder_overlap, wall];
    
    dy_wall = pin_holder_width/2 + slide_clearance;
    
    module assembly() {
        base();
        left_wall();
        right_wall();
    }    
    
    module base() { 
        difference() {
            block(base, center=BELOW);
            hull() { 
                center_reflect([1, 0, 0]) translate([slot_length/2, 0, 25]) hole_through("M3");
            }
        }
    }
    
    module left_wall() {
        color("magenta") {
            translate([0, dy_wall , 0]) 
                block(left_wall, center=ABOVE+RIGHT);
        }
            
    }
    module right_wall() {
        color("Turquoise") {
            translate([0, -dy_wall, 0]) 
                block(right_wall, center=ABOVE+LEFT);
            translate([0, -dy_wall + slide_clearance + holder_overlap, right_wall.z]) 
                block(right_retainer, center=ABOVE+LEFT);  
        }      
    }
}


module customized_pin_holder() {

    pin_holder(
        z_spring = use_default_z_spring_cph  ?  default_z_spring_cph :  z_spring_cph,
        z_housing_catch = use_default_z_housing_catch_cph ? default_z_housing_catch_cph : z_housing_catch_cph,
        slider = use_default_slider_cph ? default_slider_cph : slider_cph,
        include_screw_holes = use_default_include_screw_holes_cph ? default_show_part_colors_cph : include_screw_holes_cph,
        include_post_body = use_default_include_post_body ? default_include_post_body: include_post_body_cph,
        latch_is_open = use_default_latch_is_open_cph ? default_latch_is_open_cph : latch_is_open_cph,
        show_part_colors = use_default_show_part_colors_cph ? default_show_part_colors_cph : show_part_colors_cph,
        show_mock = use_default_show_mock_cph ? default_show_mock_cph : show_mock_cph,
        mock_is_male = use_default_mock_is_male_cph ? default_mock_is_male_cph : mock_is_male_cph,
        color_name = use_default_color_name_cph ? default_color_name_cph : color_name_cph,
        color_alpha = use_default_alpha_cph ? default_color_alpha_cph : color_alpha_cph,
        orient_for_build = use_default_orient_for_build ? default_orient_for_build_cph : orient_for_build_cph);  
}

default_z_spring_cph = 1.0; 
default_z_housing_catch_cph = 0.1;
default_slider_cph = false;
default_include_screw_holes_cph = false;
default_include_post_body = false;
default_parts_separation_clearance_cph = 1;
default_show_part_colors_cph = false;
default_latch_is_open_cph = false;
default_lifter_angle_cph = 0;
default_show_mock_cph = true;
default_mock_is_male_cph = true;
default_color_name_cph = "orange";  
default_color_alpha_cph = 1;  
default_orient_for_build_cph = false;


if (show_pivot_development) {
    pivot_development(pivot_size);
}



//*************************************************************************************************** pivot_development
module pivot_development(pivot_size = 0.5) {
    
    air_gap = 0.35;
    * fake_handle(pivot_size);
    
    
    // Want to use the child to generate an attachment
    clipping_diameter = 9;
    attachment_instructions = [
        [ADD_HULL_ATTACHMENT, AP_BEARING, 0, clipping_diameter],
        [ADD_HULL_ATTACHMENT, AP_TCAP, 1, clipping_diameter],
        [ADD_HULL_ATTACHMENT, AP_LCAP, 1, clipping_diameter]
    ];
    * echo("attachment_instructions", attachment_instructions);
    
    translate([0, 0, 3])
        rotate([90, 0, 0]) {
            pivot(pivot_size, air_gap, angle_bearing_t, angle_pin_t, attachment_instructions=attachment_instructions) {
                fake_handle(pivot_size);
                fake_handle(0.75*pivot_size);
            }
        }
}



//***************************************************************************************************   show_pin_strip_clamp_development 
if (show_pin_strip_clamp_development) {
    pin_strip_clamp(allowance_psc);
    if (show_mock_psc) {
        female_pin(conductor_wrap = 1, insulation_wrap = 1, orient=BEHIND);
    }
}

module pin_strip_clamp(allowance=0.2) {
    
    module carve_out(extra_z=false) {
        z_allowance = extra_z ? allowance/2 + 0.4 : allowance/2;
        hull() {
            translate([0, 0, z_allowance]) cross_section() children();
            translate([0, 0, -allowance/2]) cross_section() children();
            translate([allowance/2, 0, 0]) cross_section() children();
            translate([-allowance/2, 0, 0]) cross_section() children();
        }    
    }
     
    module cross_section() {   
        hull() {
            center_reflect([0, 1, 0]) {
                translate([0, 10, 0]) { 
                    children();
                }
            }
        }
    }
    module blank() {
        a_lot = 10;
        d_snap_ring = 2.50;
        blank = [20, 6, 5];
        handles = [6, 2, 6];
        center_reflect([0, 0, 1]) 
            translate([0, blank.y/2, 4])
                difference() {
                    block(handles, center=LEFT);
                    rod(d=d_snap_ring, l=a_lot, center=SIDEWISE);
                } 
        
        block(blank, center=BEHIND);
    }
    difference() {
        blank();
        carve_out() 
            male_pin(strike = false, detent = false, barrel = false, conductor_wrap = false, insulation_wrap = false, strip = false, orient=FRONT);
        carve_out() 
            female_pin(strike = true, detent = false, barrel = false, conductor_wrap = false, insulation_wrap = false, strip = false, orient=BEHIND);
        carve_out() 
            female_pin(strike = false, detent = true, barrel = false, conductor_wrap = false, insulation_wrap = false, strip = false, orient=BEHIND);
        carve_out() 
            female_pin(strike = false, detent = false, barrel = true, conductor_wrap = 1, insulation_wrap = false, strip = false, orient=BEHIND);
        carve_out(extra_z=true) 
            female_pin(strike = false, detent = false, barrel = false, conductor_wrap = 1, insulation_wrap = false, strip = false, orient=BEHIND);
        carve_out(extra_z=true) 
            female_pin(strike = false, detent = false, barrel = false, conductor_wrap = false, insulation_wrap = 1, strip = false, orient=BEHIND);
        carve_out(extra_z=true) 
            female_pin(strike = false, detent = false, barrel = false, conductor_wrap = false, insulation_wrap = false, strip = true, orient=BEHIND);
    }        
    
}

module pin_holder(
        z_spring = default_z_spring_cph, 
        z_housing_catch = default_z_housing_catch_cph,
        slider = default_slider_cph,
        include_screw_holes = default_include_screw_holes_cph,
        include_post_body = default_include_post_body,
        parts_separation_clearance = default_parts_separation_clearance_cph, 
        latch_is_open = default_latch_is_open_cph,
        lifter_angle = default_lifter_angle_cph, 
        show_mock = default_show_mock_cph,
        mock_is_male = default_mock_is_male_cph,
        show_part_colors = default_show_part_colors_cph,
        color_name = default_color_name_cph, 
        color_alpha = default_color_alpha_cph,
        orient_for_build = default_orient_for_build_cph
        ) { 
         
    echo("orient_for_build", orient_for_build); 
    echo("g lifter_angle", lifter_angle);       
    s = DUPONT_HOUSING_WIDTH(); 
    hsg_l = DUPONT_STD_HOUSING();
    
            
    alot = 20;            
    wall = 1;
            
    
             
    width = s + wall;
            
    housing_std_dpg = [hsg_l, s, s];
    walls = [wall, 2*wall, 2*wall];
    housing_clearance = 0.2;
    housing_clearances = 2*[housing_clearance, housing_clearance, housing_clearance];
    minimal_body = housing_std_dpg + housing_clearances + walls; 
    // Make body a metric width:
    body = [minimal_body.x, 6, 6]; 
    x_spring = body.x-4;
    
    maximum_lift = 1;
    spring_lift = latch_is_open && !orient_for_build ? maximum_lift : 0;  // TODO figure it out from what latch needs!
    
    spring_gap = 2; 
            
    z_clearance = body.z/2 - s/2 + spring_gap;
            
    d_housing_catch = wall + z_housing_catch + housing_clearance;
    
    cavity_for_pin = housing_std_dpg + housing_clearances + [alot, 0, 0];
    
    dx_lifter_center_of_rotation = 4;
    displace_latch_lifter = [-dx_lifter_center_of_rotation, body.y/2, body.z/2];
      

    shelf = [dx_conductor_wrap_dpgn-1, body.y, body.z/2-od_barrel_dpgn/2];  //dx_barrel_dpgn
    front_shelf = [dx_center_of_detent, body.y, body.z/2];
         
    if (show_mock && !orient_for_build) {
        if (include_screw_holes) {
            translate([0, -wall-housing_clearance, 0]) pin_holder_screws(as_screw=true, $fn=12); 
        }
        if (mock_is_male) {
            dupont_connector(center=BEHIND, has_pin=false, color_alpha=color_alpha);
            male_pin();
        } else {
            dupont_connector(center=BEHIND, has_pin=true, color_alpha=color_alpha);
            female_pin(alpha=0.5);
        }
        if (include_post_body) {
            post_body_screw_block(as_clearance=false); 
        }
        translate(displace_latch_lifter) sized_latch_lifter(); 
    } 
    
    module sized_latch_lifter(orient_for_build=false, as_clearance = false) {
        echo("lifter_angle", lifter_angle);

            latch_lifter(
                lift = maximum_lift, 
                y_spring = 0.6*body.y, 
                allowable_cut = 0.75*wall,
                lifter_angle = orient_for_build ? 0: lifter_angle, 
                as_clearance = as_clearance,
                orient_for_build = orient_for_build);
    }
    

    if (orient_for_build) {
       rotate([-90, 0, 0])  translate([0, -body.y/2, 0])  assembly();
       translate([20, 0, 0]) sized_latch_lifter(orient_for_build=true);
    } else {
        echo("color_alpha", color_alpha);
        colorize(show_part_colors=show_part_colors, color_name=color_name, color_alpha=color_alpha ) {
            difference() {
                assembly();
                if (slider) {
                    translate([0, 0, -body.y/2+1.5]) slider_rail(body.y, as_clearance=true);
                }
            }
        }
    }
    
    module assembly() {
        body("yellow", color_alpha); 
        housing_latch();       
        sized_pin_latch();
        spring("green", color_alpha);
        shelf("violet", color_alpha);
        if (include_screw_holes) {
            screw_block();
        }        
    }
    
    module screw_block() {
        color("blue", color_alpha) {
            difference() {
                translate([2, 0, -body.z/2]) block([16, body.y, 3], center=BEHIND); 
                pin_holder_screws(as_hole_through=true, $fn=12);
            }
        }
    }
    
    module sized_pin_latch() {
        difference() {
            pin_latch(
                width = body.y, 
                z_clearance= z_clearance, 
                show_mock = false, 
                latch_is_open = latch_is_open && !orient_for_build,
                mock_is_male = mock_is_male, 
                color_alpha = color_alpha);
        }
    }
   
    module housing_latch() {
        translate([-hsg_l - 2*housing_clearance, 0, body.z/2-d_housing_catch/2]) {
            color("pink", color_alpha) {            
                difference() {
                    rod(d=d_housing_catch, l=body.y, center=SIDEWISE, rank=5);
                    translate([0, 0, -wall/2]) plane_clearance(FRONT+BELOW);
                }
            }
        }        
    } 
    
    module post_body_screw_block(as_clearance) {
        module process() {
            m25_child = 0;
            m3_child = 1;
            dz = as_clearance ? 25 : body.z/2;
            dz_rotated = as_clearance ? 25 : body.y/2;
            rotate([180, 0, 0]) {
                translate([-(body.x + 1 + 3), 0, dz]) children(m3_child);
                translate([-(body.x + 7 + 3), 0, dz]) children(m25_child);
            }
            rotate([90, 0, 0]) {
                translate([-(body.x + 1), 0, dz_rotated]) children(m25_child);
                translate([-(body.x + 7), 0, dz_rotated]) children(m3_child); 
            } 
        }
        if (as_clearance) {
            process() {
                hole_through("M3"); //hole_through("M2.5");
                hole_through("M3");
            }
        } else {
            process() {
                screw("M3x8"); //screw("M2.5x8");
                screw("M3x8");
            }               
        }          
    }    

    
    module body(color_name = "yellow", color_alpha=1) {
        extra_for_post_body_screw_block = include_post_body ? [14, 0, 0] : [0, 0, 0];     
        color(color_name, color_alpha) {         
            difference() {
                translate([0, 0, 0]) 
                    block(body + extra_for_post_body_screw_block, center = BEHIND);  
                block(cavity_for_pin, center = BEHIND);
                block(.9*housing_std_dpg);
                if (include_screw_holes) {
                    pin_holder_screws(as_hole_through=true, $fn=12);
                }
                if (include_post_body) {
                    post_body_screw_block(as_clearance=true);
                }
                
                translate(displace_latch_lifter) sized_latch_lifter(as_clearance = true);
            }
        }

    }

    
    module spring(color_name="green", color_alpha=1) {
        
        y_spring_narrow = 0.55 * body.y;
        
        z_spring_end = body.z/2 + spring_gap + spring_lift;
        color("green", color_alpha) {
            // Lower part
            hull() {
               translate([0, body.y/2, z_spring_end]) 
                    rod(d=z_spring, l=y_spring_narrow, center=SIDEWISE+ABOVE+LEFT);  
               translate([-x_spring, body.y/2, body.z/2 + spring_gap]) 
                    rod(d=z_spring, l=y_spring_narrow, center=SIDEWISE+ABOVE+LEFT);  
            }
            // Pedistal 
            translate([-x_spring, body.y/2, body.z/2]) 
                block([3, y_spring_narrow, 8], center=ABOVE+LEFT); 
        } 
    }
    
    
    module shelf(color_name, color_alpha=1) {
        color(color_name, color_alpha) {

           
            difference() {
                union() {
                    translate([0, 0, -body.z/2]) 
                        block(shelf, center=ABOVE+FRONT);
                
                    block(front_shelf, center=BELOW+FRONT);
                }
                    
                if (include_screw_holes) {
                    pin_holder_screws(as_hole_through=true, $fn=12);
                }
                hull () {
                    translate([dx_center_of_detent, 0, -body.z/2 + shelf.z]) rod(d=2, l=alot, center=SIDEWISE);
                    translate([dx_center_of_detent, 0, 0]) rod(d=2, l=alot, center=SIDEWISE);
                }
                hull() 
                    center_reflect([0, 0, 1]) male_pin(
                        pin = false, 
                        strike = true,
                        detent = false, 
                        barrel = false,
                        conductor_wrap = false,
                        insulation_wrap = false, 
                        strip = false);
            }
        }
    }
    
    

}



module customized_wire_holders() {
    pincher_clearances = [ each [0.2:0.05:0.4]];
    echo(pincher_clearances);
    for (i = [0:len(pincher_clearances)-1]) {
        translate([0, i*20, 0]) {
            wire_holder(
                pincher_clearance = pincher_clearances[i], 
                z_pivot = z_pivot_dpwh,
                orient_for_build=orient_for_build_dpwh, 
                clamp_angle=clamp_angle_dpwh, 
                show_body = show_body_dpwh,
                show_clamp = show_clamp_dpwh,
                show_mock = show_mock_dpwh); 
        }   
    }
}



module wire_holder(
        pincher_clearance, 
        z_pivot = 6,
        include_screw_holes = true, 
        orient_for_build=false, 
        show_mock=true, 
        show_clamp = true,
        clamp_angle = 0, 
        show_body = true) {
    
    alot = 100;

    upper_body = [8, 6, z_pivot+7];
    handle = [12, 2, 8];
    handle_clearance = 0.2;
    
    z_screw_block =  include_screw_holes ?  5 : DUPONT_HOUSING_WIDTH()/2;      
    screw_block = [16, upper_body.y, z_screw_block];
    t_axle = [-4, 0, z_pivot];
    
    
    if (orient_for_build) {
        if (show_body) {
            translate([0, 0, screw_block.z]) body();
        }
        if (show_clamp) {
            translate([screw_block.x/2, -5, handle.y/2]) rotate([90, 0, 0]) clamp();
        }
        
    } else {
        if (show_mock) { 
            rod(d=DUPONT_WIRE_DIAMETER(), l=30); 
        }
        if (show_clamp) {
            clamp(clamp_angle);
        }
        body();
    }
    
    module pivot_hole() {
        translate([0, -25, 0]) rotate([90, 0, 0]) hole_through("M2"); 
    }
    
    module handle(color_name="green", color_alpha=1) {
        color(color_name, color_alpha) {
            difference() {
                union() {
                    hull() {
                        rod(d=handle.z, l=handle.y, center=SIDEWISE);
                        block(handle, center=BEHIND);
                    }
                }
                pivot_hole();
                // Connection for moving clamp
                translate([-handle.x + 2, -25, 0]) rotate([90, 0, 0]) hole_through("M2"); 
            } 
        }        
    }
    
    module pincher() {
        translate([0, 0, -handle.z/2]) block([2, handle.y, z_pivot-handle.z/2-pincher_clearance], center=BELOW+BEHIND);
    }
    
    module clamp(angle=0) {
        translate(t_axle) {
            rotate([0, angle, 0]) {
                handle();
                pincher();
            }
        }
    }
    
    module axle_clearance() {
        translate(t_axle) translate([0, -25, 0]) rotate([90, 0, 0]) hole_through("M2", $fn=12);
    }
    
    
    module body(alpha=1) {
        color("blue") {
            render(convexity=10) difference() {
                union() {
                    block(upper_body, center=BEHIND+ABOVE); 
                    block(screw_block, center=BEHIND+BELOW); 
                }
                block([alot, handle.y + 2* handle_clearance, upper_body.z-0.5], center=ABOVE);
                hull() {
                    rod(d=DUPONT_WIRE_DIAMETER(), l=alot, $fn=12); 
                }
                translate([-2, 0, 0]) pin_holder_screws(as_hole_through=true, $fn=12);
                axle_clearance();
            }
        }
    }
        
    
    
}
