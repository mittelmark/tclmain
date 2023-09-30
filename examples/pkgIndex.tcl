if {![package vsatisfies [package provide Tcl] 8.6]} {return}

package ifneeded testx  0.0.1 [list source [file join $dir testx.tcl]]
