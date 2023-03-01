/*

use <potentiometer_mounting.scad>

*/

include <logging.scad>
include <centerable.scad>
use <shapes.scad>

/* [Customization] */
    show_housing = true;
    show_default = false;
    allowance_ = 0.3; // [0:0.05:2]
    clip_overlap_ = 1; // [0:0.05:1]
    clip_thickness_ = 1.; // [0:0.25:4]
    count_ = 1; // [1: 10]
    spacing_ = 2; // [0 : 1 : 20]
    show_mocks_= false;
    build_from_ = 0; //[0:Designed, 1:From face, 2:Side, 3:End]
    retain_pins_ = true;
    arrow_up_ = true;
    spring_width_ = 4.;
    
    if (show_housing) {
        breadboard_compatible_trim_potentiometer_housing(
            count = count_, 
            spacing = spacing_, 
            allowance = allowance_,
            clip_overlap = clip_overlap_,
            clip_thickness = clip_thickness_,
            spring_width = spring_width_,
            build_from = build_from_,
            arrow_up = arrow_up_,
            show_mocks = show_mocks_,
            retain_pins = retain_pins_);
    }

    if (show_default) {
        breadboard_compatible_trim_potentiometer_housing();
    }

module end_of_customization() {}

// Rotations:  Move to centrable???
Z_TO_MINUS_Z = [180, 0, 0];
Z_TO_MINUS_Y = [90, 0, 0];
Z_TO_X = [0, 90, 0];
X_TO_Y = [0, 0, 90];

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


// Housing Constants
BODY_IDX = 0;
X_OFFSET_IDX = 1;
DX_IDX = 2;
FACE_PLATE_IDX = 3;
PIN_RETENTION_BASE_IDX = 4;
PIN_RETENTION_LOWER_WALL_IDX = 5;
PIN_WIDTH = 6;
PIN_LENGTH = 7;
PIN_WIRE_FIN = 8;
PIN_WIRE_GAP = 9;
D_KNOB_CLEARANCE = 10;
BACK_PLATE = 11;
HOUSING = 12;

 
function  breadboard_compatible_trim_potentiometer_housing_dimensions(
        wall = 2, 
        face = 0.5, 
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3, 
        clip_overlap = 1.0, 
        clip_thickness = 1.0) =
    let(
        knob_dims = breadboard_compatible_trim_potentiometer_dimensions(),
        pedistal = knob_dims[PEDISTAL_IDX],
        allowances = [2*allowance, 2*allowance, 2*allowance],
        walls = [2*wall, 2*wall, 0],
        housing = pedistal+allowances+walls,
        x = (housing.x - wall) * count + spacing * (count-1) + wall,
        y = pedistal.y + 2 * allowance + 2 * wall,
        z = pedistal.z + allowance,
        dx = housing.x - wall + spacing,
        back_plate = [x, y, back],
        body = [x, y, z],
        x_offset = -body.x/2 + wall + allowance + pedistal.x/2,
        
        face_plate = [body.x, body.y, face],
        pin_length = 14,
        pin_length_allowance = 0.2,
        pin_width = 2.54,
        clip_thickness = pin_width,
        pin_retention_base = [housing.x, wall+clip_overlap, pin_length + pin_length_allowance + clip_thickness], 
        pin_retention_lower_wall = [
            4*pin_width, 
            body.y/2 - pin_width/2, 
            1.5*clip_thickness
        ],
        wire_gap = 1.24 * 1.1,
        wire_fin = [pin_width - wire_gap, pin_width, clip_thickness],
        knob_allowance = 0.50,
        d_knob_clearance = knob_dims[KNOB_IDX][D_BASE] + 2*knob_allowance,
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
        wire_gap,
        d_knob_clearance,
        back_plate, 
        housing,
    ];
    
