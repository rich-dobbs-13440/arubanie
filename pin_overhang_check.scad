/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];

module pin(d, h, center=true, v=Y_ORIENTATION) {
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
} 

module base(dh, bar_height) {
    y = 2; // base thickness
    x = dh; // distance between pins for same diameter
    z = bar_height;
    dx = -dh/2;
    dy = -y;
    dz = -z/2;
    translate([dx, dy, dz]) cube([x, y, z]);
}

module pin_overhang(diameters, overhangs) {
    x_gap = 10; //mm
    y_gap = 4; // mm
    z_padding = 4;
    dd = max(diameters) + x_gap;
    dh = max(overhangs) + y_gap; 
    
    function location(idx_d, idx_h) = [ idx_h * dh, idx_d * dd, 0 ];
    
    c_h = len(overhangs);
    echo("c_h", c_h);
    c_d = len(diameters);
    echo("c_d", c_d);
    
    for (idx_d = [0 : c_d-1]) {
        d = diameters[idx_d];
        bar_height = d + z_padding;
        // Draw bar         
        for (idx_h = [0 : c_h-1])  {
            h = overhangs[idx_h];
            translate(location(idx_d, idx_h)) {
                base(dh, bar_height);
                pin(d=d, h=h, center=false);
                
            }
        }
    } 
} 

overhangs = [ each [1 : 5] ];
diameters = [ each [1 : 5] ];



pin_overhang(diameters, overhangs);

















//module pin_overhang_test_fixture(diameters, overhangs) {
//    for (d = diameter) {
//        for (h = overhang) {
//            cylinder(d=d, h=h, center=false);
//        }
//    } 
//}



//s = 1;
//for (j = s) echo("s - j", j);
//    
//v = [1, 2, 3];
//for (j = v) echo("vv - j", j);





//echo("overhang", overhangs);
//
//* pin_overhang_test_fixture(diameter=3, overhang=[0.3 : 0.1 : 0.5] );




//
//h_r = [ 0.3 : 0.1 : 0.5 ];
//h = [ (for h = h_r) h ];


////len(h);
////echo ("h", h);
//
//* pin_overhang_array(diameter=3, h_range=[0.3 : 0.1 : 0.5]);
//
////array1=[1,2,3,4,5,6,7,8]; len_array1=len(array1);
////echo(array1,len_array1);
//
//
//list1 = [ for (i = [0 : 2 : 10]) i ];
//echo(list1); // ECHO: [0, 2, 4, 6, 8, 10]
//
//g = [0 : 2 : 10];
//
//list2 = [ for (i = g) i ];
//echo(list1);
//
//echo("is_list(g)", is_list(g));




