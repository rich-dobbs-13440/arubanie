

include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/sub_micro_servo.scad>
use <lib/9g_servo.scad>
use <lib/small_pivot_vertical_rotation.scad>
use <master_air_brush.scad>
include <arb_saduri_paint_pivot.scad>

/* [Boiler Plate] */

fa_shape = 10;
fa_bearing = 1;
infinity = 300;


/* [ Build or Design] */
    orient_for_build = true;

/* [Show] */
    show_servo_mount = true;
    show_paint_pull_rod = true;
    show_paint_pull_gudgeon = true;
    
    dy_spacing = 40; // [40:5:99.9]

    dy_servo_mount  = 0 + 0;
    dy_paint_pull_rod = 
        dy_servo_mount 
        + (show_servo_mount ? dy_spacing : 0);
    dy_paint_pull_gudgeon = 
        dy_paint_pull_rod
        + (show_paint_pull_rod ? dy_spacing : 0); 

/* [Paint Flow Servo Design] */

    show_paint_flow_servo_mount = true;
    show_paint_flow_servo = true;
    show_mount_plate_joiner = true;
    show_screw_plate = true;

    dx_servo = 42; // [10 : 0.5 : 40]
    dz_servo = 11; // [10 : 0.5 : 20]
    servo_rotation = -9; // [-20 : 1 : 20]
    y_servo_mount_connector = 10; // [0 : 1 : 20]
    barrel_clip_strap_length = 8;

    dy_servo_support = 15;



/* [Paint Pull Rod Design] */
    paint_pull_rod_length = 50; // [0: 2: 99.9]

    
/* [Paint Pull Gudgeon Design] */

    paint_pull_gudgeon_length = 14;  // [0:99.9]
    paint_pull_gudgeon_angle = 16; // [0:99.9]
    //paint_pull_nutcatch_depth = 9;
    paint_pull_range_of_motion = [135,135];
//    dx_paint_pull_gudgeon_offset = -20; // [-20:0.5:20]
//    dy_paint_pull_gudgeon_offset = 8;  // [-20:20]

/* [Master Air Brush Design] */
    // Only works if not in build orientation
    show_air_brush = true;

    air_brush_alpha = 0.10; // [0:0.05:1]

    barrel_clearance = 0.3;
    wall_thickness = 2;
    barrel_clip_inside_diameter = master_air_brush("barrel diameter") + barrel_clearance; 
    barrel_clip_outside_diameter = barrel_clip_inside_diameter + 2 * wall_thickness;



module end_of_customization() {}


if (show_servo_mount) {
    translate([0, dy_servo_mount, 0]) {
        show_servo_mount();
    }
}


if (show_paint_pull_gudgeon) {
    translate([0, dy_paint_pull_gudgeon, 0]) {
        paint_pull_gudgeon();
    }
}


if (show_paint_pull_rod) {
    translate([0, dy_paint_pull_rod, 0]) {
        paint_pull_rod(); 
    }
}


module show_servo_mount() {
    if (show_paint_flow_servo_mount) {
        show_servo = orient_for_build ? false : show_paint_flow_servo;
        color("red") {
            paint_flow_servo_mount(show_servo);
        } 
    }

    if (show_screw_plate) {
        color("white") {
            mounting_screw_plate();
        }
    }

    if (show_mount_plate_joiner) {
        color("blue") {
            mount_plate_joiner();
        }
    }
}


module mount_plate_joiner() {
    plate_target = [
        1, 
        y_servo_mount_connector, 
        wall_thickness
    ];
    mount_target = [
        1, 
        y_servo_mount_connector, 
        wall_thickness
    ];
    dy_plate_target = barrel_clip_inside_diameter/2;
    
    difference() {
        hull() {
            translate([0, dy_plate_target, 0]) {
                block(plate_target, center=RIGHT+ABOVE+FRONT);
            }
            translate([dx_servo,dy_servo_support, 0]) {
                block(mount_target, center=RIGHT+ABOVE+FRONT);
            }
        }
        mounting_screw_clearance();
        simple_barrel_clearance() ;
    }
}

module plane_clearance(center) {
    block([infinity, infinity, infinity], center=center);
}



module simple_barrel_clearance() {
    translate(-disp_air_brush_relative_paint_pivot_cl) { 
        rod(d=barrel_clip_inside_diameter, l=100, fa=fa_shape);
    }
}

module mounting_screw_clearance() {
    dy = paint_pivot_screw_dy/2;
    $fn=12;
    center_reflect([0, 1, 0]) 
        translate([0, dy, 25]) hole_through(name="M3", cld=0.4);
}

module mounting_screw_plate() {

    x = 10;
    y = paint_pivot_screw_dy + 10;
    z = wall_thickness;
    difference() {
        union() {
            block([x, y, z], center=ABOVE);
            translate(-disp_air_brush_relative_paint_pivot_cl) {
                rod(d=barrel_clip_outside_diameter, l=barrel_clip_strap_length, fa=fa_shape);
            }
                
        }
        mounting_screw_clearance();
        simple_barrel_clearance() ;
        plane_clearance(BELOW);
    }
} 

module paint_flow_servo_mount(show_servo) {

