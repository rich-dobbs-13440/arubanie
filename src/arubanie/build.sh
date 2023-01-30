#!/usr/bin/env bash


set -x
set -e


function build() {
    file=$1
    filename=basename filename .scad
    stl_file="${filename}.stl"
    echo ${stl_file}
    #openscad -D show_name=true -o "../../../build/${stl_file}" ${file}
    echo "Elapsed Time: $SECONDS seconds"
}

for file in "*.scad"; do 
   build() "${file}" 
done