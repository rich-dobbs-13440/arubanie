/* 

9g sub micro servo mounting.

Usage:

use <lib/sub_micro_servo.scad>


sub_micro_servo__mounting(
    screw_offset=1.5, 
    clearance = [0.5, 1, 1],
    omit_top=true, 
    omit_base=false,
    mount=FRONT, //LEFT, FRONT, BACK
    locate_relative_to="SERVO", // "SERVO", "MOUNTING SURFACE
    show_servo=false,
    flip_servo=false,
    log_verbosity=verbosity);

sub_micro_servo__mount_to_axle(
    axle_diameter=4, 
    axle_height= 10,
    wall_height=6,
    radial_allowance=0.4, 
    axial_allowance=0.4, 
    wall_thickness=2, 
    angle = 0,
    log_verbosity=verbosity);
        
        
sub_micro_servo__mounting(
    mount=RIGHT, 
    locate_relative_to="SERVO",  
    show_servo=true,
    flip_servo=false,
    log_verbosity=verbosity);
        
sub_micro_servo__single_horn_long(
    allowance=al, 
    log_verbosity=verbosity);
    
sub_micro_servo__single_horn_long(
    items=["nutcatch_extension"], 
    allowance=al, 
    log_verbosity=verbosity);


Notes:  
    This note may be obsolete!  Must confirm:
    
    For sub_micro_servo__mounting, the default origin is at the 
    half way between the two mounting screws,
    at the front of the mounting.surface.

*/

//   Line Ruler   20        30        40        50        60        70        80        90       100

include <logging.scad>
include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>
use <9g_servo.scad>
use <small_servo_cam.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
use <small_pivot_vertical_rotation.scad>

/* [Boiler Plate] */
    fa_shape = 10;
    fa_bearing = 2;
    infinity = 300;

/* [Logging] */
    log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
    verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [Show] */
    show__sub_micro_servo__mounting = true;
    show__sub_micro_servo__mount_to_axle = true;
    show__sub_micro_servo__single_horn_long = true;
    show__sub_micro_servo__radial_stall_limiter = true;

    dy_spacing = 50; // [40:5:99.9]

    dy_mounting = 0 + 0;
    dy_mount_to_axle = 
        dy_mounting 
        + (show__sub_micro_servo__mounting ? dy_spacing : 0);
    dy_single_horn_long = 
        dy_mount_to_axle
        + (show__sub_micro_servo__mount_to_axle ? dy_spacing : 0); 
    dy_radial_stall_limiter = 
        dy_single_horn_long
        + (show__sub_micro_servo__single_horn_long ? dy_spacing : 0); 
 
/* [Options for sub_micro_servo__mounting  Module] */
    show_with_servo_mtg = false;
    show_with_back_mtg = false; 
    show_offset_relative_to_servo_mtg = false;

/* [Options for sub_micro_servo__mount_to_axle  Module] */
    angle_mta = 0; // [-180: 5: +180]
    axle_height_mta  = 18.5; // [6: 0.5: 20]
    axle_diameter_mta  = 4; // [2: 1: 20]
    wall_height_mta  = 6; // [2: 1: 20]
    radial_allowance_mta  = 0.4; // [0 : 0.2 : 10]
    axial_allowance_mta  = 0.4; // [0 : 0.2 : 10]
    wall_thickness_mta  = 2; // [2: 0.5: 10]

/* [Options for show__sub_micro_servo__single_horn_long  Module] */
    show_default_shl = true;
    show_nutcatch_extension_shl = true;
    show_crank_extension_shl = true;
    radial_allowance_shl = 0.2;
    axial_allowance_shl = 0.2;

// This section is generate code.  Do not directly modify.  Instead run the 
// generate_updated_debug_options option!

