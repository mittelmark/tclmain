#!/usr/bin/env tclsh

namespace eval ::dg::run { }

proc ::dg::run::main {argv} {
    puts "this is ::dgw::run::main $argv"
}

package provide dg::run 0.1
    
