/*

Usage:

use <lib/print_in_place_joints.scad>

can_to_plate_connection(plate_side, diameter, slide_allowance);

*/


include <centerable.scad>
use <shapes.scad>


$fa = 10;
fa_as_arg = $fa;
$fs = 0.4;
eps = 0.001;

infinity = 50;

pin_radius = 5;

lap_radius_clearance = 0.3;
pin_tolerance = 0.3;


/* [Show] */
test_show_assembly = false;
test_show_modified_part_1 = false;
test_show_pin = false;
test_show_pin_added_back_on = false;
test_show_lap = false;
test_show_cutter = false;
test_show_artifact_tearaway = false;
test_show_pin_angle = false;
/* [Test] */
test_length = 30;
test_part_2_width = 10;
test_thickness = 4;
test_breakable_gap = 0.28;
test_breakable_gap_spacing = 1.5;
test_pin_angle = 5;
test_pin_for_angle_extend = false;

test_overlap = 10;

lap_radius = 2 * pin_radius;

//height=0.25;
//r=1;
//thickness=0.25;
//loops=6;

/* [Filler Tests] */
element_size = 0.5;
artifact_radius = 10;
h_base = 2;

/* [Rod, can to plate] */
show_plate_connection = false;
show_rod_connection = false;
show_dove_tailed_rod = true;


module end_of_customization() {}


module can_to_plate_connection(plate_side, diameter, slide_allowance) {
    plate_h = diameter/2;
    module bit(allowance) {
        //cutter_h = plate_h;
        
        d1 = 0.65 * diameter + 2*allowance;
        d2 = diameter + 2*allowance;
        translate([0, 0, eps]) can(d=d1, taper=d2, h=plate_h, center=BELOW, fa=fa_as_arg); 
        
    }
    module dove_tail(allowance) {
        hull() {
            bit(allowance);
            translate([4*diameter, 0, 0]) bit(allowance);
        }
    }
    if (plate_side) {
        translate([0, 0, eps]) render() difference() {
            can(d=2*diameter, h=plate_h-slide_allowance, center=BELOW, fa=fa_as_arg);
            dove_tail(slide_allowance);
        } 
    } else {
        
        render() intersection() {
            dove_tail(0);
            translate([0, 0, -slide_allowance]) can(d=diameter, h=plate_h, center=BELOW, fa=fa_as_arg); 
        } 
        render() difference() {
            children();
            translate([0, 0, eps]) can(d=diameter+1, h=plate_h+eps, center=BELOW, fa=fa_as_arg);
        }
    }
}

module rod_to_block_dove_tail_connection(plate_side, diameter, slide_allowance) {
    rotate([0, -90, 0]) {
        can_to_plate_connection(plate_side, diameter, slide_allowance) {
            rotate([0,90,0]) {
                children();
            }
        }
    }
}

module dove_tailed_rod(d, l, rotation, ends=[true, false]) {
    size = [l, d, d]; 
    center_rotation(rotation) {
        rod_to_block_dove_tail_connection(plate_side=false, diameter=d, slide_allowance=0.2) {
            rod(d=d, l=l, center=FRONT);
        }
    }
} 

//rod_to_block_dove_tail_connection(plate_side=false, diameter=5, slide_allowance=0.2) 
//       rod(d=5, l=30, center=SIDEWISE+ABOVE+RIGHT)

if (show_plate_connection) {
   
    color("red") can_to_plate_connection(plate_side=true, diameter=5, slide_allowance=0.2); 
}

if (show_rod_connection) {
    // can(d=5, h=10, center=BELOW);
    color("blue") can_to_plate_connection(plate_side=false, diameter=5, slide_allowance=0.2) {
        can(d=5, h=10, center=BELOW);
    }
}

//if (show_dove_tailed_rod) {
//    * rod_to_block_dove_tail_connection(plate_side=false, diameter=5, slide_allowance=0.2) {
//        rod(d=5, l=30, center=FRONT);
//    }  
//}

dove_tailed_rod(d=5, l=30, rotation=BELOW);  //center=SIDEWISE+ABOVE+RIGHT); 

//    rod(d=d, l=ys[0], center=SIDEWISE+ABOVE+RIGHT);
    ///rod_to_block_dove_tail_connection(plate_side=false, diameter=5, slide_allowance=0.2) {
//////////  =====================================================================


show_name = false;
if (show_name) {
    linear_extrude(2) text("print_in_place_joints.scad", halign="center");
}

