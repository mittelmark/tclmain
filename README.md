# tclmain

Standalone script to run Tcl applications from packages using the - tclmain pkgname - syntax.

This Tcl application provides a facility to run Tcl applications, display help pages and show demo applications
for Tcl packages, similar like the Python `__main__.py` file is doing this in a Python package. 
In Python, if your provide a file `__main__.py` within your package, you can exectute this file directly using the syntax: `python -m pkgname`.
The Tcl script `tclmain` will do a similar thing.

## Examples

Here is an example on how to execute programs or get help pages by a user or developer if a package developer used this facilities by creating several files in his/her package folder. These files `tclmain_xyz.tcl` needs not to be sourced in the `pkgIndex.tcl` file.

* `tclmain` - list all packages which provides tclmain files or where the user has these files in it's own configuration folder
* `tclmain pkgname` - executes the file `tclmain_run.tcl` within the package directory
* `tclmain pkgname run` - does the same
* `tclmain pkgname help` - executes the file  `tclmain_help.tcl` which should provide the help pages for the packages, or get's a hint of how to get see them
* `tclmain pkgname demo` - executes the file `tclmain_demo.tcl` which could provide a short demo
* `tclmain pkgname xxx` - executes the file `tclmain_xxx.tcl` and so on, may be this is better implemented as `tclmain pkgname run xxx` so as an command line argument to the `tclmain_run.tcl script`

There should be as well a possibility to provide these facilities if you are not having access to the package folders. It can't be assumed that a lot of Tcl packages will offer this functionality at any time soon. In this case you should be able to place these files witin your own configuration folder like `~/.config/tclmain/pkgname` on a Linux/Unix system. That way you can add these facilities to Tcl packages which does not use `tclmain` approach.

## Tclsh

The Tclsh should provide such an approach using a module/package flag like Python, for instance `tclsh -m pkgname` or `tclsh -p pkgname`

## Examples

Here a few examples to add this functionality to existing packages. As `tclmain` strips of the `pkgname` argument, the first argument is run in the `argv` list.

`ctext/tclmain_run.tcl`

```

```
