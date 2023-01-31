#!/usr/bin/env tclsh
# WIP - not ready to use
#' ---
#' title: Install Tcl packages 
#' author: Detlef Groth, Caputh-Schwielowsee
#' license: BSD 3
#' date: <230131.0651>
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
#' a file setup.tcl to work reliable. In most cases however if given only a
#' directory name it should be as well possible to copy this directory into the
#' right folder. Package files can be as well in zip-archives where for the required
#' files, setup.tcl or pkgIndex.tcl is searched then automatically. 
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
#' # setup file for tclinstall package
#' 
#' array set setup {
#'   name kroki4tcl
#'   version 0.4.0
#'   url https://github.com/mittelmark/kroki4tcl
#'   author {Detlef Groth}
#'   license {BSD 3.0}
#'   include {kroki4tcl/*.tcl kroki4tcl/kroki4tcl.md}
#' }
#' 
#' if {$::argv0 eq [info script]} {
#'     # making it a standalone install script
#'     package require tclinstall
#'     set ::argv0 "tclinstall"
#'     tclinstall::install [info script]
#' }
#' ```
#'
#' TODO: If no `setup.tcl` is found the folder which contain pkgIndex.tcl files simply
#' will copied to the appropiate directories.
#' 
#' Author and License: Detlef Groth, Schwielowsee, Germany
#' 

# Space required to stop help page
#' 
#' # API
#' 
#' package tclinstall - install tclpackages using Tcl setup files
#' 
#' ## COMMANDS
#' 
package require Tcl 8.6
package provide tclinstall 0.1
namespace eval ::tclinstall { 
    variable script 
    set script [info script]
}


#' **tclinstall::help**
#' 
#' Prints the extended help page to the terminal.
#' 
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
                if {![regexp {^#} $nline]} {
                    set nline "  $nline"
                }
                puts $nline
            }
        }
        close $infh
    }
}

#' **tclinstall::install** *setupfile*
#' 
#' Installs the package for the given setup file.
#' 

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

#' **tclinstall::installGit** *pkg url*
#' 
#' Install a Tcl package *pkg* for the given *url* using the
#' *git* terminal application.
#' 
#' TODO: implementation

proc ::tclinstall::installGit {pkg url} {
    set base $pkg
    # TODO: check for git
    if {[auto_execok git] eq ""} {
        error "Git is not found! Please install the git terminal application!"
    }
    
    file mkdir git-install
    cd git-install
    set var2 [list git clone $url $base]
    exec >@stdout 2>@stderr {*}$var2
    set dir [lindex [glob *] 0]
    cd $dir
    set setups [glob -nocomplain setup*.tcl]
    puts $setups
    if {[llength $setups] > 0} {
        foreach setup $setups {
            ::tclinstall::install $setup
        }
    }
    cd ..
    cd ..
}    

#' **tclinstall::installZip** *zipfile*
#' 
#' Install Tcl package from the given Zip file. If a URL is
#' given one of the executables *curl*, *wget* or *python* mustg be available.
#  Windows 10: curl.exe --output index.html --url https://superuser.com

proc ::tclinstall::installZip {zipfile} {
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

#' **tclinstall::main** *argv*
#' 
#' Main entry point for the given arguments in argv. 
#' Usually the argv are the command line options for the
#' application.
#' 
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

#'
#' **tclinstall::parseArgs *argv*
#' 
#' Do the command line parsing for the given command line arguments in *argv*..
#' 
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


#' **tclinstall::usage**
#' 
#' Prints the usage line for the terminal installer to the terminal.
#' 
proc ::tclinstall::usage {} {
    puts "Usage: $::argv0 ? DIRECTORY | SETUPFILE] ZIPFILE?"
}



