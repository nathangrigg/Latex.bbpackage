#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"

for f in *.applescript
do
	osacompile -o "../Contents/Scripts/${f%.applescript}.scpt" "$f"
done
