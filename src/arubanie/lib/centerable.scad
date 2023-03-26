use <vector_operations.scad>


echo("Template: \n translate([0, 0, 0]) \n  block([x, y, z], \n   center=ABOVE+FRONT+RIGHT     center=BELOW+BEHIND+LEFT );\n");


function bw_lshift(number, places) = 
    number * pow(2, places);
    
function bw_rshift(number, places) = 
    floor(number / pow(2, places));
    
function bw_extract(number, places, bits) = 
    bw_rshift(number, places) % pow(2, bits);

// A bit less brain-damaged primative shapes

CENTER = 0;   
PLUS = 1;
MINUS = 2;

FRONT = 1;
BEHIND = 2; 
RIGHT = 4;
LEFT =  8;    
ABOVE = 16;
BELOW = 32;
SIDEWISE = 64;

X_AXIS = 128;
Y_AXIS = 256;
Z_AXIS = 512;

_X_BITS = [0, 2];
_Y_BITS = [2, 2];
_Z_BITS = [4, 2];
_O_BITS = [6, 1];

_XYZO_BITMAP = [_X_BITS, _Y_BITS, _Z_BITS, _O_BITS];

function _number_to_bitvector(number) = [ 
    for (i = [0:3]) let(places = _XYZO_BITMAP[i][0], bits = _XYZO_BITMAP[i][1]) 
       bw_extract(number, places, bits) 
];
    

function _bv_to_sign(bv) = [
    for (i = [0:len(bv)]) 
        bv[i] == PLUS ? 1 :
        bv[i] == MINUS ? -1 : 0
];
    

function _center_to_dv(center, s, bv) = [
    for (i = [0:len(s)-1]) s[i] * bv[i]
];
    
function _center_to_displacement(center, size) = 
    _center_to_dv(
        center, 
        v_mul_scalar(size, 0.5),
        _bv_to_sign(_number_to_bitvector(center))); 

function _rotation_to_angles(angles) = 
    let(
         bv = v_shorten(_number_to_bitvector(angles), 3),
         signs = _bv_to_sign(bv),
         // signs = [FRONT|BEHIND, RIGHT|LEFT, ABOVE|BELOW]
         // A sign of zero for FRONT|BEHIND is treated as FRONT
         rotation = 
            [0, 0, signs[0] == 1 ? 0 :  signs[0] == -1 ? 180: 0] + 
            v_mul_scalar([0, 0, 90], signs[1]) + 
            v_mul_scalar([0, -90, 0], signs[2])
    )
    rotation;

function _rotate_size(size, rotation) =
    is_undef(rotation) ? size :
    rotation==LEFT ? [size.y, size.x, size.z] :
    assert(false);


module center_translation(size, center, rotation) {
    size_for_disp = _rotate_size(size, rotation); 
    disp = _center_to_displacement(center, size_for_disp);
    translate(disp) { 
        children();
    }
}

module center_rotation(rotation) {
    angles = _rotation_to_angles(rotation);
    rotate(angles) {
        children();
    }
}

module center_orient(orient, initial_orient) 
    center_rotation(orient) {  
        center_rotation(initial_orient) {
           children();
        }
    }

module center_rotate(from_axis, to_axis) {
    
    rotation =
       (from_axis == X_AXIS) && (to_axis == X_AXIS) ? [0, 0, 0] :
       (from_axis == X_AXIS) && (to_axis == Y_AXIS) ? [0, 0, 0] :
       (from_axis == X_AXIS) && (to_axis == Z_AXIS) ? [0, 0, 0] :
       (from_axis == Z_AXIS) && (to_axis == X_AXIS) ? [0, -90, 0] :
       (from_axis == Z_AXIS) && (to_axis == Y_AXIS) ? [0, 0, 0] :
       (from_axis == Z_AXIS) && (to_axis == Z_AXIS) ? [0, 0, 0] :
       assert(false, assert_msg("Not implemente yet: from_axis", str(from_axis), " to_axis : ", to_axis));
       


    rotate(rotation) {
        children();
    }
}


module center_reflect(v) {
    assert(!is_undef(v), "You must pass an mirroring argument to center_reflect()");
    children();
    mirror(v) children();
}


function center_str_to_center(center_as_str) = 
    center_as_str == "RIGHT" ? RIGHT :
    center_as_str == "LEFT" ? LEFT :
    center_as_str == "FRONT" ? FRONT :    
    center_as_str == "BEHIND" ? BEHIND :
    center_as_str == "ABOVE" ? ABOVE :
    center_as_str == "BELOW" ? BELOW :
    assert(false, "Not implemented");
  
