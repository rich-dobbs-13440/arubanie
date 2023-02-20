/* 

9G Servo in OpenSCAD by TheCase on Thingiverse: https://www.thingiverse.com/thing:29734

This thing was started by Thingiverse user TheCase, and is licensed under cc.

The origin for the received object is the center of the main block, 
and there was no easy way to determine where to mount the servo and 
install a servo horn.


Usage: 

    use <9g_servo.scad>




*/

* 9g_motor();

function 9g_motor() = 
    let(
        tran_sprkt = [5.5,0,3.65],
        sprkt_h = 29.25,
        tran_sprkt_top = [0, 0, sprkt_h/2],
        tran_mnt = [0,0,5],
        thick_mnt = 2,
        size_mnt = [32,12,thick_mnt],
        size_body = [23,12.5,22],
        offset_sprkt_origin = -(tran_sprkt + tran_sprkt_top),
        offset_mnt = -[0, 0, thick_mnt/2 ],
        tran_mnt_cl =  offset_sprkt_origin + tran_mnt - [0, 0, thick_mnt/2 ]
    ) 
    
[
    [
        ["offset_for_sprocket_origin", offset_sprkt_origin],
        ["mount_cl_bottom_translation", tran_mnt_cl]
    ],
    [
        ["sprocket_translation", tran_sprkt],
        ["sprocket_height", sprkt_h],
        ["mounting_translation", tran_mnt],
        ["mounting_size", size_mnt],
        ["body_size", size_body],
    ]   
];


* 9g_motor_sprocket_at_origin();

module 9g_motor_sprocket_at_origin(alpha=1, highlight=false) {
    offset_for_sprocket_orgin = 9g_motor()[0][0][1];
    tran_mnt_cl = 9g_motor()[0][1][1];
    //color("black") translate(tran_mnt_cl) sphere(1);
    if (highlight) {
        # translate(offset_for_sprocket_orgin)  9g_motor();  
    } else {
        color("green", alpha=alpha)  translate(offset_for_sprocket_orgin)  9g_motor(); 
    } 
}




module 9g_motor_centered_for_mounting() {
    t_mnt = 9g_motor()[1][2][1] ;
    s_mnt = 9g_motor()[1][3][1];
    rotate([-90,0,90]) 
        translate(-t_mnt+[0,0,s_mnt.z/2] ) 9g_motor();  
}

9g_motor_centered_for_mounting();

module 9g_motor(alpha=1){
    body_color = "SteelBlue";
    sprocket_color = "white";
    t_sprkt = 9g_motor()[1][0][1];
    h_sprkt = 9g_motor()[1][1][1];
    t_mnt = 9g_motor()[1][2][1];
    s_mnt = 9g_motor()[1][3][1];
    s_body = 9g_motor()[1][4][1];
    
	difference(){			
		union(){
			color(sprocket_color) translate(t_sprkt) cylinder(r=2.35, h=h_sprkt, $fn=20, center=true);
			color(body_color, alpha=alpha) translate(t_mnt) cube(s_mnt, center=true);
			color(body_color, alpha=alpha) translate([5.5,0,2.75]) cylinder(r=6, h=25.75, $fn=20, center=true);
			color(body_color, alpha=alpha) translate([-.5,0,2.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color(body_color, alpha=alpha) translate([-1,0,2.75]) cube([5,5.6,24.5], center=true);		
            color(body_color, alpha=alpha) cube(s_body, center=true);    
		}
		translate([10,0,-11]) rotate([0,-30,0]) cube([8,13,4], center=true);
		for ( hole = [14,-14] ){
			translate([hole,0,5]) cylinder(r=2.2, h=4, $fn=20, center=true);
		}	
	}
}