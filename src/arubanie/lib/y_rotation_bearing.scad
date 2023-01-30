use <vector_cylinder.scad>

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Show] */
show_bearing_blank_t = false;
show_bearing_t = false;
show_axle_t = false;
show_bearing_carve_out_t=false;
show_axle_void_t = false;

show_cross_section_t = false;

/* [Colors] */
shoulder_color_cst = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
axle_color_cst = "red"; // ["red", "blue", "green", "yellow", "orange", "purple"]
clip_color_cst = "blue"; // ["red", "blue", "green", "yellow", "orange", "purple"]

colors_cst = [shoulder_color_cst, axle_color_cst, clip_color_cst];

bearing_color_cst = "green"; // ["red", "blue", "green", "yellow", "orange", "purple"]
bearing_alpha_cst = 0.2; // [0: 0.01 : 1]

alpha_bearing_blank_cst = 0.2; // [0: 0.01 : 1]
alpha_bearing_carve_cst = 0.4; // [0: 0.01 : 1]

axle_alpha_max_cst = 0.5; // [0: 0.01 : 1]
axle_clip_max_cst = 1.0; // [0: 0.01 : 1]

cap_color = "orange"; // ["red", "blue", "green", "yellow", "orange", "purple"]
post_color = "purple"; // ["red", "blue", "green", "yellow", "orange", "purple"]

//h_clip_to_dclip = 0.5; // [0: 0.01 : 10]
//
//d_axle_mid_to_d = 0.5; // [0: 0.01 : 10]

/* [Dimensions] */

d_cst = 6; // [1 : 1 : 10]
h_cst = 10; // [1 : 1 : 10]
d_ratio_cst = 0.4; // [0: 0.01 : 1]
h_ratio_cst = 0.7; // [0: 0.01 : 1]

slope_cst = 0.4; // [0: 0.1 : 1]

air_gap_cst = 0.5; // [0: 0.01 : 1]

//printable_grade_cst = 0.3;
//clip_grade_cst = 2.6; // [0: 0.0.1 : 5]
//
//h_clip_cst = h_clip__ratio_cst * h_cst; 

module cut_for_cap(d, h) {
    s = infinity;

    rotate([0, 0, 90]) translate([d/2, 0, h]) translate([s/2, 0, s/2]) cube([s, s, s], center=true);
}


module axle_shape(d, h, d_ratio, h_ratio, is_axle, colors) {

    c_a = 0;
    c_c = 1;
    
    columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];
    
    h_n = h * h_ratio;
    d_n = d * d_ratio;
    
    h_c = h - h_n;
    
    axle_data = 
    [   
        [ d/2, d_n/2,  h_n, c_a ],
        [ d_n/2, d/2,  h_c, c_c ],
    ];
    
    difference() {
        v_conic_frustrum(
            columns,         
            axle_data, 
            colors);
        if (is_axle) {
            cut_for_cap(d_n, h_n);
        }
    }
       
}    

* axle_shape(d_cst, h_cst, d_ratio_cst, h_ratio_cst, trim_cap, colors_cst);


//module adjust_components() {
//    // Layout for 
//    rotate([-90, 0, 0]) {
//        children();
//    }
//}
//
//module axle_blank(d, h, air_gap) {
//    translate([0, 0, -dh/2]) cylinder(d=d-air_gap, h=h+dh);
//}

module bearing_blank(d, h) {
    color("SteelBlue", alpha=alpha_bearing_blank) translate([0,0,h/2]) cylinder(d=d, h=h, center=true); 
}


module axle(d, h, d_ratio, h_ratio, colors, air_gap) {
    axle_shape(d-air_gap, h, d_ratio, h_ratio, true, colors);
}



module bearing_carve_out(d, h, d_ratio_axle, h_ratio, air_gap) {
    
    axle_neck_diameter = d * d_ratio_axle;
    bearing_neck_diameter = axle_neck_diameter + 2 * air_gap;
    
    bearing_neck_ratio = bearing_neck_diameter/d;  
    
    difference() {
        bearing_blank(d, h);
        axle_shape(d, h, bearing_neck_ratio, h_ratio, false); 
    }
//    // ensure that the carve goes beyond the end of the blank
//    color("white") cylinder(d=d+air_gap, h=air_gap, center=true);
//    translate([0,0,h]) color("white") cylinder(d=d, h=air_gap, center=true);
//    // Add a central cylinder all the way through
//    color("blue") translate([0,0,h/2]) cylinder(d=bearing_neck_diameter, h=h+2*air_gap, center=true);
//    // 
    
}



module axle_void(d, h, d_ratio, h_ratio, colors, air_gap) {
    difference() {
        translate([0, 0, -eps]) bearing_blank(d-eps, h-eps);
        bearing_carve_out(d, h, d_ratio_axle, h_ratio, air_gap);
        //axle(d, h, d_ratio, h_ratio, colors, air_gap);      
    }
}

