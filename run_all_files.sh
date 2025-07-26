#! /bin/bash

#To run all the files in the folder to run stop_find.sh run

shopt -s nullglob

filename=$1

for file in "$filename"/* .fna; do
    if [[ -f "$file" && "$file" == *.fna ]]; then
        ./stop_find.sh "$file"
    fi
done
