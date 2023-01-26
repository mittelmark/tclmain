#!/usr/bin/env tclsh

# this file should be placed in a folder ~/.config/tclmain
# the file should be used together with the script tclmain(.tcl)

package require Markdown
proc usage {} {
    puts "Usage: tclmain -m Markdown main mdfile|- ?htmlfile|-?"
    puts "       instead of filenames as well - can be used to indicate stdin and stdout"
    puts "\nExample:\n   echo '**Hello World!**' |  tclmain -m Markdown main - out.html"
}

if {[llength $argv] < 1} {
    usage
} else {
    set mdfile [lindex $argv 0]
    set htmlfile -
    if {[llength $argv] > 1} {
        set htmlfile [lindex $argv 1]
    }
    if {![file exists $mdfile] && $mdfile ne "-"} {
        usage
        puts "Error: File '$mdfile' does not exists!"
    } else {
        if {$mdfile eq "-"} {
            set infh stdin
        } else {
            if [catch {open $mdfile r} infh] {
                puts stderr "Cannot open $mdfile: $infh"
                exit
            } 
        }
        if {$htmlfile eq "-"} {
            set out stdout
        } else {
            set out [open $htmlfile w 0600]
        }
        set txt ""
        while {[gets $infh line] >= 0} {
            append txt "$line\n"
            
        }
        puts $out [Markdown::convert $txt]
        close $out
        close $infh
    }
}