// Build orientation Constants
BUILD_UP_TO_FACE = 0; // As designed, with no rotation 
BUILD_FROM_FACE = 1;    
BUILD_FROM_SIDE = 2;
BUILD_FROM_END = 3; 
 
 module breadboard_compatible_trim_potentiometer_housing(
        wall = 2, 
        face = 0.5,
        back = 1, 
        count = 1, 
        spacing = 2, 
        allowance = 0.3, 
        clip_overlap = 0.5,
        clip_thickness = 1.0,
        spring_width = 3, 
        center = 0, 
        build_from = 0,
        retain_pins = false,
        arrow_up = true,
        show_mocks = false) {
            
          
            
    dims = breadboard_compatible_trim_potentiometer_housing_dimensions(wall, face, back, count, spacing, allowance, clip_overlap);
    knob_dims =  breadboard_compatible_trim_potentiometer_dimensions();
    pedistal = knob_dims[PEDISTAL_IDX];
    body = dims[BODY_IDX];
    face_plate = dims[FACE_PLATE_IDX];
    back_plate = dims[BACK_PLATE];
    pin_retention_base = dims[PIN_RETENTION_BASE_IDX];
    pin_retention_lower_wall = dims[PIN_RETENTION_LOWER_WALL_IDX];
    wire_fin = dims[PIN_WIRE_FIN]; 
    pin_width = dims[PIN_WIDTH];
    pin_length = dims[PIN_LENGTH];
    wire_gap = dims[PIN_WIRE_GAP];
    d_knob_clearance = dims[D_KNOB_CLEARANCE];
    housing = dims[HOUSING];
    
    orient() assembly();
    
    module assembly() {
        
        replicate() {
            if (show_mocks) {
                orient_mocks(arrow_up) {
                    breadboard_compatible_trim_potentiometer();
                    dupont_pins();
                }
            } 
            spring_clip();

            housing_lower_xz_wall(narrow=false);
            
            if (retain_pins) {
                pin_retention_clip();
            }
        } 
    
        render() difference() {
            block(face_plate, center=ABOVE);
            replicate() knob_clearance();
        }    
                
        render() difference() {
            block(back_plate, center=BELOW);
            replicate() pedistal_clearance();
        }
        three_d_printing_aids();
    }
    
    module three_d_printing_aids() {
        if (build_from == BUILD_FROM_END) {
            build_from_end_printing_aids();
        }
    }
    
    module build_from_end_printing_aids() {
        bridging_pillar = [body.x, 2*allowance, 2*allowance];
        // Bridging supports for top of housing and retention clips
        top_wall_pillar = [body.x, wall, wall];
        center_reflect([0, 1, 0]) {
            translate([0, body.y/2, -housing.z]) block(top_wall_pillar, center=LEFT+ABOVE);
        }

        module pin_supports() {
            // Bridging supports for pin wire fins
            bridging_pillar = [body.x, 2*allowance, 2*allowance];
            t_fins_o = [0, pin_width/2, -body.z - pin_retention_base.z];
            translate(t_fins_o) block(bridging_pillar);
            t_fins_i = [0, pin_width/2, -body.z - pin_retention_base.z + pin_width];
            translate(t_fins_i) block(bridging_pillar);   
       
            t_lw_o = [
                0, 
                -body.y/2+pin_retention_lower_wall.y-allowance,  
                -body.z - pin_retention_base.z + allowance
            ];
            #translate(t_lw_o) block(bridging_pillar);
            t_lw_i = [
                0, 
                -body.y/2+pin_retention_lower_wall.y-allowance, 
                -body.z - pin_retention_base.z +  pin_retention_lower_wall.z - allowance
            ];
            translate(t_lw_i) block(bridging_pillar);             
        }        
    }

    module dupont_pins() {
        color("black") {
            translate([pin_width, 0, -pedistal.z]) block([pin_width, pin_width, pin_length], center=BELOW);
        }
        color("red") {
            translate([-pin_width, 0, -pedistal.z]) block([pin_width, pin_width, pin_length], center=BELOW);
        }  
       color("yellow") {
            translate([0, -pin_width/2, -pedistal.z]) 
                rotate([5, 0, 0]) 
                    block([pin_width, pin_width, pin_length], center=BELOW);
        }            
    }  

    module housing_lower_xz_wall(narrow = true) {
        xz_wall = narrow ? [housing.x, wall, wall] : [housing.x, wall, housing.z];
        translate([0, -housing.y/2, -housing.z]) block(xz_wall, center=ABOVE+RIGHT); 
    }
    
    module spring_clip() {
        lower_spring_clip();
        upper_spring_clip();
    }
    
    module upper_spring_clip() {
        t_housing_corner = [housing.x/2, housing.y/2, -housing.z];
        d_snap_ring_hole = 1.44 + 0.6; // measured plus allowance
        snap_ring_wall = 1;
        t_snap_ring_hole = [-wall+snap_ring_wall, 0, -clip_overlap];
        center_reflect([1, 0, 0]) {
            translate(t_housing_corner) {
                translate(t_snap_ring_hole) {
                    rod(
                        d=d_snap_ring_hole+2, 
                        l=wall, 
                        hollow = d_snap_ring_hole, 
                        center=SIDEWISE+ABOVE+BEHIND+LEFT);
                }
            }
        }
    }

    module lower_spring_clip() {
        spring();
        module clip() {
            ramp_length = 3;
            catch = [
                wall + clip_overlap, 
                4, 
                clip_thickness
            ];
            ramp = [
                wall/2, 
                catch.y, 
                ramp_length
            ]; 
            
            print_support = [
                0.01, 
                ramp.y + ramp_length, 
                0.01
            ];           
            hull() {
                block(catch, center=BELOW+BEHIND+LEFT);
                block(ramp, center=BELOW+BEHIND+LEFT);
                block(print_support, center=BELOW+BEHIND+LEFT);
            }
        }
        
        module spring() {
            t_housing_corner = [housing.x/2, housing.y/2, -housing.z];
            spring = [wall, housing.y, spring_width];
            center_reflect([1, 0, 0]) {
                translate(t_housing_corner) {
                    block(spring, center=ABOVE+LEFT+BEHIND);
                    clip();
                }
            }
        } 
    }

    module knob_clearance() {
        can(d=d_knob_clearance, h=20);
    }
     
    module pedistal_clearance() {
        allowances = [2*allowance, 2*allowance, 20];
        translate([0, 0, -pedistal.z/2]) block(pedistal + allowances);
    }
    
    module pin_retention_clip() {
        module wire_clip() {
            translate([0, 0, -body.z-pin_retention_base.z])
                center_reflect([1, 0, 0]) 
                    translate([wire_gap/2, 0, 0]) 
                        block(wire_fin, center=ABOVE+FRONT); 
        }
            
        
        translate([0, -body.y/2, -body.z]) block(pin_retention_base, center=BELOW+RIGHT);
        translate([0, -body.y/2, -body.z-pin_retention_base.z]) block(pin_retention_lower_wall, center=ABOVE+RIGHT);
        wire_clip();
        center_reflect([1, 0, 0]) translate([pin_width, 0, 0]) wire_clip();     
    }    
    
    module orient() {
        assert(build_from <=4);
        rotation = [[0, 0, 0], Z_TO_MINUS_Z, Z_TO_MINUS_Y, Z_TO_X][build_from];
        rotate(rotation) { 
            children();
        }
    } 
 
    module orient_mocks(arrow_up) {
        rotation = arrow_up ? [0, 0, 0] : [0, 0, 90];
        rotate(rotation) { 
            children();
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
    
 }