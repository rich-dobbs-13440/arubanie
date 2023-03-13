include <centerable.scad>
use <shapes.scad>
use <dupont_pin_fitting.scad>

/* [Logging] */
log_verbosity_choice = "INFO"; // ["WARN", "INFO", "DEBUG"]
verbosity = log_verbosity_choice(log_verbosity_choice); 

/* [Show] */

orient_for_build = false;

show_housing_ = true;
show_plug_ = true;
    show_mock_instrument = true;
/* [Replicate] */

    count_ = 1; // [1: 10]
    spacing_ = 2; // [-3 : 1 : 20]
    padding = [2, 2, 2];

/* [Customize] */

pin_length = 14; //[12:"12 mm - Short", 14:"14 mm - Standard", 14.7:"14.7 mm - Short + Header", 16.7:"Standard + Header"]

// Relative strength of latch - scaled height of catch
latch_strength_ = 0.2; // [-1: 0.01 : 1]
// Distance between latch parts in mm
latch_clearance_ = 0.2; // [0: 0.05 : 1]

module end_of_customization() {}

face_plate_thickness = 0.5; // Minimal printable amount to retain instrument

rotation = orient_for_build ? [180, 0, 0] : [0, 0, 0];



rotate(rotation) {
    x_replicate_facing_above(count_, spacing_, _bctp_face_plate(), padding) {

        if (show_mock_instrument && !orient_for_build ) { 
            breadboard_compatible_trim_potentiometer(show_mock_pins=true);
        }
        mounting_plug_and_socket(orient_for_build, show_plug_, show_housing_); 
    }
}

module x_replicate_facing_above(count, spacing, face, padding, show_padding = false) {
    x_offset = face.x/2; 
    dx = face.x + spacing;
    // Replicate the item
    for (i = [0 : count-1] ) {
        x = i * dx + x_offset;
        assert(is_num(x));
        translate([x, 0, 0]) {
            children();
        }
    }
    if (show_padding) {    
        face_spacer = [spacing, face.y, face.z];
        back_spacer = [spacing, face.y, padding.z];
        space_count = count - 1;
        x_offset_space = face.x;
        for (i = [0 : space_count-1] ) {
            x = i * dx + x_offset_space;
            translate([x, 0, 0]) {
                block(face_spacer, center=ABOVE+FRONT);
                block(back_spacer, center=BELOW+FRONT);
            }
        }

        x_total = count * face.x + space_count * spacing;
        x_padding_face = [x_total + 2 * padding.x, padding.y, face.z];
        x_padding_back = [x_total + 2 * padding.x, padding.y, padding.z];
        center_reflect([0, 1, 0]) {
            translate([-padding.x, face.y/2, 0]) {
                block(x_padding_face, center = ABOVE+FRONT+RIGHT);
                block(x_padding_back, center = BELOW+FRONT+RIGHT);
            }
        }
        y_padding_face = [padding.x, face.y, face.z];
        y_padding_back = [padding.x, face.y, padding.z];
        translate([x_total/2, 0, 0]) {
            center_reflect([1, 0, 0]) {
                translate([x_total/2, 0, 0]) {
                    block(y_padding_face, center = ABOVE+FRONT);
                    block(y_padding_back, center = BELOW+FRONT);
                }
            }
        }
    }
    
}

// Potentiometer Constants
PEDISTAL_IDX = 0;
KNOB_IDX = 1;
 