if (show_axle_void_t) {
    axle_void(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
}





module bearing(d, h, d_ratio, h_ratio, air_gap) {
    difference() {
        bearing_blank(d, h);
        bearing_carve_out(d, h, d_ratio, h_ratio, air_gap);
    }
}





if (show_bearing_carve_out_t) {
    viewing_slice(show_cross_section_t) {
        color("Orange", alpha=alpha_bearing_carve_cst)  
            bearing_carve_out(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
    }
}

if (show_bearing_t) {
    bearing(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
}

if (show_bearing_blank_t) {
    bearing_blank(d_cst, h_cst);
}


module viewing_slice(condition) {
    if (condition) {
        difference() {
            children();
            translate([0, 0, -eps]) cube([d_cst, d_cst, 2*h_cst]);
        }
    } else {
        children();
    }
}























//dd = -air_gap_cst;
//dh = air_gap_cst;
//
//difference () {
//    bearing_blank(d_cst, h_cst);
//    axle(d_cst, h_cst, d_ratio_cst, h_ratio_cst, colors_cst, dd);

//}
//
//* wtfwtfw(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
//* bearing(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);

//axle_blank(d_cst, h_cst, air_gap_cst); 
    

//difference() {
//    axle(d_cst, h_cst, d_ratio_cst, h_ratio_cst, colors_cst);
//translate([d_cst, 0, 0])
//    difference() {
//        // axle(d_cst, h_cst, d_ratio_cst, h_ratio_cst, colors)
//        bearing_carve_out(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
//        
////
////}

//translate([2*d_cst, 0, 0]) {
//    axle_shape(d_cst, h_cst, d_ratio_cst, h_ratio_cst, true, colors_cst);
//    color(bearing_color_cst, alpha=bearing_alpha_cst) {
//    
//        bearing(d_cst, h_cst, d_ratio_cst, h_ratio_cst, air_gap_cst);
//    }
//    
//}






//adjust_components() {
//    axle = true;
//    axle_shape(d_cst, h_cst, d_ratio_cst, h_ratio_cst, true, colors_cst); 
// 
//    axle_neck_diameter = d_cst * d_ratio_cst;
//    bearing_neck_diameter = axle_neck_diameter * 2 * air_gap;
//    bearing_neck_ratio = bearing_neck_diameter/d;
//    color(bearing_color_cst, alpha=bearing_alpha_cst) axle_shape(d_cst, h_cst, d_ratio_cst, h_ratio_cst, false, colors_cst); 
//}


//module axle(d, h, h_cap, gap, slope=0.7, colors) {
//    
//    d_mid = (d / sqrt(2)) - gap;
//    h_outer = h/2 - h_cap;
//    
//    
//    d_outer = d_mid - slope * h_outer;
//    assert(d_outer > 0, str("d_outer negative", d_inner));
//    
//    
//    r1_a = d/2;
//    r2_a = d_outer/2;
//    
//    r1_c = d_outer/2;
//    r2_c = d/2;
//    
//    h_a = h - h_cap;
//    h_c = h_cap;
//    
//    c_s = 0;
//    c_a = 1;
//    
//    columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];
//    
//    axle_data = 
//    [   
//        [ r1_a, r2_a,  h_a, c_a ],
//        [ r1_c, r2_c,  h_c, c_c ],
//    
//    ];
// 
//    echo("axle_data", axle_data);
//  
//    v_conic_frustrum(
//        columns,         
//        axle_data, 
//        colors);  
//    
//}  









//module y_rotation_bearing(d, d_axle, h, h_clip, air_gap, grade, clip_grade) {
//    d_outer_max = d - h * grade;
//    assert(d_outer_max > 0, "Unable to print bearing, must make diameter larger for given heigth");
//    
//    
//    r1 = d/2;
//    r2 = d - h_clip * clip_grade; 
//
//    columns = [vcf_r1_idx(), vcf_r2_idx(), vcf_h_idx(), vcf_color_idx()];
//    colors = ["red"];
//    axle_data = 
//    [   [ r1, r2,  h_clip, 0 ],   ];  
//    
//    v_conic_frustrum(
//        columns, 
//        axle_data, 
//        colors);  
//    
//    rotate([-90, 0, 0]) {
//        
////        color(axle_color_cst, alpha=axle_clip_max_cst) { 
////            // retaining clip 
////            d_clip = d - h_clip_to_dclip * h_clip;
////            translate([0, 0, 0]) cylinder(r1=d/2, r2=d_clip/2, h=h_clip-eps);
////            dz_clip = h - h_clip;
////            translate([0, 0, dz_clip]) cylinder(r1=d_clip/2, r2=d/2, h=h_clip+eps);
////            
////            h_axle = (h/2 -h_clip)
////            d_mid =  * d;
////            d_1 = d_mid +  h_axle *  printable_grade;
////            
////            
////            
////        }
//        
//        
//        // Biggest axle possible
//        * color(axle_color_cst, alpha=axle_alpha_max_cst)  cylinder(r1=d/2, r2=d_outer_max/2, h=h+eps);
//        
//
//        
//        
//        // bearing bounding cylinder
//        color(bearing_color_cst, alpha=bearing_alpha_cst)  cylinder(d=d, h=h-eps);
//
//    }
//} 
//
//
//y_rotation_bearing(d_cst, h_cst, h_clip_cst, air_gap_cst, printable_grade_cst, clip_grade_cst);