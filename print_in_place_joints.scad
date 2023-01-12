$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

pin_radius = 5;

lap_radius_clearance = 1;
pin_tolerance = 1;


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

test_overlap = 2 * pin_radius;

lap_radius = 2 * pin_radius;




module part_1() {
    x = test_length + test_overlap;
    y = test_length;
    z = test_thickness;
    dx = -x/2 + test_overlap; 
    translate([dx, 0, 0]) cube([x, y, z], center=true);
}

*part_1();

module part_2() {
    x = test_length   +  test_overlap;
    y = test_part_2_width;
    z = test_thickness;
    dx = x/2 - test_overlap ; 
    translate([dx, 0, 0]) cube([x, y, z], center=true);
}

* part_2();

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

* lap_end_to_radius(r=2*pin_radius) part_2();    

module lap() {
    scale([1.0 + eps,1.00 + eps, 1.0+eps]) difference() {
        intersection() {
            part_1();
            part_2();
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
* part_2();

module lap_removed() {
    difference() {
        part_2();
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
        part_1();
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