D_BASE = 0;
H_BASE = 1;
D_TAPER= 2;
D_INDICATER = 3;
H_INDICATER = 4;
 
 function breadboard_compatible_trim_potentiometer_dimensions() =
    let (
        pedistal = [9.6, 9.6, 5.0],
        knob = [7.89, 3.81, 7.48, 6.47, 1.39],
        last = undef
    )
    [ pedistal, knob ];



 
 module breadboard_compatible_trim_potentiometer(alpha=1, show_mock_pins=true) {
    // Center of origin at the centerline of the knob where the knob meets the base.  
    // The default orientation is for the knob to rotate along the z-axis.
    dims = breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = dims[PEDISTAL_IDX];
    color("SteelBlue", alpha=alpha) {
        pedistal();
        knob();
    }
    if (show_mock_pins) {
        mock_pin("yellow", alpha, 0, -1);
        mock_pin("red", alpha, 1, 0);
        mock_pin("black", alpha, -1, 0);
        
    } 
    module mock_pin(color_name, alpha, x_offset, y_offset) {
        pin_width = 2.54;
        pin_length = 14;
        wire_diameter = 1;
        translation = [
            x_offset*pin_width, 
            y_offset*pin_width,
            -pedistal.z
        ];
        color(color_name, alpha=alpha) {
            translate(translation) {
                block([pin_width, pin_width, pin_length], center=BELOW);
                can(d=wire_diameter, h=25, center=BELOW);
            }
        }
    }
    

    module pedistal() {
         block(pedistal, center=BELOW); 
    }
    
    module arrow() {
        linear_extrude(4) {    
            text("\u2191", font="DevaVu Sans Mono", halign="center", valign="center", size = 5);
        }
    }
    module knob() {
        dim = dims[KNOB_IDX];
        can(d=dim[D_BASE], h=dim[H_BASE], taper=dim[D_TAPER], center=ABOVE);
        translate([0, 0, dim[H_BASE]]) {
            render() difference() {
                can(d=dim[D_INDICATER], h=dim[H_INDICATER], center=ABOVE);
                arrow();
            }
        }
    }
}

function _bctp_face_plate() = 
    let(
        pin_width = 2.54,
        face_plate_thickness = 0.5, // As thin as can still be printed reliabily
        face_plate = 6 * [pin_width, pin_width, 0] + face_plate_thickness * [0, 0, 1],
        last = undef
    )
    face_plate;






module mounting_plug_and_socket(orient_for_build, show_plug, show_housing) {
    component_dims = breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = component_dims[PEDISTAL_IDX];
    knob = component_dims[KNOB_IDX];
    pin_width = 2.54;
    pin_length = 14;
    plug_base_thickness = 2;
    face_plate = _bctp_face_plate();
     
    
    color("orange") {
        if (show_plug) {
            if (orient_for_build) {
                    translate([0, 30, -plug_base_thickness + face_plate.z])
                        rotate([180, 0, 0]) 
                            plug();
            
            } else {
                translate([0, 0, -pedistal.z - pin_length]) 
                    rotate([0, 0, -90]) 
                        plug();
            }
        }
    }
    
    color("olive", alpha=1){
        if (show_housing) {
            housing(); 
        }
    }
    
    module housing() {
        knob_allowance = 0.50;
        d_knob_clearance = knob[D_BASE] + 2*knob_allowance; 
        difference() {
            block(face_plate, center=ABOVE);
            can(d=d_knob_clearance, h=20);
        }
        difference() {
            translate([0, 0, -pedistal.z]) { 
               rotate([180, 0, ]) 
                   socket();
            }
            pedistal_clearance = [0.2, 0.2, 4];
            block(pedistal + pedistal_clearance, center=BELOW);
        }
    }

    
    module plug() {
    
        
        pin_holder = "
          ▂╳▂  ;
          ╶┼╴  ;
          ▂╵▂  
        ";

        
        bare_plug = "
           ▒◒▂◒▒  ;
           ◑▂╳▂◐  ;
           ▂╶┼╴▂  ;     
           ◑▂╵▂◐  ;
           ▒◓▂◓▒   ";
       
        dupont_pin_fitting(
            pattern = bare_plug, 
            latch_strength = latch_strength_,
            latch_clearance = latch_clearance_,
            base_thickness = plug_base_thickness, 
            center = ABOVE,
            log_verbosity = verbosity);
//        dupont_pin_fitting(
//            pattern = pin_holder,
//            latch_strength = latch_strength_,
//            latch_clearance =latch_clearance_,
//            base_thickness = plug_base_thickness,
//            center = ABOVE,
//            log_verbosity = verbosity); 
           
    } 
    module socket() {
        socket = "
           ▒◓◓◓▒  ;
           ◐░░░◑  ;
           ◐░░░◑  ;
           ◐░░░◑  ;           
           ▒◒◒◒▒   "; 
        
        dupont_pin_fitting(
            pattern = socket, 
            latch_strength = latch_strength_,
            latch_clearance =latch_clearance_,        
            base_thickness = pedistal.z,
            center=ABOVE,
            log_verbosity = verbosity);
    }
}
