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

build_slide = true;
build_cage_lower = true;
build_cage_upper = true;
build_packing_gland_face = true;
build_packing_gland = true;
build_traveller = true;
build_clamp = true;

/* [Actuator Design] */

actuator_range_of_motion = 50; // [10 : 1: 100]
d_clamp_screw = 3; //[2, 2.5, 3, 4, 5, 6]
l_clamp_screw = 8; //[4, 5, 6, 8, 10, 12]
clamp_screw_family = str("M", d_clamp_screw); // [M2, M2.5, M3, M4, M5, M6]
echo("clamp_screw_family", clamp_screw_family);
clamp_screw_name = str("M", d_clamp_screw, "x", l_clamp_screw);
echo("clamp_screw_name", clamp_screw_name);


clamp_opening = 0.5; // [0.25, 0.5, 0.75, 1]
x_clamp_minimum = 3;

y_packing_gland = 2;

packing_gland_id = 4.1; // [4.0, 4.05, 4.1, 4.15, 4.2, 4.25]
packing_gland_count = 2;
x_clamping_interference = 0.5;

module end_of_customization() {}

df = _get_fam(clamp_screw_family);
echo("df", df);
nutkey = df[_NB_F_NUT_KEY];
echo("nutkey", nutkey);
nutheight = df[_NB_F_NUT_HEIGHT];
echo("nutheight", nutheight);

a_lot = 1000;

filament_diameter = 1.75;
filament_clearance = 0.5;
filament_wall = 1;
slot_width = 3; // For an M3 nut to ride include
d_clamp_slot = 2;

strut_width = 3;
//clamp_thickness = 2;
traveller_engagement = 1;
traveller_clearance = 0.4;
extra_for_screws = 2;
x_traveller = 7 + nutkey; 
y_traveller = 8 + nutkey; 
z_traveller = 9 + nutheight; 
echo("x_traveller: ", x_traveller);
x = x_traveller + 2 * strut_width + 2*filament_clearance;
y = actuator_range_of_motion + y_traveller;
z = 2 * strut_width + slot_width + filament_diameter + 2*filament_clearance + 2 * traveller_engagement + filament_wall;    
dz_slot = strut_width + slot_width/2 + traveller_engagement + traveller_clearance;

traveller = [x_traveller, y_traveller, z_traveller];
dz_filament = dz_slot + slot_width/2 + filament_clearance + filament_diameter/2 + nutheight;
y_end_block = 10;
dx_screws = 5;    
faceplate_screw_translation = [dx_screws, 2.5, dz_filament];

packing_gland_face = [x, y_packing_gland, z-dz_slot];
cage_length_half_length = actuator_range_of_motion/2 + y_traveller + 3 + y_end_block;
gland_translation = [0, cage_length_half_length+1, dz_slot-1];

// slide_extra should include engagement with mounting, as well as extra for clearance.
// Guess for now!
slide_extra = 10;
slide_length = actuator_range_of_motion + traveller.y + slide_extra;

module traveller_clearance() {
    z_tc = z - 2 * strut_width;
    x = x_traveller + 2*traveller_clearance;
    translate([0, 0, strut_width]) block([x, a_lot, z_tc], center=ABOVE); 
}


module filament_clearance() {
    translate([0, 0, dz_filament]) rotate([90, 0, 0]) can(d=2.5, h=200);
}


module slot_hole(as_slot_clearance=true, as_guide_hole=false) {
    cld = as_slot_clearance ? 0.4 : as_guide_hole ? 0.2 : assert(false);
    rotate([0, 90, 0]) translate([0, 0, 25]) hole_through("M3", cld=cld, $fn=12);
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
    translate([0, 0, 25]) hole_through("M3", cld=0.4, $fn=12);
}    


module clamp_slot_clearance(clamp_opening, transition) {
    
    //translate([0, 0, dz_slot]) { 
        center_reflect([1, 0, 0]) {            
//            if (transition > 0) {
//                hull() {
//                    translate([x_clamp_minimum, 0, 0]) hole_through("M3");
//                    translate([x_clamp_minimum + clamp_opening, transition, 0]) ole_through("M3");
//                }
//            }            
//
                #hull() {
                    #translate([0, a_lot, 25]) hole_through("M3", cld=0.4, $fn=12);
                    translate([0, a_lot, 25]) hole_through("M3", cld=0.4, $fn=12);
                } 
            }
 //       }
    // }        
}


module slot_block(length, clamp_opening, transition) {
    slot_block = [x, length, z];
    difference() {
        block(slot_block, center = ABOVE+RIGHT);
        slot_clearance();
        clamp_slot_clearance(clamp_opening, transition);
        traveller_clearance();
        filament_clearance();       
    }
}


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




module ptfe_tube_packing_clearance() {
    translate([0, y_end_block, dz_filament]) rotate([90, 0, 0]) can(d = 6, taper=5, h=4, center=ABOVE, rank=10);
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
    difference() {
        block([x, y_end_block, z], center=ABOVE+RIGHT);
        filament_clearance(); 
        ptfe_tube_packing_clearance();

        center_reflect([1, 0, 0]) translate([dx_screws, 2.5, 25]) hole_through("M2", cld=0.2, $fn=12);
        face_plate_screw_clearance();
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
        slot_block(length=actuator_range_of_motion/2, clamp_opening=0, transition=0);
        translate([0, actuator_range_of_motion/2, 0]) slot_block(length=y_traveller + 3, clamp_opening=1, transition=3);
        translate([0, actuator_range_of_motion/2 + y_traveller + 3, 0]) end_block();
    }
}


