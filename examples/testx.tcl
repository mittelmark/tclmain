package provide testx 0.0.1

namespace eval testx { }

proc testx::hello {name} {
    puts "Hello ${name}!"
}   

proc testx::main {{argv {}}} {
    if {[llength $argv] != 1} {
        puts "Usage: tclmain -m testx NAME"
    } else {
        testx::hello [lindex $argv 0]
    }   
}
