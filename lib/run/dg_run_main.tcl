package require dg::run

if {[info script] eq $argv0} {
    puts "dg_run_main.tcl"
    ::dg::run::main $argv
    
}