    function translation_with_y_rotation(disp, angle_y) = 
        let (
            dx = 
                disp.x * cos(angle_y)
                - disp.z * sin(angle_y),
            dz = 
                - disp.x * sin(angle_y)
                - disp.z * cos(angle_y),
            last=undef
        )
        [dx, disp.y, dz];
    
    
    dx_servo_support = 24;
    dx_servo_offset = 6.2;
    dy = dy_servo_support;
    dz_servo_support = 12-0.5;
    dz_offset = dz_servo_support/2;
    y_support = 15;
    dx_servo_offset_n = - (dx_servo_support - dx_servo_offset); 
    echo("cos(servo_rotation)", cos(servo_rotation));
    echo("sin(servo_rotation)", sin(servo_rotation)); 
    disp_far = translation_with_y_rotation(
        [dx_servo_offset, dy_servo_support, dz_offset],
        servo_rotation);
    overlap_and_clearance = [0.5, 0, 3];
    
    disp_near = translation_with_y_rotation(
        [dx_servo_offset_n, dy_servo_support, dz_offset],
        servo_rotation);
    
    difference() {
        translate([dx_servo, 0, dz_servo]) { 

            translate(disp_far+overlap_and_clearance) { 
                block([2, y_support, 50], center=BELOW+FRONT+RIGHT); 
            }
            translate(disp_near) { 
                block([4, y_support, 50], center=BELOW+BEHIND+RIGHT); 
            }

            rotate([0, servo_rotation, 0]) {
                sub_micro_servo__mounting(  
                    mount=RIGHT, 
                    locate_relative_to="SERVO",
                    clearance = [1, 0.5, 0],
                    show_servo=show_servo, 
                    flip_servo=true,
                    omit_top=true,
                    omit_base=true);
            }
      
        }
        plane_clearance(BELOW);
    }
    connector();
    
    module connector() {
        x = disp_far.x - disp_near.x + 2*wall_thickness; 
        size = [x, y_servo_mount_connector, wall_thickness];
        dx = dx_servo + disp_far.x + wall_thickness;
        translate([dx, dy_servo_support, 0]) {
            block(size, center=RIGHT+ABOVE+BEHIND);
        }
    }
     
}

module paint_pull_rod() {
    eps = 0.01;
    paint_pull_pivot_allowance = paint_pivot_allowance;
    pintle_length = paint_pull_rod_length/2+eps;
    dz = paint_pivot_h/2;
    translate([0, 0, dz]) {
        pintle(
            paint_pivot_h, 
            paint_pivot_w, 
            pintle_length, 
            paint_pull_pivot_allowance,
            range_of_motion=[145, 180], 
            pin= "M3 captured nut");
        
        translate([paint_pull_rod_length, 0, 0])
            rotate([0, 0, 180])
                pintle(
                    paint_pivot_h, 
                    paint_pivot_w, 
                    pintle_length, 
                    paint_pull_pivot_allowance, 
                    range_of_motion=[145, 180],
                    pin= "M3 captured nut");
        
    }
    x = 15; 
    y = paint_pivot_w;
    z = wall_thickness;
    dx = paint_pull_rod_length/2;
    translate([dx, 0, 0]) 
        block([x, y, z], center=ABOVE);    
}



module paint_pull_gudgeon() { 
    assembly();
    
    module assembly() {
        difference() {
            color("teal") screw_plate();
            hole_clearance();
        }
        difference() {
            color("orange") oriented_gudgeon();
            plane_clearance(BELOW);
            plane_clearance_screw_plate();
        }
        color("Salmon") joiner();     
    }
    

    
    // Make origin at cl of screw holes, bottom of screw plate.
    
    x_sp = paint_pivot_h;
    y_sp = 22;  
    z_sp = wall_thickness;
    
    z_hole_through = 50;
    screw_offset = 6;
    d_clear_push_rod = 5.75;
    module hole_clearance() {
        center_reflect([0, 1, 0]) {
            $fn = 12;
            dz = z_hole_through/2;  
            dy = screw_offset;
            translate([0, dy, dz]) hole_through(name="M3", cld=0.4);
        }
        can(d=d_clear_push_rod, h=infinity);

    }
    module screw_plate() {
         // TODO pull from common parameters
        block([x_sp, y_sp, z_sp], center=ABOVE);

    }
    module oriented_gudgeon() {
        
        dx = paint_pull_gudgeon_length; //x_sp/2 + paint_pivot_h/2 + gudgeon_to_face_gap; 
        dz = paint_pivot_h/2; // paint_pull_gudgeon_length; 
        rotate([0, -paint_pull_gudgeon_angle, 0]) {
                translate([dx, 0, 0]) {
                gudgeon(
                    paint_pivot_h, 
                    paint_pivot_w, 
                    paint_pull_gudgeon_length, 
                    paint_pivot_allowance, 
                    range_of_motion=[180, 180],    
                    pin= "M3 captured nut");
            }
        }
    }
    
    module plane_clearance_screw_plate() {
        translate([x_sp/2, 0, 0]) 
            plane_clearance(BEHIND);
    }
    
    module joiner() {
        eps = .01;
        base = [eps, y_sp, wall_thickness]; 
        dx_b = x_sp/2;
        z_support = 
            paint_pull_gudgeon_length * sin(paint_pull_gudgeon_angle)
            - paint_pivot_h/2;
        x_support = 
            paint_pull_gudgeon_length * cos(paint_pull_gudgeon_angle)
            - x_sp/2;
        support = [x_support, paint_pivot_w/2, z_support];
        dx_support = x_sp/2;
        gudgeon_base = [x_support/2, paint_pivot_w/2, wall_thickness]; 
        translate([dx_support, 0, 0]) block(support, center=ABOVE+FRONT);
        hull() {
            translate([dx_b, 0, 0]) block(base, center=ABOVE+FRONT);
            translate([dx_support, 0, 0]) block(gudgeon_base, center=ABOVE+FRONT);
        } 
    }
    



}

