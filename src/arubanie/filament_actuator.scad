include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
include <MCAD/servos.scad>
use <lib/ptfe_tubing.scad>

/* [Output Control] */

orient_for_build = false;

show_mocks = true;

build_end_caps = true;
build_ptfe_glides = true;
build_cage = true;
build_packing_gland_face = true;
build_packing_gland = true;
build_traveller = true;


/* [Actuator Design] */

actuator_range_of_motion = 50; // [10 : 1: 100]
d_clamp_screw = 3; //[2, 2.5, 3, 4, 5, 6]
l_clamp_screw = 8; //[4, 5, 6, 8, 10, 12]
clamp_screw_family = str("M", d_clamp_screw); // [M2, M2.5, M3, M4, M5, M6]
echo("clamp_screw_family", clamp_screw_family);
clamp_screw_name = str("M", d_clamp_screw, "x", l_clamp_screw);
echo("clamp_screw_name", clamp_screw_name);


y_packing_gland = 2;

packing_gland_id = 4.1; // [4.0, 4.05, 4.1, 4.15, 4.2, 4.25]
packing_gland_count = 2;
x_clamping_interference = 0.5;

module end_of_customization() {}

filament_diameter = 1.75;
ptfe_diameter = 4;

df = _get_fam(clamp_screw_family);
echo("df", df);
nutkey = df[_NB_F_NUT_KEY];
echo("nutkey", nutkey);
nutheight = df[_NB_F_NUT_HEIGHT];
echo("nutheight", nutheight);

front_wall = 2;
gap_between_nut_and_filament = 1;
x_traveller_front = nutheight + front_wall + gap_between_nut_and_filament + filament_diameter/2;
y_traveller_front = nutkey + 8;
gap_to_slide = 3;
slide_engagement = 1;
x_traveller_behind = filament_diameter/2 + gap_to_slide + slide_engagement;
y_traveller_behind = ptfe_diameter - .5;
z_traveller = nutkey + 2;

a_lot = 1000;


filament_clearance = 0.5;
filament_wall = 1;
slot_width = 3; // For an M3 nut to ride include
d_clamp_slot = 2;

strut_width = 3;
traveller_engagement = 1;
traveller_clearance = 0.4;
extra_for_screws = 2;
 
  
dz_slot = 0; //strut_width + slot_width/2 + traveller_engagement + traveller_clearance;

//traveller = [x_traveller, y_traveller, z_traveller];
dz_filament = 0; //dz_slot + slot_width/2 + filament_clearance + filament_diameter/2 + nutheight;
y_end_block = 10;
z_end_cap  =  y_end_block;
dy_screws = 5;    
faceplate_screw_translation = [0, dy_screws, z_end_cap-3];


packing_gland_face = [10, y_packing_gland, 20];
cage_length_half_length = actuator_range_of_motion/2 + z_traveller + y_end_block;
gland_translation = [0, cage_length_half_length+1, dz_slot-1];

// slide_extra should include engagement with mounting, as well as extra for clearance.
// Guess for now!
slide_extra = 10;
slide_length = actuator_range_of_motion + z_traveller + slide_extra;


module filament_clearance() {
    can(d=2, h=200);
}

module face_plate_screw_clearance() { 
    center_reflect([0, 1, 0]) 
        translate(faceplate_screw_translation) 
            rotate([180, 0, 0]) 
                hole_through("M2", cld=0.2, $fn=12);  
    center_reflect([0, 1, 0]) 
        translate(faceplate_screw_translation + [0, 2, 0]) 
            rotate([0, 0, 90]) 
                nutcatch_sidecut("M2", clh=.5);        
}




module ptfe_tube_packing_clearance() {
    translate([0, 0, z_end_cap]) {
        can(d = 5, taper=6, h=4, center=BELOW, rank=10);
        can(d = 4.5, taper=4, h=z_end_cap, center=BELOW, rank=10);
    }
}

