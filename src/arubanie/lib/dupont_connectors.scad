/* 

use <lib/servo_extension_wires.scad>

*/



include <centerable.scad>
use <shapes.scad>
use <MCAD/boxes.scad>
use <MCAD/regular_shapes.scad>

/* [Boiler Plate] */
   infinity = 1000; 

/* [Test] */
    show_dupont_pin_orientation_test = false;

/* [Show] */

    orient_for_build_ = true;
    
    show_socket_holder = true;
    show_socket_holders = true;
    show_slide_pin_retainer = true;
    show_clip_pin_retainer = true;
    show_pin_junction = true;
    // This is the 
    show_pin_holder_plug= true; 
    show_pin_holder_socket = true;
    
/* [Adjust] */

    allowance_=0.4; // [0 : 0.05: 0.4]
    count_ = 4; // [1, 2, 3, 4, 5, 6, 7, 8]
    
/* [Pin Junction] */
    high_count_ = 3; // [1 : 0.5 : 4]
    wide_count_ = 4; // [1 : 0.5 : 8]

    clip_overlap_ = 5; // [0: 0.5 : 10]
    show_assembled_ = true;
    // Only works if show assmble is false.
    show_lid_ = true;
    // Only works if show assmble is false.
    show_bottom_ = true;
    
 
    
/* [Pin Holder Plug and Socket] */
    
    
    wall_plug_ = 1; // [1, 1.5, 2]
    minimum_socket_opening_ = [0, 11, 11];
    
    spring_length_ = 13; // [0: 0.5 : 14]
    spring_width_ = 4; // [0: 0.5 : 10]
    prong_depth_ = 7; // [0: 0.5 : 10]
    prong_flat_ = 2; // [0: 0.25 : 2]
    // Includes the flat section:
    catch_depth_ = 2; // [0: 0.5 : 10]
    catch_allowance_ = 0.4; // [0: 0.25 : 2]
    
    SPRING_LENGTH = 0 + 0;
    SPRING_WIDTH = 1 + 0;
    PRONG_DEPTH = 2 + 0;
    PRONG_FLAT = 3 + 0;
    CATCH_DEPTH = 4 + 0;
    CATCH_ALLOWANCE = 5 + 0;
    
    
    prong_dimensions_ =  [
        spring_length_, 
        spring_width_, 
        prong_depth_, 
        prong_flat_, 
        catch_depth_, 
        catch_allowance_];
        
    echo("prong_dimensions", prong_dimensions_) ;
        
    
    

module end_customization() {}
    
// Customization Invocations:

if (show_pin_holder_plug) {
    pin_junction(
        3, 
        2, 
        part="Plug",
        wall = wall_plug_,
        prong_dimensions = prong_dimensions_,
        minimum_socket_opening = minimum_socket_opening_,
        orient_for_build=orient_for_build_);  
}

if (show_pin_holder_socket) {
    pin_junction(
        3, 
        2, 
        part="Socket",
        wall = wall_plug_,
        prong_dimensions = prong_dimensions_,
        minimum_socket_opening = minimum_socket_opening_,
        orient_for_build=orient_for_build_);     
}
    
if (show_socket_holder ) {
    x_placement(1){
        color("green") servo_female_socket_holder(allowance_, center=ABOVE);    
    }
}
if (show_socket_holders ) {
    x_placement(2){
        color("blue") servo_socket_holders();
    }
}
if (show_slide_pin_retainer ) {
    x_placement(3){
        color("orange") servo_pin_retainer(assembly="slide", count=count_);
    }
}
if (show_clip_pin_retainer ) {    
    x_placement(4){
        color("brown")  servo_pin_retainer(assembly="clip", count=count_);
    }
}   
 
if (show_pin_junction) {
    assert(!(show_assembled_ && orient_for_build_), "Thest options conflict!")
    x_placement(0){
        if (show_assembled_) {
            pj_bottom (false);
            pj_lid (false);
        } else {
            if (show_lid_) {
                pj_lid(orient_for_build_);
            }
            if (show_bottom_) {
                translate([0, 20, 0]) {
                    pj_bottom(orient_for_build_);
                }
            }
        } 
    }
}
  
   
module pj_bottom (orient_for_build) {
    pin_junction(high_count_, wide_count_, part="Holder", orient_for_build=orient_for_build);
}

module pj_lid(orient_for_build) {
    pin_junction(
        high_count_, 
        wide_count_, 
        part="Clip",
        clip_overlap = clip_overlap_,
        orient_for_build=orient_for_build);        
}
    

