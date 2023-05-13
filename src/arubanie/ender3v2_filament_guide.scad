include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <MCAD/servos.scad>
include <MCAD/stepper.scad>
use <NopSCADlib/vitamins/rod.scad>
use <lib/ptfe_tubing.scad>
use <lib/ptfe_tubing_quick_connect.scad>

include <ender3v2_z_axis_mocks.scad>




/* [Output Control] */
orient_for_build = false;

build_filament_guide_faceplate = true;
build_filament_guide_cone = true;
build_filament_clip = true;
build_quick_connects = true;

show_mocks = true;
show_z_axis_support = true;
show_modified_z_axis = false;



/* [Filament Clip Design] */

d_cam_clearance = 24.0; // [5: 0.5: 20]
d_extruder_gear_clearance = 22.5; // [5: 0.5: 25]
d_idler_gear_clearance = 19; // [1: 0.5: 30]

filament_screw_locations = [
    [14, 6, 0],
    [24, 4, 0],
    [22, 22, 0],
    z_axis_tapped_screw_translation,
];


/* [Quick Connects Design] */
dz_quick_connects = 46; // [30 : 0.5 : 60]

module end_of_customization() {}




filament_guide_translation = [20, 12, 0];
filament_entrance_translation = [-4, 14., z_extruder_base + 5.31];

l_filament_entrance = 23;
multiplex_translation = filament_entrance_translation + [l_filament_entrance-1, 0, 0];
faceplace_clip_translation = multiplex_translation + [20, 0, -2];

if (show_mocks && !orient_for_build) {
    //servo_mount_screws(as_clearance=false);
    if (show_z_axis_support) {
        z_axis_support();
    }
    z_axis_threaded_rod();
    z_axis_bearing();
    spring_arm();
    extruder_base();
    stepper();
    filament_guide_screws(as_clearance=false);
    filament_guide_faceplate_screws(as_clearance = false, locate = true);
    quick_connect_screws();
    
}

if (build_filament_guide_cone) {
    if (orient_for_build) {
        translate([-40, -10, 0]) filament_guide_cone(orient_for_build=true);
    } else {
        filament_guide_cone();
    }
}

if (build_filament_guide_faceplate) {
    if (orient_for_build) {
        translate([-50, -20, 0]) filament_guide_faceplate(orient_for_build=true);
    } else {
        filament_guide_faceplate();
    }
    
}


if (build_filament_clip) {
    if (orient_for_build) {
        translate([10, 40, 0]) filament_clip(orient_for_build=true);
    } else {
        filament_clip();
    }
}

if (build_quick_connects) {
    quick_connects();
}



module filament_guide_cone(orient_for_build=false, as_clearance = false, clearance=0.2) {
    z_filament_entrance = 9.5;
    entrance_guide = [11, 7, 13];
    
    module screw_block() {
        hull() {
            for (screw_location = filament_screw_locations) {
                translate(screw_location) can(d=8, h=4, center=ABOVE);
            }
        }
    }
    module located_shape() {
        render(convexity=10) difference() {
            union() {
                translate(filament_guide_translation) {
                    translate([-1, 2, 0]) block(entrance_guide, center=ABOVE+BEHIND);
                    multiplex_entrance_guide(as_clearance, clearance);
                }
                screw_block();
            }
            filament_guide_screws(as_clearance=true);
            z_axis_bearing(as_clearance=true);
            z_axis_threaded_rod(as_clearance=true, clearance=0.3);
            translate(filament_entrance_translation) {
                ptfe_tubing(od=4, as_clearance=true, center=FRONT, l=l_filament_entrance);
            }
            multiplex_clearance();
            filament_guide_faceplate_screws(as_clearance=true, locate = true);
        }
    }
    if (orient_for_build) {
        translate(-filament_guide_translation) located_shape();
    } else {
        color("violet") located_shape();
    }
}


module filament_guide_screws(as_clearance=false) {
    module item() {
        if (as_clearance) {
            h_clearance = 6;
            translate([0, 0, -z_z_axis_support-h_clearance]) {  
                rotate([180, 0, 0]) {
                    hole_through("M3", cld=0.04, $fn=12);
                }
            }
//            translate([0, 0, -1]) {
//                rotate([180, 0, 0]) {
//                    nutcatch_parallel("M3", clh=2, clk=1);
//                }
//            }             
        } else {
            color("silver") {
                translate([0, 0, -z_z_axis_support]) {
                    rotate([180, 0, 0]) {
                        screw("M2.5x20",  $fn=12);
                    }
                }
                translate([0, 0, 2]) nut("M3");
            }
        }
    }
    for (screw_location = filament_screw_locations) {
        translate(screw_location)
            item();
    }
}



module multiplex_clearance() {
    translate(multiplex_translation) 
        rotate([0, -90, 0]) 
            can(d=20, taper=2.0, h=21, center=BELOW);
}


module multiplex_entrance_guide(as_clearance = false, clearance=0.2) {
    actual_clearance = as_clearance ? clearance : 0;
    clearances = 2 * [actual_clearance, actual_clearance, actual_clearance];
    entrance = [0.1, 2*multiplex_translation.z, 2*multiplex_translation.z];
    module entrance() {
        block(entrance + clearances, center = FRONT);
    }
    translate(multiplex_translation-filament_guide_translation) {
        hull() {
            block([0.1, 5, 5], center = FRONT);
            translate([15, 0, 0]) entrance();
            translate([19, 0, 0]) entrance();
        }
    }
    
}

wall = 2;
faceplate_clip = [5, 2*multiplex_translation.z, 2*multiplex_translation.z] + 2* [wall, wall, -2];

quick_connect_screw_block = [28, 14, 18];


