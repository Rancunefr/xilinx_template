# scripts/simulate.tcl

set tb [lindex $argv 0]

read_verilog ./src/*.sv
read_verilog ./tb/*.sv

set_property top $tb [current_fileset]
elaborate $tb

log_vcd *
start_vcd ./build/wave.vcd

launch_simulation
run 1 ms
stop_vcd
exit