module packing_gland(orient_for_build,  id=4.0, face_thickness = 1) {   
    module shape() {
        difference() {
            union() {
                can(d = 6, taper=5, h=4, center=ABOVE);
                can(d = 8, h=face_thickness, center=BELOW);
            }
            can(d=id, h=a_lot);
        }
    }
    if (orient_for_build) {
        translate([0, 0, face_thickness]) shape();
    } else {
        translate([0, -dz_filament, -cage_length_half_length]) shape();
        translate([0, -dz_filament, cage_length_half_length]) rotate([180, 0, 0]) shape();
    }
}

   
module end_block() {
    x = 10;
    z = 10;
    difference() {
        block([x, y_end_block, z], center=ABOVE+RIGHT);
        filament_clearance(); 
        #ptfe_tube_packing_clearance();

        center_reflect([1, 0, 0]) translate([dx_screws, 2.5, 25]) hole_through("M2", cld=0.2, $fn=12);
        face_plate_screw_clearance();
    }
}

module end_cap(orient_for_build) {
    module blank() {
        hull() {
            glide_placement() {
                rotate([0, 0, 135]) block([7, 7, z_end_cap], center=ABOVE);
                block([7, 7, z_end_cap], center=ABOVE);
            }
            block([5, 15, z_end_cap], center=ABOVE); // Space for packing gland screws and nuts
        }
    }
    module shape() {
        z_glide = 100;
        difference() {
            blank();
            filament_clearance(); 
            ptfe_tube_packing_clearance();
            face_plate_screw_clearance();
            translate([0, 0, -z_glide/2-0.1]) ptfe_glides(h=z_glide, as_clearance=true);
        }
        
    }
    if (orient_for_build) {
        translate([0, 0, z_end_cap]) rotate([180, 0, 0]) shape();
    } else {
        shape();
    }
}


module packing_gland_face(orient_for_build) {
    module located_shape() {
        difference() {
            translate(gland_translation) block(packing_gland_face, center=ABOVE+RIGHT);
            face_plate_screw_clearance();
            translate([0, 0, dz_filament]) rotate([90, 0, 0]) can(d = 4.5, h=a_lot, rank=10);
        }
    } 
    if (orient_for_build) {
        translate([0, gland_translation.y + 10, 0] ) rotate([90, 0 , 0]) translate(-gland_translation) located_shape();
        translate([0, gland_translation.y + 20, 0] ) rotate([90, 0 , 0]) translate(-gland_translation) located_shape();
    } else {
        located_shape();
    }     
}


module actuator_cage() { 
    center_reflect([0, 1, 0]) {
        translate([0, cage_length_half_length, 0]) end_block();
    }
}

module ptfe_tube_as_slide(h, as_clearance, clearance=0.2, ) {
    hollow = as_clearance ? 0 : 2.0;
    actual_clearance = as_clearance ? clearance: 0;
    color("white") can(d=ptfe_diameter + 2 * actual_clearance, hollow=hollow, h=h);
}

module ptfe_glide(h, orient_for_build = false, angle=0, as_clearance=true) {
    assert(is_num(h));
    z_capture = ptfe_diameter/2 - 1.5 + 0.75;
    x_side = 8;
    y_side = 6;
    screw_offset = 3;
    module screw_clearance() {
        center_reflect([0, 0, 1]) 
            translate([5, 0, h/2 + screw_offset]) 
                rotate([0, 90, 0]) hole_through("M2", $fn=12, cld=0.2);
    }
    module shape(as_clearance) {
        extra_length = 20;
        color("green") {
            rotate([0, 0, angle]) {
                difference() {
                    block([x_side, y_side, h + 4 * screw_offset]); 
                    ptfe_tube_as_slide(h=h, as_clearance = true);
                    translate([0, 0, z_capture]) plane_clearance(FRONT);
                    screw_clearance();
                }
                if (as_clearance) {
                    screw_clearance();
                }
            }
            
        }
    }
    if (!orient_for_build && !as_clearance) {
        ptfe_tube_as_slide(h=h, as_clearance = false);
    } 
    if (orient_for_build) {
        translate([0, 0, side/2]) rotate([0, -90, 90]) shape(as_clearance=false);
    } else {
        shape(as_clearance=as_clearance);
    }
}

