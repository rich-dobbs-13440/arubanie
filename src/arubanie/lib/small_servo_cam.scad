/*

Usage:
    
    use <lib/small_servo_cam.scad>
    
    horn(h=4);
    
    linear_small_servo_cam(travel=4, include_follower=true);
    
Note: 

    The origin is place at the center of the sprocket, where the horn arms 
    start to go out.

*/

/* [Boiler Plate] */

$fa = 1;
$fs = 0.4;
fa_shape = 10;
fa_bearing = 1;

/* [Show] */

show_horn = false;
show_first_small_servo_cam = true;
show_linear_small_servo_cam = true;

example_travel = 4; //[1:1:8]
include_follower_example = true;

//horn_thickness = 
//hub_diameter

module end_of_customization() {}


function small_servo_cam_horn_thickness() = 1.46;
function small_servo_cam_hub_diameter() = 23.8;

module horn_arm(h) {
    outer_clearance = 0.50;
    inner_clearance = 0.0;
    hub_clearance = 0.5;
    hub_across = 23.8 + hub_clearance;
    x = hub_across/2;
    dy1 = 5.32/2 + outer_clearance;
    dy2 = 4.0/2 + inner_clearance;
    horn_points = [
        [ 0,  -dy1,  0 ],  //0
        [ x,  -dy2,  0 ],  //1
        [ x,  dy2,  0 ],  //2
        [  0,  dy1,  0 ],  //3
        [  0,  -dy1,  h ],  //4
        [ x,  -dy2,  h ],  //5
        [ x,  dy2,  h ],  //6
        [  0,  dy1,  h ]]; //7
    
    faces = [
      [0,1,2,3],  // bottom
      [4,5,1,0],  // front
      [7,6,5,4],  // top
      [5,6,2,1],  // right
      [6,7,3,2],  // back
      [7,4,0,3]]; // left
    polyhedron( horn_points, faces);
}



module horn(h) {
    horn_arm(h);
    rotate([0,0,90]) horn_arm(h);
    rotate([0,0,180]) horn_arm(h);
    rotate([0,0,270]) horn_arm(h);
    
    translate([0, 0, h/2]) cylinder(d=8.2 + 3, h=h, center=true, $fa=fa_shape);
}

if (show_horn) {
    color("AntiqueWhite") horn(h=1.40);
}


module cylinder_arc(r1, r2, h, angle) {
    difference() {
        cylinder(r=r2, h=h, center=true);
        cylinder(r=r1, h=2*h, center=true);
        translate([-0.01,0,-h]) cube([2*r2, 2*r2, 2*h]);
        rotate([0,0,90]) translate([-0.01,0,-h]) cube([2*r2, 2*r2, 2*h]);
        rotate([0,0,180]) translate([-0.01,0,-h]) cube([2*r2, 2*r2, 2*h]);
        rotate([0,0,270-angle]) translate([-0.01,0,-h]) cube([2*r2, 2*r2, 2*h]);
    }
}

module spring(r0, r1, r2, h, angle1, angle2) {
    cylinder_arc(r1, r2, h, angle1, $fa=fa_shape);
    cylinder_arc(r0, r2 + 2, h, angle2, $fa=fa_shape);  
}

* spring(8, 10, 13, 3, 45, 10);

module latch(base_diameter, horn_thickness) {
    assert(is_num(base_diameter));
    assert(is_num(horn_thickness));
    catch_overlap = 0.3;
    catch_clearance = 0.5;
    
     
    dx = 1.0 * horn_thickness;
    dy = 1.0 * horn_thickness;
    dz = 2.0 * horn_thickness;
    x = -dx/2;
    y = base_diameter/2 + horn_thickness/2; 
    
    // vertical
    color("red") translate([x, y, -horn_thickness] ) cube([dx, dy, dz]);
    color("blue") translate([x, y, -horn_thickness] ) rotate([10,0,0]) cube([dx, dy, 1.5*dz]);
    
    // latch
    dz_latch = 2* horn_thickness;
    dy_latch = base_diameter/2;
    color("orange") translate([0, dy_latch, dz_latch] ) 
    rotate([0,90,0]) 
    cylinder(r=horn_thickness, h=dx, center=true, $fa=3*fa_shape);

    // spring
    r1 = y;
    r2 = r1 + horn_thickness;
    rotate([0,0,55]) spring(8, r1, r2, 3, 55, 15);
    
//    // base_connector
//    yb = base_diameter/2 - catch_overlap;
//    dyb = y - yb + horn_thickness - 0.5;
//    * translate([0,0, catch_clearance]) difference() {
//        // catch
//        color("red") translate([x, yb, +horn_thickness] ) cube([dx, dyb, 1 * horn_thickness]);
//        // slice
//        translate([x-1, yb, +horn_thickness] ) rotate([60,0,0]) cube([2*dx, 10, 10]);
//}
}

