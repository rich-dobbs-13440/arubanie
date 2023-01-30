#!/usr/bin/env bash

: ' 
The show_name parameter suppresses the warning message for 
   Current top level object is empty.

Each such file should contain this code snippet:

show_name = false;
if (show_name) {
    linear_extrude(2) text("file_name.scad", halign="center");
}

'

set -x
set -e

date
SECONDS=0
openscad -o ../../../build/bearing_spike.stl bearing_spike.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/four_bar_classification.stl four_bar_classification.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o  ../../../build/four_bar_linkage.stl four_bar_linkage.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/layout_for_3d_printing.stl layout_for_3d_printing.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/logging.stl logging.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/not_included_batteries.stl not_included_batteries.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -o ../../../build/print_in_place_development.stl print_in_place_development.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/print_in_place_joints.stl print_in_place_joints.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/small_pivot.stl small_pivot.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/small_pivot_vertical_rotation.stl small_pivot_vertical_rotation.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/small_servo_cam.stl small_servo_cam.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/small_servo_linkages.stl small_servo_linkages.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/vector_cylinder.stl vector_cylinder.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/vector_operations.stl vector_operations.scad
echo "Elapsed Time: $SECONDS seconds"
openscad -D show_name=true -o ../../../build/y_rotation_bearing.stl y_rotation_bearing.scad
echo "Elapsed Time: $SECONDS seconds"