if (show_dupont_pin_orientation_test) {
    x_placement(7) {
        dupont_pin(color="orange", orient=LEFT); 
        dupont_pin(color="green", orient=RIGHT);
        dupont_pin(color="purple", orient=FRONT);
        dupont_pin(color="yellow", orient=BEHIND);
        dupont_pin(color="blue", orient=ABOVE);
        dupont_pin(color="red", orient=BELOW);   
    }
    x_placement(7) {
        dupont_pin();  
    }
}
 

// TODO Move to logging???
function assert_msg(c1, c2, c3, c4, c5) = 
    let (
        s1 = is_undef(c1) ? "" : c1,
        s2 = is_undef(c2) ? "" : c2,
        s3 = is_undef(c3) ? "" : c3,
        s4 = is_undef(c4) ? "" : c4,
        s5 = is_undef(c5) ? "" : c5,
        last = undef
    )
    str("In module '", parent_module(0), "' ", s1, s2, s3, s4, s5);


pin_width = 2.54; // Using standard dimensions, rather than measured
pin_length = 14.0; // Using standard dimensions, rather than measured
wire_diameter = 1.0 + 0.25; // measured plus allowance

module dupont_pin(color="black", alpha=1, orient=FRONT) {
    
    rotation = 
        orient == RIGHT ?  [90, 0, 0] :
        orient == LEFT ?  [-90, 0, 0] :
        orient == FRONT ?  [0, -90, 0] :
        orient == BEHIND ?  [0, 90, 0] :
        orient == BELOW ?  [0, 0, 0] :
        orient == ABOVE ?  [180, 0, 0] :
        
        orient == RIGHT ? [0, -13, 0] :
        assert(false, assert_msg("Not implement, orient=", orient, "  LEFT:", LEFT));
    color(color, alpha=alpha) {
            rotate(rotation) 
                block([pin_width, pin_width, pin_length], center=BELOW);
    }            
} 

