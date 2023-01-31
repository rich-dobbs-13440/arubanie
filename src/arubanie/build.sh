#!/usr/bin/env bash


set -x
set -e


function build {
    set +e
    file=$1
    filename=$(basename "$file" .scad)
    stl_file="${filename}.stl"
    set -e
    openscad --hardwarnings -D show_name=true -o "../../build/${stl_file}" "${file}"
    echo "Elapsed Time: $SECONDS seconds"
}

date
SECONDS=0
scad_files="*.scad"
for file in $scad_files; do 
   build "${file}"
done