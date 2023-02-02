module sub_micro_servo_mounting_block(
        screw_allowance, 
        screw_length, 
        pilot_diameter, 
        block_depth, 
        block_width, 
        bar_thickness) {

    dz = bar_thickness  + block_width/2;
    dx = screw_allowance/2;
    difference() {
        cube([screw_allowance, block_depth, block_width + bar_thickness]);
        color("red") translate([dx, 0, dz]) {
            rotate([90,0,0]) cylinder(h=2 * screw_length, d=pilot_diameter, center=true);
        }
    }
}

module sub_micro_servo_mounting(y_inside, y_outside, bar_thickness) {
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
    * echo("server_mounting_block(", screw_allowance, servo_block_depth, servo_width, bar_thickness);
    translate([servo_edge_x1, dy_servo, 0]) {
        sub_micro_servo_mounting_block(
            screw_allowance, 
            screw_length, 
            pilot_diameter, 
            servo_block_depth, 
            servo_width, 
            bar_thickness);
    }
    translate([servo_edge_x2, dy_servo, 0]) {
        sub_micro_servo_mounting_block(
            screw_allowance, 
            screw_length, 
            pilot_diameter, 
            servo_block_depth, 
            servo_width, 
            bar_thickness);
    }
}


// Test code for servo mounting
sub_micro_servo_mounting(y_inside=13, y_outside=17, bar_thickness=4);

* servo_mounting_block(8, 10, 11.73, 4);