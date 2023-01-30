# setup file for tclinstall
# using tclmain and installed tclinstall
# you can install it with:
# tclmain -m tclinstall path-to/lib/setup-tclinstall.tcl

array set setup {
   name tclinstall   
   version 0.1
   url https://github.com/mittelmark/tclmain/lib/tclinstall
   author {Detlef Groth}
   license {BSD 3.0}
   include {tclinstall/*.tcl tclinstall/tclinstall.md}
}


