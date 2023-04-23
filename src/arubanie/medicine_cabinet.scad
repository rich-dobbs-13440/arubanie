include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
use <MCAD/boxes.scad>

build_rail = false;
build_clip = true;
show_mocks = true;
test_fit = false;

clip_z = 12;
clip_x = 3.5;
clearance_ = 0.2;

module end_of_customization() {}



tooth_brush_holder = [20.6, 31.7, 108.6];
tooth_brush_holder_lid = [19.5, 30.4, 95.8];

module tooth_brush_holder(clearance=0) {
    translate([tooth_brush_holder.x/2 + 5, 0, 0]) {
        intersection() {
            roundedCube(
                tooth_brush_holder + 2*[clearance, clearance, clearance], 
                r=tooth_brush_holder.x/2, 
                sidesonly=true, 
                center=true, 
                $fn=30);
            translate([0, 0, 5]) 
                roundedCube(
                    tooth_brush_holder + 2*[clearance, clearance, clearance] + [0, 0, 10], 
                    r=tooth_brush_holder.y/2, 
                    sidesonly=false, 
                    center=true, 
                    $fn=30);
        }
    }
}

module rail(length, clearance=0) {
    color("red") {
        difference() {
            union() {
                block([1, length, 8], center=FRONT);
                hull() {
                    translate([1, 0, 0]) block([0.01, length, 8], center=FRONT);
                    translate([2, 0, 0]) block([0.5 + clearance, length, 10 + 2* clearance], center=FRONT);
                }
            }
            rod(d=3, l=length, center=SIDEWISE, rank=4);
        }
    }
    
}

module clip(length) {
    color("blue") {
        render(convexity=10) difference() {
            block([clip_x, length, clip_z], center=FRONT);
            hull() rail(length+5., clearance=0.2);
            hull() {
                block([0.01, length, 10.5], center=FRONT);
                translate([1, 0, 0]) block([0.01, length, 9], center=FRONT);
            }
        }
    }
}

if (show_mocks) {
    translate([2, 0, 0]) tooth_brush_holder();
}

if (build_rail) {
    rail(40);  
}

module tooth_brush_holder_clip() {
    holder_holder = [tooth_brush_holder.x + 7, tooth_brush_holder.y+7, clip_z+5];
    clip(tooth_brush_holder.y);
    color("green") {
        difference() {
            translate([clip_x + holder_holder.x/2, 0, 0]) 
                roundedCube(holder_holder, r=3, sidesonly=false, center=true, $fn=30);
            translate([2, 0, 0]) tooth_brush_holder(clearance=clearance_);
        }
    }    
}

if (build_clip) {
    if (test_fit) {
        difference() {
            tooth_brush_holder_clip();
            plane_clearance(BELOW);
            translate([0, 0, 2]) plane_clearance(ABOVE);
        }
    } else {
        tooth_brush_holder_clip();
    }

}