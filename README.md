# tclmain

Standalone script to run Tcl applications from packages using the - tclmain pkgname - syntax.

This Tcl application provides a facility to run Tcl applications, display help pages and show demo applications
for Tcl packages, similar like the Python `__main__.py` file is doing this in a Python package. 
In Python, if your provide a file `__main__.py` within your package, you can exectute this file directly using the syntax: `python -m pkgname`.
The Tcl script `tclmain` will do a similar thing.

## Examples

Here is an example on how a package developer could use this facilities by creating several files in his/her package folder. These files
needs not to be sourced in the `pkgIndex.tcl` file.

* `tclmain pkgname` - executes the file `tclmain_run.tcl` within the package directory
* `tclmain pkgname run` - does the same
* `tclmain pkgname help` - executes the file  `tclmain_help.tcl` which should provide the help pages for the packages, or get's a hint of how to get see them
* `tclmain pkgname demo` - executes the file `tclmain_demo.tcl` which could provide a short demo
* `tclmain pknname xxx` - executes the file `tclmain_xxx.tcl` and so on