module pin_junction(
        high_count, 
        wide_count, 
        wall = 2, 
        pin_allowance = 0.5,
        part="Holder", 
        clip_overlap=5,
        pin_retention_lip = 0.5,
        socket_allowance = 0.1,
        socket_wall = 1,
        minimum_socket_opening = [0, 0, 0],
        prong_dimensions, 
        orient_for_build=true) {
            
    assert(is_num(high_count), assert_msg(" high_count=", str(high_count))); 
    echo("pin_width", pin_width);
    depth_count = 2;
    pins = [depth_count * pin_length, wide_count*pin_width, high_count*pin_width];
    echo("pins", pins);
    pin_allowances = 2 * [pin_allowance, pin_allowance, pin_allowance];
    socket_allowances = 2 * [socket_allowance, socket_allowance, socket_allowance];        
    walls = 2 * [wall, wall, wall];
    socket_walls = 2 *  [socket_wall, socket_wall, socket_wall];
    body = pins + pin_allowances + walls;
    cavity = pins + pin_allowances;
    x_extension = [100, 0, 0];
    z_extension = [0, 0, 100];
    lip = [pin_retention_lip, pin_retention_lip, pin_retention_lip];
    lip_radius = (pin_width - 2*pin_retention_lip)/2;
    assert(lip_radius > 0, assert_msg("The argument pin_retention_lip is too large large - no room for wires"));
    cable_clearance = pins - 2 * lip + x_extension;
            
    default_prong_dimensions = [12.5, 4, 7, 2, 2, 0.4];
    defaulted_prong_dimensions = is_list(prong_dimensions) ? prong_dimensions : default_prong_dimensions; 
    
    prong_height = socket_wall + 2 * socket_allowance;
    function prong_depth() = defaulted_prong_dimensions[PRONG_DEPTH];
    function catch_allowance() = defaulted_prong_dimensions[CATCH_ALLOWANCE];
    function catch_depth() = defaulted_prong_dimensions[CATCH_DEPTH];
    function prong_flat() = defaulted_prong_dimensions[PRONG_FLAT];
    function spring_width() = defaulted_prong_dimensions[SPRING_WIDTH];
    function spring_length() = defaulted_prong_dimensions[SPRING_LENGTH];
    
    function socket_depth() = prong_depth() + catch_depth() + catch_allowance();
    
    plug_body = [
        body.x/2,
        max(minimum_socket_opening.y, body.y), 
        max(minimum_socket_opening.z, body.z)
    ]; 
            
    if (part == "Holder") {
        if ( orient_for_build ) {
            translate([0, 0, body.z/2]) { 
                holder(); 
            }
        } else {
            holder();
        }

    } else if (part == "Clip") {
        //assert(clip_overlap < pins.z);
        if ( orient_for_build ) {
            translate([0, 0, body.z/2+socket_allowance]) {  // Translate so it as z = zero.
                mirror([0, 0, 1]) clip();  // Flip it so lid is down
            }
        } else {
            clip();
        }
    } else if (part == "Plug") {
        if ( orient_for_build ) {
            rotate([0, 90, 0]) plug();
        } else{
            plug();
        }
    } else if (part == "Socket") {
        render() difference() {
            socket();
        }
    } else {
        assert(false, assert_msg("Not handle.  Part = ", str(part)));
    }  
    
    module socket() {
        raw_socket_body = plug_body + socket_allowances + socket_walls;
        socket_body = [2*socket_depth(), raw_socket_body.y, raw_socket_body.z];
        socket_void = plug_body + socket_allowances + x_extension; 
        render() difference() {
            # roundedBox(socket_body,  radius=socket_wall/2, sidesonly=false, $fn=12);
            roundedBox(socket_void,  radius=wall/2, sidesonly=false, $fn=12);
            plane_clearance(BEHIND);
            prong_holes();
        } 
    }

    module plug() {
        plug_void = plug_body - walls;
        render() difference() {
            union() {
                prongs();
                translate([plug_body.x/2, 0, 0]) roundedBox(plug_body,  radius=wall/2, sidesonly=false, $fn=12);
            }
            block(plug_void,  center=FRONT, rank=10);
            cable_clearance();
            block(cavity);
            spring_cuts();
            prong_clearance();
        }
        // For spring strength, we are going to print on side, so we need
        // a bit of printer support for the springs and upper part of socket
        support = [0.5, 0.4*wall, plug_body.z-wall];
        center_reflect([0, 1, 0]) {
            translate([0, plug_void.y/2, 0]) 
                block(support, center=FRONT+RIGHT);
        }
    }
    
    module prong_holes() {
        holes = [
            prong_flat() + sqrt(2) * socket_wall + 3 * catch_allowance(), 
            infinity,
            spring_width() + 0.5];
        translate([prong_depth() + catch_allowance(), 0, 0]) block(holes, center=BEHIND); 
    }
   
    
    module prongs() {
        prong_back = [prong_flat(), plug_body.y + 2*prong_height, spring_width()]; 
        prong_front = [0.01, plug_body.y-wall/2, spring_width()];
        hull() {
            block(prong_front);
            translate([prong_depth(), 0, 0]) block(prong_back, center=BEHIND);
        }
        // Bumps for depressing prongs for removal
        r1 = spring_width()/2 - prong_height/2;
        t_bump = [socket_depth()+spring_width()/2, plug_body.y/2, 0];
        center_reflect([0, 1, 0]) {
            translate(t_bump) {
                rotate([90, 0, 0]) {
                    hull() {
                        torus2(r1, prong_height/2, $fn=12);
                    }
                }
            }
        }
        
    }
    module prong_clearance() {
        prong_blank = [prong_depth(), body.y + 2*prong_height, spring_width()];
        render() difference() {
            block(prong_blank);
            prongs();
        }
    }
    
    module spring_cuts() {
        cut_diameter = 1;
        center_reflect([0, 0, 1]) {
            hull() {
                center_reflect([1, 0, 0]) 
                    translate([spring_length(), 0, spring_width()/2+cut_diameter/2]) 
                        rod(d=cut_diameter, l=infinity, center=SIDEWISE);
            }
        }
    }
    
    module cable_clearance() {
       roundedBox(cable_clearance, radius=lip_radius, sidesonly=false, $fn=12); 
    }
                    
    module holder() { 
        cut = [0, 0, wall+2*pin_allowance]; // Want the pins to be slightly exposed, so that lid presses on the pins
        cut_body = body - cut; 
        render() difference() {
            translate(-cut/2) roundedBox(cut_body,  radius=1, sidesonly=false, $fn=12);
            block(cavity);
            cable_clearance();
            block(cable_clearance+z_extension, center=ABOVE); 
        }
    }
    
    module clip() {
        clip_body = body + socket_allowances + socket_walls;
        lid_body = [clip_body.x, clip_body.y, socket_wall + clip_overlap];
        clip_cavity = body + socket_allowances;
        zt_lid = (clip_body.z - (socket_wall + clip_overlap))/2;
        assert(clip_overlap < clip_cavity.z);
        
        render() difference() {
            translate([0, 0, -(wall)]) {
                render() difference() {
                    translate([0, 0, zt_lid]) roundedBox(lid_body, radius=socket_wall/2, sidesonly=false, $fn=12);
                    roundedBox(clip_cavity, radius=lip_radius, sidesonly=false, $fn=12);
                }
            }
            roundedBox(cable_clearance, radius=lip_radius, sidesonly=false, $fn=12);
            block(cable_clearance+[0, 0, 10], center=BELOW);
        }
    }    
}