module filament_guide_faceplate_screws(as_clearance=true, locate = false) {
    location_translation = locate ? faceplace_clip_translation + [0, 0, 2] : [0, 0, 2];
    color(BLACK_IRON) {
        translate(location_translation) {
            center_reflect([0, 1, 0]) {
                center_reflect([0, 0, 1]) {
                    rotate([90, 0, 0]) {
                        if (as_clearance) {
                            translate([-3, faceplate_clip.z/2, -faceplate_clip.y/2 + 6.5]) 
                                hole_through("M2", $fn=12);
                        } else {
                            translate([-3, faceplate_clip.z/2, faceplate_clip.y/2]) 
                                screw("M2x4");
                        }
                    }
                }
            }
        }
    }
    
}

module filament_guide_faceplate(orient_for_build=false) {
 
    module clip() {
        difference() {
            union() {
                block(faceplate_clip, center=BEHIND);
                //translate([0, 0, -8]) 
            }
            filament_guide_faceplate_screws(as_clearance=true); 
        } 
    }
    
    module located_clip() {
        render() difference() {
            translate(faceplace_clip_translation) {
                clip();
            }
            translate([0, 0, 0]) filament_guide(orient_for_build=false, as_clearance=true);
            translate([0, 0, -0.5]) filament_guide(orient_for_build=false, as_clearance=true);
            translate([-0.2, 0, 0]) multiplex_clearance();
        }
        
    }
    module ptfe_sockets() {
        difference() {
            translate(multiplex_translation + [20, 0, -2]) {        
                block([6, faceplate_clip.y, 2*multiplex_translation.z + 5] , center=FRONT);
                block(quick_connect_screw_block, center=FRONT);
            }
            plane_clearance(BELOW);
            for (az = [-12, -0, 12]) {
                for (ay = [-12, -0, 12]) {
                    translate(multiplex_translation) {
                        rotate([0, ay, az]) {
                            translate([22, 0, 0])
                                ptfe_tubing(od=4, as_clearance=true, center=FRONT, l=100); 
                        }
                    }
                }
            } 
            quick_connect_screws(as_clearance=true);
        }
    }
    color("aquamarine") {    
        if (orient_for_build) {
            located_clip();
            ptfe_sockets();
        } else {
            located_clip();
            ptfe_sockets();
        }
    }
}



module filament_clip(orient_for_build=false) {
    clip_height = z_spring_arm ;
    wall = 2;
    clip = [12.71, 22.58, clip_height] + 2*[wall, wall, 0];
    dz = z_extruder_base + z_spring_arm + wall;
    //rotation = orient_for_build ? [180, 0, 0] : [0, 0, 0];
    //rotate(rotation) {
    a_lot = 100;
    entrance = [4, 6, clip.z];
    module cam_clearance() {
        translate([3, 0, 0]) can(d=d_cam_clearance, h=a_lot);
    }
    module extruder_gear_clearance() {
        translate(stepper_translation) {
            can(d=d_extruder_gear_clearance, h=a_lot);
        }
    }
    module idler_gear_clearance() {
        translate(idler_translation) {
            can(d=d_idler_gear_clearance, h=a_lot);
        }
    }
    module entrance_clearance() {
        translate(filament_entrance_translation) 
            rotate([0, -90, 0]) 
                can(d=13, taper=2.5, h=20, center=BELOW);
    }
    
    module shape() {
        difference() {
            union() {
                translate([-dx_extruder_base+1+wall, 5, dz]) 
                    block(clip, center=BELOW+BEHIND+RIGHT);
                translate([-dx_extruder_base+1+wall, 11., dz])
                    block(entrance, center=BELOW+FRONT+RIGHT);
            }
            spring_arm(as_clearance=true, clearance=0.2); 
            cam_clearance();
            extruder_gear_clearance();
            idler_gear_clearance();
            z_axis_threaded_rod(as_clearance=true, clearance=1);
            entrance_clearance();
        }
    }
    if (orient_for_build) {
        rotate([180, 0, 0]) 
            translate([0, 0, -dz]) 
                shape();
    } else { 
        color("magenta") shape();
    }
}




module quick_connect_screws(as_clearance=false) {
    module multiplex(dz) {
        for (ax = [-6, 6]) {
            for (ay = [-6, 6]) {
                rotate([ax, ay, 0]) {
                    translate([0, 0, dz]) {
                        children();
                    }
                }
            }
        }            
    }
    translate(multiplex_translation) {
        rotate([0, 90, 0]) {    
            multiplex(dz_quick_connects + 6) {
                if (as_clearance) {
                    hole_through("M3", l=12);
                } else {
                    screw("M3x10");
                }
            }
        }
    }
}


module quick_connects(orient_for_build = false) {
    dz_cutoff = dz_quick_connects + 2;
    module bodies() {
        
        translate([0, 0, -dz_cutoff]) 
        difference() {
            for (ax = [-12, -0, 12]) {
                for (ay = [-12, -0, 12]) {
                    rotate([ax, ay, 0]) {
                        translate([0, 0, dz_quick_connects]) {
                            quick_connect_body(orient_for_build=true);
                        }
                    }
                }
            }
            translate([0, 0, dz_cutoff]) plane_clearance(BELOW);
        } 
    }
    module shape() {
        render(convexity=10) difference() {
            translate([0, 0, 0.01]) scale([1.2, 1.2, 1]) hull() bodies();
            hull() bodies();
            translate([0, 0, 2]) plane_clearance(ABOVE);
        }
        bodies();
    }
    color("purple") {
        if (orient_for_build) {
            shape();
        } else  {
            translate(multiplex_translation) 
                rotate([0, 90, 0]) 
                    translate([0, 0, dz_cutoff]) 
                        shape(); 
        }
    }
}




