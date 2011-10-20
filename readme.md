# Description

This is a collection of clippings and scripts that I used to write Latex in BBEdit.

# Installation

If you are using BBEdit 10.1 or newer, you can drag the package `Latex.bbpackage` onto the BBEdit dock icon, and it will install
it for you.

If you are using BBEdit 10 or newer, you can put the package
`Latex.bbpackage` into the folder `~/Library/Application Support/BBEdit/Packages/`.

If you are using a version of BBEdit less than 10, you can look into
the package and install the pieces in the appropriate locations
within `~/Library/Application Support/BBEdit/`. I have not tested
any of the scripts with versions of BBEdit less than 10.

# Philosophy

The purpose of the package is to make things easier for me (and you) to
typeset Latex using BBEdit. The purpose is not to make a complete catalog
of all commonly used latex commands.

In particular, commands without arguments such as `\alpha` or `\times` are almost never included as clippings. The reason is that BBEdit automatically
suggests words that you have been using in your document, which is more
likely to be helpful than a list of all possible keywords.

I also like to include commands that may be useful, but only once in a
while, so that you are likely to forget their names or how to use them.
(For me, accents and matrices fall into this category.) I also include
commands which lend themselves well to keyboard shortcuts (such as `inverse`, `mathbb`, and `display math`). You are responsible for setting your own
keyboard shortcuts using the clippings palette.

If you have anything that you think I should add, feel free to contact me.

**A note on using clippings:**
Clippings do not have backslashes in their names, but they do have
backslashes in their definitions. So if you begin typing `mathbb` and
then select the correct clipping, `\mathbb{}` will be inserted. On the
other hand, if you begin typing `\mathbb` and then select the clipping,
the result will be `\\mathbb{}`, which is not correct.

# Scripts

I find the following scripts useful. They are written by me unless otherwise
noted.

## Typeset with TeXShop

This opens the pdf version of your Latex document using TeXShop and asks
TeXShop to typeset it.

TeXShop needs to be installed on your computer.

For best results, you should check the box marked "Configure for External
Editor" in the "On Startup" section of the "Source" tab of the TeXShop
preferences.

## Declare Math Operator

This applescript prompts for the two arguments of the `\DeclareMathOperator`
command, and then inserts the appropriate command in the preamble, all without
losing your place in the document. Definitely worth a keyboard shortcut.

## TeX Documentation

Type in the name of a package, and this script will attempt to find the documentation file, using `texdoc`.

## Insert KOMAoptions

This script brings up a list of all the most useful KOMA options. You can select one or more, and it will insert a `\KOMAoptions` command into the document.

## Typeset inserting gitinfo

If the document is part of a git repository, this script defines a command `\RevisionInfo` that prints the current git revision information. It then typsets the document and then deletes the command.

To make this useful to you, you will need to put the `\RevisionInfo` command somewhere in your document (e.g. in a header or watermark). Furthermore, you should include the command `\providecommand{\RevisionInfo}{}`, which will cause `\RevisionInfo` to be blank unless otherwise defined.

The idea is that when you usually typeset, the info will not be printed. Only under certain circumstances (e.g. you are going to print it out or email it to someone) do you want to include the revision information. One benefit to this method is that if someone else needs to typeset the document and they do not have the full git repository or even know what git is, everything will work.

This also requires TeXShop to be installed on your computer.

## Check Latex Syntax

This is a script by Ramón M. Figueroa-Centeno that invokes ChkTeX on your document and displays the results in a nice format. You need to have ChkTeX installed for this to work. (For more information on ChkTeX, see
<http://baruch.ev-en.org/proj/chktex/>.) ChkTeX is included in the TeXLive package. Alternatively, if you use homebrew, you can install it using `brew install chktex`.

# License

(also known as the New BSD License)

Copyright (c) 2011, Nathan Grigg
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of this package nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

This software is provided by the copyright holders and contributors "as is" and
any express or implied warranties, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose are
disclaimed. In no event shall Nathan Grigg be liable for any
direct, indirect, incidental, special, exemplary, or consequential damages
(including, but not limited to, procurement of substitute goods or services;
loss of use, data, or profits; or business interruption) however caused and
on any theory of liability, whether in contract, strict liability, or tort
(including negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.
