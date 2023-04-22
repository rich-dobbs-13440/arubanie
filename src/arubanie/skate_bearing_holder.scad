include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>

/* [Build] */

build_skate_bearing_holder = true;
build_non_ice_filament_spool_holder_drilling_guide = true;


/* [Customize skate bearing holder] */ 

clamp_mm_sbh = 2;
clearance_sbh = 0.1;

/* [Customize drilling guide] */ 

spool = 3; //[0:"Custom", 1:"ASA", 2:"Mix", 3:"Sunlu 250g", 4:"Polyfaire PLA Red, 1 kg"]

custom_inside_depth_dg_ = 52.3; //71.1; 
custom_outside_depth_dg = 60.3;//71.1;

spools = [
    ["Custom", custom_inside_depth_dg_, custom_outside_depth_dg],
    ["ASA", 71.1, 71.1],
    ["Mixed 1kg", 52.3, 71.1],
    ["Sunlu 250g", 37.3, 41.5],
    ["Polyfaire PLA Red", 64, 65.25],
];

inside_depth_dg = spools[spool][1];
outside_depth_dg = spools[spool][2];

echo("inside_depth_dg", inside_depth_dg);
echo("outside_depth_dg", outside_depth_dg);

thickness_dg = 2;
padding_dg = 5;
clearance_dg = 0.4;



module end_of_customization() {}

bearing_od = 22;
bearing_id = 8;
bearing_width = 7;
insert_od = 12.1;
insert_id = 5.8;
insert_width = 11.2;
a_lot = 100;


module skate_bearing(as_clearance = false, include_insert = true, clearance = 0) { 
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

module skate_bearing_holder(clamp_mm, as_clearance = false, clearance = 0.2) {

    bearing_block = [bearing_width, bearing_od, bearing_od];
    walls = 2*[2, 2, 8];
    render(convexity=10) difference() {
        block(bearing_block + walls);
        skate_bearing(as_clearance = true, include_insert=true, clearance=clearance);
        translate([0, 0, clamp_mm]) plane_clearance(ABOVE);
        center_reflect([0, 1, 0]) translate([0, 8, 0]) hole_through("M3", h=bearing_od/2 + 3, cld=0.4, $fn=12);
    }
    
   
}

if (build_skate_bearing_holder) {
    skate_bearing_holder(clamp_mm = clamp_mm_sbh, clearance = clearance_sbh);
}

if (build_non_ice_filament_spool_holder_drilling_guide) {
    non_ice_filament_spool_holder_drilling_guide(
        inside_depth_dg, outside_depth_dg, thickness_dg, padding_dg, clearance_dg);
}

module non_ice_filament_spool_holder_drilling_guide(inside_depth, outside_depth, thickness, padding, clearance) {
    screw_mount_body = [37, 6.9, 7.6];
    centerline_y = (inside_depth + outside_depth) / 2;
    base = [screw_mount_body.x, screw_mount_body.y, thickness] + 2*[padding, padding, 0] + [0, centerline_y, 0];
    clearances = 2 * [clearance, clearance, clearance];
    difference() {
        block(base, center=ABOVE);
        center_reflect([0, 1, 0]) translate([0, centerline_y/2, 0]) block(screw_mount_body + clearances);
        hull() center_reflect([0, 1, 0]) translate([0, centerline_y/2-screw_mount_body.y-padding, 0]) block(screw_mount_body);
    }
    
    
    
    

}