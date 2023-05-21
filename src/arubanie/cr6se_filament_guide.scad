include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <lib/material_colors.scad>

a_lot = 100;



/* [Output Control] */
show_mocks = true;
show_vitamins = true;

orient_for_build = false;

build_guide = true;
build_outlet = true;
build_inlet = false; // Currently, the inlet is built into the guide!

/* [Guide design] */
adjustable_entrance = false;
y_lip = 0;
z_lip = 2;
z_runout_screw_tab = 4;
pivot_clearance_angle = 3;
x_extruder_clearance = 0.5;
x_runout_clearance =0.5;
dx_slot = 0.1;
dy_slot = 0.25;
slot_translation = [dx_slot, dy_slot, 0];

/* [Tube design] */

od_ptfe_tube = 4 + 0;
h_taper = 7;
l_tube_holder = 7; 
ptfe_tube_tolerance = 0.1;

as_cavity = false;

z_runout_detector_screw_lift = 2; //[0: 0.5: 2.5]

/* [Colors] */
guide_show_parts = false;
guide_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
inlet_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
outlet_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible] 

bracket_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
runout_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
extruder_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]

guide_color = "#AF55E4";
outlet_color = "purple";
inlet_color = "violet";

idler_color = "#800000"; // Hexadecimal value for maroon color


guide_visualization = visualize_info(guide_color, guide_alpha);
inlet_visualization = visualize_info(inlet_color, inlet_alpha);
outlet_visualization = visualize_info(outlet_color, outlet_alpha);
extruder_visualization = visualize_info(BLACK_PLASTIC_1, extruder_alpha);
bracket_visualization = visualize_info(CREALITY_POWDER_COATED_METAL_PLATE, bracket_alpha);
idler_visualization = visualize_info(idler_color, bracket_alpha);
runout_visualization = visualize_info(BLACK_PLASTIC_2, runout_alpha);

module end_of_customization() {}

entrance_translation = [0, 15, 11]; //[0, 14.6, 10.0];

function visualize_info(color_code, alpha) = [color_code, alpha];
    
// TODO - move to a reusable location!
module visualize(info,  show_part_colors=false) {
    color_code = info[0];
    alpha = info[1];
    if (show_part_colors) {
        // Just pass through, so that underlying colors can be seen
        children();
    } else if (alpha == 0) {
        // Don't create anything.  This avoids some artifacts in rendering
        // such as wrong z ordering or not enough convexity being specified.
    } else {
        color(color_code, alpha) {
            children();
        }
    }
}

/* [ Dimensions] */


runout_detector = [40, 31.12, 17.75];
runout_detector_filament_offset  = [0, 16, entrance_translation.z];
runout_detector_translation = [19, entrance_translation.y - runout_detector_filament_offset.y, 0];
runout_detector_x_screw_offset = 5;
runout_detector_y_screw_offset = 3.5;

z_lifted_screw = runout_detector.z + z_runout_detector_screw_lift;
 
runout_detector_screw_offsets = [
    [runout_detector.x - runout_detector_x_screw_offset, runout_detector_y_screw_offset, runout_detector.z],
    [runout_detector_x_screw_offset, runout_detector.y - runout_detector_y_screw_offset, runout_detector.z],
];



extruder = [42.8, 43.3, 24.7];
dy_extruder_offset = -16.5;
bracket_front = [57, 45.6, 4.7];
dy_back_bracket = dy_extruder_offset + extruder.y + 4;

module Extruder() {
    translate([0, dy_extruder_offset, 0]) {
        visualize(extruder_visualization) { 
            difference() {
                block(extruder, center=ABOVE+RIGHT+BEHIND);
                translate(entrance_translation + [0, -dy_extruder_offset, 0]) rod(d=5, l=a_lot);
            }
        }
    }
}

module ExtruderSupportBracket() {
    visualize(bracket_visualization) {
        hull() {
            translate([-extruder.x, 0 , 0])  can(d=2, h=bracket_front.z, center=BELOW+RIGHT+FRONT);
            translate([-extruder.x, dy_back_bracket , 0])  can(d=2, h=bracket_front.z, center=BELOW+LEFT+FRONT);
            translate([bracket_front.x, bracket_front.y, 0]) can(d=2, h=bracket_front.z, center=BELOW+BEHIND+LEFT);
            translate([bracket_front.x, 0, 0]) can(d=2, h=bracket_front.z, center=BELOW+BEHIND+RIGHT);
        }
        hull() {
            translate([-extruder.x, dy_extruder_offset , 0])  can(d=2, h=bracket_front.z, center=BELOW+RIGHT+FRONT);
            translate([-extruder.x, 1 , 0])  can(d=2, h=bracket_front.z, center=BELOW+RIGHT+FRONT);
            translate([0, 1 , 0])  can(d=2, h=bracket_front.z, center=BELOW+RIGHT+BEHIND);
            translate([0, dy_extruder_offset, 0])  can(d=2, h=bracket_front.z, center=BELOW+RIGHT+BEHIND);
        }
    }
}

