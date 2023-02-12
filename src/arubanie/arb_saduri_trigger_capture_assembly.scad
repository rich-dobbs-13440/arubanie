/* 

All the parts in the assembly that captures the trigger for control of the 
air air and paint flow.

The coordinate system is based center of rotation of the paint pivot.

*/
include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <lib/small_3d_printable_scotch_yoke.scad>
use <trigger_holder.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;

$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [Logging] */

log_verbosity_choice = "DEBUG"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [ Example for demonstration] */
orient_for_build_example = true;


/* [ Paint Gudgeon Design] */
show_paint_pivot_gudgeon_yoke = true;

// Set to clear the trigger, at depressed with clearance for trigger cap.
// But also need to allow air barrel clip to clear!
paint_pivot_inner_height = 25;
wall_thickness = 2;
paint_pivot_bridge_thickness = 4;

paint_pivot_top_of_yoke =  
    paint_pivot_inner_height 
    + paint_pivot_bridge_thickness;

paint_gudgeon_color = "LightSkyBlue"; // [DodgerBlue, LightSkyBlue, Coral]
paint_gudgeon_alpha = 1; // [0:0.05:1]



/* [Paint Pull Rod Design] */


show_paint_pull_rod = true;
paint_pull_rod_length = 54; // [40:70]

paint_pull_rod_color = "Orange"; // [DodgerBlue, Orange, Coral]
paint_pull_rod_alpha = 1; // [0:0.05:1]

paint_pull_gudgeon_length = 17;
paint_pull_gudgeon_offset = 6;
dy_paint_pull_gudgeon_offset = 8;
paint_pull_nutcatch_depth = 8;
paint_pull_range_of_motion = [120,60];

//paint_pull_rod_angle = 34; // [0: 5 : 40]

/* [Air Flow Actuator Design] */
show_scotch_yoke = true;
show_scotch_yoke_mount = true;
show_air_flow_servo = false;

air_flow_servo_angle = 0; // [0 : 15 : 270]
// Must clear paint pot
dx_scotch_yoke = 55; // [50 : 1 : 70]
scotch_yoke_wall_thickness = 2; // [2 : 0.5 : 4]
scotch_yoke_options = undef; // [["show only", ["wall"]]]; //"push_rod"
scotch_yoke_base_plate_thickness = 6.8;
scotch_yoke_nutcatch_dy = 6;
scotch_yoke_depth_of_nutcatch = 4;
scotch_yoke_extra_depth_for_screw = 1.5;
scotch_yoke_extra_dy_right = 6;  // covers up small gap with servo mounting post.

scotch_yoke_extend_trigger_cap = 5;

scotch_yoke_radial_allowance = 0.4;
scotch_yoke_axial_allowance = 0.6;

scotch_yoke_bearing_width = 5;


air_flow_servo_color = "PaleTurquoise"; // [DodgerBlue, PaleTurquoise, Coral]
air_flow_servo_alpha = 1; // [0, 0.25. 0.5, 0.75, 1]


/* [Trigger Shaft Design] */

trigger_shaft_min_x = 10;
trigger_shaft_catch_clearance = 1;
trigger_shaft_diameter = 5;

trigger_shaft_range = 
    paint_pivot_inner_height 
    - trigger_shaft_catch_clearance
    - trigger_shaft_min_x ;
    


module end_of_customization() {}

FOR_DESIGN = [0, 0, 0];
FOR_BUILD = [180, 0, 0];  

viewing_orientation_example = orient_for_build_example ? FOR_BUILD : FOR_DESIGN;

barrel_diameter = master_air_brush("barrel diameter");

* screw(name="M3x8");

* translate([5, 0, 0]) nut("M3");

//module supported_servo_mounting(show_servo) {
//  
//    sub_micro_servo_mounting(
//        size=size_air_servo_mount,
//        include_children=show_servo,
//        center=ABOVE,
//        rotation=LEFT) {
//            rotate([180,0,0])
//            9g_motor_centered_for_mounting();
//    } 