/* [ Debug Options for sub_micro_servo__single_horn_long Module ] */
    show_screw_pilot_holes_shl = false;
    show_screw_access_clearance_shl = false;
    show_nutcatch_clearance_shl = false;
    show_servo_hub_clearance_shl = false;
    show_slot_clearance_shl = false;
    show_catch_clearance_shl = false;
    show_arm_blank_shl = false;
    show_nutcatch_extension_blank_shl = false;
    show_generate_updated_debug_options_shl = false;
    debug_items_shl = [
            show_screw_pilot_holes_shl ? "screw_pilot_holes" : "",
            show_screw_access_clearance_shl ? "screw_access_clearance" : "",
            show_nutcatch_clearance_shl ? "nutcatch_clearance" : "",
            show_servo_hub_clearance_shl ? "servo_hub_clearance" : "",
            show_slot_clearance_shl ? "slot_clearance" : "",
            show_catch_clearance_shl ? "catch_clearance" : "",
            show_arm_blank_shl ? "arm_blank" : "",
            show_nutcatch_extension_blank_shl ? "nutcatch_extension_blank" : "",
            show_generate_updated_debug_options_shl ? "generate_updated_debug_options" : "",
    ];

/* [Dimensions for Crank Extension] */
    crank_offset_to_right = false; 
    crank_length_shl_ce = 15; // [10: 1: 99.9] 
    crank_width_shl_ce = 4.5;
    crank_height_shl_ce = 8;
    hole_shl_ce = 2.81; // "M3";
    options_shl_ce = [
        ["crank_offset_to_right", crank_offset_to_right],
        ["crank_length", crank_length_shl_ce],
        ["crank_width", crank_width_shl_ce],
        ["crank_height", crank_height_shl_ce],
        ["crank_hole", hole_shl_ce],
    ];
    
// End of generated code


/* [Options for sub_micro_servo__radial_stall_limiter  Module] */
    //spring_offset_angle_rsl = 15; // [-45 : 0.5: 45]
    //x_right_gudgeon_clearance_rsl = 7.5; // [-1 : 0.5: 10]
    //spring_coverage_angle_rsl = 330; // [270 : 0.5: 360]


end_of_customization() {}

//------------------------------ Start of Demonstration ----------------------------

if (show__sub_micro_servo__mounting) {
    translate([0, dy_mounting, 0]) {
        if (show_with_back_mtg) {
            sub_micro_servo__mounting(size=[18, 32, 18]);
        } else if (show_with_servo_mtg) {
            sub_micro_servo__mounting() {
                9g_motor_centered_for_mounting();
            }
        } else {
            sub_micro_servo__mounting();
        }
        
        if (show_offset_relative_to_servo_mtg) {
            sub_micro_servo__mounting(
                mount=RIGHT, //LEFT, FRONT, BACK
                locate_relative_to="SERVO", //"MOUNTING SURFACE
                show_servo=true,
                flip_servo=false,
                log_verbosity=INFO);
        }
    }
    // Obsolete for now!
    //if (show_translation_test) {
    //    color("red") sub_micro_servo__mounting(center=ABOVE);
    //    color("blue") sub_micro_servo__mounting(omit_top=false, center=BELOW);
    //    color("green") sub_micro_servo__mounting(center=LEFT);
    //    color("yellow") sub_micro_servo__mounting(center=RIGHT);
    //    color("white") sub_micro_servo__mounting(center=BEHIND);
    //    color("black") sub_micro_servo__mounting(center=FRONT);
    //}
    //
    //if (show_rotate_left_translation_test) {
    //    color("orange") sub_micro_servo__mounting(rotation=LEFT);
    //    color("red") sub_micro_servo__mounting(center=ABOVE, rotation=LEFT);
    //    color("blue") sub_micro_servo__mounting(omit_top=false, center=BELOW, rotation=LEFT);
    //    color("green") sub_micro_servo__mounting(center=LEFT, rotation=LEFT);
    //    color("yellow") sub_micro_servo__mounting(center=RIGHT, rotation=LEFT);
    //    color("white") sub_micro_servo__mounting(center=BEHIND, rotation=LEFT);
    //    color("black") sub_micro_servo__mounting(center=FRONT, rotation=LEFT);
    //}
}
    

if (show__sub_micro_servo__mount_to_axle) {
    translate([0, dy_mount_to_axle, 0]) {
        sub_micro_servo__mount_to_axle(
            axle_diameter=axle_diameter_mta, 
            axle_height= axle_height_mta,
            wall_height=wall_height_mta,
            radial_allowance=radial_allowance_mta, 
            axial_allowance=axial_allowance_mta, 
            wall_thickness=wall_thickness_mta, 
            angle=angle_mta,
            log_verbosity=verbosity);
    }
}

