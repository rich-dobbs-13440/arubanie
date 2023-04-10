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

y_face_plate = 36;
x_face_plate = 3.25;
z_3_prong_= 


z_3_prong_offset = -40;
z_web_cam_usb_offset = +20;
z_printer_usb_offset = +40;
z_barell_pigtail_plug_offset = 5;



module end_of_customization() {}

module powerswitch_tail_II_socket () {
    color("gray") {
        translate([1, 0, 1]) {
            hull() {
                translate([-23.49/2, 0, 0]) roundedBox([23.49, 26.67, 17.24], radius=1, sidesonly=false, $fn=12);
                translate([0, 0, -6.5]) rod(d=2*11.60, l=23.49, center=BEHIND);
            }
            hull() {
                rod(d=9.46, l=4.87, center=BEHIND);
                translate([0, 0, 11.5]) rod(d=9.46, l=4.87, center=BEHIND);
            }
        }
    }
}

module C2G_USB_a_extension_socket() {
    color("SlateGray") roundedBox([21.40, 17.82, 10.42], radius=1, sidesonly=false, $fn=12);
}

module MILAPEAK_DC_power_pigtail_cable_plug() {
    // MILAPEAK (Real 18AWG 43x2pcs Strands) 10 Pairs DC Power Pigtail Cable 12V 5A Male & Female
    translate([1, 0, 0]) {
        color("silver") rod(d=5.44, l=9.35, center=FRONT);
        color("DarkSlateGray") {
            rod(d=8.46, l=2.30, center=BEHIND);
            translate([-2.30, 0, 0]) rod(d=10.10, l=5.84, center=BEHIND);
        }
    }
}

if (show_mocks) {
    translate([0, 0, z_3_prong_offset]) powerswitch_tail_II_socket();
    translate([0, 0, z_web_cam_usb_offset]) C2G_USB_a_extension_socket();
    translate([0, 0, z_printer_usb_offset]) C2G_USB_a_extension_socket();
    translate([0, 0, z_barell_pigtail_plug_offset]) MILAPEAK_DC_power_pigtail_cable_plug();
    
}

module barell_pigtail_plug_holder_face() {
    difference() {
        block([x_face_plate, y_face_plate, 15], center=BEHIND);
        scale([1.05, 1.05, 1]) MILAPEAK_DC_power_pigtail_cable_plug();
    }
}


module three_prong_socket_holder_face() {
    difference() {
        block([x_face_plate, y_face_plate, 40], center=BEHIND);
        scale([1.05, 1.05, 1]) powerswitch_tail_II_socket();
    }
}




module usb_extender_face() {
    difference() {
        block([x_face_plate, y_face_plate, 14], center=BEHIND);
        scale([1.05, 1.05, 1]) C2G_USB_a_extension_socket();
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

//         translate([target.z/2, target.y/2, 0]) 
//                rotate([0, 90, 0]) 
//                   roundedBox(target,  radius=target.y/2, sidesonly=sidesOnly, $fn=12);  