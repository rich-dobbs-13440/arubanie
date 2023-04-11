include <lib/logging.scad>
include <lib/centerable.scad>
use <lib/shapes.scad>
use <lib/not_included_batteries.scad>
include <nutsnbolts-master/cyl_head_bolt.scad>
use <MCAD/boxes.scad>

show_mocks = true;
build_three_prong_socket_holder_face = true;
build_web_cam_usb_extender_face = true;
build_printer_usb_extender_face = true;
build_barell_pigtail_plug_holder_face = true;

allowance = 0.4;   // Combination of inaccuracy in printing and clearance to slide things together
radius = 2;
y_face_plate = 38;
x_face_plate = 3.25;
z_3_prong_face_plate = 40;
z_pigtail_face_plate = 16;
z_extender_face_plate = 14;

z_3_prong_offset = -z_3_prong_face_plate/2;
z_barell_pigtail_plug_offset = z_pigtail_face_plate/2;
z_web_cam_usb_offset = z_barell_pigtail_plug_offset + z_pigtail_face_plate/2 + z_extender_face_plate/2;
z_printer_usb_offset = z_web_cam_usb_offset + z_extender_face_plate;




module end_of_customization() {}

module faceplate(size) {
    padding = [0, 4, 4];
    side_wall = [6, 4, size.z];
    difference() {
        union() {
            block(size + padding, center=BEHIND);
            center_reflect([0, 1, 0]) translate([0, y_face_plate/2, 0]) block(side_wall, center=BEHIND+LEFT);
        }
        center_reflect([0, 1, 0])
            center_reflect([0, 0, 1])
            translate([1, y_face_plate/2-side_wall.y/2, size.z/2-3]) 
                rotate([0, 90, 0]) hole_through("M2", $fn=12);
    }
    
//    difference() {
//        
//        translate([-(x_face_plate + side_wall.x/2), 0, 0]) center_reflect([0, 1, 0]) rotate([90, 0, 0]) hole_through("M2.5");
//    }
}

module powerswitch_tail_II_socket (as_clearance=false) {
    al = as_clearance ? allowance : 0;
    color("gray") {
        translate([radius, 0, 1]) {
            hull() {
                translate([-23.49/2, 0, 0]) 
                    roundedCube([23.49, 26.67, 18.78] + [0, 2*al, 2*al], r=radius, sidesonly=false, center=true, $fn=12);
                translate([0, 0, -11.9]) rod(d=13.0 + 2*al, l=23.49+al, center=BEHIND);
            }
            upper_tab();
        }
    }
    module upper_tab() {
        hull() {
            rod(d=9.46 + 2*al, l=4.87 + al, center=BEHIND);
            translate([0, 0, 11.5]) rod(d=9.46 + 2*al, l=4.87 + al, center=BEHIND);
        }
    }
}

module C2G_USB_a_extension_socket(as_clearance=false) {
    al = as_clearance ? allowance : 0;
    allowances = 2 * [al, al, 0];
    translate([1, 0, 0]) {
        color("SlateGray") translate([-21.40/2, 0, 0]) roundedCube([21.40 , 17.82, 10.42] + allowances, r=1, sidesonly=false, center=true, $fn=12);
    }
}

module MILAPEAK_DC_power_pigtail_cable_plug(as_clearance=false) {
    // MILAPEAK (Real 18AWG 43x2pcs Strands) 10 Pairs DC Power Pigtail Cable 12V 5A Male & Female
    al = as_clearance ? allowance : 0;
    translate([1, 0, 0]) {
        color("silver") rod(d=5.44, l=9.35, center=FRONT);
        color("DarkSlateGray") {
            rod(d=8.46 + 2*al, l=2.30+al, center=BEHIND);
            translate([-2.30, 0, 0]) rod(d=10.10 + 2*al, l=5.84+al, center=BEHIND);
            translate([-2.30-5.84, 0, 0]) rod(d=11.08+2*al, l=12.65, center=BEHIND, $fn=6);
        }
    }
}

if (show_mocks) {
    translate([0, 0, z_3_prong_offset]) powerswitch_tail_II_socket();
    translate([0, 0, z_web_cam_usb_offset]) C2G_USB_a_extension_socket();
    translate([0, 0, z_printer_usb_offset]) C2G_USB_a_extension_socket();
    translate([0, 0, z_barell_pigtail_plug_offset]) MILAPEAK_DC_power_pigtail_cable_plug();
    
}




module three_prong_socket_holder_face() {
    difference() {
        faceplate([x_face_plate, y_face_plate, z_3_prong_face_plate]);
        powerswitch_tail_II_socket(as_clearance=true);
    }
}

module barell_pigtail_plug_holder_face() {
    difference() {
        union() {
            faceplate([x_face_plate, y_face_plate, z_pigtail_face_plate]);
            rod(d=16, l=6, center=BEHIND);
        }
        MILAPEAK_DC_power_pigtail_cable_plug(as_clearance=true);
    }
}


module usb_extender_face() {
    difference() {
        union() {
            faceplate([x_face_plate, y_face_plate, z_extender_face_plate]);
            block([6, 25, z_extender_face_plate], center=BEHIND); 
        }
        C2G_USB_a_extension_socket(as_clearance=true);
    }      
}

if (build_barell_pigtail_plug_holder_face) {
    translate([0, 0, z_barell_pigtail_plug_offset]) barell_pigtail_plug_holder_face();
}



if (build_web_cam_usb_extender_face) {
    translate([0, 0, z_web_cam_usb_offset]) usb_extender_face();
}

if (build_printer_usb_extender_face) {
    translate([0, 0, z_printer_usb_offset]) usb_extender_face();
}

if (build_three_prong_socket_holder_face) {
    translate([0, 0, z_3_prong_offset]) three_prong_socket_holder_face();
}

