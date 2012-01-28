# Description

This is a collection of scripts and clippings used to write Latex in BBEdit.

You can download the package at <http://nb.nathanamy.org/latex-bbpackage> or
the git repository at <http://github.com/nathan11g/Latex.bbpackage>

# Installation

If you are using BBEdit 10.1 or newer, you can drag the `Latex.bbpackage`
package onto the BBEdit dock icon, and it will install it for you.

Or you can clone the git repository from the command line

    $ cd Library/Application\ Support/BBEdit/
    $ mkdir Packages # if it doesn't already exist
    $ cd Packages
    $ git clone git://github.com/nathan11g/Latex.bbpackage.git

Since, at that point, you're already in the proper directory, you may want to
open up the README markdown document, and INSTALL shell worksheet (to install
software this package depends on)

	$ bbedit Latex.bbpackage/readme.md
	$ bbedit Latex.bbpackage/install.worksheet


# Scripts

The following scripts are written by Nathan Grigg, unless otherwise noted.

### Typeset Latex

This AppleScript typesets your Latex document and opens the pdf file.

By default, the script uses [Skim][1] to view the pdf, although you can change
this. It looks for Latex executables in `/usr/texbin`, which is where
[MacTeX][2] installs them by default. If necessary, you can change these
defaults by editing the beginning of the script.

Usually, the script uses `pdflatex` to typeset your document, but this can
be changed by including a `program` directive at the beginning of your document.
If you are using multiple files to organize your Latex markup, you can also use
a `root` directive. For example:

	% !TEX program = xelatex
	% !TEX root = main.tex

If there is a typesetting error, the script will try to take you to the place
in your document where the error occurred. For this, the script
searches through the log file using code from the [rubber][3] project by
Emmanuel Beffara.


### Open pdf

This AppleScript opens the pdf file corresponding to your Latex document.

By default, the script uses [Skim][1] and tries to find the place in the pdf
that corresponds to your current cursor position in the Latex file. If you want
to change the viewer, you can edit the first lines of the script.

### Show log warnings and errors

This searches through the log file for warnings and errors and displays them
in a BBEdit results browser. It uses code from the [rubber][3] project to parse
the log file.

### Check Latex Semantics

This is a script by Ramón M. Figueroa-Centeno that invokes [ChkTeX][4] on your
document and displays the results in a BBEdit results browser. You need to have
ChkTeX installed for this to work. ChkTeX is included in the MacTeX package.

### Declare Math Operator

This applescript prompts for the two arguments of the `\DeclareMathOperator`
command, and then inserts the appropriate command in the preamble, all without
losing your place in the document.


### Insert KOMAoptions

For users of [KOMA-script][5], this script brings up a list of all the most
useful KOMA options. You can select one or more, and it will insert a
`\KOMAoptions` command into the document.

### TeX Documentation Lookup

Type in the name of a package, and this script will attempt to find the
documentation file, using `texdoc`.

### Typeset inserting gitinfo

If the document is part of a git repository, this script defines a command
`\RevisionInfo` that prints the current git revision information. It then
typsets the document and then deletes the command.

To make this useful to you, you will need to put the `\RevisionInfo` command
somewhere in your document (e.g. in a header or watermark). Furthermore, you
should include the command `\providecommand{\RevisionInfo}{}`, which will cause
`\RevisionInfo` to be blank unless otherwise defined.

The idea is that when you usually typeset, the info will not be printed. Only
under certain circumstances (e.g. you are going to print it out or email it to
someone) do you want to include the revision information. One benefit to this
method is that if someone else needs to typeset the document and they do not
have the full git repository or even know what git is, everything will work.

# Clippings

Clippings do not have backslashes in their names, but they do have backslashes
in their definitions. So if you begin typing `mathbb` and then select the
correct clipping, `\mathbb{}` will be inserted. On the other hand, if you begin
typing `\mathbb` and then select the clipping, the result will be `\\mathbb{}`,
which is not correct.

The purpose of the package is to make things easier to typeset Latex using
BBEdit. The purpose is not to make a complete catalog of all commonly used latex
commands.

In particular, commands without arguments such as `\alpha` or `\times` are
almost never included as clippings. The reason is that BBEdit automatically
suggests words that you have been using in your document, which is more likely
to be helpful than a list of all possible keywords.

Also included are commands that may be useful, but only once in a while, so that
you are likely to forget their names or how to use them. (such as accents and
matrices). Commands which lend themselves well to keyboard shortcuts (such as
`inverse`, `mathbb`, and `display math`) are included as well. You are
responsible for setting your own keyboard shortcuts using the clippings palette.

# License

(also known as the New BSD License)

Copyright (c) 2011-2012, Nathan Grigg
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


[1]: http://skim-app.sourceforge.net/
[2]: http://www.tug.org/mactex/
[3]: https://launchpad.net/rubber/
[4]: http://baruch.ev-en.org/proj/chktex/
[5]: http://www.ctan.org/tex-archive/macros/latex/contrib/koma-script/
