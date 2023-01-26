#!/usr/bin/env tclsh

foreach folder $auto_path {
    set demo [file join $folder demos widget]
    if {[file exists $demo]} {
        source $demo
        break
    }
}
