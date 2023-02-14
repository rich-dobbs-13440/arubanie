/* 

All the parts in the assembly that captures the trigger for control of the 
air air and paint flow.

The coordinate system is based center of rotation of the paint pivot.

*/

//**************************************************************************************************
//      10        20        30        40        50        60        70        80        90       100

include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <lib/small_3d_printable_scotch_yoke.scad>
use <trigger_holder.scad>
use <lib/print_in_place_joints.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

$fa = 10;
fa_as_arg = $fa;

$fs = 0.8;
eps = 0.001;

infinity = 1000;

/* [Logging] */

log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [ Build Or Design] */
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
paint_pull_rod_length = 54;
paint_pull_gudgeon_length = 17;
paint_pull_gudgeon_offset = 6;
dy_paint_pull_gudgeon_offset = 8;
paint_pull_nutcatch_depth = 9;
paint_pull_range_of_motion = [120,60];
//paint_pull_rod_angle = 34; // [0: 5 : 40]
paint_pull_rod_color = "Orange"; // [DodgerBlue, Orange, Coral]
paint_pull_rod_alpha = 1; // [0:0.05:1]



/* [Air Flow Actuator Design] */
show_scotch_yoke = true;
show_scotch_yoke_mounting = true;
show_air_flow_servo = false;

air_flow_position = 0;  // [0 : 45: 270]
air_flow_servo_angle = -air_flow_position; 

support_offset_p1 = 10; //[0:0.25:30]
support_offset_p2 = 6.75; //[0:0.25:30]
support_offset_p3 = 4.25; //[0:0.25:30]
support_offset_p4 = 4.0; //[0:0.25:30]
support_offset_m1 = 10; //[0:0.25:30]
support_offset_m2 = 7.0; //[0:0.25:30]
support_offset_m3 = 11.5; //[0:0.25:30]
support_offset_m4 = 5.5; //[0:0.25:30]


p_offsets = [
    support_offset_p1,
    support_offset_p2,
    support_offset_p3,
    support_offset_p4
];
p_locations = v_set(v_cumsum(p_offsets));
    
m_offsets = [
    -support_offset_m1,
    -support_offset_m2,
    -support_offset_m3,
    -support_offset_m4
];
    
m_locations = v_set(v_cumsum(m_offsets));

support_location_list = concat(p_locations, m_locations);

support_locations = [for (item = support_location_list) if (item != 0) item];

scotch_yoke_options = [
    ["push rod support", support_locations],
    //["show only", ["push_rod"]]
]; 
//undef; // [["show only", ["wall"]]]; //"push_rod"

// (must clear paint pot)
dx_scotch_yoke = 55; 
scotch_yoke_wall_thickness = 3; 


scotch_yoke_extra_depth_for_screw = 1.5;
// (covers up small gap with servo mounting post)
scotch_yoke_extra_dy_right = 6;  
scotch_yoke_extend_trigger_cap = 5;
scotch_yoke_radial_allowance = 0.4;
scotch_yoke_axial_allowance = 0.6;
scotch_yoke_bearing_width = 5;



air_flow_servo_color = "PaleTurquoise"; // [DodgerBlue, PaleTurquoise, Coral]
air_flow_servo_alpha = 1; // [0, 0.25. 0.5, 0.75, 1]


scotch_yoke_mounting_color = "Blue";
scotch_yoke_mounting_alpha = 1; // [0, 0.25. 0.5, 0.75, 1]


/* [Trigger Catch Design] */

show_trigger_catch = true;

trigger_shaft_diameter = 5;
trigger_shaft_bore = trigger_shaft_diameter + 2 * scotch_yoke_radial_allowance;
trigger_shaft_min_x = 13;
trigger_shaft_catch_clearance = 6.81; // Screw head + catch thickness

trigger_shaft_range = 
    paint_pivot_inner_height 
    - trigger_shaft_catch_clearance
    - trigger_shaft_min_x ;

trigger_shaft_dx = 0;
trigger_catch_color = "LightSkyBlue"; // [DodgerBlue, LightSkyBlue, Coral]
trigger_catch_alpha = 1; // [0:0.05:1]

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





show_gudgeon_assembly(
    orient_for_build=orient_for_build_example,
    viewing_orientation=viewing_orientation_example);


module show_gudgeon_assembly(orient_for_build, viewing_orientation) {
    //echo("show_gudgeon_assembly_parent_module(0)", parent_module(0));
    rotate(viewing_orientation) {
        show_gudgeon_assembly_design_orientation(orient_for_build);
    }
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
    if (show_scotch_yoke_mounting) {
        color(scotch_yoke_mounting_color, alpha=scotch_yoke_mounting_alpha) { 
            air_flow_scotch_yoke_mounting();
        }
    }
    
    if (show_trigger_catch) {
        color(trigger_catch_color, alpha=trigger_catch_alpha) {
            translate([trigger_shaft_dx, 0, 0]) {
                trigger_catch();
            }
        }
    }
}


