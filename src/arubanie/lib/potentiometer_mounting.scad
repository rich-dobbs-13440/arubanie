/*

use <potentiometer_mounting.scad>

*/

include <logging.scad>
include <centerable.scad>
use <shapes.scad>

/* [Customization] */

allowance_ = 0.3; // [0:0.05:2]
clip_overlap_ = 0.5; // [0:0.05:1]
count_ = 1; // [1: 10]
spacing_ = 2; // [0 : 1 : 20]
show_mocks_= false;

AS_DESIGNED = 0 + 0;
ON_FACE = 1 + 0;
ON_SIDE = 2 + 0;
orientation_ = 0; //[0:As designed, 1:On face, 2: On side]


*breadboard_compatible_trim_potentiometer();


 
orient() { 
     breadboard_compatible_trim_potentiometer_housing(
        count = count_, 
        spacing = spacing_, 
        allowance = allowance_,
        show_mocks = show_mocks_);
}

module orient() {
    rotation = [[0, 0, 0], [180, 0, 0], [90, 0, 0]][orientation_];
    rotate(rotation) { 
        children();
    }
}
 
 end_of_customization() {}
 
PEDISTAL_IDX = 0;
KNOB_IDX = 1;
 
D_BASE = 0;
H_BASE = 1;
D_TAPER= 2;
D_INDICATER = 3;
H_INDICATER = 4;
 
 function breadboard_compatible_trim_potentiometer_dimensions() =
    let (
        pedistal = [9.4, 9.4, 4.5],
        knob = [7.89, 3.81, 7.48, 6.47, 1.39],
        last = undef
    )
    [ pedistal, knob ];
 
 module breadboard_compatible_trim_potentiometer(alpha=1) {
    // Center of origin at the centerline of the knob where the knob meets the base.  
    // The default orientation is for the knob to rotate along the z-axis.
    dims = breadboard_compatible_trim_potentiometer_dimensions();
    color("SteelBlue", alpha=alpha) {
        pedistal();
        knob();
    }
     
    module pedistal() {
         block(dims[PEDISTAL_IDX], center=BELOW); 
    }
    module knob() {
        dim = dims[KNOB_IDX];
        can(d=dim[D_BASE], h=dim[H_BASE], taper=dim[D_TAPER], center=ABOVE);
        translate([0, 0, dim[H_BASE]]) 
            can(d=dim[D_INDICATER], h=dim[H_INDICATER], center=ABOVE);
    }
}
 
BODY_IDX = 0;
X_OFFSET_IDX = 1;
DX_IDX = 2;
FACE_PLATE_IDX = 3;
PIN_RETENTION_BASE_IDX = 4;
PIN_RETENTION_LOWER_WALL_IDX = 5;
PIN_WIDTH = 6;
PIN_LENGTH = 7;
PIN_WIRE_FIN = 8;
 
function  breadboard_compatible_trim_potentiometer_housing_dimensions(
        wall=2, face=0.5, count=1, spacing=2, allowance=0.3) =
    let(
        knob_dims = breadboard_compatible_trim_potentiometer_dimensions(),
        pedistal = knob_dims[PEDISTAL_IDX],
        x = pedistal.x * count + spacing * (count-1) + 2 * wall + 2 * allowance,
        y = pedistal.y + 2 * allowance + 2 * wall,
        z = pedistal.z + allowance,
        body = [x, y, z],
        x_offset = -body.x/2 + wall + allowance + pedistal.x/2,
        dx = pedistal.x + spacing,
        face_plate = [body.x, body.y, face],
        pin_length = 14,
        pin_width = 2.54,
        pin_retention_base = [2*pin_width, wall, pin_length + wall],
        pin_retention_lower_wall = [4*pin_width, body.y/2, wall],
        wire_gap = 1.24,
        wire_fin = [pin_width - wire_gap, pin_width, wall],
        
        last = undef
    ) 
    [
        body, 
        x_offset, 
        dx, 
        face_plate, 
        pin_retention_base, 
        pin_retention_lower_wall,
        pin_width, 
        pin_length, 
        wire_fin, 
        
    ];
    
 
 module breadboard_compatible_trim_potentiometer_housing(
        wall=2, 
        face=0.5, 
        count=1, 
        spacing=2, 
        allowance=0.3, 
        clip_overlap=0.5, 
        center=0, 
        show_mocks=false) {
            
    if (show_mocks) {
        replicate() breadboard_compatible_trim_potentiometer();
    }            
            
    dims = breadboard_compatible_trim_potentiometer_housing_dimensions(wall, face, count, spacing, allowance);
    knob_dims =  breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = knob_dims[PEDISTAL_IDX];
    body = dims[BODY_IDX];
    face_plate = dims[FACE_PLATE_IDX];
    pin_retention_base = dims[PIN_RETENTION_BASE_IDX];
    pin_retention_lower_wall = dims[PIN_RETENTION_LOWER_WALL_IDX];
    wire_fin = dims[PIN_WIRE_FIN]; 
    pin_width = dims[PIN_WIDTH];
            
    render() difference() {
        block(body, center=BELOW);
        replicate() pedistal_clearance();
    }
    render() difference() {
        block(face_plate, center=ABOVE);
        replicate() knob_clearance();
    }

    replicate() instrument_retention_clip();
    replicate()  pin_retention_clip();
    
    module pin_retention_clip() {
        
        translate([0, -body.y/2, -body.z]) block(pin_retention_base, center=BELOW+RIGHT);
        translate([0, -body.y/2, -body.z-pin_retention_base.z]) block(pin_retention_lower_wall, center=BELOW+RIGHT);
        translate([pin_width/2, 0, -body.z-pin_retention_base.z]) block(wire_fin, center=BELOW+RIGHT+BEHIND);
        translate([-pin_width/2, 0, -body.z-pin_retention_base.z]) block(wire_fin, center=BELOW+RIGHT+FRONT);
        translate([3*pin_width/2, 0, -body.z-pin_retention_base.z]) block(wire_fin, center=BELOW+RIGHT+BEHIND);
        translate([-3*pin_width/2, 0, -body.z-pin_retention_base.z]) block(wire_fin, center=BELOW+RIGHT+FRONT);        
    }
     
    module instrument_retention_clip() {
        // truncated cones at the corners
        d_outer = 1;
        d_inner = d_outer + clip_overlap; // Inner with respect z axis!
        h_clip = 1;
        t_clip = [
            pedistal.x/2 + d_outer/2, 
            pedistal.y/2 + d_outer/2, 
            -body.z
        ];
        dt_bound = -d_outer/2 + wall + allowance;
         
        center_reflect([1, 0, 0]) {
            center_reflect([0, 1, 0]) {
                translate(t_clip) {
                    render() difference() {
                        can(d=d_outer, taper=d_inner, h=h_clip, center=BELOW);
                        translate([dt_bound, 0, 0]) block([d_inner, d_inner, 4*h_clip], center=BELOW+FRONT);
                        translate([0, dt_bound, 0]) block([d_inner, d_inner, 4*h_clip], center=BELOW+RIGHT);
                    }
                }
            }
        }
    }
     
    module replicate() {
        dx = dims[DX_IDX];
        x_offset = dims[X_OFFSET_IDX];
        for (i = [0 : count-1] ) {
            translate([i * dx + x_offset, 0, 0]) {
                children();
            }
        }           
    }
     
    module knob_clearance() {
        can(d=pedistal.x, h=20);
    }
     
    module pedistal_clearance() {
        allowances = [2*allowance, 2*allowance, 20];
        translate([0, 0, -pedistal.z/2]) block(pedistal + allowances);
    }
 }