if (show__sub_micro_servo__single_horn_long) {
    translate([0, dy_single_horn_long, 0]) {
        if (show_default_shl) {
            sub_micro_servo__single_horn_long(radial_allowance_shl, axial_allowance_shl, log_verbosity=verbosity);
        }
        if (show_nutcatch_extension_shl) {
            sub_micro_servo__single_horn_long(
                items=["nutcatch_extension"], radial_allowance_shl, axial_allowance_shl, log_verbosity=verbosity);
        }
        if (show_crank_extension_shl) {
            sub_micro_servo__single_horn_long(
                items=["crank_extension"], 
                radial_allowance_shl, 
                axial_allowance_shl,
                options=options_shl_ce, 
                log_verbosity=verbosity);
        }
        sub_micro_servo__single_horn_long(
            items=debug_items_shl, radial_allowance_shl, axial_allowance_shl, log_verbosity=verbosity);
    }
}


if (show__sub_micro_servo__radial_stall_limiter) {
    translate([0, dy_radial_stall_limiter, 0]) {
        sub_micro_servo__radial_stall_limiter();
    }
}

//-------------------------------- Start of Implementation -------------------------

module sub_micro_servo__pilot_hole() {
    pilot_diameter = 2;
    screw_length = 8;
    screw_length_allowance = 2;
    l = screw_length+screw_length_allowance;
    d = pilot_diameter;
    rod(d=d, l=l, center=FRONT, rank=2, fa=4*fa_shape);
}


