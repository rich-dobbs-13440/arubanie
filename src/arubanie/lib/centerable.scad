use <vector_operations.scad>


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

module center_translation(size, center) {
    disp = _center_to_displacement(center, size);
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
  
