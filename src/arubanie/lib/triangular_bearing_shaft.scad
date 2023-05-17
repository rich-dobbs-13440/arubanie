include <material_colors.scad>
include <logging.scad>
include <centerable.scad>
use <shapes.scad>
use <material_colors.scad>
use <not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
include <nutsnbolts-master/data-metric_cyl_head_bolts.scad>
use <rcolyer-threads-scad/threads.scad>
use <PolyGear/PolyGear.scad>


od_bearing = 22.0 + 0;
id_bearing = 8.0 + 0;
h_bearing = 7.0 + 0;
md_bearing = 14.0 + 0;

/* [Clearances] */ 
ptfe_snap_clearance = 0.17;
ptfe_slide_clearance = 0.5; // [0.5:Actual, 1:test]


/* [Output] */ 

orient_for_build = true;
show_vitamins = true;
build_prong_assembly = true;
build_ziptie_bearing_attachment = true;
build_shaft = true;
build_screw_clutch = true;
build_shaft_rider = true;

/* [Shaft Design] */

shaft_length = 100; // [0:100]
shaft_clearance = 0.4;


/* [Rider Design] */
r_shaft_end = 0.1;
r_shaft = id_bearing/2;
// 4.5, 4.4 yielded lots of play 
r_rider = 4.2; // [1: .1 : 10]


// 0.15 was pretty tight, 0.2 was loose, might be interaction with r_rider though

/* [Clutch Design] */
n_thumb_wheel_teeth = 15; //[1:30]

m_thumb_wheel = 1.9; // [1.5: .1 :2]
/* [Prong Design] */
prong_locked = true;
h_prong_clip = 4;
h_prong_assembly_gap = 10; // [7: 20]
dz_bearing_prong_mocks = 2; // [-5:0.1:5]
dz_shaft_gear_prong_mocks = 0; // [-5:0.1:5]

module end_of_customization() {}

if (build_shaft_rider) {
    shaft_rider(h=5, orient_for_build=true, show_vitamins=false);
}

if (build_prong_assembly) {
    if (orient_for_build) {
        translate([20, -20, 0]) prong_assembly(orient_for_build=true);
    } else {
        prong_assembly(locked=prong_locked, show_mocks=show_vitamins, h_gap=h_prong_assembly_gap);
    }     
}



if (build_ziptie_bearing_attachment) {
    ziptie_bearing_attachment();
}

if (build_screw_clutch) {
    screw_clutch();
}

module screw_clutch() {
    
    z_thumb_wheel = 6;

    diameter = 14;
    id = 9;
    length = 4;

    infinity = 100;
    original_z_nut = 14;
    z_nut = 2;
    total_bolt_length = length+z_nut;
    
    module left_handed_hollow_bolt() {
        color("lightpink") {
            mirror([0, 0, 1]) right_handed_hollow_bolt();
        }
    }
    
    module right_handed_hollow_bolt() {
        color("red") {
            translate([0, 0, -length-z_nut]) {
                render(convexity = 10) difference() {
                    translate([0, 0, -original_z_nut+z_nut]) MetricBolt(diameter, length, tolerance=0.4);
                    plane_clearance_below();
                    cylinder(h=infinity, d=id, center=true);
                } 
            }  
        }     
    }   

    module plane_clearance_below() {
        translate([0, 0, -infinity/2]) cube([infinity, infinity, infinity], center=true);
    }
    
    module thumb_wheel() {
        color("orange") {
            render(convexity = 10) {
                center_reflect([0, 0, 1]) {
                    MetricNut(diameter, z_thumb_wheel/2, tolerance=0.4);
                }

                difference() {
                    spur_gear(
                        n = n_thumb_wheel_teeth,  // number of teeth
                        m = m_thumb_wheel,   // module
                        z = z_thumb_wheel);   // thickness
                        can(d=diameter+4, h=100);
                }
            }
        }
    }
    if (orient_for_build) {
        spacing = 2.5*diameter;
        translate([+spacing, 0, total_bolt_length]) //rotate([180, 0, 0]) 
        right_handed_hollow_bolt();
        translate([-spacing, 0, total_bolt_length]) rotate([180, 0, 0]) left_handed_hollow_bolt();
        translate([0, 0, z_thumb_wheel/2]) thumb_wheel();
    } else {
        right_handed_hollow_bolt();
        left_handed_hollow_bolt();
        thumb_wheel();
    }
    
}



