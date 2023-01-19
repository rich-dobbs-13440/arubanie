/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
eps = 0.001;

infinity = 50;

/* [Pin Overhang] */

max_overhang = 3; // [ 1 : 0.5 : 5]
delta_overhang = 0.25; // [0.25, 0.50, 1]
pin_diameter = 3; // [1 : 1 : 10]
gap_x = 1; // [1: 5]

overhangs = [ each [1 : delta_overhang: max_overhang] ];
echo("overhangs", overhangs);
h_count = len(overhangs);
echo("h_count", h_count);
//diameters = [ each [1 : 5] ];



// Cumulative sum of values in v
function cumsum(v) = [for (a = v[0]-v[0], i = 0; i < len(v); a = a+v[i], i = i+1) a+v[i]];
    
function vector_sum(v, i=0, r=0) = i<len(v) ? vector_sum(v, i+1, r+v[i]) : r;
    

Y_ORIENTATION = [-90, 0, 0];
X_ORIENTATION = [0, 90, 0];

module pin(d, h, center=true, v=Y_ORIENTATION) {
    rotate(v) {
        cylinder(d=d, h=h, center=center);
    }
} 

module base(bar_height, width) {
    y = 2; // base thickness
    x = width; // distance between pins for same diameter
    z = bar_height; //bar_height;
    dx = -x/2;
    dy = -y;
    dz = -z/2;
    translate([dx, dy, dz]) cube([x, y, z]);
}



module pin_overhang_for_d(d, overhangs, gap_x) {
    vertical_padding = gap_x;
    bar_height = d + 1.5 * vertical_padding;
    dx = [ for (i_h = [0 : len(overhangs) - 1]) d + gap_x ];
    echo("dx", dx);  
    x = cumsum(dx);
    echo("x", x); 
    for (i_h = [0 : len(overhangs)-1])  {
        h = overhangs[i_h];
        translate([x[i_h], 0, 0]) { 
            pin(d=d, h=h, center=false);
            base(bar_height, dx[i_h]);
            
        }
    }    
    
}

pin_overhang_for_d(pin_diameter, overhangs, gap_x);







