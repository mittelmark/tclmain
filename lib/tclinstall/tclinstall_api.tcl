#!/usr/bin/env tclsh

if {[llength $argv] > 0 && "--nocolor" in $argv} {
    set color false
} else {
    set color true
}
set filename [regsub {_api.tcl} [info script] .tcl]

if [catch {open $filename r} infh] {
    puts stderr "Cannot open $filename: $infh"
    exit
} else {
    set example false

    while {[gets $infh line] >= 0} {
        if {[regexp {^\s*#'} $line]} {
            set nline [regsub {^\s*#' ?} $line ""]
            if {$color} {
                if {![regexp {^#} $nline]} {
                    set nline "  $nline"
                }
                set nline [regsub {^(#.+)} $nline "\033\[01;36m\\1\033\[0m"]
                set nline [regsub {(\*\*.+?\*\*)} $nline "\033\[01;33m\\1\033\[0m"]
                set nline [regsub {(__.+?__)} $nline "\033\[01;33m\\1\033\[0m"]
                set nline [regsub {( [\*_][^\s*_].+?[\*_])} $nline "\033\[01;34m\\1\033\[0m"]
                set nline [regsub {^> } $nline "  "]
                if {$example && [regexp {^ {0,4}```} $nline]} {
                    set nline "$nline\033\[0m"
                    set example false
                } elseif {[regexp {^ {0,4}```} $nline]} {
                    set nline "\033\[01;31m$nline"
                    set example true
                }
            }
            puts stdout $nline
        }
    }
    close $infh
}