module ptfe_tube(as_clearance, h, clearance) {
    d = as_clearance ? 4 + 2*clearance : 4;
    color("white") can(d=d, h=h, $fn=32);
}



module prong_screws(as_clearance=false, dz=0) {
    h = 10;
    if (as_clearance) {
        center_reflect([0, 1, 0]) translate([-8, 3, h + dz]) hole_through("M2", h=h, $fn=12);
    } else {
        color(BLACK_IRON) {
            center_reflect([0, 1, 0]) translate([-8, 3, dz]) screw("M2x6", $fn=12);
        }
    }
} 

if (build_shaft) {
    if (orient_for_build) {
        translate([40, 0, 0]) slider_shaft(length=shaft_length, orient_for_build=true);
    } else {
        slider_shaft(length=shaft_length, orient_for_build=false);
    }    
}



module prong_assembly(locked=true, orient_for_build=false, show_mocks=false, h_gap=0) {
    prong_insert_angle = 9; // [0: 0.1: 20]
    dy_prong_spacing = 11.8; // [5:0.1:20]   
    dx_insertion = 2.85;
    d_contact = 14.1;
    hinge_thickness = 0.3;
    a_lot = 200;
    
    //assert(false);
    echo("h_gap", h_gap);
    h_below = h_gap - h_bearing + h_prong_clip;
    echo("h_below", h_below);
    dz_screws = -h_below + h_prong_clip/2;
    module prong() {
        h_above = h_bearing + h_prong_clip;
        rotate([0, -prong_insert_angle, 0]) {
            render(convexity=10) difference() {            
                rotate([0, prong_insert_angle, 0]) {
                    bearing_insert_splinter(h_above);
                    translate([-dx_insertion, 0, h_above]) block([5, 5.3, h_prong_clip], center=BEHIND+BELOW);
                }
                translate([0, 0, 5]) can(d=od_bearing, hollow=id_bearing, h=a_lot, center=ABOVE);
            }
        }
        
        translate([0, 0, -h_below]) bearing_insert_splinter(h_below);
        difference() {
            translate([-dx_insertion, 0, -h_below])
                block([6, 8, h_prong_clip], center=ABOVE+BEHIND);
            rotate([0, 0, 30]) plane_clearance(FRONT);
            rotate([0, 0, -30]) plane_clearance(FRONT);
            #prong_screws(as_clearance=true, dz=dz_screws); 
        }                  
    }
    module pronate_prong() {
        render(convexity=10) difference() {
            rotate([0, 90, 0]) translate([dx_insertion, 0, 0]) prong();
            plane_clearance(BELOW);
            translate([0, 5, 0]) rotate([45, 0, 0]) plane_clearance(BELOW);
            translate([0, -5, 0]) rotate([-45, 0, 0]) plane_clearance(BELOW);
        }
        
    }
    if (show_mocks) {
        *translate([0, 0, dz_bearing_prong_mocks]) 
            color("silver", 0.25) ball_bearing(BB608); 
        *translate([0, 0, dz_shaft_gear_prong_mocks]) 
            shaft_gear(orient_to_center_of_rotation=true,  show_vitamins=false);
        prong_screws(as_clearance=false, dz=dz_screws);
    }
    if (orient_for_build) {
        pronate_prong();
        //translate([0, dy_prong_spacing, 0]) pronate_prong();
        //translate([0, -dy_prong_spacing, 0]) pronate_prong();
    } else {
        triangle_placement(0) {
            prong();   
        }
    }
}



