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


/* [Wire Holder Design] */
z_pivot_dpwh = 6; // [4:0.5:8]

show_mock_dpwh = true;
show_body_dpwh = true;
show_clamp_dpwh = true;
orient_for_build_dpwh = false;
clamp_angle_dpwh = 0; // [0:5:90]


/* [Housing Length] */

housing_ = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

/* [Show] */
show_top_level = false;
show_only_one = false;
one_to_show = -10; // [-11:"customized wire holders", -7: "Customized pin holder", -10:"Wire holders array", -4:"male_pin(insulation_wrap=0.75, orient=RIGHT)", -3:"Isolate insulation wrap - half closed", -2:"Isolate insulation wrap - closed", -1:" male_pin(orient=LEFT)", 0:"Selectable housing lengths for dupont connector", 1:"default dupont_connector()", 2:"dupont_connector(has_pin=true)", 3:"Short housing, custom colors", 4:"Custom colors for dupont connector", 7:"Male pin orientation", 10:"Female pin orientation"]

delta_ = 10; // [10:10:100]

/* [Pin Holder Customization] */
use_default_values = false;

x_spring_cph = 8; // [0:1:10]
z_spring_cph = 1.5; // [0: 0.01 : 3]
z_housing_catch_cph = 0.1; // [0: 0.01 : .2]
show_part_colors_cph = false;
show_mock_cph = true;
mock_is_male_cph = true;
color_name_cph = "orange";  
color_alpha_cph = 1; // [0:0.1:1]



use_default_x_spring_cph = use_default_values;
use_default_z_spring_cph = use_default_values; 
use_default_z_housing_catch_cph = use_default_values;
use_default_show_part_colors_cph = use_default_values;
use_default_show_mock_cph = use_default_values;
use_default_mock_is_male_cph = use_default_values;
use_default_color_name_cph = use_default_values;  
use_default_alpha_cph = use_default_values;

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
// 0:"Selectable housing lengths for dupont connector"
x_position(0) dupont_connector(housing=housing_);

// 1:"default dupont_connector()"
x_position(1) dupont_connector();

// 2:"dupont_connector(has_pin=true)"
x_position(2) dupont_connector(has_pin=true);

// 3:"Short housing, custom colors"
x_position(3)  dupont_connector("chartreuse", "salmon", ABOVE, DUPONT_SHORT_HOUSING());

// 4:"Custom colors for dupont connector"
x_position(4) dupont_connector(
        wire_color="pink", 
        housing_color="blue",         
        center=LEFT,
        housing=DUPONT_STD_HOUSING(),
        has_pin=true);


//7:"Male pin orientation", 
x_position(7) {
    color("red") male_pin(ABOVE);
    color("orange") male_pin(BELOW);
    color("yellow") male_pin(FRONT);
    color("green") male_pin(BEHIND);
    color("blue") male_pin(RIGHT);
    color("violet") male_pin(LEFT);
}

//10:"Female pin orientation
x_position(10) {
    color("red") female_pin(orient=ABOVE);
    color("orange") female_pin(orient=BELOW);
    color("yellow") female_pin(orient=FRONT);
    color("green") female_pin(orient=BEHIND);
    color("blue") female_pin(orient=RIGHT);
    color("violet") female_pin(orient=LEFT);
}

// -1:" male_pin(orient=LEFT);" 
x_position(-1) male_pin(orient=LEFT); 

// -2:"Isolate insulation wrap - closed"
x_position(-2) rotate([0, 0, 90]) 
    male_pin(
        pin = false, 
        strike = false,
        detent = false, 
        barrel = false,
        conductor_wrap = false,
        insulation_wrap = 0, 
        strip=false); 

// -3:"Isolate insulation wrap - half closed"    
x_position(-3) rotate([0, 0, 90]) 
    male_pin(
        pin = false, 
        strike = false,
        detent = false, 
        barrel = false,
        conductor_wrap = false,
        insulation_wrap = 0.5, 
        strip=false);       

// -4:"Male pin - insulation_wrap=0.75"        
x_position(-4) 
    male_pin(insulation_wrap=0.75, orient=RIGHT);


x_position(-7) 
    customized_pin_holder();
 
