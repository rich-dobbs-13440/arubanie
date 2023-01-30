$fa = 1;
$fs = 0.4;

eps = 0.01;

screw_block_size = 9;
screw_shaft_diameter = 1.1*2.85;
nut_inset = 6;
nut_diameter = 6.24 * 1.2; // Increase size for clearance

registration_diameter = 2 * screw_shaft_diameter;
registration_clearance = 0.25;

rotation_pivot_offset_x = 5;
rotation_pivot_offset_y = 17;
rotation_pivot_diameter = 5;
rotation_pivot_clearance = 0.5;

barrel_diameter = 11.9;
brace_width = 7.7;
brace_height = 6.9;

base_thickness = 3;

block_thickness = 9;
block_height = 11;


joiner_thickness = 24;
joiner_width = 8;
joiner_height = 5;

// distance between the hole and the centerline of the back bracket
dx_bracket = 60;


top_shoulder = screw_block_size;
bottom_shoulder = screw_block_size + brace_height;

// block width is dx
block_width = barrel_diameter + top_shoulder + bottom_shoulder;
echo("block_width = ", block_width);



barrel_radius = barrel_diameter/2.;
total_thickness = block_thickness + joiner_thickness + block_thickness;
echo("total_thickness = ", total_thickness);

pivot_diameter = rotation_pivot_diameter - 2 * rotation_pivot_clearance;


module basic_block(include_registration) {
    translate([0., 0., -block_height/2.]) {
        
        difference() {
            translate([brace_width/2., 0, 0]) {
                cube([block_width, block_thickness, block_height], center=true);
            }

            translate([0, 0, block_height/2.]) {
                rotate([90,0,0]) {
                    cylinder(h=block_thickness * (1 + eps), r=barrel_radius, center=true);
                };
            };

        };
        
        if(include_registration) {
            offset_screw_x = barrel_radius + brace_height + screw_block_size/2.;
            translate([offset_screw_x, 0, block_height/2.]) sphere(d = registration_diameter); 
        };
        if(include_registration) {
            offset_screw_x = -barrel_radius - screw_block_size/2.;
            translate([offset_screw_x, 0, block_height/2.]) sphere(d = registration_diameter); 
        };
        if(include_registration) {
            offset_screw_x = barrel_radius + brace_height + screw_block_size/2.;
            offset_screw_y = joiner_thickness + screw_block_size;
            translate([offset_screw_x, offset_screw_y, block_height/2.]) sphere(d = registration_diameter); 
        };
        if(include_registration) {
            offset_screw_x = -barrel_radius - screw_block_size/2.;
            offset_screw_y = joiner_thickness + screw_block_size;
                translate([offset_screw_x, offset_screw_y, block_height/2.]) sphere(d = registration_diameter); 
        };
    
    }
    
}

module brace_cutout() {   
    width = brace_height + barrel_radius;
    translate([width/2, 0, 0])
        cube([width, block_thickness * (1 + eps), brace_width], center=true);
}

// Front block has a cutout for the brace
module front_block() {

    * color("red") brace_cutout();
    
    difference() {
        basic_block();
        brace_cutout();
    }
}


module basic_holder_side (include_registration) {
    // back block
    translate([0, 0., 0]) {
        basic_block(include_registration);
    };

    // front_block
    translate([0, joiner_thickness + block_thickness, 0]) {
        //basic_block();
        front_block();
    };

    offset_joiner_x1 = barrel_radius + brace_height + screw_block_size - joiner_width/2.;
    offset_joiner_x2 = barrel_radius + screw_block_size - joiner_width/2.;

    offset_2 = -block_height + joiner_height/2.;

    translate([offset_joiner_x1, joiner_thickness/2. + block_thickness/2, offset_2]) 
        cube([joiner_width, joiner_thickness * (1 + eps), joiner_height], center=true);


//    * color("blue") translate([-offset_joiner_x2, joiner_thickness/2. + block_thickness/2, offset_2]) 
//        cube([joiner_width, joiner_thickness * (1 + eps), joiner_height], center=true);

    // base
    clearance_for_trigger = 7;
    offset_3 = -block_height + base_thickness/2;
    offset_4 = brace_height/2 + clearance_for_trigger/2;
     
    reveal = 1;

    base_width = block_width + reveal + reveal - clearance_for_trigger;
    base_length = total_thickness + reveal + reveal;
    color("red") translate([offset_4, total_thickness/2.-block_thickness/2., offset_3])
    {
        cube([base_width, base_length, base_thickness], center=true);
    }
}

module screw_cut_out(include_registration) {

    union() {
        // Shaft
        cylinder(h=block_height * 2, d=screw_shaft_diameter, center=true);
        // Nut
        translate([0, 0, -block_height]) cylinder(h=nut_inset*2, d=nut_diameter, center=true, $fn=6);
        // Registration
        if(include_registration) { sphere(d = registration_diameter + registration_clearance); }
    }
}

module screw_hole_1(include_registration) {
    offset_screw_x = barrel_radius + brace_height + screw_block_size/2.;
    translate([offset_screw_x, 0, 0]) screw_cut_out(include_registration);
}

module screw_hole_4(include_registration) {
    offset_screw_x = barrel_radius + brace_height + screw_block_size/2.;
    offset_screw_y = joiner_thickness + screw_block_size;
    translate([offset_screw_x, offset_screw_y, 0]) screw_cut_out(include_registration);
}