module RunoutDetector(as_screw_clearance=false) {
    translate(runout_detector_translation) { 
        if (as_screw_clearance) {
            translate(runout_detector_screw_offsets[0] + [0, 0, 25]) hole_through("M3", cld=0.6, $fn=12);
            translate(runout_detector_screw_offsets[1] + [0, 0, 25]) hole_through("M3", cld=0.6, $fn=12);            
        } else {
            difference() {
                visualize(runout_visualization) block(runout_detector, center=ABOVE+FRONT+RIGHT);
                translate(runout_detector_filament_offset) rod(d=4, l=a_lot);
                
            }
            color(STAINLESS_STEEL) {
                translate(runout_detector_screw_offsets[0] + [0, 0, z_runout_detector_screw_lift]) screw("M3x25");
                translate(runout_detector_screw_offsets[1] + [0, 0, z_runout_detector_screw_lift]) screw("M3x25");
            }
        }
    } 
    
    
}



module ZAxisIdlerRoller(offset_x = 0, offset_y = 0) {
    // Dimensions
    roller_diameter = 9.1;     // Diameter of the roller
    roller_thickness = 5.5;    // Thickness of the roller


    // Create Z-axis Idler Roller
    translate([offset_x, offset_y, roller_thickness/2]) {
        visualize(idler_visualization)
        cylinder(d = roller_diameter, h = roller_thickness, center = true);
    }
}



if (show_mocks && ! orient_for_build) {
    RunoutDetector();
    Extruder();
    ExtruderSupportBracket();
    ZAxisIdlerRoller(9.1, 16.5);
}



if (build_guide) {
    translation = orient_for_build ? [0, 0, 0] : [0, 0, 0];  // This is the main part, so keep it at the origin.
    translate(translation) 
        guide(
            show_vitamins=show_vitamins, 
            orient_for_build=orient_for_build,
            adjustable_entrance=adjustable_entrance); 
}

if (build_outlet && adjustable_entrance) {
    if (orient_for_build) {
        translate([0, 20, 0]) outlet(orient_for_build=true);
    } else {
        outlet(orient_for_build=false); 
    }
}

if (build_inlet) {
    if (orient_for_build) {    
        translate([-10, 0, 0]) inlet(orient_for_build=true);
    } else {
        inlet(orient_for_build, ptfe_lining = adjustable_entrance, as_cavity=as_cavity);
    }
}




module outlet(orient_for_build=false, as_clearance=false, ptfe_lining=false, l_tube_holder=7) {
    id = 4.0 + 2*ptfe_tube_tolerance;
    dx_ptfe = l_tube_holder - h_taper;
    module shape() {    
        render(convexity=10) difference() {
            can(d=8, h=l_tube_holder, center=ABOVE);
            if (ptfe_lining) {
                can(d=2.0, taper=3, h=h_taper, center=ABOVE);
                translate([0, 0, l_tube_holder]) can(d=id, taper=6, h=h_taper, center=BELOW);
                translate([0, 0, 2]) can(d=id, h=a_lot, center=ABOVE);
            } else {
                hull() {
                    can(d=2.0, h = a_lot);
                    block([0.1, 1.5, a_lot], center=RIGHT);
                }
            }
        }
    }
    if (as_clearance) {
        if (ptfe_lining == false) {
            translate(entrance_translation) 
            rotate([0, 90, 0])
            hull() {
                can(d=2.0, h = a_lot);
                block([0.1, 1.5, a_lot], center=RIGHT);
            }
        }
    } else {
        if (orient_for_build) {
            shape();
        } else {
            
            translate(entrance_translation) {
                if (show_vitamins  && ptfe_lining) {
                    color(PTFE_COLOR) {
                        rod(d = od_ptfe_tube, l=l_tube_holder + 1, center=RIGHT); 
                    }
                }
                visualize(outlet_visualization) {
                    rotate([0, 90, 0])  shape();
                }
            }
        }
    }
    
}


module inlet(orient_for_build=false, as_clearance=false, ptfe_lining = false, as_cavity=false, l_tube_holder=7) {
    echo("orient_for_build", orient_for_build); 
    enough = 20;
    d_body = 8;
    d_taper = ptfe_lining ? 5 : d_body;
    
