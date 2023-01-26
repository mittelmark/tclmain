# tclmain

Standalone script to run Tcl applications from packages using the - tclmain pkgname - syntax.

This Tcl application provides a facility to run Tcl applications, display help pages and show demo applications
for Tcl packages, similar like the Python `__main__.py` file is doing this in a Python package. 
In Python, if your provide a file `__main__.py` within your package, you can exectute this file directly using the syntax: `python -m pkgname`.
The Tcl script `tclmain` will do a similar thing.

## Examples

Here is an example on how to execute programs or get help pages by a user or developer if a package developer used this facilities by creating several files in his/her package folder. These files `tclmain_xyz.tcl` needs not to be sourced in the `pkgIndex.tcl` file.

* `tclmain` - gives the help message
* `tclmain -h, --help` - gives the help message
* `tclmain -m, --module pkgname` - lists the available commands for the package `pkgname`
* `tclmain -p, --package pkgname` - lists the available commands for the package `pkgname`
* `tclmain -p pkgname main` - executes the file ending with `_main.tcl` within the package directory
* `tclmain -p pkgname help` - executes the file ending with  `_help.tcl` which should provide the help pages for the packages, or get's a hint of how to get see them
* `tclmain -p pkgname demo` - executes the file ending with `_demo.tcl` which could provide a short demo
* `tclmain -m pkgname xxx` - executes the file ending `_xxx.tcl` and so on, may be this is better implemented as `tclmain pkgname run xxx` so as an command line argument to the `tclmain_run.tcl script`, only three letter commands should be provided

## Config folder 

There should be as well a possibility to provide these facilities if you are
not having access to the package folders. It can't be assumed that a lot of
Tcl packages will offer this functionality at any time soon. In this case you
should be able to place these files witin your own configuration folder like
`~/.config/tclmain/pkgname_main.tcl` or `~/.config/tclmain/pkgname_demo.tcl`
on a Linux/Unix system. That way you can add these facilities to Tcl packages
which does not use the `tclmain` approach. 

Colons in the package name should be replaced in this case with underlines. So
for the package `canvas::zoom` the filename becomes `canvas_zoom_main.tcl` for
instance.

## Tclsh

The Tclsh should provide such an approach using a module/package flag like
Python, for instance `tclsh -m pkgname` or `tclsh -p pkgname`

## Examples

Here a few examples to add this functionality to existing packages. As
`tclmain` strips of the `pkgname` argument, the first argument is run in the
`argv` list.

`ctext/ctext_main.tcl`

```

```
