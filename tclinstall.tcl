#!/usr/bin/env tclsh

# WIP - not ready to use

namespace eval tclinstall { }

proc ::tclinstall::install {argv} {
    
    if {[llength $argv] < 1 && [file tail [lindex $argv 0]] ne "setup.tcl"} {
        puts "Usage: $::argv0 setup.tcl"
        puts "where setup.tcl is in the parent folder of the package"
        exit 0
    }
    set setupfile [lindex $argv 0]
    if {[file exists $setupfile]} {
        source [lindex $argv 0]
    } else {
        puts "Error: File '$setupfile' does not exists!"
        exit 0
    }
    
    set owd [pwd]
    cd [file dirname $setupfile]
    set files [list]
    foreach f $setup(include) {
        foreach file [glob -nocomplain $f] {
            lappend files $file
        }
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
    
    # to do platform specific checks, windows, osx etc.
    
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
    }
    puts "Package files installed into $targetdir!"
    lappend ::auto_path [file join $targetdir ..]
    package require $setup(name)
    
    puts "Success: package $setup(name) [package present $setup(name)] is installed!"  
    cd $owd
}
tclinstall::install $argv

if {false} {
    # zip files in folder "config" to file test.zip
    package require zipfile::mkzip
    zipfile::mkzip::mkzip test.zip -directory config
    # unzip file test.zip to folder config
    package require zipfile::decode
    ::zipfile::decode::open test.zip
    set archiveDict [::zipfile::decode::archive]
    ::zipfile::decode::unzip $archiveDict config
    ::zipfile::decode::close
}