module old_prong_assembly(locked=true, orient_for_build=false, show_vitamins=false) {
    dx_insert = 2.9;
    dy_cut = 2.2; // [0:.1:5]
    prong_insertion_angle = 129; // [120:140]
    h_clip = 2;
    h_total = h_bearing + 4*h_clip;    
    module prong() {
        translate([0, 0, -h_total/2]) bearing_insert_splinter(h=h_total);
        translate([-dx_insert, 0, 0]) {
            center_reflect([0, 0, 1]) {
                translate([0, 0, h_total/2])
                    difference() {
                        can(d=id_bearing, h=2, center=BELOW);
                        plane_clearance(FRONT);
                        rotate([0, 0, 45]) translate([0, -dy_cut, 0]) plane_clearance(LEFT);
                        rotate([0, 0, -45]) translate([0, dy_cut, 0]) plane_clearance(RIGHT);
                    }
            }
        }
    }
    module pronate_prong() {
        rotate([0, 90, 0]) 
            translate([dx_insert, 0, h_total/2]) 
                prong();        
    }
    if (show_vitamins && !orient_for_build) {
        ball_bearing(BB608);
    }
    if (orient_for_build) {
        pronate_prong();
        translate([0, 10, 0]) pronate_prong();
        translate([0, -10, 0]) pronate_prong();

    } else {
        prong_angle = locked ? 120: prong_insertion_angle;
        dx_prong = locked ? 0 : dx_insert;
        translate([dx_prong, 0, 0]) prong();
        rotate([0, 0, prong_angle]) prong();
        rotate([0, 0, -prong_angle]) prong();
    }
}


module ziptie_bearing_attachment()  {
    a_lot = 100;
    render(convexity=10) difference() {
        can(d=md_bearing, h=4, center=ABOVE);
        slider_shaft(as_gear_clearance=true);
        triangle_placement(0) 
            translate([-id_bearing/2, 0, 0]) 
                rotate([0, -45, 0]) 
                    block(1.5*[1.2, 2.5, a_lot], center=FRONT); 
    }
}


module bearing_insert_splinter(h) {
    module blank() {
        can(d=id_bearing, h=h, center=ABOVE);
    }    
    module shape() {
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
            rotate([0, 0, 30]) plane_clearance(FRONT);
            rotate([0, 0, -30]) plane_clearance(FRONT);
        }
    }   
    shape(); 
}



module shaft_rider(h, orient_for_build, show_vitamins) {
    a_lot = 200; 
    module blank() {
        can(d=md_bearing + 1, h=h, center=ABOVE);
    }
    module shape() {    
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
            rotate([0, 0, 60]) triangle_placement(r=r_rider) 
                ptfe_tube(as_clearance=true, h=a_lot, clearance=ptfe_snap_clearance);            
        }
    }
    if (show_vitamins) {
        translate([0, 0, h/2]) 
            rotate([0, 0, 60]) triangle_placement(r=r_rider) 
                ptfe_tube(as_clearance=true, h=h, clearance=ptfe_snap_clearance);         
        //translate([0, 0, -5]) ball_bearing(BB608);
        //slider_shaft(orient_for_build=true);
    }    
    if (orient_for_build) {
        translate([0, 0, 0]) rotate([0, 0, 0]) shape();
    } else {
        translation = [0, 0, 0];  
        translate(translation) shape();
    } 
}


module slider_shaft(
        length = 0,
        orient_for_build = false, 
        as_clearance = false,
        as_gear_clearance = false,
        as_circular_clearance = false,
        clearance = ptfe_slide_clearance) {
    a_lot = 300;      
    shaft_length = 
        as_clearance ? a_lot :
        as_gear_clearance ? a_lot :
        length;
      
    actual_clearance = 
        as_clearance ? clearance :
        as_gear_clearance ? clearance :
        0;
            
    assert(is_num(shaft_length));

    z_clearance = as_clearance ? a_lot : 0.01;    

    translation = orient_for_build ? [0, 0, shaft_length/2] : [0, 0, 0];    
    module blank() {
        d_end = 
            as_clearance ? 2 * r_shaft_end  + 2 * actual_clearance : 
            as_gear_clearance ? 2 * r_shaft_end  + 2 * shaft_clearance :
            2 * r_shaft_end;
        r_arm = as_gear_clearance ? r_shaft + sqrt(3) * shaft_clearance : r_shaft;
        hull() {
            triangle_placement(r=r_arm) can(d=d_end, h=shaft_length, $fn=50);
        }
    }
    module shape() {
        color("green") {
            render(convexity=10) intersection() { 
                blank();
                can(d=2*r_shaft - 2*shaft_clearance, h=a_lot);
            }
        }       
    }
    if (as_gear_clearance) {
        blank();
    } else if (as_circular_clearance) {
        d_shaft_clearance = 2 * (r_shaft + r_shaft_end + shaft_clearance);
        can(d=d_shaft_clearance , h=a_lot); 
    } else if (orient_for_build) {
        translate([0, 0, shaft_length/2]) shape();
    } else {
        translate(translation) shape();
    } 
}