// -11:"customized wire holders"
x_position(-11) 
    customized_wire_holders();


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

    echo("orient: ", orient);
            
    _generic_pin_dp(
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
        orient, 
        pin,
        strike,
        detent, 
        barrel,
        conductor_wrap,
        insulation_wrap, 
        strip,
        alpha) {
            
    echo("orient: ", orient);

    center_orient(orient, FRONT) pin(); 

    module pin() {
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
        z_factor = conductor_wrap < 0.5 ? 1 : 1.5 - conductor_wrap;
        extent = [x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_conductor_wrap_dpgn];
        translate([dx_conductor_wrap_dpgn, 0, 0]) 
            wing(
                [x_conductor_wrap_dpgn, wire_diameter, od_barrel_dpgn/2], 
                [0.8*x_conductor_wrap_dpgn, y_conductor_wrap_dpgn, z_factor*(z_conductor_wrap_dpgn - od_barrel_dpgn/2)]); 
    }
    module insulation_wrap() {
        z_factor = insulation_wrap < 0.5 ? 1 : 1.5 - insulation_wrap;
        translate([dx_insulation_wrap_dpgn, 0, 0]) 
            wing(
                [x_insulation_wrap_dpgn, wire_diameter, od_barrel_dpgn/2], 
                [0, (1-insulation_wrap)*y_insulation_wrap_dpgn, z_factor*(z_insulation_wrap_dpgn - od_barrel_dpgn/2)]);         
    } 
    module strip() {
        translate([dx_strip_dpgn, 0, -z_insulation_wrap_dpgn/2+2*z_metal_dpgn])
            difference() {
                block([x_strip_dpgn, y_strip_dpgn, z_metal_dpgn], center=FRONT);
                translate([x_strip_dpgn/2, 0, 0]) can(d=d_strip_dpgn, h=5);
            }
    }
 
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


module pin_latch(
        width, 
        z_clearance = 1, 
        color_name = "FireBrick", 
        color_alpha = 1, 
        show_mock = true, 
        mock_is_male = true,) {
            
            
    s = DUPONT_HOUSING_WIDTH(); 
    body = [4, width, 4];
    dx = (dx_detent_dpgn + dx_barrel_dpgn)/2;  // Center over detent
    dx_hole = 2;
    dz_release = body.z/2 + s/2 + z_clearance;
    color(color_name, color_alpha) {
        difference() {
            union() {
                *translate([dx, 0, dz_release]) block(body);
                translate([0, 0, dz_release]) block(body, center=FRONT);
                hull() {

                    translate([dx, 0, s/2]) block([x_detent_dpgn, width, z_clearance], center=ABOVE);
                    translate([dx, 0, -.25]) block([x_detent_dpgn/2, width, s/2 + 0.25 ], center=ABOVE); 
                }
                hull() {
                   translate([dx, 0, s/2]) block([x_detent_dpgn, width, z_clearance], center=ABOVE); 
                   translate([2, 0, s/2+z_clearance]) block([3, width, 0.1], center=ABOVE+FRONT);
                   translate([2, 0, s/2+z_clearance]) block([2, width, 4], center=ABOVE+FRONT);
                }
            }
            translate([dx_hole, -25, dz_release]) rotate([90, 0, 0]) hole_through("M2", cld=0.4, $fn=12);
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
    

module customized_pin_holder() {

    pin_holder(
        x_spring = use_default_x_spring_cph  ?  default_x_spring_cph :  x_spring_cph,
        z_spring = use_default_z_spring_cph  ?  default_z_spring_cph :  z_spring_cph,
        z_housing_catch = use_default_z_housing_catch_cph ? default_z_housing_catch_cph : z_housing_catch_cph,
        show_part_colors = use_default_show_part_colors_cph ? default_show_part_colors_cph : show_part_colors_cph,
        show_mock = use_default_show_mock_cph ? default_show_mock_cph : show_mock_cph,
        mock_is_male = use_default_mock_is_male_cph ? default_mock_is_male_cph : mock_is_male_cph,
        color_name = use_default_color_name_cph ? default_color_name_cph : color_name_cph,
        color_alpha = use_default_alpha_cph ? default_alpha_cph : color_alpha_cph);  
}

default_x_spring_cph = 8;
default_z_spring_cph = 1.5; 
default_z_housing_catch_cph = 0.1;
default_include_screw_holes = true;
default_show_part_colors_cph = false;
default_show_mock_cph = true;
default_mock_is_male_cph = true;
default_color_name_cph = "orange";  
default_color_alpha_cph = 1;    

module pin_holder(
        x_spring = default_x_spring_cph, 
        z_spring = default_z_spring_cph, 
        z_housing_catch = default_z_housing_catch_cph,
        include_screw_holes = default_include_screw_holes,
        show_part_colors = default_show_part_colors_cph,
        show_mock = default_show_mock_cph,
        mock_is_male = default_mock_is_male_cph,
        color_name = default_color_name_cph, 
        color_alpha = default_color_alpha_cph) { 
            
    s = DUPONT_HOUSING_WIDTH(); 
    hsg_l = DUPONT_STD_HOUSING();
            
    alot = 10;            
    wall = 1; 
    spring_gap = 1;          
    width = s + wall;
            
    housing_std_dpg = [hsg_l, s, s];
    walls = [wall, 2*wall, 2*wall];
    housing_clearance = 0.2;
    housing_clearances = 2*[housing_clearance, housing_clearance, housing_clearance];
    body = housing_std_dpg + housing_clearances + walls; 
            
    z_clearance = body.z/2 - s/2 + spring_gap;
            
    d_housing_catch = wall + z_housing_catch + housing_clearance;
            
    spring = [x_spring, body.y, z_spring];       

    shelf = [dx_barrel_dpgn, body.y, body.z/2-od_barrel_dpgn/2];
    
    //pin_holder_screws(as_hole_threaded=true, $fn=12);
    
        
    if (show_mock) {
        translate([0, -wall-housing_clearance, 0]) pin_holder_screws(as_screw=true, $fn=12); 
        if (mock_is_male) {
            dupont_connector(center=BEHIND, has_pin=false, color_alpha=color_alpha);
            male_pin();
        } else {
            dupont_connector(center=BEHIND, has_pin=true, color_alpha=color_alpha);
            female_pin(alpha=0.5);
        }
    }        
    colorize(show_part_colors=show_part_colors) {
        body(); 
        housing_latch();        
        sized_pin_latch();
        spring();
        shelf();
        screw_block();
    }
    
    module screw_block() {
        color("blue", color_alpha) {
            difference() {
                translate([2, 0, -body.z/2]) block([16, body.y, 3], center=BEHIND+BELOW); 
                pin_holder_screws(as_hole_through=true, $fn=12);
            }
        }
    }
    
    module sized_pin_latch() {
        pin_latch(
            width = body.y, 
            z_clearance= z_clearance, 
            show_mock = false, 
            mock_is_male = mock_is_male, 
            color_alpha = color_alpha);
    }
   
    module housing_latch() {
        translate([-hsg_l - 2*housing_clearance, 0, body.z/2-d_housing_catch/2]) {  
            difference() {
                color("pink", color_alpha) rod(d=d_housing_catch, l=body.y, center=SIDEWISE, rank=5);
                translate([0, 0, -wall/2]) plane_clearance(FRONT+BELOW);
            }
        }        
    } 
    
    module body() {
        difference() {
            color("yellow", color_alpha) { 
                translate([wall, 0, 0]) block(body, center = BEHIND);  
            }
            block(housing_std_dpg + housing_clearances + [alot, 0, 0], center = BEHIND);
            block(.9*housing_std_dpg);
            pin_holder_screws(as_hole_through=true, $fn=12);
        }        
    }
    
    module spring() {
        color("green", color_alpha) {
            translate([0, 0, body.z/2 + spring_gap])  block(spring, center=ABOVE+BEHIND);
            translate([-x_spring, 0, body.z/2])  block([2, spring.y, spring.z+spring_gap], center=ABOVE+BEHIND); 
        } 
    }
    
    module shelf() {
        color("violet", color_alpha) {
            difference() {
                translate([0, 0, -body.z/2]) 
                    block(shelf, center=ABOVE+FRONT);
                pin_holder_screws(as_hole_through=true, $fn=12);
            }
        }
    }
    
    
    module colorize(show_part_colors) {
        if (show_part_colors) {
            children();
        } else {
            color(color_name, color_alpha) {
                children();
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
        orient_for_build=false, 
        show_mock=true, 
        show_clamp = true,
        clamp_angle = 0, 
        show_body = true) {
    
    alot = 100;

    upper_body = [8, 6, z_pivot+4];
    handle = [12, 2, 8];
    handle_clearance = 0.2;
    
    screw_block = [16, upper_body.y, 5];
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
        clamp(clamp_angle);
        body();
    }
    
    module pivot_hole() {
        translate([0, -25, 0]) rotate([90, 0, 0]) hole_through("M2"); 
    }
    
    module handle() {
        color("green") {
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
        translate(t_axle) translate([0, -25, 0]) rotate([90, 0, 0]) hole_through("M2");
    }
    
    
    module body(alpha=1) {
        color("blue") {
            render(convexity=10) difference() {
                union() {
                    block(upper_body, center=BEHIND+ABOVE); 
                    block(screw_block, center=BEHIND+BELOW); 
                }
                block([alot, handle.y + 2* handle_clearance, alot], center=ABOVE);
                hull() {
                    rod(d=DUPONT_WIRE_DIAMETER(), l=alot); 
                }
                translate([-2, 0, 0]) pin_holder_screws(as_hole_through=true, $fn=12);
                axle_clearance();
            }
        }
    }
        
    
    
}
