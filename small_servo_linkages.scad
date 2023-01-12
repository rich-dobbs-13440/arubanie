$fa = 1;
$fs = 0.4;

eps = 0.01;
linkage_height = 2;
linkage_width = 7;
pin_size = 4;
hole_size_by_pin_size = 1.1;
/* [snap_together_pin] */
cap_overhang_by_pin_size = 0.2;
gap_width_by_pin_size = 0.4;
gap_depth_by_linkage_height = 1.; // [0:0.01:2]
pin_height_by_linkage_height = 2.;


test_link_length = 10;

module square_pin() {
    x = pin_size / sqrt(2);
    y = pin_size / sqrt(2);
    z = 2*linkage_height;
    dz = z/2;
    translate([0,0,dz]) cube([x,y,z], center=true);
}

module round_hole() {
    d = hole_size_by_pin_size * pin_size;
    cylinder(h = 5, d=d, center=true);
}

module default_pin() {
    x = pin_size;
    y = pin_size;
    z = 2*linkage_height;
    dz = z/2;
    translate([0,0,dz]) cylinder(h = 5, d=pin_size, center=true);   
}

module copy_and_mirror(v) {
    children(0);
    mirror(v) children(0);
    
}

module snap_cap(d, overhang_ratio) {
    copy_and_mirror([0,1,0]) {
        dy = d * overhang_ratio / 2;
        translate([0,dy,0]) {
            difference () {
                sphere(d=d);
                translate([0,0,-d]) cube([2*d,2*d,2*d], center=true);
                translate([0,-d,0]) cube([2*d,2*d,2*d], center=true);
            }
        }
    } 
}


* snap_cap(1, 0.1);

module snap_gap(post_height) {
    // Gap
    x_g = 2 * pin_size;
    y_g = gap_width_by_pin_size * pin_size;
    z_g = 10 * linkage_height  ;

    dz_g = z_g/2 + post_height - gap_depth_by_linkage_height * linkage_height; // h - z_g + eps;
    translate([0, 0, dz_g]) 
        cube([x_g, y_g, z_g], center=true);
}

* color("pink") snap_gap(1);

module snap_together_pin() {
    h = (0.5 + pin_height_by_linkage_height) * linkage_height; // 0.5 is to reach middle of linkage for overlap  
    h_bearing = 1;
    d_bearing = pin_size * 1.5;
    dz_bearing = 0.5 * linkage_height;
    
    difference() {
        union() {
            dz = h/2;
            translate([0,0,dz]) cylinder(h = h, d=pin_size, center=true);  // Post
            translate([0,0,dz_bearing]) cylinder(h = h_bearing, d=d_bearing, center=true);  // Post
            translate([0,0,h]) snap_cap(d=pin_size, overhang_ratio=cap_overhang_by_pin_size); // Cap
            
        };
        snap_gap(h);
    }
}

* snap_together_pin();

module default_hole() {
    round_hole();
}

module hole(location, rotation) {
    object_idx = 0;
    pin_idx = 1;
    difference() {
        children(object_idx);
        translate(location) rotate(rotation) children(pin_idx);
    } 
}

module linkage(length, pins=[], holes=[]) {
    use_default_hole = $children < 1;
    use_default_pin = $children < 2;
    difference() {
        union() {
            hull() {
                cylinder(h=linkage_height, d=linkage_width, center=true);
                translate([length,0,0]) cylinder(h=linkage_height, d=linkage_width, center=true);
            }
            for (x=pins) {
                translate([x,0,0])
                if (use_default_pin) {
                     default_pin();
                } else {
                    children(1);
                }
            }
        }
        union() {
            for (x=holes) {
                translate([x,0,0]) 
                    if (use_default_hole) {
                        default_hole();
                    } else {
                        children(0);
                    }
            }
        }
    }
    //}
}



* linkage(test_link_length, holes=[5, 12],  pins=[1,20]);

module test_assembly() {
    for(i = [0 : 1]) {
        dy = i * 1.2 * linkage_width;
        translate([0, dy, 0]) 
        linkage(test_link_length, pins=[test_link_length], holes=[0]) {
            round_hole();
            snap_together_pin();  
        }
    }
}

test_assembly();