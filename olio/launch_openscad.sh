#!/usr/bin/env bash

set -x
set -e

openscad   "$1"

# openscad  -o test.stl  -p test_small_pivot_vertical.json -P fred test_small_pivot_vertical.scad



curl -k4 --request POST -H 'X-Api-Key: REDACTED' -H 'Content-Type: application/json' --data '{"command":"select","print":true}' http://charming-pascal.local/api/files/local/UnderTop.gcode