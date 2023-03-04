/* 

use <lib/dupont_connectors.scad>

*/


include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <prong_and_spring.scad>
use <MCAD/boxes.scad>
use <MCAD/regular_shapes.scad>
include <TOUL.scad>

/* [Boiler Plate] */
   infinity = 1000; 

/* [Logging] */
    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice);    

/* [Test] */
    show_dupont_pin_orientation_test = false;

/* [Show] */

    orient_for_build_ = false;
    
    show_socket_holder = true;
    show_socket_holders = true;
    show_slide_pin_retainer = true;
    show_clip_pin_retainer = true;
    show_pin_junction = true;
    
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
    wall_socket_ = 1; // [1, 1.5, 2]
    
    minimum_socket_opening_ = [0, 11, 11];
    pin_insert_thickness_ = 1; //[0: No plate, 1, 1.5, 2]
    show_plug = true;
    show_pin_insert = false; 
    // Distance that the socket extends beyond catch offset 
    socket_retention_ = 4;  // [0: 0.5 : 10]
    

/* [Spring Dimensions] */
//    spring_length_ = 13; // [0: 0.5 : 14]
//    spring_thickness_ = wall_plug_; // 1; // [0: 0.5 : 3]
//    spring_width_ = 4; // [0: 0.5 : 10]
//    
//    catch_offset_ = 7; // [0: 0.5 : 10]
//    
//    catch_length_ = 2; // [0: 0.25 : 2]
//    catch_thickness = 1; // [0: 0.5 : 10]
//    catch_width_ = spring_width_;
//
//    catch_allowance_ = 0.4; // [0: 0.25 : 2]
//
//    prong_dimensions_ = prong_dimensions(
//        spring = [spring_length_, spring_thickness_, spring_width_],
//        catch = [catch_length_, catch_thickness, catch_width_], 
//        catch_offset = catch_offset_,
//        catch_allowance = catch_allowance_);  

module end_customization() {}
    
// Customization Invocations:




    
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
    x_placement(5){
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


if (show_pin_holder_plug) {
    x_placement(6){
        if (show_plug) {
            pin_junction(
                high_count = 3,
                wide_count = 3, 
                part="Plug",
                wall = wall_plug_,
                pin_allowance = [0.5+pin_insert_thickness_, 0.5, 0.5],
                minimum_socket_opening = minimum_socket_opening_,
                orient_for_build=orient_for_build_,
                log_verbosity=verbosity); 
            }
        
        if (show_pin_insert) {
            //******************************************************************
            assert(pin_insert_thickness_ > 0);
            dy = 0; // 20
            all_pattern = "
                ░░░░░░░░░
                ░╋░░┃░░━░ 
                ░░░░░░░░░
                ░░░░░░░░░
                ░╬░░║░░═░
                ░░░░░░░░░
                ░┼░░│░░─░ 
                ░░░░░░░░░ 
                ▁▂▄▆█
            ";
            
            test_pattern = "
                          ▄▄█
                          ╴▄╶
                          █╷▄ 
                    
            ";
            translate([0, dy, 0]) {
                pin_retention_plate(
                   pin_insert_thickness = pin_insert_thickness_,
                   pattern = test_pattern);
            }
        }
        
        
    } 
}
 
if (show_pin_holder_socket) {
    x_placement(7){
        pin_junction(
            3, 
            3, 
            part="Socket",
            socket_retention = socket_retention_,
            wall = wall_plug_,
            socket_wall = wall_socket_, 
            minimum_socket_opening = minimum_socket_opening_,
            orient_for_build=orient_for_build_,
            log_verbosity=verbosity); 
    }    
}
  
   
module pj_bottom (orient_for_build) {
    pin_junction(
        high_count_, 
        wide_count_, 
        part="Holder", 
        orient_for_build=orient_for_build,
        log_verbosity=verbosity);
}

module pj_lid(orient_for_build) {
    pin_junction(
        high_count_, 
        wide_count_, 
        part="Clip",
        clip_overlap = clip_overlap_,
        orient_for_build=orient_for_build,
        log_verbosity=verbosity);        
}
    

if (show_dupont_pin_orientation_test) {
    x_placement(8) {
        dupont_pin(color="orange", orient=LEFT); 
        dupont_pin(color="green", orient=RIGHT);
        dupont_pin(color="purple", orient=FRONT);
        dupont_pin(color="yellow", orient=BEHIND);
        dupont_pin(color="blue", orient=ABOVE);
        dupont_pin(color="red", orient=BELOW);   
    }
    x_placement(9) {
        dupont_pin();  
    }
}

function dupont_pin_width() = 2.54; // Using standard dimensions, rather than measured
function dupont_pin_length() = 14.0; // Using standard dimensions, rather than measured
function dupont_wire_diameter() = 1.0 + 0.25; // measured plus allowance

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
    size = [dupont_pin_width(), dupont_pin_width(), dupont_pin_length()];
    color(color, alpha=alpha) {
            rotate(rotation) 
                block(size, center=BELOW);
    }            
} 