// 8************************************************************************




function create_air_flow_scotch(angle, extra_push_rod) = 
    let(
        //extend_left = scotch_yoke_extend_left,
        //extend_trigger_cap = scotch_yoke_extend_trigger_cap,
        support_axle = ["servo horn", true],
        last=undef
    )
    scotch_yoke_create(
        trigger_shaft_diameter, 
        trigger_shaft_range, 
        scotch_yoke_radial_allowance, 
        scotch_yoke_axial_allowance, 
        scotch_yoke_wall_thickness, 
        scotch_yoke_bearing_width,
        angle,
        extra_push_rod=extra_push_rod,
        support_axle=support_axle);
        
module emplace_air_flow_scotch_yoke() {
    dz = paint_pivot_h/2;
    translate([dx_scotch_yoke, 0, dz]) {
        mirror([0, 1, 0]) { // Want servo on +y, +x quadrant
            rotate([0, 180, 0]) {  // Cope with building downward
                rotate([0, 0, 90]) { // Align push rod with trigger
                    children();
                }
            }
        }
    }
} 


module bore_for_scotch_yoke_connection() {
    module place(side, extra=0) {
        dx_nc = 
            paint_pivot_inner_height 
            + paint_pivot_bridge_thickness 
            + scotch_yoke_depth_of_nutcatch 
            + extra;
        dy_nc = scotch_yoke_nutcatch_dy;
        translate([dx_nc, side*dy_nc, 0]) rotate([0, 90, 0]) children();
    }
    render() difference() {
        children();
        place(1) nutcatch_sidecut(name="M3");
        place(-1) nutcatch_sidecut(name="M3");
        place(1, extra=scotch_yoke_extra_depth_for_screw) hole_through();
        place(-1, extra=scotch_yoke_extra_depth_for_screw) hole_through();
    }    
}
   
//        extend_left = 13.5,
//        extra_push_rod = [0, extend_left],  //[0, extend_left + extend_trigger_cap],

module air_flow_scotch_yoke(show_servo, angle) {
    dummy_instance = create_air_flow_scotch(angle, extra_push_rod=[0,0]);
    frame = scotch_yoke_attribute(dummy_instance, "frame");
    extend_left = dx_scotch_yoke - frame.y/2 - paint_pivot_top_of_yoke;

    
    dy_outside_plus = paint_pivot_cl_dy + paint_pivot_w/2 + scotch_yoke_extra_dy_right;
    dy_inside = paint_pivot_cl_dy-paint_pivot_w/2; 
    
    left_base_plate = [
        [dy_outside_plus, scotch_yoke_base_plate_thickness, paint_pivot_h],
        [dy_inside , scotch_yoke_base_plate_thickness, paint_pivot_h]
    ];
    extra_push_rod=[0, extend_left];
    instance = create_air_flow_scotch(angle, extra_push_rod=extra_push_rod);
    log_v1("air_flow_scotch_yoke", instance, verbosity, DEBUG);
    
    bore_for_scotch_yoke_connection() {
        emplace_air_flow_scotch_yoke() {
            scotch_yoke_operation(
                instance, "show", scotch_yoke_options, log_verbosity=verbosity);
            
            scotch_yoke_mounting(
                instance,
                extend_left,
                extend_right=false,
                screw_mounting="M3",
                left_base_plate=left_base_plate);
        }
    }

}



module trigger_slider() {
    x = trigger_slider_length;
    y = trigger_bearing_od;
    z = paint_pivot_h/2;
    y_slot = wall_thickness + 2 * trigger_slider_clearance;
    translate([paint_pivot_top_of_yoke - eps, 0, 0]) {
        render() difference() {
            union() {
                block([x, y, z], center=ABOVE+FRONT);
                rod(
                    d=trigger_bearing_od,
                    l=trigger_slider_length, 
                    center=FRONT,
                    fa=fa_as_arg);
            }
            rod(
                d=trigger_bearing_id, 
                l=2* trigger_slider_length, 
                fa=fa_as_arg); 
            block([x, y_slot, 2* z], center=ABOVE+FRONT);
        }
         
    }
}


