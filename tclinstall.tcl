#!/usr/bin/env tclsh
# WIP - not ready to use
#' ---
#' title: Install Tcl packages 
#' author: Detlef Groth, Caputh-Schwielowsee
#' date: <230130.0709>
#' ---
#' 
#' # NAME
#' 
#' `tclinstall` - installation of Tcl packages using setup.tcl files.
#' 
#' # DESCRIPTION
#' 
#' The Tcl application *tclinstall* installs Tcl packages into standard locations.
#' If the users then uses the application *tclmain* to start its Tcl scripts they
#' package should be automatically in the Tcl package path. The application requires
#' a file setup.tcl to to work reliable. In most cases however if given only a
#' directory name it should be as well possible to copy this directory into the
#' right folder. Package files can be as well in zip-archives where for the required
#' files, setup.tcl or pkgIndex.tcl is searched then automatically.. 
#' 
#' # USAGE
#' 
#' ```
#' tclinstall setup.tcl
#' tclinstall . 
#' tclinstall folder
#' tclinstall package-main.zip
#' ```
#' 
#' Or using `tclmain`
#' 
#' ```
#' tclmain -m tclinstall setup.tcl
#' tclmain -m tclinstall .
#' ```
#' 
#' # EXAMPLE SETUPFILE
#' 
#' Here a setup.tcl file:
#' 
#' ```
#' # setup file for tclinstaller.tcl
#' 
#' array set setup {
#'   name kroki4tcl
#'   version 0.4.0
#'   url https://github.com/mittelmark/kroki4tcl
#'   author {Detlef Groth}
#'   license {BSD 3.0}
#'   include {kroki4tcl/*.tcl kroki4tcl/kroki4tcl.md}
#' }
#' ```
#'
#' If no `setup.tcl` is found the folder which contain pkgIndex.tcl files simply
#' will copied to the appropiate directories.
#' 
#' # AUTHOR AND LICENSE
#' 
#' Detlef Groth, Schwielowsee, Germany, BSD 3
#' 

namespace eval ::tclinstall { 
    variable script 
    set script [info script]
}

proc ::tclinstall::usage {} {
    puts "Usage: $::argv0 ? DIRECTORY | SETUPFILE] ZIPFILE?"
}

proc ::tclinstall::help {} {
    variable script
    if [catch {open $script r} infh] {
        puts stderr "Cannot open $script $infh"
        exit
    } else {
        set flag false
        while {[gets $infh line] >= 0} {
            if {$flag && [regexp {^\s*$} $line]} {
                break
            }
            if {[regexp {^#'} $line]} {
                set flag true
            }
            if {$flag} {
                set nline [regsub {^#' ?} $line ""]
                puts $nline
            }
        }
        close $infh
    }
}
proc ::tclinstall::parseArgs {argv} {
    # TODO: 
    #   - multiple files
    #   - https addresses using wget or Python
    #   - git repos using git
    if {[llength $argv] == 1 && [file extension [lindex $argv 0]] eq ".zip"} {
        set setupfile [unzipSetup [lindex $argv 0]]
        return $setupfile
    }
    if {[llength $argv] < 1 && [file tail [lindex $argv 0]] ne "setup.tcl"} {
        puts "Usage: $::argv0 setup.tcl"
        puts "where setup.tcl is in the parent folder of the package"
        exit 0
    }
    set setupfile [lindex $argv 0]
    if {![file exists $setupfile]} {
        puts "Error: File '$setupfile' does not exists!"
        exit 0
    }
    return $setupfile
}
proc ::tclinstall::install {setupfile} {
    source $setupfile
    set owd [pwd]
    cd [file dirname $setupfile]
    set files [list]
    foreach f $setup(include) {
        foreach file [glob -nocomplain $f] {
            lappend files $file
        }
    }
    if {[llength $files] < 1} {
        puts "Error: No files in $setup(include) found!"
        exit 0
    }
    puts "Installation"
    puts "    Package: $setup(name) version: $setup(version)"
    puts "    Author:  $setup(author)"
    puts "    License: $setup(license)"
    puts "    URL:     $setup(url)"
    puts "    Files:"
    foreach file $files {
        puts  "       $file"
    }
    
    # TODO: Do platform specific checks, windows, osx etc.!
    
    set targetdir [file join $::env(HOME) .local lib $setup(name)]
    puts -nonewline "Install these files into $targetdir (yes|no): " 
    flush stdout

    set answer [gets stdin]
    
    if {[regexp -nocase {^ye?s?} $answer]} {
        if {[file exists $targetdir]} {
            puts -nonewline "Folder $targetdir already exists! Overwrite this folder (yes|no): " 
            flush stdout
            set answer [gets stdin]
            if {[regexp -nocase {^ye?s?} $answer]} {
                file delete -force $targetdir
            } 
        }
    } 

    if {[regexp -nocase {^ye?s?} $answer]} {
        file mkdir $targetdir
        foreach file $files {
            set nfile [regsub "$setup(name)" $file $targetdir]
            file copy $file $nfile
        }
    } else {
        puts "Installation canceled!"
        exit 0
    }
    puts "Package files installed into $targetdir!"
    lappend ::auto_path [file join $targetdir ..]
    package require $setup(name)
    
    puts "Success: package $setup(name) [package present $setup(name)] is installed!"  
    cd $owd
}

proc ::tclinstall::unzipSetup {zipfile} {
    # TODO: check for package
    # if not available use Python ur unzip
    package require zipfile::decode
    ::zipfile::decode::open $zipfile
    set archiveDict [::zipfile::decode::archive]
    ::zipfile::decode::unzip $archiveDict setup-tcl
    ::zipfile::decode::close
    set setup [glob -nocomplain setup-tcl/setup.tcl]
    if {[llength $setup] == 0} {
        set setup [glob -nocomplain setup-tcl/*/setup.tcl]
    }
    if {[llength $setup] > 0} {
        # TODO: multiple files in zip
        puts "setupfound in zip [lindex $setup 0]"
        return $setup
    } else {
        return [list]
    }
}

proc ::tclinstall::main {argv} {
    if {"-h" in $argv || "--help" in $argv} {
        ::tclinstall::help 
        exit 0
    }
        
    set setupfiles [tclinstall::parseArgs $argv]
    foreach setupfile $setupfiles {
        tclinstall::install $setupfile
    }
}

::tclinstall::main $argv