function create_air_flow_scotch(angle, extra_push_rod) = 
    let(
        support_axle = ["servo horn", true],
        last=undef
    )
    scotch_yoke_create(
        trigger_shaft_diameter, 
        trigger_shaft_range, 
        scotch_yoke_radial_allowance, 
        scotch_yoke_axial_allowance, 
        scotch_yoke_wall_thickness,
        paint_pivot_h, 
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


function air_flow_scotch_yoke_frame() =
    let (
        dummy_instance = create_air_flow_scotch(0, extra_push_rod=[0,0]),
        frame = scotch_yoke_attribute(dummy_instance, "frame"),
        last=undef
    )
    frame;


function air_flow_scotch_yoke_extend_left() =
    let (
        frame = air_flow_scotch_yoke_frame(),
        extend_left = dx_scotch_yoke - frame.y/2 - paint_pivot_top_of_yoke,
        last=undef
    )
    extend_left;


function air_flow_scotch_extra_push_rod() = 
    [0, air_flow_scotch_yoke_extend_left() - 3]; // kludge!


function air_flow_scotch_with_extra_rod(angle) =
    let (
        instance = create_air_flow_scotch(
            angle, 
            extra_push_rod=air_flow_scotch_extra_push_rod()),
        //log_v1("air_flow_scotch_yoke", instance, verbosity, DEBUG);
        last = undef
    )
    instance;

module air_flow_scotch_yoke_mounting() {
    dy_inside = 
        paint_pivot_cl_dy 
        - paint_pivot_w/2; 
    dy_outside_plus = 
        paint_pivot_cl_dy 
        + paint_pivot_w/2 
        + scotch_yoke_extra_dy_right;
    left_lengths = [dy_outside_plus, dy_inside];
    emplace_air_flow_scotch_yoke() {
        scotch_yoke_mounting(
            air_flow_scotch_with_extra_rod(0),
            frame_to_base=[0, dx_scotch_yoke - paint_pivot_top_of_yoke],
            screw_name="M3",
            left_lengths=left_lengths);
    }
}
   

module air_flow_scotch_yoke(show_servo, angle) {
    emplace_air_flow_scotch_yoke() {
        scotch_yoke_operation(
            air_flow_scotch_with_extra_rod(angle), 
            "show", 
            scotch_yoke_options, 
            log_verbosity=verbosity);
    }
}


module trigger_catch() {
    module catch() {
        dz_build_plane = paint_pivot_h/2; 
        difference() {
            rotate([-90, 180, 90]) {
                master_air_brush_trigger_catch();
                rotate([0, 0, 90]) 
                    can_to_plate_connection(
                        plate_side=true, diameter=5, slide_allowance=0.2);
            }
            translate([0, 0, dz_build_plane]) {
                block([100, 100, 50], center=ABOVE);
            } 
            // Make sure that the is no interference with the barrel:
            rotate([0,-75,0]) 
                translate([0, 0, 0.75*barrel_diameter]) 
                    rod(d=barrel_diameter, l=20);
        }
    }
    if (orient_for_build_example) {
        translate([0, 0, -0.1]) rotate([0,90, 0]) catch();
    } else {
        catch();
    }
}


module paint_pivot_gudgeons() {
    difference() {
        translate([0, paint_pivot_cl_dy, 0]) {
            paint_pivot_gudgeon(paint_pivot_top_of_yoke); 
        }
        paint_pull_clearance();
    }
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


//module bore_for_push_rod() {
//    air_flow_scotch_yoke = 
//        create_air_flow_scotch(angle=0, extra_push_rod=[100,100]);
//    options=[["fin", false]];
//    emplace_air_flow_scotch_yoke() { 
//        scotch_yoke_operation(
//                air_flow_scotch_yoke, 
//                "bore for push rod - build plate", 
//                options=options) {
//            emplace_children_into_scotch_yoke() {
//                children();
//            }
//        }
//    }
//}

module hole_through_clearance() {
}

module trigger_shaft_clearance() {
    dz_trigger = trigger_shaft_diameter/2 + wall_thickness;
    //dz = -0.5 ; // paint_pivot_h/2 - scotch_yoke_wall_thickness;
    dz = dz_trigger - paint_pivot_h/2;
    translate([0, 0, dz]) {
        rod(d=trigger_shaft_bore, l=4*paint_pivot_bridge_thickness);
    }
}

module bore_for_nuts_and_push_rod() {
    difference() {
        children();
        hole_through_clearance();
        trigger_shaft_clearance();
    }
    //trigger_shaft_clearance();
}


module paint_pivot_gudgeon_bridge() {
    x = paint_pivot_bridge_thickness; 
    y = 2* paint_pivot_inside_dy;
    z = paint_pivot_h;
    translate([paint_pivot_inner_height, 0, 0]) {
        bore_for_nuts_and_push_rod() {
            block([x, y, z], center=FRONT);
        }
    }
}



module paint_pull_emplace() {
    dx = paint_pivot_top_of_yoke - paint_pull_gudgeon_offset ;
    dy = paint_pivot_cl_dy + dy_paint_pull_gudgeon_offset;
    translate([dx, dy, 0]) { 
        children();
    } 
}



module paint_pull_clearance() {
    // TODO: Move this into small_pivot_vertical_rotation.scad
    a = 90 - paint_pull_range_of_motion[0];
    dx = paint_pivot_h/2 + paint_pivot_allowance;
    x = 50;
    y = paint_pivot_w + 2 * paint_pivot_allowance;
    z = 50;
    
    paint_pull_emplace() {
        rotate([0, a, 0]) 
            translate([-dx, 0, 0]) 
                block([x, y, z], center=FRONT);
        
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
