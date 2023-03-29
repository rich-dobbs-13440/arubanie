include <logging.scad>
include <centerable.scad>
include <dupont_pins.scad>
include <SN_28B_measurements.scad>
use <SN_28B_pin_crimper.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

/* [Build] */ 
build_only_one = false;
// Check console for description of build items!
one_to_build = -1; // [-2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

/* [Minimal Jig Customization] */
show_mocks_mj = true;
show_wire_clamp_mj = true;
orient_for_build_mj = true;
z_yoke_mj = 2;

/* [Jaw Yoke Customization] */

x_front_cjy = 24; // [0:1:40]
x_behind_cjy = 20; // [0:1:24]
y_cjy = 20; // [0:1:24]
z_cjy = 1; // [0:0.5:4]
color_name_cjy_ = "SandyBrown"; 
screws_cjy = true; 


end_of_customization() {}


 module minimal_jig_base() { 
             
    SN_28B_jaw_yoke(
        x_front = 36 ,// dx_100_anvil - 3 ,
        x_behind = 14,
        y = 26,
        z = z_yoke_mj,
        color_name = "SandyBrown",
        color_alpha =1,
        screws = true);
 }


module slider_fixture() {
    spacing = 6;
    module oriented_slider() {
        rail_size = [4*spacing, spacing, 4];
        translate([0, 0, rail_size.z/2]) 
            rotate([0, 0, 90]) slider_rail(size=rail_size, depth=1, flat=1, as_clearance=false);
    }     
    color("white") { 
        difference() {
            oriented_slider();
            center_reflect([0, 1, 0]) {
                translate([0, 0.5*spacing, 25]) rotate([0, 0, 0]) hole_through("M3", cld=0.4, $fn=12);
                translate([0, 1.5*spacing, 25]) rotate([0, 0, 0]) hole_through("M3", cld=0.4, $fn=12);
            }
//
        }  
    } 
}

module minimal_jig(show_mocks=false, show_wire_clamp=false, orient_for_build = true) {
    z_clearance = 0.25;
    dz = dz_100_wire_punch_z + od_barrel_dpgn/2+z_clearance;
    t_pin_holder = [dx_100_anvil, -dx_insulation_wrap_dpgn, dz];
    t_wire_holder = [dx_100_anvil, x_insulation_wrap_dpgn + x_strip_dpgn, dz];
    t_pivot_block =  [dx_100_anvil - 3, y_lower_jaw_anvil/2, z_yoke_mj];
    
    module basic_pin_holder() { 
        pin_holder(
            z_spring = 0.5, 
            z_housing_catch = 0.1,
            include_screw_holes = false,
            slider = true,
            show_part_colors = true,
            show_mock = show_mocks && ! orient_for_build,
            mock_is_male = true,
            color_name = "orange", 
            color_alpha = 1);  
    }   
    
    module oriented_pin_holder() {
        translate(t_pin_holder) 
            rotate([0, 0, 90])
                basic_pin_holder();
    }
    
    module basic_wire_holder() {
        wire_holder(
            pincher_clearance=0.5, 
            z_pivot = 3,
            include_screw_holes = true,
            orient_for_build = false, 
            show_mock = show_mocks && ! orient_for_build,
            show_clamp = false,
            clamp_angle = 0, 
            show_body = true);
                       
    }
    module oriented_wire_holder() {
        translate(t_wire_holder) rotate([0, 0, -90]) basic_wire_holder();
    }


         
     module pivot_block() {
         
        module nutcatch(y, hole=true, nut=true) {
            translate([-2, y,  1.9]) {
                rotate([0, 90, 0]) {
                    if (hole) {
                        translate([0, 0, 47]) hole_through("M2", cld=0.4, $fn=12);
                    }
                    if (nut) {
                        nutcatch_sidecut("M2");
                        /*	l      = 50.0,  // length of slot
                        clk    =  0.0,  // key width clearance
                        clh    =  0.0,  // height clearance
                        clsl   =  0.1)  // slot width clearance */
                    }
                }
            } 
        }       
        module shape() { 
            translate(t_pivot_block) {
                difference() { 
                    union() {
                        block([4, 30, 7], center=ABOVE+BEHIND+RIGHT);
                        block([12, 30, 4], center=ABOVE+BEHIND+RIGHT);
                    }
                    nutcatch(y=2.8);
                    nutcatch(y=8.8);
                    hull() {
                        nutcatch(y=8.8, hole=false, nut=true);
                        nutcatch(y=25, hole=false, nut=true);
                    }
                    hull() {
                        nutcatch(y=8.8, hole=true, nut=false);
                        nutcatch(y=25, hole=true, nut=false);
                    }
                }
            }
        }
        difference() {
            shape();
            translate([8, 8, 25]) rotate([0, 0, 0]) hole_through("M3", cld=0.4, $fn=12);
            translate([8, 14, 25]) rotate([0, 0, 0]) hole_through("M3", cld=0.4, $fn=12);
            translate([8, 20, 25]) rotate([0, 0, 0]) hole_through("M3", cld=0.4, $fn=12);
        }     
    }
 