module pin_retention_plate(
   pin_insert_thickness,
   pattern,
   allowance = 0.0) {
       

    /*
       Key: 
       
        ▁▂▄▆█  Pin inserts with various height
        ╋      Pin and wire clearance, both directions
        ┃      Pin and wire clearance vertical
        ━      Pin and wire clearance horizontal
        ╬║═    Wire access in particular directions
        ┼│─    Wire access in particular directions
        ╴╵╶╷
        ░      Bare plate
       
       
       
       all_pattern = "░░░ ╋┃━ ░░░ ╬║═ ░░░ ▁▂▄▆█ ┼│─ "
    */
       


    layout = split_no_separators(pattern);  
    generate(); 
   
    module generate() {
        render() difference() {
            union() {
                base_plate();
                pin_inserts();
            }
            clearances();
        }
    }       
    
    pin_width = dupont_pin_width();
    pin_length = dupont_pin_length();
    pin = [pin_width, pin_width, pin_length];
    allowances = 2* [allowance, allowance, 0];
    
    module base_plate() {
        plate_map = []; // Empty map
        process(layout, plate_map, missing_child_idx=0) {
            block([pin_width, pin_width, pin_insert_thickness] + allowances, center=BELOW);
        }
    }
    
    
    module pin_inserts() {
        module pin(fraction) {
            block([pin_width, pin_width, fraction*pin_length], center=ABOVE);
        }
        
        map =  concat(
            [
                ["█", 0],
                ["▆", 1],
                ["▄", 2],
                ["▂", 3], 
                ["▁", 4],
                ["╬", 0],
                ["║", 0],
                ["═", 0]
            ]
        );
        
        //log_v1("map", map,verbosity, DEBUG, IMPORTANT);
        process(layout, map) {
            pin(1);
            pin(3/4);
            pin(1/2);
            pin(1/4);
            pin(1/8);
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
        symbols = "╋┃━╬║═┼│─╷╵╴╶";
        
        map = [for (i = [0:len(symbols)-1]) [symbols[i], i]];
            
        log_v1("map", map, verbosity, DEBUG);
        

        PIN_PASS_THROUGH = true;
        NO_PIN_PASS_THROUGH = false;
        
        process(layout, map) {
            clearance(PIN_PASS_THROUGH, [FRONT, BEHIND, LEFT, RIGHT]);
            clearance(PIN_PASS_THROUGH, [LEFT, RIGHT]);
            clearance(PIN_PASS_THROUGH, [FRONT, BEHIND]);
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

    function split_no_separators(string) = 
        let(a =  split(string, " ")) 
        [ for (item = a) if (item != "") item];
    
    
    
    function pattern_to_map(layout, idx)  = [
            for (cmd = layout) if (cmd != " ") [cmd, idx]
        ];

    module locate(i, j) {
        x = i * pin_width;
        y = j * pin_width;
        translate([x, y, 0]) children();
    }
    
    module process(layout, map_cmd_to_child, missing_child_idx) {
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


function pin_junction_dimensions(
        high_count=1, 
        wide_count=1, 
        wall = 2, 
        pin_allowance = 0.5,
        part="Holder", 
        clip_overlap=5,
        pin_retention_lip = 0.5,
        socket_allowance = 0.1,
        socket_wall = 1,
        socket_retention = 4,
        minimum_socket_opening = [0, 0, 0]) = 

    let (
        pin_width = dupont_pin_width(), 
        pin_length = dupont_pin_length(),
        spring_length = pin_length,
        spring_thickness = wall, 
        spring_width = 4, // Tune for strength?? 
        catch_offset = 7, // Is this necessarily part of the prong???
        catch_length = 1.5,
        catch_thickness = 1,
        catch_width = spring_width,
        catch_allowance = 0.4, 
        prong = prong_dimensions(
                    spring = [spring_length, spring_thickness, spring_width],
                    catch = [catch_length, catch_thickness, catch_width], 
                    catch_offset = catch_offset,
                    catch_allowance = catch_allowance), 


        x_extension = [100, 0, 0],
        z_extension = [0, 0, 100],
 
        //wire_diameter = dupont_wire_diameter, 
        socket_walls = 2 *  [socket_wall, socket_wall, socket_wall],
        socket_allowances = 2 * [socket_allowance, socket_allowance, socket_allowance],
        walls = 2 * [wall, wall, wall],
        depth_count = 2,
        pins = [depth_count * pin_length, wide_count*pin_width, high_count*pin_width],
        //dmy3 = echo("pins", pins),
        pin_allowances = 
            is_num(pin_allowance) ? 2 * [pin_allowance, pin_allowance, pin_allowance] :
            is_list(pin_allowance) ? 2 * pin_allowance :
            assert(false, assert_msg("Not implemented: pin_allowance", str(pin_allowance))),
        //dmy2 = echo("pin_allowances", pin_allowances),
        body = pins + pin_allowances + walls,
        //dmy1 = echo("body", body),
        plug_body = [
            body.x/2,
            max(minimum_socket_opening.y, body.y), 
            max(minimum_socket_opening.z, body.z)
        ], 
        raw_socket_body = plug_body + socket_allowances + socket_walls,
        //catch_offset = prong_dimension(prong, "catch_offset"),
        socket_depth =  catch_offset + socket_retention,
        socket_body = [2*socket_depth, raw_socket_body.y, raw_socket_body.z],
        socket_void = plug_body + socket_allowances + x_extension, 
        last = undef
    )
    [
        ["component", "pin_junction_dimensions"],
        ["part", part],
        ["high_count", high_count],
        ["wide_count", wide_count],
        ["wall", wall],
        ["clip_overlap", clip_overlap],
        
        ["raw_socket_body", raw_socket_body],
        ["socket_body", socket_body],
        ["socket_void", socket_void],
        ["pin_length", pin_length],
        ["pin_width", pin_width],
        ["prong", prong],
    ];
    

function pin_junction_dimension(dimensions, item) = 
    find_in_dct(dimensions, item);

module pin_junction(
        high_count=1, 
        wide_count=1, 
        wall = 2, 
        pin_allowance = 0.5,
        part="Holder", 
        clip_overlap=5,
        pin_retention_lip = 0.5,
        socket_allowance = 0.1,
        socket_wall = 1,
        socket_retention = 4,
        minimum_socket_opening = [0, 0, 0],
        orient_for_build=true,
        log_verbosity=INFO) {
            
    log_s("part:", part, log_verbosity, DEBUG);        
    log_s("high_count:", high_count, log_verbosity, DEBUG);  
    log_s("wide_count:", wide_count, log_verbosity, DEBUG); 
    log_s("pin_allowance:", pin_allowance, log_verbosity, DEBUG);
    //log_s("prong_dimensions:", prong_dimensions, log_verbosity, DEBUG);   

 
          
    dims = pin_junction_dimensions(
        high_count, 
        wide_count, 
        wall, 
        pin_allowance,
        part, 
        clip_overlap,
        pin_retention_lip,
        socket_allowance,
        socket_wall,
        socket_retention,
        minimum_socket_opening          
    );
    log_v1("dims:", dims, log_verbosity, DEBUG); 
    pin_length = pin_junction_dimension(dims, "pin_length");
    pin_width = pin_junction_dimension(dims, "pin_width"); 
    prong =  pin_junction_dimension(dims, "prong"); 
            
    assert(is_num(high_count), assert_msg(" high_count=", str(high_count))); 
    depth_count = 2;
    pins = [depth_count * pin_length, wide_count*pin_width, high_count*pin_width];
    pin_allowances = 
        is_num(pin_allowance) ? 2 * [pin_allowance, pin_allowance, pin_allowance] :
        is_list(pin_allowance) ? 2 * pin_allowance :
        assert(false, assert_msg("Not implemented: pin_allowance", str(pin_allowance)));
    socket_allowances = 2 * [socket_allowance, socket_allowance, socket_allowance];        
    walls = 2 * [wall, wall, wall];
    socket_walls = 2 *  [socket_wall, socket_wall, socket_wall];
            
    body = pins + pin_allowances + walls;
    log_s("body:", body, log_verbosity, DEBUG);         
            
    cavity = pins + pin_allowances;
    x_extension = [100, 0, 0];
    z_extension = [0, 0, 100];
    lip = [pin_retention_lip, pin_retention_lip, pin_retention_lip];
    lip_radius = (pin_width - 2*pin_retention_lip)/2;
    assert(lip_radius > 0, assert_msg("The argument pin_retention_lip is too large large - no room for wires"));
    cable_clearance = pins - 2 * lip + x_extension;
    catch_offset = prong_dimension(prong, "catch_offset");
    catch = prong_dimension(prong, "catch");
    spring = prong_dimension(prong, "spring");
    socket_depth =  catch_offset + socket_retention;    


    
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
        socket_body = [2*socket_depth, raw_socket_body.y, raw_socket_body.z];
        log_s("socket_body:", socket_body, log_verbosity, DEBUG); 
        socket_void = plug_body + socket_allowances + x_extension; 
        render() difference() {
            roundedBox(socket_body,  radius=socket_wall/2, sidesonly=false, $fn=12);
            roundedBox(socket_void,  radius=wall/2, sidesonly=false, $fn=12);
            plane_clearance(BEHIND);
            prong_holes();
        } 
    }
    
    module prong_holes() {
        spring_and_prong(prong, "prong_hole_through");
    }
    
    module prongs() {
        prong_items("prong");
    }
    
    module prong_items(part) {
        print_separation = 0.5;
        dy = plug_body.y/2 + max(catch.y, socket_wall) + print_separation;
        center_reflect([0, 1, 0]) {
            translate([0, dy, 0]) {
                spring_and_prong(prong, part);
            } 
        }
        
        prong_connection = [spring.z, 2*dy, 2*wall];      
    }
    
    module prong_clearances() {
        prong_items("spring_cuts");
    }  
  
    module plug_body() {
        translate([plug_body.x/2, 0, 0]) roundedBox(plug_body,  radius=wall/2, sidesonly=false, $fn=12);
    } 
   


    module plug() {
        prongs();
        render() difference() {
            plug_body();  
            block(cavity); 
            cable_clearance();
        }
    }
    
    
    module cable_clearance() {
       roundedBox(cable_clearance, radius=lip_radius, sidesonly=false, $fn=12); 
    }
                    
    module holder() { 
        cut = [0, 0, wall+2*pin_allowances.z]; // Want the pins to be slightly exposed, 
                                                
        log_s("cut:", cut, log_verbosity, DEBUG); 
         
        cut_body = body - cut;
        
        render() difference() {
            translate(-cut/2) roundedBox(cut_body,  radius=1, sidesonly=false, $fn=12);
            block(cavity);
            cable_clearance();
            block(cable_clearance+z_extension, center=ABOVE); 
        }
    }
    
//    module clip() {
//        clip_body = body + socket_allowances + socket_walls;
//        lid_body = [clip_body.x, clip_body.y, socket_wall + clip_overlap];
//        clip_cavity = body + socket_allowances;
//        zt_lid = (clip_body.z - (socket_wall + clip_overlap))/2;
//        assert(clip_overlap < clip_cavity.z);
//        
//        render() difference() {
//            translate([0, 0, -(wall)]) {
//                render() difference() {
//                    translate([0, 0, zt_lid]) {
//                        roundedBox(lid_body, radius=socket_wall/2, sidesonly=false, $fn=12);
//                    }
//                    roundedBox(clip_cavity, radius=lip_radius, sidesonly=false, $fn=12);
//                }
//            }
//            roundedBox(cable_clearance, radius=lip_radius, sidesonly=false, $fn=12);
//            block(cable_clearance+[0, 0, 10], center=BELOW);
//        }
//    }    
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