module latches(base_diameter, horn_thickness) {
    color("Turquoise") {
        latch(base_diameter, horn_thickness);
        rotate([0,0,90]) latch(base_diameter, horn_thickness);
        rotate([0,0,180]) latch(base_diameter, horn_thickness);
        rotate([0,0,270]) latch(base_diameter, horn_thickness);
    }
}

* latches(base_diameter=23.7, horn_thickness=small_servo_cam_horn_thickness());

module bare_hub(horn_thickness) {
    inner_hub = 5.32;
    hub_clearance = 1.5;
    hub_diameter = 23.8;
    color("PaleTurquoise") {
        difference() {
            // Basic wheel
            cylinder(d=hub_diameter, h=2*horn_thickness, center=true, $fa=fa_shape);
            // Cutout for hub
            cylinder(d=inner_hub+hub_clearance, h=4*horn_thickness, center=true, $fa=2*fa_shape);
            // cutout for horn
            horn(h=2*horn_thickness);
        }
    }
}

//hub(horn_thickness=small_servo_cam_horn_thickness(), hub_diameter=small_servo_cam_hub_diameter());

module hub(horn_thickness, hub_diameter) {
    assert(is_num(horn_thickness));
    assert(is_num(hub_diameter));
    bare_hub(horn_thickness);
    latches(hub_diameter, horn_thickness);
}




module pie_slice(a, r, h){
  // a:angle, r:radius, h:height
  rotate_extrude(angle=a) square([r,h]);
}
* pie_slice(110,20,3);


* pie(10, 1, 12);

module cylinder_arc2(r1, r2, h, angle) {
    intersection() {
        difference() {
            cylinder(r=r2, h=h, center=true, $fa=fa_shape);
            cylinder(r=r1, h=2*h, center=true, $fa=fa_shape);
        };
        color("red") translate([0, 0, -h]) pie_slice(angle, r2, 2*h);
    }
}

//module cam_base_ring() {
//    r1 = 15;
//    r2 = 16;
//    h = 3;
//    angle = 170;
//    cylinder_arc2(r1, r2, h, angle);
//}
//
//* cam_base_ring();

module linear_cam_surface(
        r_0, 
        r_1, 
        r_2, 
        h, 
        angle, 
        include_follower=true,
        follower_diameter=3.0,
        follower_outer_rim_thickness=2,
        follower_inner_rim_thickness = 2,
        follower_lip = 0.7) {
    
    s = (r_2 - r_1) / angle;  
    da = 1;
    for(a = [0 : da : angle]) {
        * echo("a", a);
        r = r_1 + a * s;
        * echo("r", r);
        dx = r - r_0;
        rotate([0, 0, a]) translate([r-dx, 0, 0]) {
            cube([dx, 0.5, h]);
        }   
       
        if (include_follower) {
            // Outer edge
            rotate([0, 0, a]) translate([r + follower_diameter, 0, 0]) {
                cube([follower_outer_rim_thickness, 0.5, h]);
            }
            // bottom 
            rotate([0, 0, a]) translate([r-dx, 0, 0]) {
                cube([dx+follower_diameter+follower_outer_rim_thickness, 0.5, 1]);
            }
            //outer_keeper
            rotate([0, 0, a]) translate([r + follower_diameter-follower_lip, 0, h]) {
                cube([follower_outer_rim_thickness+follower_lip, follower_lip, 2*follower_lip]);
            }
            //Inner keeper

            rotate([0, 0, a]) translate([r- 2 * follower_lip, 0, h]) {
                cube([3 * follower_lip, follower_lip, 2*follower_lip]);
            }
        } 
    }     
}


module linear_small_servo_cam(travel, include_follower=true) {
    
    assert(is_num(travel));

    hub(small_servo_cam_horn_thickness(), small_servo_cam_hub_diameter());
    r_min = 16;
    r2 = r_min + travel;
    color("LightCyan") {
        translate([0, 0, -small_servo_cam_horn_thickness()]) rotate([0,0,40]) 
            linear_cam_surface(15, r_min, r2, h=4, angle=195, include_follower=include_follower);
    }
    // connectors
    h_connector=3 - 0.1;
    r_inside_hub = 9;
    color("MediumTurquoise") {
        rotate([0, 0, 40]) cylinder_arc2(r_inside_hub, r_min, h=h_connector, angle=30);
        rotate([0, 0, 40+90]) cylinder_arc2(r_inside_hub, r_min, h=h_connector, angle=30);
        rotate([0, 0, 40+180]) cylinder_arc2(r_inside_hub, r_min, h=h_connector, angle=15);
    }
    
}

if (show_linear_small_servo_cam) {
    linear_small_servo_cam(travel=example_travel, include_follower=include_follower_example);
}
