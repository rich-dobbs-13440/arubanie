cura
====


usage: cura [--version] [--external-backend] [--headless] [--debug] 
[-qmljsdebugger QMLJSDEBUGGER] [--help] [--single-instance] [--trigger-early-crash] [file [file ...]]

positional arguments:
  file                  Files to load after starting the application.

optional arguments:
  --version             show program's version number and exit
  --external-backend    Use an externally started backend instead of starting it automatically. This is a debug feature to make it possible to run the engine with debug options
                        enabled.
  --headless            Hides all GUI elements.
  --debug               Turn on the debug mode by setting this option.
  -qmljsdebugger QMLJSDEBUGGER
                        For Qt's QML debugger compatibility
  --help, -h            Show this help message and exit.
  --single-instance
  --trigger-early-crash
                        FOR TESTING ONLY. Trigger an early crash to show the crash dialog.

CuraEngine
====

CuraEngine connect <host>[:<port>] [-j <settings.def.json>]
  --connect <host>[:<port>]
        Connect to <host> via a command socket, 
        instead of passing information via the command line
  -v
        Increase the verbose level (show log messages).
  -m<thread_count>
        Set the desired number of threads. Supports only a single digit.

CuraEngine slice [-v] [-p] [-j <settings.json>] [-s <settingkey>=<value>] [-g] [-e<extruder_nr>] [-o <output.gcode>] [-l <model.stl>] [--next]
  -v
        Increase the verbose level (show log messages).
  -m<thread_count>
        Set the desired number of threads.
  -p
        Log progress information.
  -j
        Load settings.def.json file to register all settings and their defaults.
  -s <setting>=<value>
        Set a setting to a value for the last supplied object, 
        extruder train, or general settings.
  -l <model_file>
        Load an STL model. 
  -g
        Switch setting focus to the current mesh group only.
        Used for one-at-a-time printing.
  -e<extruder_nr>
        Switch setting focus to the extruder train with the given number.
  --next
        Generate gcode for the previously supplied mesh group and append that to 
        the gcode of further models for one-at-a-time printing.
  -o <output_file>
        Specify a file to which to write the generated gcode.

The settings are appended to the last supplied object:
CuraEngine slice [general settings] 

        -g [current group settings] 
        -e0 [extruder train 0 settings] 
        -l obj_inheriting_from_last_extruder_train.stl [object settings] 
        --next [next group settings]
        ... etc.

In order to load machine definitions from custom locations, you need
 to create the environment variable CURA_ENGINE_SEARCH_PATH, 
 which should contain all search paths delimited by a (semi-)colon.


(.venv) rich@rich-amd-5600x-b550M:~/code/arubanie$ CuraEngine slice -l small_pivot.stl -o small_pivot.gcode 

Cura_SteamEngine version 4.4.1
Copyright (C) 2019 Ultimaker

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
[ERROR] Trying to retrieve setting with no value given: 'mesh_rotation_matrix'




 CuraEngine slice -l small_pivot.stl -o small_pivot.gcode -j  /home/rich/.local/share/Creality/Creative3D/sliceconfig/default/fdm.def.json

 CuraEngine slice -j  fdmprinter.def.json  -o small_pivot.gcode -l small_pivot.stl

 echo "CuraEngine slice -o small_pivot.gcode -l small_pivot.stl " $(cat cura_options.txt) > ce_cmd.sh


 You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
[ERROR] Couldn't find definition file with ID: fdmextruder
[ERROR] Couldn't open JSON file: 
[WARNING] Unrecognized data type in JSON setting machine_disallowed_areas
[WARNING] Unrecognized data type in JSON setting nozzle_disallowed_areas
[WARNING] Unrecognized data type in JSON setting machine_head_with_fans_polygon
[ERROR] Trying to retrieve setting with no value given: 'extruder_nr'