module sub_micro_servo__single_horn_long(
        radial_allowance=0.2, 
        axial_allowance=0.2, 
        items=["default"],
        options=[],
        log_verbosity=INFO) {
            
    log_s("radial_allowance", radial_allowance, log_verbosity, DEBUG);
    log_s("axial_allowance", radial_allowance, log_verbosity, DEBUG);
    log_s("items", items, log_verbosity, DEBUG);
    assert(is_num(radial_allowance)); 
    assert(is_num(axial_allowance)); 
            
    function option(name, required=false) = 
        let(
            result = find_in_dct(options, name),
            dummy = required ? 
                assert(!is_undef(result), str("Require option not found: ", name)) : 
                undef,
            last = undef
        )
        result;

    d_out_hub = 5.72;
    d_inner_hub = 3.81;
    h_hub = 3.30;
    d_arm_end = 3.83;
    h_arm = 1.96;
    r_arm = 25.1;
    screw_driver_diameter = 5; // For accessing servo
    servo_screw_head = 3.7;
    screw_diameter = 1.5;
    slot_width = 1.54;
    
    wall_thickness = 2;
    base_thickness = 1;
    catch_overlap = 0.5;
    catch_thickness = 1.5;
    
    blank_h_allowance = base_thickness/2 + catch_thickness/2;
    blank_d_allowance = wall_thickness;
    arm_max_width = d_out_hub + 2*blank_d_allowance;
    arm_length = r_arm + d_arm_end/2 + blank_d_allowance;
    

    dz_catch_clearance = base_thickness + h_arm/2;
    
    crank_clearance = 1;
 
    function want(name) = in_list(items, name);
    
    if (want("default") || want("arm holder")) {
        color("Turquoise") arm_holder();
    }
    if (want("nutcatch_extension")) {
        color("DarkTurquoise") nutcatch_extension(); 
    }
    if (want("crank_extension")) {
        color("PaleTurquoise")  crank_extension();
    }
    
    // These items are for debugging - Order them from inside to outside
    if (want("screw_pilot_holes")) {
        color("brown") screw_pilot_holes();
    }
    
    if (want("screw_access_clearance")) {
        color("orange") servo_screw_access_clearance(with_screw_driver=false);
        color("orange", alpha=0.5) servo_screw_access_clearance(with_screw_driver=true);
    }  
     
    if (want("nutcatch_clearance")) {
        color("yellow", alpha=0.25) nutcatch_clearance(side_cuts=true);
    }

    if (want("slot_clearance")) {
        color("gray", alpha=0.25)  slot_clearance();
    }
    if (want("catch_clearance")) {
        color("Indigo", alpha=0.25)  catch_clearance();
    }
    if (want("servo_hub_clearance")) {
        color("pink", alpha=0.25)  servo_hub_clearance();
    }
    if (want("arm_blank")) {
        color("purple", alpha=0.25) arm_blank();
    } 
    if (want("nutcatch_extension_blank")) {
        color("Aqua", alpha=0.25) nutcatch_extension_blank();
    } 
    if (want("generate_updated_debug_options")) {
        generate_updated_debug_options();
    } 

    // TODO verify that items are possible
    debug_options = [
        "screw_pilot_holes",
        "screw_access_clearance",
        "nutcatch_clearance", 
        "servo_hub_clearance", 
        "slot_clearance", 
        "catch_clearance", 
        "arm_blank", 
        "nutcatch_extension_blank",
        "generate_updated_debug_options",
    ];
    log_s("Debugging options", debug_options, log_verbosity, DEBUG);
    
    module generate_updated_debug_options() {
        customizer_items_to_checkboxes(
            items=debug_options, 
            suffix = "_shl",
            list_name="debug_items",
            tab_name="Debug Options for sub_micro_servo__single_horn_long Module",
            log_verbosity=DEBUG);
    }

    module arm_holder() {
        difference() {
            arm_blank();
            screw_pilot_holes();
            servo_screw_access_clearance();
            slot_clearance();
            catch_clearance();
            servo_hub_clearance();
        }
    }

    module crank_extension() {
        crank_length = option("crank_length", required=true);
        crank_width = option("crank_width", required=true);
        crank_height = option("crank_height", required=true);
        hole = option("crank_hole");
        offset_to_right = option("crank_offset_to_right", required=true);
        function crank_angle() = 
            let (
                arm_clearance_length = arm_length + crank_clearance + crank_width/2,
                must_offset = crank_length < arm_clearance_length,
                dy_crank = crank_height/2 + arm_max_width/2 + crank_clearance,
                angle = must_offset ? asin(dy_crank/crank_length) : 0,
                signed_angle = offset_to_right ? angle : -angle,
                last=undef
            )
            assert(is_num(angle), str("Minimum possible crank length is ", dy_crank))
            signed_angle;
        
        module crank_body() {
            size = [crank_length, crank_width, crank_height];
            rotate([0, 0, crank_angle()]) 
                translate([crank_length, 0, crank_width/2]) 
                    rotate([90, 0, 180]) 
                        crank(size, hole=hole, rank=-3);
        }
        eps = 0.001;
        render() difference() {
            crank_body();
            scale([1-eps, 1-eps, 2]) arm_blank();
            
        }
    }
    
    module nutcatch_extension() {
        difference() {
            nutcatch_extension_blank()
            servo_screw_access_clearance();
            nutcatch_clearance(side_cuts=true);
            servo_screw_access_clearance(with_screw_driver=true);
        }
    } 
    
    module arm_blank() {
        arm_clearance(blank_d_allowance, blank_h_allowance);
    }
    
    module servo_hub_clearance() {
        dz = base_thickness + 2; // Make at the top of the arm
        translate([0, 0, dz]) can(d=13, h=5, center=ABOVE);
    }
    
    module arm_catch_clearance() {
        translate([0, 0, 2.6]) center_reflect([1, 0, 0]) 
            arm_clearance(-catch_overlap, 2*catch_thickness);
    }
    
    module screw_pilot_holes() {
        for (dx = [9 : 3 :24]) {
            translate([dx, 0, 0]) can(d=screw_diameter, h=20, fa=fa_shape); 
        }
    }
 
    module servo_screw_access_clearance(with_screw_driver=false) {
       // Access to center screw
        d = with_screw_driver ? screw_driver_diameter: servo_screw_head;
        can(d=d, h=50, fa=fa_shape);
    }
  
    module slot_clearance() {
        translate([0, 0, base_thickness]) {
            center_reflect([1, 0, 0]) {
                arm_clearance(radial_allowance, axial_allowance);
            }
        } 
    } 

    module catch_clearance() {
        translate([0, 0, dz_catch_clearance]) 
            center_reflect([1, 0, 0]) 
                arm_clearance(-catch_overlap, 3);
    }      
                
    module arm_clearance(r_allowance, h_allowance) {
        assert(is_num(r_allowance));
        assert(is_num(h_allowance));
        function swell(d) = d + 2*r_allowance; 
        function swell_h(h) = h + 2*h_allowance;     
        hull() {
            can(d=swell(d_out_hub), h=swell_h(h_arm), center=ABOVE, fa=fa_shape);
            translate([r_arm, 0, 0]) 
                can(d=swell(d_arm_end), h=swell_h(h_arm), center=ABOVE, fa=fa_shape);  
        }
    }

    module nutcatch_clearance(side_cuts) {
        eps = 0.01;
        module cut(dx) {
            if (side_cuts) {
                dz_nut_offset = eps; //1.5;
                translate([dx, 0, dz_nut_offset]) {
                    rotate([0, 0, 90]) {             
                        nutcatch_sidecut(name="M3");
                    }
                }
            }
            dz_hole = 25;
            translate([dx, 0, 0]) {
                rotate([0, 0, 90]) {
                    translate([0, 0, dz_hole]) 
                        hole_through(name="M3");
                }
            }
        }
        cut(8);
        cut(20);
    }
    
    module nutcatch_extension_blank() {
        h_nut = 2;
        mirror([0, 0, 1]) arm_clearance(blank_d_allowance, h_nut);
    }

  
}


