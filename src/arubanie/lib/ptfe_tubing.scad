include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>

 module ptfe_tubing(od, l, as_clearance = false, center = CENTER, clearance = 0.5) {
   a_lot = 200;
    d = as_clearance ? od + 2 * clearance :  od;
    rod(d=od, l=l, center=center);
    if (as_clearance) {
      rod(d=3, l=a_lot);
    }
 }