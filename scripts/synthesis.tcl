set part [lindex $argv 0]
set sdf  [lindex $argv 1]
set netlist  [lindex $argv 2]
set top  [lindex $argv 3]
set xdc  [lindex $argv 4]
set files [lrange $argv 5 end]

set files [lrange $argv 5 end]
foreach f $files {
    read_verilog $f
}

read_xdc ${xdc}
synth_design -top ${top} -part ${part}
write_verilog -mode timesim -force ${netlist}
write_sdf -force ${sdf}
write_checkpoint -force synth.dcp
exit 
