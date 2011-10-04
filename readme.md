# Description

This is a collection of tools that I used to write Latex in BBEdit.

# Installation

Place the package `Latex.bbpackage` in
`~/Library/Application Support/BBEdit/Packages/`.

Alternatively, you can look into the package on only install
the pieces that you want.

# Tools

## Declare Math Operator applescript

This applescript prompts for the two arguments of the `\DeclareMathOperator`
command, and then inserts the appropriate command in the preamble, all without
losing your place in the document.

## Typeset with TeXShop applescript

This opens the pdf version of your Latex document using TeXShop and asks
TeXShop to typeset it.

TeXShop needs to be installed on your computer.

For best results, you should check the box marked "Configure for External
Editor" in the "On Startup" section of the "Source" tab of the TeXShop
preferences.
