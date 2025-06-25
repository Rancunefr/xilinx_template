set part [lindex $argv 0]
set top  [lindex $argv 1]
set xdc  [lindex $argv 2]
set src  [lrange $argv 3 end]
foreach f $src {
    read_verilog $f 		;# FIXME C'est pas forcement du verilog !
}
read_xdc ${xdc}
synth_design -top ${top} -part ${part}
write_verilog -mode timesim -sdf_anno true -force netlists/synth_sim_netlist.v
write_sdf -process_corner slow -force netlists/synth_sim_netlist.sdf
write_verilog -mode design -force netlists/synth_design_netlist.v
write_checkpoint -force checkpoints/synth.dcp
exit 
