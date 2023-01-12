$fa = 1;
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
/* [Test] */
test_length = 30;
test_part_2_width = 10;
test_thickness = 4;
test_breakable_gap = 0.28;
test_breakable_gap_spacing = 1.5;

test_overlap = 10;

lap_radius = 2 * pin_radius;

height=0.25;
r=1;
thickness=0.25;
loops=6;


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
            part_1(test_overlap);
            part_2(test_overlap);
        }
        octants([0,0,1]);
    }
}

if (test_show_lap) {
    color("red") lap();
}

* lap_end_to_radius(r=2*pin_radius, excise_t=[-1, 0, 0]) lap();

module lap_2() {
    r_lap = 2*pin_radius;
    lap_end_to_radius(r=r_lap, excise_t=[-1, 0, 0]) lap();
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

// for (a =[-20:4:20])echo(a);
//b = [-20:4:20];
//for (a = b) echo(a);

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

    linear_extrude(height=height) {
        polygon(
            points=concat( [for(t = [90:360*loops]) [(r-thickness+t/90)*sin(t),(r-thickness+t/90)*cos(t)]], [for(t = [360*loops:-1:90]) [(r+t/90)*sin(t),(r+t/90)*cos(t)]] ));
    }  
}



module test_artifact_2() {
    w=0.25;
    
    cylinder(d=20, h=1, center=true);
    cube([30, 8, 1], center=true);
    translate([0,0,0.5]) union() {
        for (az = [0 : 15 : 360]) {
            rotate([90,0,az]) cylinder(d=w, h=20, center=true);
        }
    }
    translate([0,0,2.5]) spiral(r=r, thickness=thickness, loops=loops, height=height);

}
test_artifact_2();
//w = 0.25;
//    thickness=w;
//    loops=6;

    