module trigger_catch() {
    dz_build_plane = paint_pivot_h/2; 
    difference() {
        rotate([-90, 180, 90]) master_air_brush_trigger_catch();
        translate([0, 0, dz_build_plane]) {
            block([100, 100, 50], center=ABOVE);
        } 
        // Make sure that the is no interference with the barrel:
        rotate([0,-75,0]) 
            translate([0, 0, 0.75*barrel_diameter]) 
                rod(d=barrel_diameter, l=20);
    }
}


module trigger_shaft() {
    fa_as_arg = $fa;
    
    translate([-eps, 0, 0]) { 
        rod(
            d=trigger_shaft_diameter, 
            l=trigger_shaft_length, 
            center=FRONT,
            fa=fa_as_arg);
        // Slide section has support
        translate([trigger_shaft_length+eps, 0, 0]) 
            block(
                [trigger_slider_length, wall_thickness, paint_pivot_h/2], 
                center=BEHIND+ABOVE);  
    }   
}


module trigger_shaft_gudgeon() {
    dx = trigger_shaft_length + paint_pivot_h/2-eps;
    translate([dx, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            trigger_shaft_diameter, 
            trigger_shaft_gudgeon_length, 
            trigger_shaft_pivot_allowance, 
            range_of_motion=[90, 90],
            pin= "M3 captured nut",
            fa=fa_as_arg);
}


module trigger_rod() {

    pintle(
        paint_pivot_h, 
        trigger_shaft_diameter, 
        trigger_rod_length/2 + eps, 
        trigger_shaft_pivot_allowance,
        range_of_motion=[90, 90], 
        pin= "M3 captured nut",
        fa=fa_as_arg);
    translate([trigger_rod_length, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            trigger_shaft_diameter, 
            trigger_rod_length/2 + eps, 
            trigger_shaft_pivot_allowance, 
            range_of_motion=[90, 90],
            pin= "M3 captured nut", 
            fa=fa_as_arg);
        
}


module connected_trigger_rod(angle) {
    dx = trigger_shaft_length + paint_pivot_h/2-eps;
    translate([dx, 0, 0]) {
        rotate([0, angle, 0]) { 
            trigger_rod();
        }
    }
}


module paint_pivot_gudgeons() {
    //render() difference() {
        translate([0, paint_pivot_cl_dy, 0]) {
            paint_pivot_gudgeon(paint_pivot_top_of_yoke); 
        }
        //paint_pull_clearance();
    //}

    translate([0, -paint_pivot_cl_dy, 0]) {
        paint_pivot_gudgeon(paint_pivot_top_of_yoke);
    }
}

module emplace_children_into_scotch_yoke() {
    dz = paint_pivot_h/2;

    rotate([0, 180, 0]) 
    mirror([0, -1, 0])
    rotate([0, 0, -90])
    translate([-dx_scotch_yoke, 0, -dz]) 
    children(); 
} 


module bore_for_push_rod() {
    air_flow_scotch_yoke = create_air_flow_scotch(angle=0, extra_push_rod=[100,100]);
    options=[["fin", false]];
    emplace_air_flow_scotch_yoke() { 
       scotch_yoke_operation(air_flow_scotch_yoke, "bore for push rod - build plate", options=options) {
            emplace_children_into_scotch_yoke() {
                children();
            }
        }
    }
}


module paint_pivot_gudgeon_bridge() {

    bore_for_scotch_yoke_connection() {
        bore_for_push_rod() {
            translate([paint_pivot_inner_height-eps, 0, 0]) {
                block(
                    [paint_pivot_bridge_thickness, 
                    2* paint_pivot_inside_dy+eps,
                    paint_pivot_h
                ],
                center=FRONT); 
            }
        }
    }
    
