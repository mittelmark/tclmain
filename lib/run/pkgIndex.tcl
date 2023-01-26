if {![package vsatisfies [package provide Tcl] 8.4]} {return}
package ifneeded dg::run 0.1 [list source [file join $dir run.tcl]]