module part_1(overlap) {
    x = test_length + overlap;
    y = test_length;
    z = test_thickness;
    dx = -x/2 + test_overlap; 
    translate([dx, 0, 0]) cube([x, y, z], center=true);
}

*part_1(test_overlap);

module part_2(overlap) {
    assert(overlap!=undef);
    x = test_length   +  overlap;
    y = test_part_2_width;
    z = test_thickness;
    dx = x/2 - overlap; 
    translate([dx, 0, 0]) cube([x, y, z], center=true);
}

* part_2(10);

module octants(t) {
    dx = t.x * (1+eps) * infinity / 2;
    dy = t.y * (1+eps) *infinity / 2;
    dz = t.z * (1+eps) *infinity / 2;
    translate ([dx, dy, dz]) cube([infinity, infinity, infinity], center=true);
}

module excise(t) {
    difference(t) {
        children();
        octants(t);
    }
    
}

module lap_end_to_radius(r, excise_t = [1,0,0]) {
    difference() {
        children();
        difference() {
            octants(-excise_t);
            excise(excise_t) cylinder(r=r, h=infinity, center=true);
        }
    }    
}

* lap_end_to_radius(r=2*pin_radius) part_2(10);    

module lap() {
    scale([1.0 + eps,1.00 + eps, 1.0+eps]) difference() {
        intersection() {
            children(0);  // part_1(test_overlap);
            children(0);  // part_2(test_overlap);
        }
        octants([0,0,1]);
    }
}

if (test_show_lap) {
    color("red") lap() {
        part_1(test_overlap);
        part_2(test_overlap);
    }
}

* lap_end_to_radius(r=2*pin_radius, excise_t=[-1, 0, 0]) lap() {
    part_1(test_overlap);
    part_2(test_overlap);
}

module lap_2() {
    r_lap = 2*pin_radius;
    lap_end_to_radius(r=r_lap, excise_t=[-1, 0, 0]) lap() {
        part_1(test_overlap);
        part_2(test_overlap);
    }
}

* color("blue") lap();
* color("red") translate([0, 0, 1]) lap_2();
* part_2(test_overlap);

module lap_removed() {
    difference() {
        part_2(test_overlap);
        lap_2(); // lap();
    }    
}

* lap_removed();

module pin(r, h) {
    r_1 = 0.85 * r;
    mirror([0,0,1]) translate([0,0, 0]) cylinder(r1=r_1, r2=r, h=h);
}
if (test_show_pin) {
    pin(5, test_thickness/2);
}

module pin_added_back_on() {
    union() {
        lap_end_to_radius(2*pin_radius) lap_removed();
        pin(pin_radius, test_thickness/2 + eps);
    }
}

if (test_show_pin_added_back_on) {
    pin_added_back_on();
}

module rotate_through_range(z_angle_range) {
    render(convexity = 2) union() {
        for (angle = z_angle_range) {
            rotate([0, 0, angle]) children(); 
        }
    }
}

* rotate_through_range([-10,0,10]) scale([1.01, 1.01, 1.01]) pin_added_back_on();
* rotate_through_range([-20:4:20]) scale([1.01, 1.01, 1.01]) pin_added_back_on();

// for (a =[-20:4:20])* echo(a);
//b = [-20:4:20];
//for (a = b) * echo(a);

module cutter() {
    /// Expand cutout to create outer clearance
    expansion_lap = (lap_radius + lap_radius_clearance)/lap_radius;
    expansion_pin = (pin_radius + pin_tolerance)/pin_radius;
    expansion = max(expansion_lap, expansion_pin);
    scale([expansion, expansion, 1.01])  pin_added_back_on();
    // Cut notches into bottom
    contraction = (lap_radius - lap_radius_clearance)/lap_radius;
    scale([contraction, contraction, 1.01]) pin_added_back_on();
    
    // central_clearance
    scale([expansion, expansion, expansion]) cylinder( r=2*pin_radius, h=0.3, center=true);
}

if (test_show_cutter) {
    color("purple") cutter();
}

module part_1_cutout() {
    rotate_through_range([-40, 0, 40 ]) cutter();   
    // central_clearance
    //scale([1.05, 1.05, 1.05]) cylinder( r=2*pin_radius, h=0.3, center=true);
}

* part_1_cutout();

module modified_part_1() {
    difference() {
        part_1(test_overlap);
        part_1_cutout();
    }
}

if (test_show_modified_part_1) {
    color("lime") modified_part_1();
}