    if (orient_for_build) {
        translate([0, 0, 0]) base();
        translate([30, 0, -z_yoke])  center_reflect([0, 1, 0]) pivot_block(); 
        translate([70, 0, 3]) rotate([-90, 0, 0]) basic_pin_holder();
        translate([100, 0, 3]) rotate([90, 0, 0]) basic_wire_holder();
    } else {
        minimal_jig_base();
        mirror([0, 1, 0]) translate([14, 17, z_yoke_mj]) slider_fixture();
        mirror([0, 1, 0]) translate([26, 17, z_yoke_mj]) slider_fixture();
        translate([14, 17, z_yoke_mj]) slider_fixture();
        oriented_pin_holder(); 
        oriented_wire_holder();
        //center_reflect([0, 1, 0]) pivot_block();
        //pin_holder_pivot_block();
    }
    
    if (show_mocks && ! orient_for_build) {   
        rotate([180, 0, 0])  SN_28B_upper_jaw_anvil(); 
    }  

    
}

function translation(idx) = [0, 30*idx, 0];

module build(idx, description) {
    echo("Build index: ", idx, "Description: ", description);
    if (!build_only_one || (idx == one_to_build)) {
        translate(translation(idx)) children();
    }
}

module customized_jaw_yoke() {
    SN_28B_jaw_yoke(
        x_front = x_front_cjy, // x_front_cjy = 24; // [0:1:24]
        x_behind = x_behind_cjy, // x_front_cjy = 24; // [0:1:24]
        y = y_cjy, // y_cjy = 24; // [0:1:24]
        z = z_cjy,// z_cjy = 24; // [0:0.5:4]
        color_name = color_name_cjy_, // color_name_cjy_ = "SandyBrown", 
        screws = screws_cjy); // screws_cjy = true;  
} 
    
build(-1, "minimal_jig()") 
    minimal_jig(
        show_mocks=show_mocks_mj, 
        show_wire_clamp=show_wire_clamp_mj, 
        orient_for_build = orient_for_build_mj);

build(-2, "minimal_jig_base()") minimal_jig_base();

build(1, "Customized SN_28B_jaw_yoke") customized_jaw_yoke();




build(2, "wire_holder")
    wire_holder(
        pincher_clearance=0.5, 
        z_pivot = 6,
        orient_for_build=false, 
        show_mock=true, 
        show_clamp = true,
        clamp_angle = 0, 
        show_body = true);

build(3, "dupont_connector")
    dupont_connector(
        wire_color = "yellow", 
        housing_color = "black",         
        center = ABOVE,
        housing = DUPONT_STD_HOUSING(),
        has_pin = false, 
        has_wire = true,
        color_alpha = 1);
        
build(4, "female_pin")
    female_pin( 
        orient = FRONT,
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true,
        alpha=1);                 

build(5, "male_pin")
    male_pin(
        orient = FRONT,
        pin = true, 
        strike = true,
        detent = true, 
        barrel = true,
        conductor_wrap = 0,
        insulation_wrap = 0, 
        strip = true,
        alpha=1);


build(6, "pin_latch")
    pin_latch(
        width=2.54, 
        z_clearance = 1, 
        color_name = "FireBrick", 
        color_alpha = 1, 
        show_mock = true, 
        mock_is_male = true);
     

build(7, "pin_holder")
    pin_holder(
        z_spring = 1.5, 
        z_housing_catch = 0.1,
        include_screw_holes = false,
        show_part_colors = false,
        show_mock = true,
        mock_is_male = true,
        color_name = "orange", 
        color_alpha = 1);

build(8, "pin_holder_screws")
    translate([-2, 0, 0]) 
        pin_holder_screws(as_hole_through=true, $fn=12);

build(0, "slider_fixture()") slider_fixture();       

module colorize(color_name, color_alpha, show_part_colors) {
    if (show_part_colors) {
        children();
    } else {
        color(color_name, color_alpha) {
            children();
        }
    }
}                 


// module pin_holder_screws(
//         as_screw = false, 
//         as_hole_threaded = false, 
//         as_hole_through = false,
//         as_nutcatch_sidecut = false) {
//     module process() {
//         for (x = [0 : 6 : 18]) {
//             translate([-x, 0, -3]) rotate([90, 0, 0]) children(); 
//         }
//     }
//     if (as_hole_through) {
//         process() translate([0, 0, 25]) hole_through("M2", cld=0.4);
//     }
        
//     if (as_hole_threaded) {
//         process() translate([0, 0, 12.5]) hole_threaded("M2");
//     }
//     if (as_screw) {
//         stainless() process() translate([0, 0, +2.54/2]) screw("M2x8");
//     }
//     if (as_nutcatch_sidecut) {
//         process() translate([0, 0, 2]) rotate([0, 0, 90]) nutcatch_sidecut(name = "M2", clh=0.3);
//     }
// }