module sub_micro_servo__mounting(
        screw_offset=1.5, 
        clearance = [0.5, 1, 1],
        omit_top=true, 
        omit_base=false,
        mount=FRONT, //LEFT, FRONT, BACK
        locate_relative_to="SERVO", // "SERVO", "MOUNTING SURFACE
        show_servo=false,
        flip_servo=false,
        log_verbosity=INFO) {
            
    extent = [16, 32, 18];
            
    offset_for_locate = 
        locate_relative_to== "SERVO" ? [0, 0, 0] :
        locate_relative_to=="SERVO ABOVE" ? [0, 0, extent.z/2] :
        assert(false, str("Not implemented locate_relative_to=", locate_relative_to)); 
    
    rotation_for_mount =  
        mount==FRONT ? [0, 0, 0] :
        mount==RIGHT ? [0, 0, 90] :
        assert(false, str("Not implemented mount=", mount));
            
    translate(offset_for_locate) {
        rotate(rotation_for_mount) {
            mount_and_servo();
        }
    }
    servo_size = [15.45, 23.54, 11.73];
    servo_lip = 4;
    servo_clearance = servo_size + clearance + clearance;
    remainder = extent - servo_clearance;

    module mount_and_servo() {
        servo_dimensions = 9g_motor();
        log_v2("servo_dimensions", servo_dimensions, log_verbosity, DEBUG);
        mcbt = find_in_dct(servo_dimensions[0], "mount_cl_bottom_translation");
        rotated_mounting_translation = [-mcbt.z, mcbt.x, 0];

        mirroring_for_flip_servo = flip_servo ? [0, 1, 0] : [0, 0, 0];

        mirror(mirroring_for_flip_servo)  
            translate(rotated_mounting_translation) {
                translate([extent.x/2, 0, 0]) {
                    back_wall(extent, servo_clearance, remainder);
                    screw_blocks(screw_offset, extent, servo_clearance, remainder);
                    base_and_top(extent, servo_clearance, remainder, omit_top, omit_base);
                }
            }   
        if (show_servo) {
            rotate([-90,0,90]) { // Translate so that servo is to the front
                9g_motor_sprocket_at_origin(highlight=true);
            }
        }
    }

    module base_and_top(extent, servo_clearance, remainder, omit_top, omit_base) {
        base = [
            extent.x, 
            extent.y,
            remainder.z/2
        ];
        dz_base = -servo_clearance.z/2- base.z/2;
        
        if (!omit_base) {
            translate([0, 0, dz_base]) 
                cube(base, center=true);
        }

        if (!omit_top) {
            translate([0, 0, -dz_base]) 
                cube(base, center=true);
        }
    }

    module screw_blocks(screw_offset, extent, servo_clearance, remainder) {
        screw_block = [
            min(extent.x, servo_clearance.x), 
            remainder.y/2, 
            min(extent.z, servo_clearance.z)];
        dx_screw_block = -(extent.x - screw_block.x)/2;
        dy_screw_block = servo_clearance.y/2 + screw_block.y/2;
        
        center_reflect([0,1,0]) 
            translate([dx_screw_block, dy_screw_block, 0]) 
                drill_pilot_hole(screw_offset, screw_block) 
                    cube(screw_block, center=true);  
    }

    module back_wall(extent, servo_clearance, remainder) {
        back_wall = [
            remainder.x, 
            extent.y, 
            min(extent.z, servo_clearance.z)];
        dx_back_wall = servo_clearance.x/2;
    
        servo_connector_window = [4, 7, 9];
        dy_window = servo_clearance.y/2; 
        
        translate([dx_back_wall, 0, 0])
            render() difference() {
                cube(back_wall, center=true);
                translate([0, dy_window, 0]) cube(servo_connector_window, center=true);
                translate([0, -dy_window, 0]) cube(servo_connector_window, center=true);
            } 
    }


    module pilot_hole(screw_offset, screw_block) {
        t = [
            -(screw_block.x/2), 
            -screw_block.y/2 + screw_offset, 
            0
        ];
        translate(t) sub_micro_servo__pilot_hole(); 
    }


    module drill_pilot_hole(screw_offset, screw_block) {
        difference() {
            children();
            pilot_hole(screw_offset, screw_block);
        }
    }
    
}