module test_assembly() {
    modified_part_1();
    color("magenta") pin_added_back_on();
}

if (test_show_assembly) {
    test_assembly();
}


module test_breakable_shoulder() {
    part_2(-1);
    mirror([1,0,0]) part_2(0); 
    translate([0,0,test_thickness-eps]) part_2(0);
    // overlap
    translate([0,0,test_thickness+test_breakable_gap]) part_2(5); 
    
    // breakable_filler
    for (dx = [0: test_breakable_gap_spacing: 5]) {
        translate([-dx , -test_part_2_width/2, test_thickness/2]) cube([test_breakable_gap, test_part_2_width, test_breakable_gap+eps]);
    }
}

* test_breakable_shoulder();




module spiral(r, thickness, loops, height) {
    // From https://www.hubs.com/talk/t/need-help-want-to-make-a-spiral-flat/9081/5
    // Doesn't give control of spacing between loos

    linear_extrude(height=height) {
        polygon(
            points=concat( [for(t = [90:360*loops]) [(r-thickness+t/90)*sin(t),(r-thickness+t/90)*cos(t)]], [for(t = [360*loops:-1:90]) [(r+t/90)*sin(t),(r+t/90)*cos(t)]] ));
    }  
}

module annulus(r1, r2, h, center=false) {
    difference() {
        cylinder(r=r2, h=h, center=center);  
        cylinder(r=r1, h=infinity, center=true); 
    }
}

module rings(r, dr, h, center) {
    for (r2 = [0 : dr : r]) {
        r1 = r2-h;
        annulus(r1, r2, h, center=center);
    }
}

* rings(r=20, dr=2, h=0.25, center=true);

module star(r, delta_angle, h, center) {
    x = r;
    dx = center ? x/2 : 0;   
    for (az = [0 : delta_angle : 360]) {
        rotate([90,0,az]) translate([dx, 0, 0]) cube([x, h, h], center=center);

    }
}

* star(r=10,  delta_angle=360/5, h=0.25, center=false);


//rings(r_range=[10], r_element=1 );

module filler(artifact_radius, dr, element_size, filler_delta_angle) {
    translate([0, 0, -element_size / 2]) star(r=artifact_radius, delta_angle=filler_delta_angle, h=element_size,center=true); 
    translate([0, 0, element_size / 2]) rings(r=artifact_radius, dr=dr, h=element_size, center=true);
    rotate([0, 0, filler_delta_angle/2]) translate([0, 0, 1.5*element_size]) star(r=artifact_radius, delta_angle=filler_delta_angle, h=element_size,center=true);
}
* filler();

module base(d_base, h) {
    cylinder(d=d_base, h=h, center=true);
    cube([1.5*d_base, 0.25*d_base, h], center=true);
}


module top_over_filler(d_base, h, h_support) {
    cylinder(d=d_base, h=h, center=true);
    // Tabs
    tab_width = 0.25*d_base;
    rotate([0,0,90]) {
        cube([1.5*d_base, tab_width, h], center=true);
        // Support for tabs
        x = tab_width;
        z = h_support; 
        dx = 1.05*d_base/2 + tab_width/2;
        dz = -z/2 - h/2;
        translate([dx, 0, dz]) cube([x, tab_width, z], center=true);
        translate([-dx, 0, dz]) cube([x, tab_width, z], center=true);
    }

}

module test_artifact_tearaway() {
    d_base = artifact_radius * 2;
    base(d_base, h_base);
    
    dr = artifact_radius/2;
    translate([0,0,h_base/2 + element_size]) {
        filler(artifact_radius = artifact_radius, dr=dr, element_size = element_size, filler_delta_angle=90); 
    }
    dz = h_base + 3 * element_size;
    translate([0,0,dz]) top_over_filler(d_base, h_base, h_support=dz); 
}

if (test_show_artifact_tearaway) {
    test_artifact_tearaway();
}
////[0 : 4*w : artifact_radius - 1]
////w = 0.25;
////    thickness=w;
//    loops=6;

//circle(r = 0.25);

module test_article_bridging() {
}

module pin_for_angle(r, a, h, extend=false) {
    r_1 = r + h * tan(a) ;
    mirror([0,0,1]) translate([0,0, 0]) cylinder(r1=r_1, r2=r, h=h);
}

if (test_show_pin_angle) {
    pin_for_angle(r=pin_radius, a=test_pin_angle, h=test_thickness/2, extend=false);
}



    
