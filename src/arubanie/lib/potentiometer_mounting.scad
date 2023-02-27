/*

use <potentiometer_mounting.scad>

*/

include <logging.scad>
include <centerable.scad>
use <shapes.scad>


count_ = 1; // [1: 10]
spacing_ = 0; // [0 : 1 : 20]
show_mocks_= false;

AS_DESIGNED = 0 + 0;
ON_FACE = 1 + 0;
ON_SIDE = 2 + 0;
orientation_ = 0; //[0:As designed, 1:On face, 2: On side]


*breadboard_compatible_trim_potentiometer();


 
orient() { 
     breadboard_compatible_trim_potentiometer_housing(
        count = count_, spacing = spacing_, show_mocks = show_mocks_);
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
 
function  breadboard_compatible_trim_potentiometer_housing_dimensions(
        wall=2, face=2, count=1, spacing=0, allowance=0.2) =
    let(
        knob_dims = breadboard_compatible_trim_potentiometer_dimensions(),
        pedistal = knob_dims[PEDISTAL_IDX],
        x = pedistal.x * count + spacing * (count-1) + 2 * wall,
        y = pedistal.y + 2 * wall,
        z = pedistal.z,
        body = [x, y, z],
        x_offset = -body.x/2 + wall + allowance + pedistal.x/2,
        dx = pedistal.x + spacing,
        face_plate = [body.x, body.y, face],
        last = undef
    ) 
    [
        body, x_offset, dx, face_plate,
    ];
    
 
 module breadboard_compatible_trim_potentiometer_housing(
        wall=2, face=0.75, count=1, spacing=0, allowance=0.2, center=0, show_mocks=false) {
            
     dims = breadboard_compatible_trim_potentiometer_housing_dimensions(wall, face, count, spacing, allowance);
     knob_dims =  breadboard_compatible_trim_potentiometer_dimensions();
     pedistal = knob_dims[PEDISTAL_IDX];
     body = dims[BODY_IDX];
     face_plate = dims[FACE_PLATE_IDX];
            
     render() difference() {
        block(body, center=BELOW);
        replicate() pedistal_clearance();
     }
     render() difference() {
         block(face_plate, center=ABOVE);
         replicate() knob_clearance();
     }
     replicate() retention_clip();
     
     module retention_clip() {
         // truncated Cones
         d_outer = 1;
         d_inner = 2;
         h_clip = 1;
         center_reflect([1, 0, 0]) {
             center_reflect([0, 1, 0]) {
                 translate([pedistal.x/2, pedistal.y/2, -pedistal.z]) {
                    can(d=d_outer, taper=d_inner, h=h_clip, center=BELOW);
                 }
             }
         }
     }
     
     if (show_mocks) {
         replicate() breadboard_compatible_trim_potentiometer();
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