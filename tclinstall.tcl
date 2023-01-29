#!/usr/bin/env tclsh

if {[llength $argv] < 1 && [file tail [lindex $argv 0]] ne "setup.tcl"} {
    puts "Usage: $argv0 setup.tcl"
    puts "where setup.tcl is in the parent folder of the package"
    exit 0
}

if {[file exists [lindex $argv 0]]} {
    source [lindex $argv 0]
} else {
    puts "Error: File '[lindex $argv 0]' does not exists!"
    exit 0
}
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
lappend auto_path [file join $targetdir ..]
package require $setup(name)

puts "Success: package $setup(name) [package present $setup(name)] is installed!"  