    d_ptfe_clearance = ptfe_lining ? 4.0 + 2*ptfe_tube_tolerance : 0;
    
    module cavity(ptfe_lining) {
        if (ptfe_lining) {
            hull() {
                can(d=6, taper=d_ptfe_clearance, h=h_taper, center=ABOVE);
                block([0.1, 6, h_taper], center=ABOVE+RIGHT);
                can(d=6, h=enough, center=BELOW);
            }
            
            hull() {
                translate([0, 0, l_tube_holder-2]) {
                    can(d=d_ptfe_clearance, h=enough, center=BELOW);
                    block([0.1, 6, enough], center=BELOW+RIGHT);
                }
            }                
        }
        translate([0, 0, l_tube_holder]) {
            hull() {
                can(d=2, taper=d_taper, h=h_taper, center=BELOW);
                block([0.1, 1.5, h_taper], center=BELOW+RIGHT);
                can(d=5, h=1, center=ABOVE);
            }
        }
        hull() {
            can(d=2, h=enough);
            block([0.1, 3, enough], center=RIGHT);
        }
    }
    
    
    module shape() {
        render(convexity=10) difference() {
            can(d=d_body, h=l_tube_holder, center=ABOVE);
            cavity(ptfe_lining);
        }
    }
    if (as_clearance) {
        translate(entrance_translation) {
            hull() {
                rod(d=d_body-.01, l=a_lot);
                if (ptfe_lining) {
                    block([a_lot, d_body, 1], center=RIGHT);
                }
            }
        }
    } else if (as_cavity) {
        cavity(ptfe_lining);
    } else if (orient_for_build) {
        translate([0, 0, l_tube_holder]) rotate([180, 0, 0]) shape();
    } else {
        translate(entrance_translation + [runout_detector_translation.x, 0, 0]) {
            visualize(inlet_visualization) {
                translate([-l_tube_holder, 0, 0]) rotate([0, 90, 0])  shape();
            }
            if (show_vitamins && ptfe_lining) {
                color(PTFE_COLOR) {
                    translate([-h_taper, 0, 0])  { 
                        rod(d = od_ptfe_tube, l=l_tube_holder + 1, center=BEHIND); 
                    }
                }
            }            
        }
    }   
}


module adjustment_screws(as_clearance = false) {
    module item() {
        if (as_clearance) {
            translate([0, 0, 25])  hole_through("M2", cld=0.4, $fn=12);
        } else {
            translate([0, 0, z_lifted_screw]) screw("M2.5x16"); 
        }
    } 
    translate([runout_detector_translation.x/2, entrance_translation.y, 0]) 
        color(STAINLESS_STEEL)
            center_reflect([1, 0, 0])  
                translate([-5, -8, 0 ])
                    item();
                            
}



module guide(orient_for_build = false, show_vitamins = true, adjustable_entrance = false) {

    x_face = z_runout_screw_tab;
    face = [
        x_face, 
        entrance_translation.y, 
        runout_detector.z - entrance_translation.z + z_runout_screw_tab];
    bottom_plate = [runout_detector_translation.x, 5, 4];
    lip = [bottom_plate.x, y_lip, 2 + runout_detector.z];
    if (show_vitamins) {
        if (adjustable_entrance) {
            adjustment_screws();
        }
    }
    
   

    module runout_face() {
        
        color("pink") 
        difference() {
            translate([runout_detector_translation.x-x_runout_clearance,  0, 0]) 
                translate([0, -y_lip, runout_detector.z + z_runout_screw_tab]) 
                        block(face, center=BELOW+BEHIND+RIGHT);           
            translate([runout_detector_translation.x - x_runout_clearance, entrance_translation.y, 0]) 
                rotate([0, 0, -pivot_clearance_angle]) 
                    plane_clearance(FRONT);
            inlet(as_clearance=true, ptfe_lining=adjustable_entrance);
        }
    }
    
    module front_base() {
        color("brown") 
        translate([0, 0, -x_face]) {
            hull() {
                translate([lip.x/2, 0, 0]) block([lip.x/2, lip.y, 4], center=ABOVE+FRONT+LEFT);
                translate([lip.x, 0, 0]) block([2, lip.y, lip.z], center=ABOVE+BEHIND+LEFT);
            }
            
        }
        
    }        
    