    // Kludge, we want a round rod through the bridge
    // so seal this off with a little plate
    translate([paint_pivot_inner_height, 0, paint_pivot_h/2])
    block([paint_pivot_bridge_thickness, 3, 1.5], center=FRONT+BELOW); 
}


module paint_pull_emplace() {
    dx = paint_pivot_top_of_yoke - paint_pull_gudgeon_offset ;
    dy = paint_pivot_cl_dy + dy_paint_pull_gudgeon_offset;
    translate([dx, dy, 0]) { 
        children();
    } 
}
// ******************************************************************************
module paint_pull_clearance() {
    paint_pull_emplace() {
        translate([0, 0,0]) 
            block(
                [2*paint_pull_gudgeon_length,
                paint_pivot_w, 
                20]);
        
        translate([0, -paint_pull_nutcatch_depth, 0]) {
            rotate([90,90,0]) {
                nutcatch_sidecut(name="M3");
                translate([0,0,1.5]) hole_through(name="M3");
            }
            
        }
    }
    
}

module paint_pull_gudgeon() {
    
    paint_pull_emplace() {
        rotate ([0, 0, 0]) {
            gudgeon(
                paint_pivot_h, 
                paint_pivot_w, 
                paint_pull_gudgeon_length, 
                paint_pivot_allowance, 
                paint_pull_range_of_motion,    
                pin= "M3 captured nut",
                fa=fa_as_arg);
        }
    }
}


module paint_pull_rod() {
    paint_pull_pivot_allowance = paint_pivot_allowance;
    pintle(
        paint_pivot_h, 
        paint_pivot_w, 
        paint_pull_rod_length/2 + eps, 
        paint_pull_pivot_allowance,
        range_of_motion=[145, 90], 
        pin= "M3 captured nut",
        fa=fa_as_arg);
    translate([paint_pull_rod_length, 0, 0]) 
        gudgeon(
            paint_pivot_h, 
            paint_pivot_w, 
            paint_pull_rod_length/2 + eps, 
            paint_pull_pivot_allowance, 
            range_of_motion=[135, 135],
            pin= "M3 captured nut", 
            fa=fa_as_arg);
        
}


module connected_paint_pull_rod(angle=0) {
    dx = paint_pivot_top_of_yoke + paint_pivot_h;
    dy = paint_pivot_cl_dy + 7.31;
    translate([dx, dy, 0]) {
        rotate([0, angle, 0]) { 
            paint_pull_rod();
        }
    }
}


module paint_pivot_gudgeon_yoke() {         
    paint_pivot_gudgeons();
    paint_pivot_gudgeon_bridge(); 
    paint_pull_gudgeon();

}


module show_gudgeon_assembly_design_orientation(orient_for_build) {

    if (show_paint_pull_rod) {
        color(paint_pull_rod_color, alpha=paint_pull_rod_alpha) {
            //angle = orient_for_build ? 0: paint_pull_rod_angle;
            connected_paint_pull_rod(); //angle);
        }
    }
      
    if (show_paint_pivot_gudgeon_yoke) {
        color(paint_gudgeon_color, alpha=paint_gudgeon_alpha) {
            paint_pivot_gudgeon_yoke();
        }
    }  

    if (show_scotch_yoke) {
        show_servo = orient_for_build ? false : show_air_flow_servo;
        color(air_flow_servo_color, alpha=air_flow_servo_alpha) {
           air_flow_scotch_yoke(show_servo, air_flow_servo_angle);
        }
    }
}

module show_gudgeon_assembly(orient_for_build, viewing_orientation) {
    rotate(viewing_orientation) {
        show_gudgeon_assembly_design_orientation(orient_for_build);
    }
} 


show_gudgeon_assembly(
    orient_for_build=orient_for_build_example,
    viewing_orientation=viewing_orientation_example);

