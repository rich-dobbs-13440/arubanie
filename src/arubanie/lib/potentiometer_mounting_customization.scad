include <potentiometer_mounting.scad>
include <logging.scad>

/* [Customization] */

allowance_ = 0.3; // [0:0.05:2]
clip_overlap_ = 0.5; // [0:0.05:1]
clip_thickness_ = 1; // [0:0.25:2]
count_ = 1; // [1: 10]
spacing_ = 2; // [0 : 1 : 20]
show_mocks_= false;

AS_DESIGNED = 0 + 0;
ON_FACE = 1 + 0;
ON_SIDE = 2 + 0;
ON_END = 3 + 0;
orientation_ = 0; //[0:As designed, 1:On face, 2: On side,  3: On end]

//build_from_ = 0; //[0, 1, 2, 3, 4]


*breadboard_compatible_trim_potentiometer();

build_from_ = [BUILD_UP_TO_FACE, BUILD_FROM_FACE, BUILD_FROM_SIDE, BUILD_FROM_END][orientation_];

breadboard_compatible_trim_potentiometer_housing(
    count = count_, 
    spacing = spacing_, 
    allowance = allowance_,
    build_from = build_from_,
    show_mocks = show_mocks_);
    
housing_dimensions = breadboard_compatible_trim_potentiometer_housing_dimensions(
    count = count_, 
    spacing = spacing_, 
    allowance = allowance_);
    
log_v1("housing_dimensions", housing_dimensions, DEBUG, INFO, IMPORTANT);


 end_of_customization() {}