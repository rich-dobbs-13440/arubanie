/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 1000;

/* [Show] */
show_spindle = true;
show_clip = true;

// All dimensions in mm

spindle_od = 22.25;
spindle_retainer_clip_od = 21.11;
spindle_mid_od = 19.45;
spindle_id = 15.68;




spindle_total_h = 15.27;
spindle_top_lip_h = 2.44;



handle_id = 22.60;
handle_clip_id = 26.03;


spdl_h = [
    0,
    1.59,
    3.31,
    11.29,
    14.87
];
spdl_d = [
    20.70,
    21.80,
    19.94,
    22.39  
];

module spindle() {

   for (i = [0 : 1 : len(spdl_h)-2]) {
       h_seg = spdl_h[i+1] - spdl_h[i];
       d_seg = spdl_d[i];
       echo(h_seg);
       color("white")
       translate([0, 0, spdl_h[i]])  
       cylinder(d=d_seg, h=h_seg, center=false); 
   } 
    
}

if (show_spindle) {
    spindle();
}


module clip() {
    clip_id_allowance = 1.0;
    clip_h_allowance = 0.5;
    clip_od = 25.32;
    clip_id = spdl_d[0] + clip_id_allowance;
    clip_h =  spdl_h[1] - spdl_h[0] - clip_h_allowance;
    color("blue", alpha=0.25)
    render()
    difference() {
        cylinder(d=clip_od, h=clip_h, center=false); 
        cylinder(d=clip_id, h=2*clip_h, center=true);
        translate([0, clip_od/2, clip_h/2]) {
            cube([0.25, clip_od, 2*clip_h], center=true);
        }
    }
     
    
}

if (show_clip) {
    clip();
}

//module old_clips() {
//    clip_width = 1.22;
//    clip_height = 4.13;
//    clip_id = 23.45;F
//    clip_od = 25.88;
//    x = (clip_od - clip_id)/2;
//    y = clip_width;
//    z = clip_height;
//    translate(dx, dy, ) cube([x, y, z], center=true);
//    
//}

//* old_clips();

























