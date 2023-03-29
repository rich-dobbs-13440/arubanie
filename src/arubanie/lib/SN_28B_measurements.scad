module end_of_customization() {}


/* [Jaw Measurements] */
 

/* 

Origin will be at center_line of jaw at the front, with jaw being on the 
x axis, with x being positive as you go deeper into the jaw.
*/
    dy_between_jaw_sides = 4.6;
    dz_between_upper_and_lower_jaw = 10.16;
    x_jaw = 24;
    y_jaw = 2.5;
    z_jaw = 15.26;
    jaws_extent = [x_jaw, 2*y_jaw + dy_between_jaw_sides, z_jaw];
    z_jaw_front = 7.3;
    max_jaw_angle = 26;

    front_to_front_of_25 = 3.42;
    front_to_back_of_25 = 5.24;
    lower_jaw_height = 1.81;
    
    
    back_jaw_to_pivot_moving = [12.62, 6.26, 20];
    back_jaw_to_pivot_fixed = [12.62, 11.2, 20];
    y_pivot = 16.32;
    d_pivot = 7.92;
    
    function translation_jaw_to_pivot(fixed) =  
        let (
            side = fixed ? -1 : +1
        )
        [
            -(back_jaw_to_pivot_moving.x + x_jaw), 
            0, 
            side * dz_between_upper_and_lower_jaw / 2
        ];    
    
 /* [Anvil Dimensions] */   
    
    x_lower_jaw_anvil = 23.4;
    y_lower_jaw_anvil =7.21;
    z_lower_jaw_anvil = 7.05;   
    lower_jaw_anvil_blank = [x_lower_jaw_anvil, y_lower_jaw_anvil, z_lower_jaw_anvil]; 

    dx_025_anvil = 3.63;
    dz_025_pin_punch_z = 5.78;
    x_b_025_pin_punch = 2.0;
    x_t_025_pin_punch =  1.7;
    x_b_025_wire_punch = 2.7;
    x_t_025_wire_punch = 1.9;
    dz_025_wire_punch_z = 5.89;       

    dx_050_anvil = 11.4;
    dz_050_pin_punch_z = 5.9;
    x_b_050_pin_punch = 2.2;
    x_t_050_pin_punch = 1.9;
    x_b_050_wire_punch = 3.1;
    x_t_050_wire_punch = 2.8;
    dz_050_wire_punch_z = 5.89;          

    dx_100_anvil = 19.7;
    dz_100_pin_punch_z = 5.78;
    x_b_100_pin_punch = 2.4;
    x_t_100_pin_punch = 2.0;   
    x_b_100_wire_punch = 3.7;
    x_t_100_wire_punch = 3.1; 
    dz_100_wire_punch_z = 5.89;            
    
    x_upper_jaw_anvil = 23.8;
    y_upper_jaw_anvil =7.13;
    z_upper_jaw_anvil = 3.06;
    upper_jaw_anvil_blank = [x_upper_jaw_anvil, y_upper_jaw_anvil, z_upper_jaw_anvil]; 
   

/* [Anvil Retainer Dimensions] */
    x_anvil_retainer = 17.09;
    y_anvil_retainer = 4.18;
    z_anvil_retainer = 9.6;
    anvil_retainer_extent = [x_anvil_retainer, y_anvil_retainer, z_anvil_retainer];
    w_rim_ar = 2.28; 
    d_screw_hole_ar = 5.12;
    d_rim_ar = d_screw_hole_ar + 2*w_rim_ar;
    z_axis_ar = z_anvil_retainer - w_rim_ar - d_screw_hole_ar/2;
    y_web_ar = 2.69;
    x_inset_ar = 10.88;
    y_inset_ar = (y_anvil_retainer - y_web_ar) / 2;
    