FEMALE_BODY = 0;
FEMALE_BACK = 1;
MALE_BODY = 2;
MALE_BACK = 3;

servo_socket_dimensions = [
    [10.71, 18.00, 3.74], // female body
    [7.87, 4.88, 2.65], //female back
    [7.69, 9.41, 2.44], // male body
    [7.92, 4.86, 2.70], // male back
];

module servo_socket_holders() {
    wall_thickness = 1;  // Code is broken unless wall_thickness is one!
    echo(parent_module(0));
    assert(is_num(wall_thickness), assert_msg("wall_thickness: ", str(wall_thickness)));
    holder_dimensions = servo_female_socket_holder_dimensions(allowance=allowance_);
    echo("holder_dimensions", holder_dimensions);
    echo("SFSH_HOLDER", SFSH_HOLDER);
    echo("holder_dimensions[SFSH_HOLDER]", holder_dimensions[SFSH_HOLDER]);
    echo("wall_thickness", wall_thickness);
    dx = holder_dimensions[SFSH_HOLDER].x - wall_thickness;
    rotate([0, 0, 180]) {
        for (i = [0:3]) {
            translate([(i-2)*dx, 0, 0]) 
                servo_female_socket_holder(wt=wall_thickness, allowance=allowance_, center=ABOVE+FRONT+LEFT);    
        }
    }
}

module x_placement(index) {
    dx_spacing = 50;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

SFSH_HOLDER = 0;
SFSH_FACE = 1;
SFSH_OPENING = 2;
SFSH_SIGNAL_WIRE_MARKER_DIAMETER_ = 3;
SFSH_SIGNAL_WIRE_MARKER_TRANSLATION = 4;
SFSH_CLIP_DIAMETER = 5;
SFSH_CLIP_LENGTH = 6;
SFSH_CLIP_TRANSLATION = 7;


function servo_female_socket_holder_dimensions(wt=1, allowance=0.2) = 
    let(
        wall = [2*wt, 2*wt, 2*wt],
        adjustment = [2*allowance, 2*allowance, 2*allowance],
        body = servo_socket_dimensions[FEMALE_BODY],
        holder = body + wall + adjustment,
        face = [holder.x, 3*wt, holder.z],
        opening = servo_socket_dimensions[MALE_BACK],
        d_signal_wire_marker = 1.4,
        t_signal_wire_marker = [
            -(opening.x/2 + allowance),
            holder.y/2, 
            -opening.z/2 + allowance
        ],
        d_clip = 2,
        l_clip = wt,
        t_clip = [
            opening.x/2 + allowance + d_clip/4,
            -holder.y/2, 
            opening.z/2 + allowance
        ],
        last = undef
    )
    [
        holder,
        face,
        opening,
        d_signal_wire_marker,
        t_signal_wire_marker, 
        d_clip,
        l_clip,
        t_clip,
    ];
    

module servo_female_socket_holder(wt=1, allowance=0.2, center=0) {
    dimensions = servo_female_socket_holder_dimensions(wt, allowance);
    holder = dimensions[SFSH_HOLDER];
    face = dimensions[SFSH_FACE];
    opening = dimensions[SFSH_OPENING];
    d_signal_wire_marker = dimensions[SFSH_SIGNAL_WIRE_MARKER_DIAMETER_];
    t_signal_wire_marker = dimensions[SFSH_SIGNAL_WIRE_MARKER_TRANSLATION];
    d_clip = dimensions[SFSH_CLIP_DIAMETER];
    l_clip = dimensions[SFSH_CLIP_LENGTH];
    t_clip = dimensions[SFSH_CLIP_TRANSLATION];
    
