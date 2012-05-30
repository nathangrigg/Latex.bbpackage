# Description

A collection of scripts and clippings used to write Latex in BBEdit.

# Installation

## Package only

Download the package at <http://nb.nathanamy.org/latex-bbpackage>, open
the disk image, and drag the `Latex.bbpackage` package onto the BBEdit
dock icon.

Repeat the process to install an updated version of the package.

Requires BBEdit 10.1 or newer.

## Full git repository

The Latex.bbpackage project is hosted at <http://github.com/nathan11g/Latex.bbpackage>.

Clone the git repository from the command line

    $ cd Library/Application\ Support/BBEdit/
    $ mkdir Packages # if it doesn't already exist
    $ cd Packages
    $ git clone git://github.com/nathan11g/Latex.bbpackage.git

Since, at that point, you're already in the proper directory, you may want to
open up the README markdown document, and INSTALL shell worksheet (to install
software this package depends on)

	$ bbedit Latex.bbpackage/readme.md
	$ bbedit Latex.bbpackage/install.worksheet

Use `git pull` to download an updated version of the package.


# Contents

## Scripts

The package include scripts to typeset Latex, view pdf (with forward search),
change environment, star/unstar environment, show errors and warnings from log,
and more.

For more details, see the [Latex.bbpackage wiki][wiki].

## Clippings

The package includes clippings to insert an arbitrary environment, close the
current environment, and many more.

For details and descriptions of the clippings,
see the [Latex.bbpackage wiki][wiki].

## Stationery

The package includes basic templates for math documents, text documents,
envelopes, labels, letters, and xelatex documents.

For more details, see the [Latex.bbpackage wiki][wiki].


# Acknowledgments

The typeset script is made possible by code from the [rubber][rubber]
project by Emmanuel Beffara. The "Check Latex Semantics" script is written
by Ramón M. Figueroa-Centeno.


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

[rubber]: https://launchpad.net/rubber/
[wiki]: https://github.com/nathan11g/Latex.bbpackage/wiki
