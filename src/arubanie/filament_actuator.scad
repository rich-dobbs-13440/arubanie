actuator_range_of_motion = 50; // [10 : 1: 100]
clamp_opening = 0.5; // [0.25, 0.5, 0.75, 1]

module filament_actuator(orient_for_build=false, build_body = true, build_packing_gland_face=false) {
    a_lot = 1000;

    filament_diameter = 1.75;
    filament_clearance = 0.5;
    slot_width = 3; // For an M3 nut to ride include
    strut_width = 3;
    clamp_thickness = 2;
    traveller_length = 10;
    traveler_engagement = 1;
    traveler_clearance = 0.4;
    extra_for_screws = 2;
    x = 2 * strut_width + filament_diameter + 2 * clamp_thickness + extra_for_screws; 
    y = actuator_range_of_motion + traveller_length;
    z = 2 * strut_width + slot_width + filament_diameter + 2*filament_clearance + 2 * traveler_engagement;    
    dz_slot = strut_width + slot_width/2 + traveler_engagement + traveler_clearance;
    dz_filament = dz_slot + slot_width/2 + filament_clearance + filament_diameter/2;
    y_end_block = 10;
    module traveler_clearance() {
        z_traveler = z - 2 * strut_width - 2*traveler_clearance;
        translate([0, 0, strut_width]) block([slot_width+5, a_lot, z_traveler], center=ABOVE); 
    }
    module filament_clearance() {
        translate([0, 0, dz_filament]) rotate([90, 0, 0]) can(d=2.5, h=200);
    }
    
    module slot_hole() {
        rotate([0, 90, 0]) translate([0, 0, 25]) hole_through("M3", cld=0.4, $fn=12);
    }
    module slot_clearance() {
        translate([0, 0, dz_slot]) { 
            hull() {
                slot_hole();
                translate([0, a_lot, 0]) slot_hole();
            } 
        }        
    }
    module clamp_hole() {
        translate([0, 0, 25]) hole_through("M2", cld=0.4, $fn=12);
    }    
    module clamp_slot_clearance(clamp_opening, transition) {
        translate([0, 0, dz_slot]) { 
            center_reflect([1, 0, 0]) {            
                if (transition > 0) {
                    hull() {
                        translate([2, 0, 0]) clamp_hole();
                        translate([2 + clamp_opening, transition, 0]) clamp_hole();
                    }
                }            
                translate([2 + clamp_opening, transition, 0]) {
                    hull() {
                        clamp_hole();
                        translate([0, a_lot, 0]) clamp_hole();
                    } 
                }
            }
        }        
    }    
    module slot_block(length, clamp_opening, transition) {
        slot_block = [x, length, z];
        difference() {
            block(slot_block, center = ABOVE+RIGHT);
            slot_clearance();
            clamp_slot_clearance(clamp_opening, transition);
            traveler_clearance();
            filament_clearance();       
        }
    }
    dx_screws = 5;    
    faceplate_screw_translation = [dx_screws, 2.5, dz_filament];
    module face_plate_screw_clearance() { 
        center_reflect([1, 0, 0]) 
            translate(faceplate_screw_translation) 
                rotate([90, 0, 0]) 
                    hole_through("M2", cld=0.2, $fn=12);  
        center_reflect([1, 0, 0]) 
            translate(faceplate_screw_translation + [0, 2, 0]) 
                rotate([90, 0, 0]) 
                    nutcatch_sidecut("M2", clh=.5);        
    }
    module end_block() {
        
        module ptfe_tube_packing_clearance() {
            translate([0, y_end_block, dz_filament]) rotate([90, 0, 0]) can(d = 6, taper=5, h=4, center=ABOVE, rank=10);
        }
        difference() {
            block([x, y_end_block, z], center=ABOVE+RIGHT);
            filament_clearance(); 
            ptfe_tube_packing_clearance();

            center_reflect([1, 0, 0]) translate([dx_screws, 2.5, 25]) hole_through("M2", cld=0.2, $fn=12);
            face_plate_screw_clearance();
        }
    }
    
    module packing_gland_face(orient_for_build) {
        y_packing_gland = 2;
        gland_translation = [0, actuator_range_of_motion/2 + traveller_length + 3 + y_end_block + 1, dz_slot-1];
        difference() {
            translate(gland_translation) block([x, y_packing_gland, z-dz_slot], center=ABOVE+RIGHT);
            face_plate_screw_clearance();
            translate([0, 0, dz_filament]) rotate([90, 0, 0]) can(d = 4.5, h=a_lot, rank=10);
        }        
    }

    
    module shape() { 
        center_reflect([0, 1, 0]) {
            slot_block(length=actuator_range_of_motion/2, clamp_opening=0, transition=0);
            translate([0, actuator_range_of_motion/2, 0]) slot_block(length=traveller_length + 3, clamp_opening=1, transition=3);
            translate([0, actuator_range_of_motion/2 + traveller_length + 3, 0]) end_block();
        }
    }
    if (orient_for_build) { 
        if (build_body) {
            // Split in half for printing in two pieces
            translate([0, 0, 0]) rotate([0, 0, 0]) {
                difference() {
                    shape();
                    translate([0, 0, dz_slot]) plane_clearance(ABOVE);
                }
            }
            translate([x + 5, 0, z]) rotate([0, 180, 0]) {
                difference() {
                    shape();
                    translate([0, 0, dz_slot]) plane_clearance(BELOW);
                }
            }
        }
        if (build_packing_gland_face) {
            packing_gland_face(orient_for_build = true);
        }
        
    } else {    
        color("teal") translate([x_actuator, y_actuator, z_actuator]) rotate([90, 0, 0]) shape();
    }
}