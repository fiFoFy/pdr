#!/usr/bin/env bash

converted=0
files=0
for file in assets/images/*.jpg
do
    if [ ! -f "assets/questions/${file##*/}" ]
    then
        convert $file -quality 75 "assets/questions/${file##*/}"
        converted=$((converted + 1))
    fi
    files=$((files + 1))
done
echo $converted of $files converted