module glide_placement() {
    center_reflect([0, 1, 0]) 
        translate([x_traveller_front, y_traveller_front/2, 0]) 
            children(0);
    translate([-x_traveller_behind - ptfe_diameter/2 + slide_engagement, 0, 0]) 
        children(1);
}



module ptfe_glides(h=100, as_clearance=false) {
    glide_placement() {
        ptfe_glide(h = h, as_clearance = as_clearance, angle=-135);
        ptfe_glide(h = h, as_clearance = as_clearance);
    }        
}


module traveller(orient_for_build, screw_name, screw_family, show_mocks=false) {
    module blank() {
        hull() {
            block([x_traveller_front, y_traveller_front, z_traveller], center=FRONT);
            block([x_traveller_behind, y_traveller_behind, z_traveller], center=BEHIND);
        }
    }
    module nut_item(as_clearance) {
        translate([filament_diameter/2 + gap_between_nut_and_filament, 0, 0]) {
            rotate([0, -90, 0]) {
                if (as_clearance) {
                    nutcatch_sidecut(screw_family, clk=0.2, clh=0.2);
                } else {
                   nut(screw_family, $fn=12); 
                }
            }
        }
    }
    module screw_item(as_clearance) {
        rotate([0, -90, 0]) {
            if (as_clearance) {
                hole_through(screw_family, $fn=12); 
            } else {
                rotate([0, 180, 0]) translate([0, 0, l_clamp_screw]) screw(screw_name, $fn=12);
            }
        }
    }
    
    module shape() {
        color("brown") difference() {
            blank();
            filament_clearance();
            nut_item(as_clearance = true);
            screw_item(as_clearance = true);
            ptfe_glides(as_clearance=true);

        }
        if (show_mocks) {
            color("silver") {
                nut_item(as_clearance = false);
                screw_item(as_clearance = false);
            }      
        }
    }
    if (orient_for_build) {
        translate([0, 0, z_traveller/2]) shape();
    } else {
        shape();
    }
    
}


if (build_cage) {
    if (orient_for_build) { 
            actuator_cage();
    } else {
        color("teal") rotate([90, 0, 0]) actuator_cage();
    }
}


if (build_packing_gland_face) {
    if (orient_for_build) {
        packing_gland_face(orient_for_build = true);
    } else {
        color("brown") packing_gland_face(orient_for_build = false);
    }
}

if (build_packing_gland) {
    if (orient_for_build) {
        for (i = [0 : packing_gland_count - 1]) { 
            translate([40, i*10, 0]) {
                packing_gland(orient_for_build = true, id = packing_gland_id);
            }
        }
    } else {
        color("aquamarine") packing_gland(orient_for_build = false);
    }            
}

if (build_traveller) {
    if (orient_for_build) {
        translate([-20, 0, 0]) traveller(
            orient_for_build = true, 
            show_mocks=false, 
            screw_family=clamp_screw_family, 
            screw_name=clamp_screw_name);        
    } else {
        traveller(
            orient_for_build = false, 
            show_mocks=show_mocks, 
            screw_family=clamp_screw_family, 
            screw_name=clamp_screw_name);
    }
}



if (build_ptfe_glides) {
    if (orient_for_build) {
        translate([-35, 0, 0]) ptfe_glide(orient_for_build = true, h = slide_length, show_mocks=false);
        translate([-45, 0, 0]) ptfe_glide(orient_for_build = true, h = slide_length, show_mocks=false);
        translate([-55, 0, 0]) ptfe_glide(orient_for_build = true, h = slide_length, show_mocks=false);
    } else {
        ptfe_glides(h = slide_length, as_clearance=false);
    } 
}

if (build_end_caps) {
    if (orient_for_build) {
        translate([0, 0, 0]) end_cap(orient_for_build=true);
    } else {
        end_cap(orient_for_build=false);
    }
}
    
