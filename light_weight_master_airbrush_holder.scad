$fa = 1;
$fs = 0.4;

// All dimensions are in mm!
eps = 0.05;
measured_barrel_diameter = 12.01; 
barrel_length = 68.26;
barrel_back_to_air_hose = 18.74;
wall_thickness = 2;
brace_height = 6.9;
brace_width = 7.40;
brace_length = 28.88;
air_hose_diameter = 8.66;
air_hose_barrel_length = 10.34;
air_hose_clip_length = 2;
trigger_diameter = 10.18;


barrel_diameter = measured_barrel_diameter + 1;



module barrel() {
    // Display horizontal zero 
    h = barrel_length+2/eps;
    d = barrel_diameter;
    translate([-eps, 0, 0]) rotate([0,90,0]) cylinder(h=h, d=d, center=false);
}



module air_hose_barrel() {
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    h = air_hose_barrel_length + barrel_diameter;
    translate([dx, 0, 0]) rotate([90,0,0]) cylinder(h=h, d=air_hose_diameter, center=false);
}


module brace() {
    // Entire block, before carve outs
    x = brace_length + air_hose_diameter/2;
    z = brace_height + barrel_diameter/2;
    dx = barrel_back_to_air_hose + air_hose_diameter/2;
    dz = -brace_height/2;
    translate([dx, 0, dz]) rotate([90, 0, 0]) cube([brace_length, brace_width, z]);
}



module air_brush() {
    barrel();
    air_hose_barrel();
    brace();
}

* air_brush();

module air_brush_on_end() {
    rotate([-90, -90, 0]) air_brush(); // Rotate to vertical
}
* air_brush_on_end();

module air_hose_bracket() {
    // bottom around air house 
    x_bah = wall_thickness;
    y_bah = barrel_diameter + 2 * air_hose_clip_length;
    z_bah = barrel_back_to_air_hose +  air_hose_diameter/2 + air_hose_clip_length;
    dx_bah = -wall_thickness/2 - barrel_diameter/2;
    dz_bah = z_bah/2;
   
    x_bah_barrel = 2*air_hose_barrel_length;
    dz_bah_barrel = air_hose_diameter / 2 + wall_thickness;
    dx_bah_barrel  = -x_bah_barrel /2 ;
    difference() {
        translate([dx_bah, 0, dz_bah]) cube([x_bah, y_bah, z_bah], center=true);
        air_brush_on_end();
    }
}

module base() {
    x = barrel_diameter + 2 * wall_thickness;
    y = barrel_diameter + 2 * wall_thickness;
    z = wall_thickness;
    //dx_trigger = barrel_diameter/2+trigger_diameter/2 - 1;
    difference() {
        translate([0, 0, z/2.]) cube([x, y, z], center=true);
        air_brush_on_end();
    }
    
}

base();

module sides() {
    // left side
    x_s = barrel_diameter + 2 * wall_thickness;
    z_s = barrel_back_to_air_hose + air_hose_diameter/2 + 0.5 * brace_length;
    dx_s = -barrel_diameter/2 - wall_thickness ;
    dy_s = barrel_diameter/2;
    dz_s = z_s / 2;

    color("red") translate([dx_s, dy_s, 0]) cube([x_s, wall_thickness, z_s]);
    
    // right side
    dy_rs = -wall_thickness - barrel_diameter/2;
    translate([dx_s, dy_rs, 0]) cube([x_s, wall_thickness, z_s]);
}



module back_block() {
    
    base();


     
}


    
* back_block();