    module back_base() {
        color("blue") {
            difference() {
                union() {
                    translate([x_extruder_clearance, 0, 0]) {
                        hull() {
                            block(bottom_plate - [x_extruder_clearance, 0, 0],  center=ABOVE+FRONT+RIGHT);
                            translate([0, 2, 0]) can(d=10, h=4, center=FRONT+ABOVE+RIGHT);
                            
                        }
                        translate([8, 2, 0]) can(d=10, h=4, center=FRONT+ABOVE+RIGHT);  
                    }  
                    translate([x_extruder_clearance, 0, -z_lip]) 
                        block([bottom_plate.x + 4, y_lip, 6], center=ABOVE+FRONT+LEFT); 
                }
                adjustment_screws(as_clearance=true);
            } 
        }
    }
    
    d_screw_pad = 8;

    module runout_screw_tab() {
        color("orange") {
            
            dx_screw = runout_detector_translation.x + runout_detector_screw_offsets[1].x;
            dy_screw  = runout_detector_translation.y + runout_detector_screw_offsets[1].y; 
            dz = runout_detector.z;
            dx_base = runout_detector_translation.x-x_runout_clearance;
            base = [2*x_face, y_lip + entrance_translation.y, z_runout_screw_tab];
            echo("base: ", base);
            difference() {
                hull() {
                    translate([dx_screw, dy_screw, dz]) 
                        can(d=d_screw_pad, h=z_runout_screw_tab, center=ABOVE);
                    translate([dx_base, -y_lip, dz]) block(base, center=ABOVE+RIGHT);  
                }
                RunoutDetector(as_screw_clearance=true);
                translate(slot_translation) RunoutDetector(as_screw_clearance=true);
                translate(-slot_translation) RunoutDetector(as_screw_clearance=true);
            }
            // Add a lip at front of detector.  Can't be to big or it will interfere with the socket.
            if (y_lip > 0) {
                translate([runout_detector_translation.x, 0, 0]) 
                    block([2, y_lip, runout_detector.z], center=ABOVE+FRONT+LEFT);
            }
        }
    }
    module runout_pivot() {
        color("tan") {
            difference() {
                hull() {
                    translate([runout_detector_translation.x, 0, 0] + runout_detector_screw_offsets[0]) 
                        can(d=d_screw_pad, h=2, center=ABOVE);
                    translate([runout_detector_translation.x, 0, runout_detector.z] ) 
                        block([d_screw_pad,d_screw_pad, 2], center=ABOVE+RIGHT+FRONT);
                }
                RunoutDetector(as_screw_clearance=true);
            }
        }
    }

    module printing_support() {
        support_block = adjustable_entrance ? [0.1, 2, 2] : 
                        [runout_detector_translation.x-x_extruder_clearance, 2, 2];
        //dy = adjustable_entrance ? 0: entrance_translation.y;
        color("limegreen") 
        render(convexity=10) difference() {
            hull() {
                inlet(orient_for_build=false);
                if (!adjustable_entrance) {
                    translate([x_extruder_clearance, 0, 0]) outlet(orient_for_build=false, ptfe_lining=false);
                }
                translate([x_extruder_clearance, -y_lip, entrance_translation.z]) 
                    block([runout_detector_translation.x-x_extruder_clearance, 1, 4], center=FRONT+RIGHT);
            }
            hull() {
                inlet(as_clearance=true, ptfe_lining=adjustable_entrance);
                outlet(as_clearance=true);
            }
            translate([0, entrance_translation.y, 0]) plane_clearance(RIGHT);
            translate([x_extruder_clearance, entrance_translation.y, 0]) 
                rotate([0, 0, pivot_clearance_angle]) 
                    plane_clearance(BEHIND);
            translate([runout_detector_translation.x - x_runout_clearance, entrance_translation.y, 0]) 
                rotate([0, 0, -pivot_clearance_angle]) 
                    plane_clearance(FRONT);
        }
    }
    
    module parts() {
        x_inlet = adjustable_entrance ? l_tube_holder :  runout_detector_translation.x/2;
        x_outlet = x_inlet;
        if (adjustable_entrance) {
            front_base();
            back_base();
        }
        runout_face();
        runout_screw_tab();
        runout_pivot();
        translate([-x_runout_clearance, -0, 0]) 
            inlet(orient_for_build=false, ptfe_lining=adjustable_entrance, l_tube_holder=x_inlet);
        if (!adjustable_entrance) {
            translate([x_extruder_clearance, 0, 0]) 
                outlet(orient_for_build=false, ptfe_lining=false, l_tube_holder=x_outlet);
        }
        printing_support();
    }
    
    module shape() {
        difference() {
            parts();
            if (!adjustable_entrance) {
                translate(entrance_translation) rod(d = 2, l=a_lot);
            }  
        }
    }
    
    visualize(guide_visualization, guide_show_parts) {
        if (orient_for_build) {
            rotate([90, 0, 0]) translate([0, y_lip, 0]) shape();
        } else {
            shape();
        }
    }
}