//            center_reflect([1, 0, 0]) hull() {
//                translate([x_clamp_minimum-0.5, 0, 0]) clamp_hole();
//                translate([x_clamp_minimum+clamp_opening, 0, 0]) clamp_hole();
//            }
//            clamp(as_clearance=true);
module clamp(orient_for_build, as_clearance=false, x_clamping_interference = 0.1) {
    dz = strut_width  + traveller_clearance;
    clamp_width = 4;
    clamp_depth = 2.2;
    clamp_length = 5;
    
    clamp_clearance = 0.4;
    clearances = 2*[clamp_clearance, clamp_clearance, 0];
    
    module located_shape() {
        x_clamping = filament_diameter/2 - x_clamping_interference;
        center_reflect([1, 0, 0]) difference() {
            rotate([90, 0, 0]) translate([x_clamping, 0, traveller.z]) block ([clamp_length, clamp_width,clamp_depth], center=ABOVE+FRONT);
            translate([x_clamp_minimum, 0, 0]) rotate([90, 0, 0]) clamp_hole(); 
        }        
    }
    if (as_clearance) {
        translate([0, 0, traveller.z - 0.5]) 
            block([20, clamp_width, clamp_depth] + clearances, center=BELOW, rank=5);
    } else if (orient_for_build) { 
        rotate([-90, 0 , 0]) translate([0, traveller.z, 0]) located_shape();
    } else {
        located_shape();
    }
}

module ptfe_glide(h, as_clearance, clearance=0.2) {
    hollow = as_clearance ? 0 : 2.0;
    actual_clearance = as_clearance ? clearance: 0;
    color("white") can(d=4.0 + 2 * actual_clearance, hollow=hollow, h=h);
}

module ptfe_glides(as_clearance=false) {
    center_reflect([1, 0, 0]) 
        translate([traveller.x/2+0.75, 0, 0]) 
            rotate([90, 0, 0]) 
                ptfe_glide(h = 100, as_clearance = as_clearance);
    translate([0, 0, traveller.z+1.4]) rotate([90, 0, 0]) ptfe_glide(h = 100, as_clearance = as_clearance);
                    
}

// ***************************************************************************

module traveller(orient_for_build, screw_name, screw_family, show_mocks=false) {
    dz = strut_width  + traveller_clearance;
    
    module blank() {
        hull() {
            block([traveller.x, traveller.y, 3], center=ABOVE);
            #translate([0, 0, nutheight + 4]) block([nutheight + 4, traveller.y, 0.1], center=BELOW);
            translate([0, 0, traveller.z]) block([4, traveller.y, 0.1], center=BELOW);
        }
    }
    
    module shape() {
        color("brown") difference() {
            blank();
            translate([0, 0, -dz]) filament_clearance();
            translate([0, 0, nutheight + 2]) nutcatch_sidecut(screw_family, clk=0.2, clh=0.2);
            translate([0, 0, nutheight + 4 + filament_diameter/2 + 1]) hole_through(screw_family, $fn=12); // dz_filament
            ptfe_glides(as_clearance=true);

        }
        if (show_mocks) {
            color("silver") {
                translate([0, 0, nutheight+2]) nut(screw_family, $fn=12);
                rotate([180, 0, 0]) translate([0, 0, 1.5]) screw(screw_name, $fn=12);
            }
            //ptfe_glides();
            
        }
    }
    if (orient_for_build) {
        translate([0, 0 , traveller.x/2]) rotate([0, -90, 0]) shape();
    } else {
        translate([0, -dz , 0]) rotate([90, 0, 0]) shape();
    }
    
}

module actuator_cage_lower() {
    difference() {
        actuator_cage();
        translate([0, 0, dz_slot]) plane_clearance(ABOVE);
    }
}

module actuator_cage_upper() {
    difference() {
        actuator_cage();
        translate([0, 0, dz_slot]) plane_clearance(BELOW);
    }
}

module slide(orient_for_build = false, length=10, show_mocks = show_mocks) {
    z_capture = 4/2 - 1.5 + 0.75;
    
    module tube(as_clearance) {
        extra_length = as_clearance ? 10 : 0;
        rotate([90, 0, 0]) ptfe_glide(h = length + extra_length, as_clearance = as_clearance);
    }
    difference() {
        block([6, length, 6]); 
        tube(as_clearance = true);
        translate([0, 0, z_capture]) plane_clearance(ABOVE);
    }
    if (show_mocks) {
        tube(as_clearance = false);
    }
}



if (build_cage_lower) {
    if (orient_for_build) { 
        // Split in half for printing in two pieces:
        translate([0, 0, 0]) rotate([0, 0, 0]) {
            actuator_cage_lower();
        }
    } else {
        color("teal") rotate([90, 0, 0]) actuator_cage_lower();
    }
}

if (build_cage_upper) {
    if (orient_for_build) {       
        translate([x + 5, 0, z]) rotate([0, 180, 0]) {
            actuator_cage_upper();
        }
    } else {    
        color("teal") rotate([90, 0, 0]) actuator_cage_upper();
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

if (build_clamp) {
    if (orient_for_build) {
        translate([-35, 0, 0]) clamp(orient_for_build = true, x_clamping_interference=x_clamping_interference);
    } else {
        clamp(orient_for_build = false);
    }    
}

if (build_slide) {
    if (orient_for_build) {
        translate([-35, 0, 0]) slide(orient_for_build = true, length = slide_length);
    } else {
        translate([0, -traveller.z-4.7, 0]) 
            rotate([-90, 0, 0])
                slide(orient_for_build = false, length = slide_length, show_mocks = show_mocks);
        center_reflect([1, 0, 0]) 
            translate([-traveller.x/2, -4.3, 0])        
                rotate([0, 0, 45]) rotate([90, 0, 0])
                    slide(orient_for_build = false, length = slide_length, show_mocks = show_mocks);  
    }   
}
    