module screw_hole_2(include_registration) {
    offset_screw_x = -barrel_radius - screw_block_size/2.;
    translate([offset_screw_x, 0, 0]) screw_cut_out(include_registration);
}

module screw_hole_3(include_registration) {
    offset_screw_x = -barrel_radius - screw_block_size/2.;
    offset_screw_y = joiner_thickness + screw_block_size;
    translate([offset_screw_x, offset_screw_y, 0]) screw_cut_out(include_registration);
}

module rotation_pivot() {
    translate([rotation_pivot_offset_x, rotation_pivot_offset_y, 0]) cylinder(h=block_height * 3, d=rotation_pivot_diameter, center=true);  
}

module holder_side(positive_registration) {
    
    * color("orange") rotation_pivot();
    difference() {
        basic_holder_side(positive_registration);
        rotation_pivot();
        screw_hole_1(!positive_registration);
        screw_hole_2(!positive_registration);
        screw_hole_3(!positive_registration);
        screw_hole_4(!positive_registration);
    }  
}

module servo_mounting_block(screw_allowance, screw_length, pilot_diameter, block_depth, block_width, bar_thickness) {
    dz = bar_thickness  + block_width/2;
    dx = screw_allowance/2;
    difference() {
        cube([screw_allowance, block_depth, block_width + bar_thickness]);
        color("red") translate([dx, 0, dz]) {
            rotate([90,0,0]) cylinder(h=2 * screw_length, d=pilot_diameter, center=true);
        }
    }
}



module servo_mounting(y_inside, y_outside, bar_thickness) {
    servo_width = 11.73;
    servo_length = 23.54;
    servo_lip = 4;
    servo_horn_offset = 8;
    screw_allowance = servo_lip;
    screw_length = 8;
    pilot_diameter = 2;
    
    min_servo_block_depth = screw_length + 2;

    servo_block_depth = max(y_outside - y_inside, min_servo_block_depth);
    servo_edge_x1 = 0;
    servo_edge_x2 = servo_length + screw_allowance;
    dy_servo = y_inside + servo_block_depth/2;
    bar_dx = servo_edge_x1 + servo_edge_x2 + screw_allowance;
    
    //bar
    translate([0, dy_servo, 0]) cube([bar_dx, bar_thickness, bar_thickness]);
    // Mounting blocks
    echo("server_mounting_block(", screw_allowance, servo_block_depth, servo_width, bar_thickness);
    translate([servo_edge_x1, dy_servo, 0]) {
        servo_mounting_block(screw_allowance, screw_length, pilot_diameter, servo_block_depth, servo_width, bar_thickness);
    }
    translate([servo_edge_x2, dy_servo, 0]) {
        servo_mounting_block(screw_allowance, screw_length, pilot_diameter, servo_block_depth, servo_width, bar_thickness);
    }
   
    
}
// Test code for servo mounting
* servo_mounting(13, 17, 4);

* servo_mounting_block(8, 10, 11.73, 4);

module rotation_bracket_half(include_servo_mounting) {
    
    pivot_height = base_thickness;
    // distance on the outside of the pivots
    pivot_span = 22;
    bar_thickness = 4;
    
    dy_1 = pivot_span/2;
    dy_2 = dy_1 + pivot_height;
    dy_3 = dy_2 + bar_thickness;
    dz = 2*pivot_diameter;
    // back
    dx_1 = dx_bracket;
    translate([dx_1, dy_3/2, 0]) cube([bar_thickness, dy_3, dz], center=true);
    // side
    dx_4 = dx_1/2;
    dy_4 = dy_2 + bar_thickness/2;
    translate([dx_4, dy_4, 0]) cube([dx_1, bar_thickness, dz], center=true);
    dx_5 = -pivot_diameter/2;
    dy_5 = dy_4;
    translate([dx_5, dy_5, 0]) cube([1.5*pivot_diameter, bar_thickness, dz], center=true);
    if (include_servo_mounting) {
        y_inside = 8;
        y_outside = dy_3;
        servo_edge_x1 = 22;
        dz_servo = pivot_diameter - bar_thickness ;
        translate([servo_edge_x1, 0, dz_servo]) servo_mounting(y_inside, y_outside, bar_thickness);
    }
    
    translate([0, pivot_span/2 - pivot_height/2, 0]) union() {
        // Pivot
        rotate([90,0,0]) cylinder(h=pivot_height*(1 + eps), d=pivot_diameter, center=true);
        // Bearing
        translate([0, pivot_height, 0]) rotate([90,0,0]) cylinder(h=pivot_height*(1 + eps), d=2*pivot_diameter, center=true);  
    }
}


module rotation_bracket() {
    rotation_bracket_half(true);
    color("red") mirror([0, 1, 0]) rotation_bracket_half(false);
}

* translate([-50, 15, 0]) color("green") screw_cut_out(true);

// Holder side one
holder_side(true);

// Holder side two
* translate([50, 0, 0]) mirror([1, 0, 0]) holder_side(false);

// Positioned rotation bracket
dz_rb = block_height -pivot_diameter;
* translate([0, 70, -dz_rb]) rotation_bracket();
//translate([0, 0, 0]) rotation_bracket();
