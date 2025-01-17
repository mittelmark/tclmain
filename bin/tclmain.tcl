#!/usr/bin/env tclsh
# This file should be named executable using chmod and renamed to tclmain
# moved thereafter to a folder belonging to your PATH variable
# 
#' usage: tclmain [-h|-v] [-m|-p pkgname command ?arg1 arg2 ...?]
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
#' 
#' author:                 Detlef Groth, Schwielowsee, Germany
#'
#' license:                BSD-3-Clause license
#' 
#' version:                0.2.1
#' 
package provide tclmain 0.2.1

namespace eval ::tclmain { 
    # check if in parent folder or in parent/lib are Tcl packages and
    # append this folder to the PATH
    set libdir [file normalize [file join [file dirname [info script]] .. lib]]
    if {[file exists $libdir] && $libdir ni $::auto_path} {
        lappend ::auto_path $libdir
    }
    
    set parentdir [file normalize [file join [file dirname [info script]] ..]]
    
    set files [glob -nocomplain [file join [file normalize $parentdir] * pkgIndex.tcl]]
    
    if {[llength $files] > 0 && $parentdir ni $::auto_path} {
        lappend ::auto_path $parentdir
    }
}

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
    if {[llength $argv] == 1 && [lindex $argv 0] in [list "-v" "--version"]} {
        puts "tclmain.tcl version: [package provide tclmain]"
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
        set cfiles [glob -nocomplain -directory [file join $::env(HOME) .config tclmain] \
                    -types f $pattern]
        foreach f $files {
            lappend cfiles $f
        }
        set files $cfiles
        set cmds [list]
        if {[llength $files] > 0} {
             foreach f $files {
                 set cmd [regsub {.+_([a-z0-9]{2,6}).[tclm]{2,3}} $f "\\1"]
                 if {$cmd in [list help demo main install] || [string length $cmd] <= 8} {
                     if {![info exists src($cmd)]} {
                         set argv0 $f
                         lappend cmds $cmd
                         set src($cmd) $f
                     }
                 }
             }
         }
         if {[llength $cmds] == 0} {
             ## check main function in package
             set package [lindex $argv 1]
             if {[info commands ::${package}::main] ne ""} {
                 if {[info args ${package}::main] eq "argv"} {
                     ::${package}::main [lrange $argv 2 end]
                     return
                 }
             }
         } else {
             if {[llength $argv] == 2} {
                 puts "Missing command for package $stat(package)."
                 puts "Available commands are: [join $cmds ,]"
                 exit 0
             } else {
                 # command given
                 set cmd [lindex $argv 2]
                 set argv [lrange $argv 3 end]
                 set ::argv $argv
             }
             if {[info exists src($cmd)]} {
                 # valid command
                 set ::argv0 $src($cmd)
                 uplevel 1 "source $src($cmd)"
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
