include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>


clamp_mm = 2;
clearance = 0.1;

module end_of_customization() {}

bearing_od = 22;
bearing_id = 8;
bearing_width = 7;
insert_od = 12.1;
insert_id = 5.8;
insert_width = 11.2;
a_lot = 100;


module skate_bearing(as_clearance=false, include_insert=true) { 
    module insert() {
        if (as_clearance) {
            rod(d=insert_od + 2, l=insert_width);
        }
    }
    if (as_clearance) {
        rod(d=bearing_od + 2*clearance, l=bearing_width + 2*clearance);
        rod(d=bearing_id, l=a_lot);
        if (include_insert) {
            insert();
        }
    } else {
        rod(d=bearing_od, l=bearing_width, hollow=bearing_id);       
    }
}

module skate_bearing_holder(as_clearance=false) {

    bearing_block = [bearing_width, bearing_od, bearing_od];
    walls = 2*[2, 2, 8];
    render(convexity=10) difference() {
        block(bearing_block + walls);
        skate_bearing(as_clearance = true);
        translate([0, 0, clamp_mm]) plane_clearance(ABOVE);
        center_reflect([0, 1, 0]) translate([0, 8, 0]) hole_through("M3", h=bearing_od/2 + 3, cld=0.4, $fn=12);
    }
    
   
}

skate_bearing_holder();