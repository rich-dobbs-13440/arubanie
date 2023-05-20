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
build_inlet = true;

/* [Guide design] */

y_lip = 0.5;
z_lip = 2;

y_filament_offset = 15.4; // [15.0  : 0.05: 16,0]
/* [Tube design] */

od_ptfe_tube = 4 + 0;
h_taper = 2;
l_tube_holder = 7; 
ptfe_tube_tolerance = 0.2;

z_runout_detector_screw_lift = 2; //[0: 0.5: 2.5]

/* [Colors] */
guide_show_parts = false;
guide_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
inlet_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]


bracket_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
runout_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]
extruder_alpha = 1; // [1:Solid, 0.25:Ghostly, 0:Invisible]

guide_color = "#AF55E4";
outlet_color = "purple";
inlet_color = "violet";

idler_color = "#800000"; // Hexadecimal value for maroon color


guide_visualization = visualize_info(guide_color, guide_alpha);
inlet_visualization = visualize_info(inlet_color, inlet_alpha);
extruder_visualization = visualize_info(BLACK_PLASTIC_1, extruder_alpha);
bracket_visualization = visualize_info(CREALITY_POWDER_COATED_METAL_PLATE, bracket_alpha);
idler_visualization = visualize_info(idler_color, bracket_alpha);
runout_visualization = visualize_info(BLACK_PLASTIC_2, runout_alpha);

module end_of_customization() {}

entrance_translation = [0, 14.6, 10.0];

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
runout_detector_y_screw_offset = 4;

z_lifted_screw = runout_detector.z + z_runout_detector_screw_lift;
 
runout_detector_screw_offsets = [
    [runout_detector.x - runout_detector_x_screw_offset, runout_detector_y_screw_offset, runout_detector.z],
    [runout_detector_x_screw_offset, runout_detector.y - runout_detector_y_screw_offset, runout_detector.z],
];



extruder = [42.8, 43.3, 24.7];
dy_extruder_offset = -16.5;
bracket_front = [57, 45.6, 4.7];
dy_back_bracket = dy_extruder_offset + extruder.y + 4;

module extruder() {
    translate([0, dy_extruder_offset, 0]) {
        visualize(extruder_visualization) { 
            difference() {
                block(extruder, center=ABOVE+RIGHT+BEHIND);
                translate(entrance_translation + [0, -dy_extruder_offset, 0]) rod(d=5, l=a_lot);
            }
        }
    }
}

module extruder_support_bracket() {
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

module runout_detector(as_screw_clearance=false) {
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
    runout_detector();
    extruder();
    extruder_support_bracket();
    ZAxisIdlerRoller(9.1, 16.5);
}



if (build_guide) {
    guide(show_vitamins=show_vitamins, orient_for_build=orient_for_build); 
}

if (build_outlet) {
    if (orient_for_build) {
        translate([10, 10, 0]) outlet(orient_for_build=true);
    } else {
        outlet(orient_for_build=false); 
    }
}

if (build_inlet) {
    if (orient_for_build) {    
        translate([20, 20, 0]) inlet(orient_for_build=true);
    } else {
        inlet(orient_for_build);
    }
}




module outlet(orient_for_build=false) {

    dx_ptfe = l_tube_holder - h_taper;
    module shape() {    
        render(convexity=10) difference() {
            can(d=8, h=l_tube_holder, center=ABOVE);
            translate([0, 0, l_tube_holder]) can(d=4.5, taper=6, h=h_taper, center=BELOW);
            can(d=2.0, taper=3, h=h_taper, center=ABOVE);
            translate([0, 0, 2]) can(d=4.5, h=a_lot, center=ABOVE);
        }
    }
    if (orient_for_build) {
        shape();
    } else {
        translate(entrance_translation) {
            if (show_vitamins) {
                color(PTFE_COLOR) {
                    rod(d = od_ptfe_tube, l=l_tube_holder + 1, center=FRONT); 
                }
            }
            color(outlet_color) {
                rotate([0, 90, 0])  shape();
            }
        }
    }
    
}







module inlet(orient_for_build=false, as_clearance=false) {

