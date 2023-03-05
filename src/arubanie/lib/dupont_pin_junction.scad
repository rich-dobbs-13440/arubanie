include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <not_included_batteries.scad>
use <prong_and_spring.scad>
use <MCAD/boxes.scad>
include <TOUL.scad>

/* [Logging] */
    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice); 
    
/* [Show] */

    orient_for_build_ = false;
    
    show_assembled = true;
    show_plug= true; 
    show_socket = true;
    show_pin_insert = true;
    show_holder = true;
    show_clip = true;
    

/* [Pin Holder Plug and Socket] */

    show_pin_holder_plug= true; 
    show_pin_holder_socket = true;

    wall_plug_ = 1; // [1, 1.5, 2]
    wall_socket_ = 1; // [1, 1.5, 2]
    
    minimum_socket_opening_ = [0, 11, 11];
    pin_insert_thickness_ = 1; //[0: No plate, 1, 1.5, 2]
    // Distance that the socket extends beyond catch offset 
    socket_retention_ = 4;  // [0: 0.5 : 10]
    
    
module end_customization() {}


function dupont_pin_width() = 2.54; // Using standard dimensions, rather than measured
function dupont_pin_length() = 14.0; // Using standard dimensions, rather than measured
function dupont_wire_diameter() = 1.0 + 0.25; // measured plus allowance



if (show_assembled) {
    x_placement(1){
        component("Plug");
        component("Socket");
        //pin_insert();
    }
}

if (show_socket) {
    x_placement(2){
        component("Socket");
    }    
}

if (show_plug) {
    x_placement(3) {
        component("Plug");
    }
}

if (show_pin_insert) {
    x_placement(4) {
        dy = 0; // 20
        translate([0, dy, 0]) {
            pin_insert();
        }
    } 
}

if (show_holder) {
    x_placement(5) {
        component("Holder");
    }    
}

if (show_clip) {
    x_placement(5) {
        component("Clip");
    }    
}

module x_placement(index) {
    dx_spacing = 20;
    translate([index*dx_spacing, 0, 0]) {
        children();
    }
}

module component(part) {
        pin_junction(
            3, 
            3, 
            part=part,
            socket_retention = socket_retention_,
            wall = wall_plug_,
            socket_wall = wall_socket_, 
            minimum_socket_opening = minimum_socket_opening_,
            orient_for_build=orient_for_build_,
            pin_insert_thickness = pin_insert_thickness_,
            log_verbosity=verbosity); 
}
        
module pin_insert() {
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
    pin_retention_plate(
       pin_insert_thickness = pin_insert_thickness_,
       pattern = test_pattern);
}
        


function pin_junction_dimensions(
        high_count=1, 
        wide_count=1, 
        wall = 2, 
        pin_allowance = 0.5,
        part="Holder", 
        clip_overlap=5,
        pin_retention_lip = 0.5,
        pin_insert_thickness = 0,
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
        
        ["pin_allowances", pin_allowances],
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
        pin_insert_thickness = 0,
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
        pin_insert_thickness,
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
    pin_allowances = pin_junction_dimension(dims, "pin_allowances"); 
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
        spring_and_barb(prong, "prong_hole_through");
    }
    
    module prongs() {
        prong_items("prong");
    }
    
    module prong_items(part) {
        print_separation = 0.5;
        offset = max(catch.y, socket_wall) + print_separation;
        dy = plug_body.y/2 + offset;
        center_reflect([0, 1, 0]) {
            translate([0, dy, 0]) {
                spring_and_barb(prong, part, support_offset=-offset-0.2);
            } 
        }
        
        prong_connection = [2*wall, 2*dy + 2*spring.y, spring.z+2*wall];
        translate([spring.x, 0, 0]) {
            roundedBox(prong_connection,  radius=wall, sidesonly=false, $fn=12);
        }
    }
    
    module prong_clearances() {
        prong_items("spring_cuts");
    }  
  
    module plug_body() {
        translate([plug_body.x/2, 0, 0]) roundedBox(plug_body,  radius=wall/2, sidesonly=false, $fn=12);
    } 
   


    module plug() {
        
        render() difference() {
            union() {
                plug_body();
                prongs();
            }
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
    
    module clip() {
        clip_body = body + socket_allowances + socket_walls;
        lid_body = [clip_body.x, clip_body.y, socket_wall + clip_overlap];
        clip_cavity = body + socket_allowances;
        zt_lid = (clip_body.z - (socket_wall + clip_overlap))/2;
        assert(clip_overlap < clip_cavity.z);
        
        render() difference() {
            translate([0, 0, -(wall)]) {
                render() difference() {
                    translate([0, 0, zt_lid]) {
                        roundedBox(lid_body, radius=socket_wall/2, sidesonly=false, $fn=12);
                    }
                    roundedBox(clip_cavity, radius=lip_radius, sidesonly=false, $fn=12);
                }
            }
            roundedBox(cable_clearance, radius=lip_radius, sidesonly=false, $fn=12);
            block(cable_clearance+[0, 0, 10], center=BELOW);
        }
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