$ ls -l cura-engine-wrapper.* test*
-rwxr-xr-x 1 erwin users 10437 Jul 25 09:37 cura-engine-wrapper.py
-rwxr-xr-x 1 erwin users   505 Jul 25 09:18 cura-engine-wrapper.sh
-rw-r--r-- 1 erwin users  1755 Jul 25 09:11 test.stl

$ curaDir=/opt/cura
$ export PYTHONPATH="${curaDir}/lib/python3/dist-packages"
$ export LD_LIBRARY_PATH="${curaDir}/lib"

$ ./cura-engine-wrapper.py "/opt/cura" "Ultimaker 2 0.80" "advance_08" "test.stl" "test.gcode" "{'infill_sparse_density':25,'gradual_infill_steps':4}"

$ ./cura-engine-wrapper.py "/opt/cura" "Ultimaker 2 0.80" "advance_08" "test.stl" "test.gcode" "{'infill_sparse_density':25,'gradual_infill_steps':4}"


./cura-engine-wrapper.py <cura-install-folder> <printer-profile-name> <material-profile-name> <stl-inputfile> <gcode-outputfile> [<additionalSettings>]

./cura-engine-wrapper.py  "$HOME/.local/share/cura" "Creality CR-10" "Generic PLA" small_pivot.stl small_pivot.gcode


cura-engine-wrapper.py "$HOME/.local/share/cura" -l

creality_cr6se.def.json

/home/rich/.local/share/cura/4.4
set CURA_ENGINE_SEARCH_PATH=/home/rich/code/arubanie:$HOME/.local/share/cura/4.4

122 export CURA_ENGINE_SEARCH_PATH=/home/lrr/workspace/Cura/resources/definitions:/home/lrr/workspace/Cura/resources/extruders
123 export PATH=$CURA_ENGINE_SEARCH_PATH:$PATH

export CURA_ENGINE_SEARCH_PATH=$HOME/code/resources/definitions:$HOME/Cura/resources/extruders
CuraEngine slice -p -j creality_cr6se.def.json -o small_pivot.gcode -l small_pivot.stl  $(cat cura_options.txt) 


meshfix_maximum_deviation="0.05"



# -- slicer independent settings

machine-name = "Creality CR-6 SE"
machine-width = 235
machine-depth = 235
machine-height = 250

filament-diameter = 1.75
nozzle-diameter = 0.4
layer-height = 0.20

fill-density = 20

temperature = 200
first-layer-temperature = 210
bed-temperature = 60

first-layer-height = 0.25
first-layer-speed = 20

skirts = 2
brims = 0
rafts = 0

support = none
support_angle = 60

seam = aligned

# -- init values so no warnings are thrown
top-thickness = 0.8
bottom-thickness = 0.8
wall-thickness = 1.2

perimeters = 3
top-layers = 4
bottom-layers = 4

# -- Note: either define z_offset for each slicer (cura 3.5.x doesn't have this feature yet) OR define M206 Z0.15
start-gcode = "G28 X0 Y0\nG1 X100 F6000\nG28 Z0\nM206 X0 Y-25 Z0.15\n"
end-gcode = "G1 Y290 F6000\nM104 S0\nM140 S0\nM84\n"
abort-gcode ="M104 S0 ; extruder heater off\nM140 S0 ; heated bed heater off (if you have it)\nG1 X10 F9000 ; go way to the left\nM84     ; motors off\n"

retraction-length = 2

print-speed = 50
travel-speed = 130

perimeter-speed = 50
small-perimeter-speed = 15

infill-speed = 80
bridge-speed = 60
retract-speed = 40

extruders-count = 1

cool_fan_speed = 100
cool_fan_speed_min = 30
cool_fan_speed_max = 100


export PRINT3R printer=cr_6_se
print3r --printer=cr_6_se --output=small_pivot.gcode slice   --slicer=cura small_pivot.scad

print3r  --output=small_pivot.gcode slice   --slicer=cura small_pivot.scad