    module shape() {
        render(convexity=10) difference() {
            can(d=8, h=l_tube_holder, center=ABOVE);
            can(d=6, taper=4.5, h=h_taper, center=ABOVE);
            translate([0, 0, l_tube_holder]) can(d=2, taper=5, h=h_taper, center=BELOW);
            translate([0, 0, l_tube_holder-2]) can(d=4.5, h=a_lot, center=BELOW);
        }
    }
    if (as_clearance) {
        translate(entrance_translation) rod(d=7.9, l=a_lot);
        
    } else if (orient_for_build) {
        translate([0, 0, l_tube_holder]) rotate([180, 0, 0]) shape();
    } else {
        translate(entrance_translation + [runout_detector_translation.x, 0, 0]) {
            visualize(inlet_visualization) {
                translate([-l_tube_holder, 0, 0]) rotate([0, 90, 0])  shape();
            }
            if (show_vitamins) {
                color(PTFE_COLOR) {
                    translate([-h_taper, 0, 0])  { 
                        rod(d = od_ptfe_tube, l=l_tube_holder + 1, center=BEHIND); 
                    }
                }
            }            
        }
    }
    
}



module guide(orient_for_build = false, show_vitamins = true) {
    //extruder_shim = [4, 1, 4];
    face = [4, 8, entrance_translation.z + 5];
    bottom_plate = [runout_detector_translation.x, entrance_translation.y - 4, 2];
    lip = [bottom_plate.x, y_lip, 2 + runout_detector.z];
    if (show_vitamins) {
        translate([runout_detector_translation.x/2, entrance_translation.y, 0]) 
            color(STAINLESS_STEEL)
                center_reflect([1, 0, 0]) 
                    center_reflect([0, 1, 0])  
                        translate([5, 8, z_lifted_screw ]) 
                            screw("M2.5x16"); 
    }
    
   

    module runout_face() {
        color("pink") 
        difference() {
            translate([runout_detector_translation.x,  0, 0]) {
                block([2, runout_detector.y-5, runout_detector.z], center=ABOVE+BEHIND+RIGHT); 
            }
            inlet(as_clearance=true);
        }
    }
    
    module front_base() {
        translate([0, 0, -2]) {
            hull() {
                translate([lip.x/2, 0, 0]) block([lip.x/2, lip.y, 4], center=ABOVE+FRONT+LEFT);
                translate([lip.x, 0, 0]) block([2, lip.y, lip.z], center=ABOVE+BEHIND+LEFT);
            }
            
        }
        
    }        

    module back_base() {
      color("blue") {
          block(bottom_plate,  center=ABOVE+FRONT+RIGHT);  
          translate([0, 0, -z_lip]) block([bottom_plate.x + 4, y_lip, 4], center=ABOVE+FRONT+LEFT);  
      }
    }

    module runout_screw_tab() {
        color("orange") {
            dx_screw = runout_detector_translation.x + runout_detector_screw_offsets[1].x;
            dy_screw  = runout_detector_translation.y + runout_detector_screw_offsets[1].y; 
            dz = runout_detector.z;
            dx_base = runout_detector_translation.x;
            difference() {
                hull() {
                    translate([dx_screw, dy_screw, dz]) can(d=14, h=2, center=ABOVE);
                    translate([dx_base, 0, dz]) #block([4, y_lip, 2], center=ABOVE+LEFT);  
                }
                runout_detector(as_screw_clearance=true);
            }
            // Add a lip at front of detector.  Can't be to big or it will interfere with the socket.
            translate([runout_detector_translation.x, 0, 0]) block([2, y_lip, runout_detector.z], center=ABOVE+FRONT+LEFT);
        }
    }

    module printing_support() {
        color("limegreen") 
        render(convexity=10) difference() {
            hull() {
                inlet(orient_for_build=false);
                translate([runout_detector.z, 5, 8]) block([0.1, 2, 2], center=LEFT+ABOVE+RIGHT);
            }
            inlet(as_clearance=true);
        }
    }
    //color(guide_color) {
    module parts() {
        color("green") front_base();
        back_base();
        runout_face();
        runout_screw_tab();
        inlet(orient_for_build=false);
        printing_support();
    }
    module shape() {
        difference() {
            parts();
            //translate(entrance_translation) rod(d = 2, l=a_lot);  
        }
    }
    visualize(guide_visualization, guide_show_parts) {
        if (orient_for_build) {
            translate([90, 0 , 0]) 
            shape();
        } else {
            shape();
        }
    }
}




