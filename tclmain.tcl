#!/usr/bin/env tclsh

#' usage: tclmain [-h] [-m pkgname command ?arg1 arg2 ...?]
#'                [-i pkgname]
#' 
#' Running Tcl application directly from packages.
#' 
#' positional arguments (require -m):
#'   pkgname               name of a Tcl/Tk package
#'   cmd                   name of a command such as main, help or demo
#'   arg1, arg2, ...       additional commands submitted to the Tcl application
#' 
#' options:
#'   -h, --help            show this help message and exit
#'   -i, --info            show package version and location and exit
#'   -m, --module          run the given command in the Tcl package `pkgname`
#'   -p, --package         handled like options -m, --main
#'   -i, --info
#' 
#' author:                 Detlef Groth, Schwielowsee, Germany
#'
#' license:                BSD 
#' 

namespace eval ::tclmain { }

#' ::tclmain::usage filename {all true}
#' 
#' Args: 
#'     - filename - the script filename to be search for mkdoc comments
#'     - all      - should all lines or just the first,  usually the
#'                  the usage line been show, default: true
#' 
#' Returns: usage string
#' 

proc ::tclmain::usage {filename {all true}} {
    set usage ""
    set flag false
    if [catch {open $filename r} infh] {
        puts stderr "Cannot open $filename: $infh"
        exit
    } else {
        while {[gets $infh line] >= 0} {
            if {$all && $flag && [regexp {^$} $line]} {
                break
            } elseif {!$all && $flag && [regexp {^#' *$} $line]} {
                break
            } elseif {[regexp {^#'} $line]} {
                set flag true
                append usage [regsub {^#'\s?} $line {}]
                append usage "\n"
            }
        }
        close $infh
    }
    return $usage
}

proc ::tclmain::parseArgs {} {
    global argv0
    global argv
    if {[llength $argv] == 0 || [lindex $argv 0] in [list "-h" "--help"]} {
        puts -nonewline [::tclmain::usage [info script]]
        exit 0
    }
    if {[llength $argv] > 1 && [lindex $argv 0] in [list "-m" "--module" "-p" "--package" "-i" "--info"]} {
        catch {
            set stat(version) [package require [lindex $argv 1]]
        }
        if {![info exists stat(version)]} {
            puts [tclmain::usage [info script] false]
            puts "Error: package [lindex $argv 1] does not exists!"
            exit  0
        }
        set stat(location) [lindex [package ifneeded [lindex $argv 1] $stat(version)] 1]
        set stat(package) [lindex $argv 1]
        if {[lindex $argv 0] in [list "-i" "--info"]} {
            puts "package:  [lindex $argv 1]"
            puts "version:  $stat(version)"
            puts "location: [file dirname $stat(location)]"
            exit 0
        }
        set pname [regsub -all {::} $stat(package) "_"]
        set pattern ${pname}_*{.tcl,.tm}
        set files [glob -nocomplain -directory [file dirname $stat(location)] \
                   -types f $pattern]
        puts $files
        set cmds [list]
        if {[llength $files] > 0} {
             foreach f $files {
                 set cmd [regsub {.+_([a-z0-9]{2,6}).[tclm]{2,3}} $f "\\1"]
                 if {$cmd in [list help demo main] || [string length $cmd] <= 3} {
                     set argv0 $f
                     lappend cmds $cmd
                     set src($cmd) $f
                 }
             }
         }
         if {[llength $cmds] == 0} {
             puts "Package $stat(package) provides no commands.\n"
         } else {
             if {[llength $argv] == 2} {
                 puts "Missing command for package $stat(package)."
                 puts "Available commands are: [join $cmds ,]"
                 exit 0
             } else {
                 # command given
                 set cmd [lindex $argv 2]
                 set argv [lrange $argv 3 end]
             }
             if {[info exists src($cmd)]} {
                 # valid command
                 set argv0 $src($cmd)
                 source $src($cmd)
             } else {
                 puts "Wrong or missing command for package $stat(package)."
                 puts "Available commands are: [join $cmds ,]"
             }
         }
    }
}
if {[info script] eq $argv0} {
    ::tclmain::parseArgs
}