module sub_micro_servo__mount_to_axle(
        axle_diameter=4, 
        axle_height= 10,
        wall_height=6,
        radial_allowance=0.4, 
        axial_allowance=0.4, 
        wall_thickness=2, 
        angle = 0,
        log_verbosity=INFO) {
    
    marker="----------------";       
    log_s(marker, "sub_micro_servo_mount_to_axle", log_verbosity, DEBUG);        
    log_s("axle_diameter", axle_diameter, log_verbosity, DEBUG);
    log_s("axle_height", axle_height, log_verbosity, DEBUG);
    log_s("wall_height", wall_height, log_verbosity, DEBUG);
    log_s("radial_allowance", radial_allowance, log_verbosity, DEBUG);
    log_s("axial_allowance", axial_allowance, log_verbosity, DEBUG);
    log_s("wall_thickness", wall_thickness, log_verbosity, DEBUG);        
    log_s("angle", axle_diameter, log_verbosity, DEBUG);
    log_s("log_verbosity", log_verbosity, log_verbosity, DEBUG);
                  
    fa_shape = 10;
    fa_bearing = 1;
            
    horn_thickness = 3;
    horn_radius = 11.9;
    horn_overlap = 0.5;
    hub_backer_l = 2;
    hub_backer_diameter = 16;
    dx_horn = horn_thickness + axial_allowance + hub_backer_l - horn_overlap;
    dx_servo_offset = 11.32; 
    dx_servo = dx_horn +  dx_servo_offset;

    servo_width = 12.00;
    size_pillar = [6, 4, servo_width/2 + axle_height];
    x_servo_side_wall = dx_servo - size_pillar.x;
    
    servo_length = 24.00;
    servo_axle_x_offset = 6;
    y_plus = servo_axle_x_offset;  // Axis differ by 90 degerees!
    y_minus = servo_length - servo_axle_x_offset;
    
    dy_wall_squared = 
        horn_radius*horn_radius 
        - (axle_height - wall_height)*(axle_height - wall_height);
    dy_wall_min = dy_wall_squared > 0 ? sqrt(dy_wall_squared) : 0;
    dy_wall = max(dy_wall_min + 2, y_plus);
    
    y_hub_clearance = dy_wall; //28/2;
                
    color("orange") x_axis_servo_hub(angle);
    rotary_servo_mount();
        
   
    module rotary_servo_mount() {
        color("red") servo_mounting_pillars();
        *color("blue") hub_yoke();
        *color("green") minus_joiner();
        *color("lime") plus_joiner();
        color("brown") bearing();
        if (dy_wall_squared < 0) {
            central_joiner();
        }
    }
    
    module horn_support() {

        dz = axle_height - horn_radius + radial_allowance;
        translate([0, 0, -axle_height]) {
            difference() {
                hull() {    
                    translate([-radial_allowance, 0, 0]) 
                        block([2*horn_thickness, 10, 0], center=ABOVE); 
                    translate([0, 0, dz]) 
                        block([2*horn_thickness, 5, 0]); 
                }
                translate([0,0, 1]) block([3*horn_thickness, 3, dz-1.5], center=ABOVE);
            }
        }
    }
    
    module truncate_at_build_plane() {
        difference() {
            children();
            translate([0, 0, -axle_height]) block([100, 100, 100], center=BELOW);
        }
    }
    
    module supported_horn() {
        translate([dx_horn, 0, 0]) {
            rotate([45, 0, 0]) {
                rotate([0, 90, 0]) 
                    bare_hub(horn_thickness);
            }
            horn_support();
        }
    }
            
    module x_axis_servo_hub(angle) {
        rotate([angle, 0, 0]) {
            truncate_at_build_plane() {
                translate([axial_allowance, 0, 0]) {
                    rod(d=hub_backer_diameter, 
                        l=hub_backer_l, 
                        center=FRONT, 
                        fa=2*fa_shape);
                    rod(d=axle_diameter, 
                        l=wall_thickness + 2 * axial_allowance, 
                        center=BEHIND, 
                        fa=fa_bearing);
                }
                supported_horn();
            }
        }
        
    }
 
    module drilled_pillar() {
        screw_offset = 2;
        difference() {
            block(size_pillar, center=BEHIND+ABOVE+RIGHT);
            translate([1, screw_offset, axle_height]) 
                rotate([0, 180, 0]) 
                    sub_micro_servo__pilot_hole();
        }
    }

    
    module servo_mounting_pillars() { 
        dy_plus = y_plus;
        
        translate([dx_servo, dy_plus, -axle_height]) {
                    drilled_pillar();     
        }
        
        dy_minus = -y_minus;
        translate([dx_servo, dy_minus, -axle_height]) {
            mirror([0, 1, 0]) drilled_pillar();
        }
        translate([dx_servo, dy_minus, -axle_height])
            block([size_pillar.x, servo_length, wall_thickness], center=BEHIND+ABOVE+RIGHT);
    }
    
    module hub_yoke() {
        side_wall = [x_servo_side_wall, wall_thickness, wall_height];
        bearing_wall = [
            wall_thickness, 
            2*y_hub_clearance + 2 * wall_thickness, 
            wall_height
        ];
        center_reflect([0, 1, 0]) {
            translate([0, y_hub_clearance, -axle_height]) { 
                block(side_wall, center=FRONT+ABOVE+RIGHT, rank=2);
            }
        }
        bore_for_axle(axle_diameter, radial_allowance, l=50) {
            translate([0, 0, -axle_height]) block(bearing_wall, center=BEHIND+ABOVE); 
        } 
    }
    
    module minus_joiner() { 
        y = y_minus - y_hub_clearance + size_pillar.y;
        dx = x_servo_side_wall;
        translate([dx, -y_hub_clearance, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+BEHIND+LEFT, rank=3);
    }
    
    module plus_joiner() {
        y = y_hub_clearance - y_plus + wall_thickness;
        dx = x_servo_side_wall;
        translate([dx, y_plus, -axle_height])  
            block([wall_thickness, y, wall_height], center=ABOVE+FRONT+RIGHT, rank=4);
    }
    
    module central_joiner() {
        dx = x_servo_side_wall;
        translate([dx, 0, -axle_height])  
            block([wall_thickness, 2*dy_wall, wall_height], center=ABOVE+BEHIND, rank=5);
    }
    
    module bearing() {
        translate([0, 0, 0]) {
            x_axle_bearing(
                axle_diameter, 
                axle_height, 
                bearing_width=wall_thickness, 
                radial_allowance=radial_allowance);
        }
    }
    
    module bore_for_axle(axle_diameter, radial_allowance, l=50) {
        bore_diameter = axle_diameter + 2 * radial_allowance;
        render() difference() {
            children();
            rod(d=bore_diameter, l=l, fa=fa_bearing);
        }
    }
    
    module x_axle_bearing(axle_diameter, axle_height, bearing_width, radial_allowance) {

        bore_for_axle(axle_diameter, radial_allowance) {
            hull() {
                block([bearing_width, 3*axle_diameter, axle_height], center=BELOW+BEHIND, rank=6);
                rod(d=3*axle_diameter, l=bearing_width, center=BEHIND, fa=fa_shape);
            }
        }

    }
}


module sub_micro_servo__radial_stall_limiter() {
    // WARNING - This is a work in progress.  Doesn't do what we want at this time.


    // Allow the servo to rotate a bit after the mechanism hits a hard stop,
    // without the motor stalling, by having the mechanism flex a bit.
    // Ideally, before the hard stop is hit, there will be little
    // flex.
    dz_shaft_engagement = 2; 
    strength = 1;
    d_shaft_hub = 8;
    h_shaft_hub = dz_shaft_engagement + strength;
    d_rim = 24;
    clearance = 1;
    h_servo_bottom = h_shaft_hub + clearance;
    dy_servo_bottom_inner = d_shaft_hub/2  + clearance;
    d_servo_hub_inner = 2 * dy_servo_bottom_inner;
    d_servo_hub = d_servo_hub_inner + strength;
    h_spring = 0.75;
    allowance = 0.4;
    horn_thickness = 2;
    y_rotation_gap = 7;
    
    spring();
    bottom_hub();
    servo_wiper();
    shaft_hub();
    servo_hub();
    
    module servo_hub() {
        dz = h_servo_bottom + horn_thickness;
        translate([0, 0, dz]) bare_hub(horn_thickness);
    }
    
    module spring() {
        d_inner = d_servo_hub+clearance;
        d_outer = d_rim-strength-clearance;
        module inner(a) {
            rotate([0, 0, a])
                translate([d_inner/2, 0 , 0]) 
                    can(d=2*allowance, h=h_spring, center=ABOVE+FRONT, fa=fa_shape);
        }
        module outer(a) {
            rotate([0, 0, a])
                translate([d_outer/2, 0 , 0]) 
                    can(d=2*allowance, h=h_spring, center=ABOVE+BEHIND, fa=fa_shape);
        }  
        da = 30;
        for (a = [0 : da : 360]) {
            hull() {
                inner(a);
                outer(a);
            }
            hull() {
                outer(a);
                outer(a + da/2); 
            }
            hull() {
                outer(a + da/2);
                inner(a + da/2); 
            }
            hull() {
                inner(a + da/2);  
                inner(a + da); 
            }
        }
    }
    
    module bottom_hub() {
        color("green")
        render() difference() {
            union() {
                can(
                    d=d_servo_hub, 
                    h=h_servo_bottom, 
                    hollow=d_servo_hub_inner, 
                    center=ABOVE,
                    rank=8);
                can(
                    d=d_rim, 
                    h=h_servo_bottom, 
                    hollow=d_rim-strength, 
                    center=ABOVE,
                    rank=4);
            }
            block([d_rim, y_rotation_gap, h_servo_bottom], center=ABOVE, rank=10);
        }
    }
    
    module servo_wiper() {
        x = strength;
        y = d_rim/2 - d_servo_hub_inner/2; 
        z = h_servo_bottom;
        dy = d_servo_hub_inner/2;
        color("blue") 
            center_reflect([0, 1, 0]) {
                translate([0, dy, 0]) block([x, y, z], center=ABOVE+RIGHT);
            }
   } 
    
    module shaft_hub() {
        difference() {
            union() {
                can(d=d_shaft_hub, h=h_shaft_hub, center=ABOVE);
                block([d_rim, strength, h_shaft_hub], center=ABOVE);
            }
            shaft_clearance();
        }
    }
    
    
    module shaft_clearance() {
        translate([0, 0, 25]) hole_through("M3");
        translate([0, 0, dz_shaft_engagement]) nutcatch_parallel("M3", clh=4);
        d_shaft = 5;
        can(d=d_shaft, h=20, center=BELOW);
    }
}





