$fa = 1;
$fs = 0.4;

eps = 0.01;
linkage_height = 2;

pin_size = 5;
hole_size_by_pin_size = 1.15;
linkage_width_to_hole_size = 1.3; 
/* [snap_together_pin] */
cap_overhang_by_pin_size = 0.25;
gap_width_by_pin_size = 0.15;
gap_depth_by_linkage_height = 1.7; // [0:0.01:2]
pin_height_by_linkage_height = 3;

linkage_width = pin_size * hole_size_by_pin_size * linkage_width_to_hole_size;
test_link_length = 20;

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

module snap_retainer() {
    h_bearing = 1;
    d_bearing = pin_size * 1.2;
    dz_bearing = 0.5 * linkage_height;
    h = pin_height_by_linkage_height * linkage_height;
    split_ring_gap = 0.5;
    difference() {
        union() {
            cylinder(h=linkage_height, d=linkage_width, center=true);
            // bearing
            translate([0,0,dz_bearing]) cylinder(h = h_bearing, d=d_bearing, center=true);
        }
        union() {
            translate([0, 0, -eps]) cylinder(h=h, d=pin_size, center=true);
            translate([0, d_bearing/2, 0]) cube([split_ring_gap, d_bearing, h], center=true);     
        } 
    }
}

* snap_retainer();


* snap_cap(10, 0.2);

module snap_gap(post_height) {
    // Gap
    x_g = 2 * pin_size;
    y_g = gap_width_by_pin_size * pin_size;
    z_g = 10 * linkage_height  ;

    dz_g = z_g/2 + post_height - gap_depth_by_linkage_height * linkage_height; // h - z_g + eps;
    translate([0, 0, dz_g]) 
        cube([x_g, y_g, z_g], center=true);
}

//color("pink") snap_gap(1);



module snap_gap_angled(post_height, angle=7) {
    // Gap
    x_g = 2 * pin_size;
    y_g = gap_width_by_pin_size * pin_size;
    z_g = 10 * linkage_height  ;

    dz_g = z_g/2 + post_height - gap_depth_by_linkage_height * linkage_height; // h - z_g + eps;
    hull() {
        rotate([angle, 0, 0]) translate([0, 0, dz_g]) cube([x_g, y_g, z_g], center=true);
        rotate([-angle, 0, 0]) translate([0, 0, dz_g]) cube([x_g, y_g, z_g], center=true);
    }

}

*color("orchid") snap_gap_angled(1);


module rounded_wedge() {
    x_g = 5;
    y_g = 20;
    z_g = 40; 
    translate([x_g/2, 0, 0]) hull() {
        for (angle = [-5, 5]) {
            rotate([0, angle, 0]) minkowski() {
              cube([0.01, y_g, z_g]);
              // cylinder(r=2,h=1);
              sphere(d=x_g);
            } 
        } 
    }
}
 
*rounded_wedge();

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
        snap_gap_angled(h);
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

module linkage_bracket(length) {
    sx_slot = 1.05;
    sy_slot = 1.05;
    clip_over_fraction = 0.25;
    translate([0, 0, linkage_height/2]) difference() {
        union() {
            // Base
            g = 1.5 * linkage_width;
            h = 2 * linkage_height - eps;
            hull() {
                cylinder(h=h, d=g, center=true);
                translate([length,0,0]) cylinder(h=h, d=g, center=true);
            }
            // clips
            x_c = length;
            y_c = 2;
            z_c = 1;
            dx_c = x_c/2;
            dy_c = linkage_width/2 + y_c/2 - clip_over_fraction*y_c;
            dz_c = 1.5 * linkage_height - z_c/2;
            translate([dx_c, dy_c, dz_c]) cube([x_c, y_c, z_c], center=true);
            translate([dx_c, -dy_c, dz_c]) cube([x_c, y_c, z_c], center=true);
        }
        translate([0, 0, linkage_height/2]) scale([sx_slot, sy_slot, 1]) linkage(2*length);
    }
    
}

* linkage_bracket(10);

module test_assembly_linkage() {
    for(i = [0 : 1]) {
        dy = i * 1.2 * linkage_width;
        translate([0, dy, 0]) 
        linkage(test_link_length, pins=[test_link_length], holes=[0]) {
            round_hole();
            snap_together_pin();  
        }
    }
    for(i = [0 : 2]) {
        dx = i * 1.5 * linkage_width;
        translate([dx, -10, 0]) snap_retainer();
    }
    for(i = [0 : 1]) {
        dy = -20 -i * 2 * linkage_width;
        translate([0, dy, 0]) linkage_bracket(test_link_length/2);
    } 
    
    
}
test_assembly_linkage();


