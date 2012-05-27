#!/bin/bash

cd $( dirname "${BASH_SOURCE[0]}" )

find . -name "*.applescript" -print0 | while read -d $'\0' file
do
    osacompile -o "../Contents/${file%applescript}scpt" "$file"
done