    lower_holder_body = [holder.x, holder.y, holder.z/2];
    upper_holder_body = [holder.x, holder.y, opening.z/2];
    extent = holder;
    center_translation(extent, center) {
        render() difference() {
            union() {
                block(lower_holder_body, center=BELOW);
                block(upper_holder_body,  center=ABOVE);
                translate([0, holder.y/2, 0]) block(face, center=LEFT);
                center_reflect([1, 0, 0]) {
                    translate(t_clip) rod(d=d_clip, l=l_clip, center=SIDEWISE+RIGHT);
                }
            }
            servo_male_plug(allowance=allowance);
            servo_female_socket(allowance=allowance);
            translate(t_signal_wire_marker) {
                rod(d=d_signal_wire_marker, l=2*wt, center=SIDEWISE+ABOVE);
            }
            can(d=0.8*holder.x, h=10);  // Just remove some unnecessary material
        }
    }
}

module servo_male_plug(center, allowance=0) {
    color("red", alpha=0.2) {
        adjustment = [2*allowance, 2*allowance, 2*allowance];
        echo("adjustment", adjustment);
        body = servo_socket_dimensions[MALE_BODY];
        dy_calc = -body.y/2 + servo_socket_dimensions[0].y/2; // servo_socket_dimensions[0].y/2;
        translate([0, dy_calc, 0]) { // Align male plug with the socke 
            block(body+adjustment);
            back = servo_socket_dimensions[MALE_BACK];
            echo(back+adjustment);
            translate([0, body.y/2, 0]) block(back+adjustment, center=RIGHT);
        }
    }
}

module servo_female_socket(center, allowance=0) {
    color("black", alpha=0.2) {
        adjustment = [2*allowance, 2*allowance, 2*allowance];
        body = servo_socket_dimensions[FEMALE_BODY];
        block(body + adjustment);
        back = servo_socket_dimensions[FEMALE_BACK];
        translate([0, -body.y/2, 0]) block(back + adjustment, center=LEFT);
    }
}




module servo_pin_retainer(assembly, count=1, allowance=0.4, wall_thickness=undef) {
    if (assembly=="clip") {
        clipping_retainer();
    } else if (assembly=="slide") {
        sliding_retainer();
    } else {
        assert(false);
    }
    wall_thickness_ = 
        !is_undef(wall_thickness) ?  wall_thickness :
        (assembly=="clip") ? 0.5 :
        (assembly=="slide") ? 1 :
        assert(false);

    adjustment = [2*allowance, 2*allowance, 2*allowance];
    walls = [2*wall_thickness_, 2*wall_thickness_, 2*wall_thickness_];
    pin_spacing = 2.54;
    pin_length = servo_socket_dimensions[MALE_BODY].y + servo_socket_dimensions[MALE_BACK].y;
    pins = [3*pin_spacing, 2*pin_length, pin_spacing];
    wire_clearance = [6.3, 40, 1.37];   
    blank = pins+walls+adjustment;
    module sliding_retainer() {
        dx = 
            blank.z // Because of rotation to being on edge!
            -wall_thickness_;  // To make interior walls the same thickness as exterior;
        replicate(dx) { 
            single_retainer();
        }

        module single_retainer() {
            rotate([0, -90, 0]) {
                difference() {
                    block(blank);
                    clearance();
                }
            }
        }
        
        module clearance() {
            block(pins+adjustment);
            block(wire_clearance+adjustment);
            translate([wire_clearance.x/2, 0, 0]) plane_clearance(FRONT);
        }        
    }

    module clipping_retainer() {
        dx = blank.x - wall_thickness_;
        replicate(dx) {
            single_retainer();
        }
        
        module single_retainer() {
            difference() {
                block(blank);
                clearance();
            }
        }
        module clearance() {
            wire_clip_clearance = [5, 30, 10];
            assembly_clearance = [30, 10, 30];
            dy_clip = 2;
            clip_overlap=[0.1, 0.1, 0.1];            
            
            block(pins+adjustment);
            center_reflect([0, 1, 0]) translate([0, dy_clip, 1]) {
                block(assembly_clearance, center=ABOVE+RIGHT);
            }
            block(wire_clearance);
            block(wire_clip_clearance, center=ABOVE);
            translate([0, 0, pin_spacing/2]) block(pins-clip_overlap, center=ABOVE);            
        }
    }
    
    module replicate(dx) {
        offset = count/2-0.5;
        for (i = [0: count-1]) {
            translate([(i-offset)*dx, 0, 0]) children(); 
        }
    }
}