module slider_shaft_bearing_insert(
        orient_for_build=false, 
        show_vitamins=false, 
        as_clearance=false,
        protect_from_elephant_foot=true) {
    h_face = 2;
    d_face = md_bearing - 2 * part_push_clearance;
    
    module blank() {
        translate([0, 0, h_bearing/2 + h_face]) 
            can(d=id_bearing, h=h_bearing+h_face+1, center=BELOW);
        translate([0, 0, -h_bearing/2-1]) 
            can(d=id_bearing - 2, taper=id_bearing, h = 1.3, center=BELOW);
    }
    module shape() {
        translate([0, 0, h_bearing/2]) {
            if (protect_from_elephant_foot) {
                render(convexity=10) intersection() {
                    can(d=d_face, h = 2, hollow=id_bearing, center=ABOVE);
                    can(d=d_face, h = 2, taper=d_face-2, center=ABOVE);
                }
            } else {
                can(d=md_bearing, h = 2, hollow=id_bearing, center=ABOVE);
            }
        }
        render(convexity=10) difference() {
            blank();
            slider_shaft(as_gear_clearance=true);
        }
    }
    if (show_vitamins) {
        ball_bearing(BB608);
        slider_shaft(orient_for_build=true);
    }
    color("DarkSeaGreen") {
        if (as_clearance) {
            can(d=d_face + 5, taper=d_face, h=5, center=BELOW); 
            
        } else if (orient_for_build) {
            translate([0, 0, h_bearing/2 + h_face]) rotate([180, 0, 0]) shape();
        } else {
            //translation = [0, 0, 0];  // centered on bearing
            translation = [0, 0, -h_bearing/2];  // centered on top
            translate(translation) shape();
        } 
    }
}




module ptfe_glides(
        glide_length, 
        orient_for_build = false, 
        show_vitamins = false, 
        as_clearance = false, 
        as_traveller_clearance = false, 
        clearance = 0) {

    a_lot = 10;
    //z_clearance = clearance ? a_lot : 0.01;
    //glide_length = slide_length + z_end_cap;
    assert(is_num(glide_length));
    translation = orient_for_build ? [0, 0, glide_length/2] : [0, 0, 0]; // [dx_glides, 0, 0]; 
    module core() {
        s = od_ptfe_tube + 2  + 2 * clearance;
        es = s - 2 * elephant_clearance;
        if (as_clearance) {
            block([s, s, glide_length], center=BEHIND);
        } else {
            hull() {
                translate([-elephant_clearance, 0, 0]) 
                    block([es, es, glide_length], center=BEHIND);
                block([s, s, glide_length - 2], center=BEHIND);
            }
        }
    }   
    module blank() {
        triangle_placement(r=r_glide + glide_engagement + clearance) core();
        if (as_traveller_clearance) {
            triangle_placement(r=r_glide + glide_engagement)
                ptfe_tube(as_clearance=true, h=slide_length, clearance=0);                
        }
    }
    module shape() {
        as_tube_clearance = as_traveller_clearance ? false : true;
        color("blue") {
            render(convexity=10) difference() { 
                blank();
                if (as_tube_clearance) {
                    triangle_placement(r=r_glide) 
                        ptfe_tube(as_clearance=true, h=slide_length-z_gear_clearance, clearance=ptfe_snap_clearance);
                }
                if (show_cross_section) {
                    plane_clearance(ABOVE);
                }
            }
        }       
    }
    
    if (show_vitamins) {  
        translate(translation) 
            triangle_placement(r=r_glide) 
                ptfe_tube(as_clearance=false, h=slide_length-z_gear_clearance);
    }    
    if (orient_for_build) {
        translate([0, 0, glide_length/2]) shape();
    } else {
        translate(translation) shape();
    }
}

