set part [lindex $argv 0]
set sdf  [lindex $argv 1]
set netlist  [lindex $argv 2]
set top  [lindex $argv 3]
set src  [lindex $argv 4 end]

read_verilog ${src}
synth_design -top ${top} -part ${part}
write_verilog -mode timesim -force ${netlist}
write_sdf -force ${sdf}
exit 
