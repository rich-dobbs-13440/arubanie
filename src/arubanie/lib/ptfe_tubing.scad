include <centerable.scad>
use <not_included_batteries.scad>
use <shapes.scad>

 module ptfe_tubing(od, l, as_clearance = false, center=CENTER) {
    rod(d=od, l=l, center=center);
 }