if {![package vsatisfies [package provide Tcl] 8.6]} {return}
package ifneeded tclinstall 0.2.0 [list source [file join $dir tclinstall.tcl]]

