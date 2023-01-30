# setup file for tclinstall
# using tclmain and installed tclinstall
# if tclinstall and tclmain are installed you can update it with:
# tclmain -m tclinstall path-to/lib/setup-tclinstall.tcl
# if tclinstall is not yet installed (chicken and egg problem)
# you can add the package folder to the TCLLIB PATH before like this:
# export TCLLIBPATH=/path-to-package-parent-folder/ and then
# tclmain -m tclinstall path-to/lib/setup-tclinstall.tcl
array set setup {
   name tclinstall   
   version 0.1
   url https://github.com/mittelmark/tclmain/lib/tclinstall
   author {Detlef Groth}
   license {BSD 3.0}
   include {tclinstall/*.tcl tclinstall/tclinstall.md}
}


if {$::argv0 eq [info script]} {
    # just required for tclinstall itself
    # to solve the chicken and egg problem
    lappend auto_path [file dirname [info script]]
    package require tclinstall
    set ::argv0 tclinstall
    tclinstall::install [info script]
}
