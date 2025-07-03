set part [lindex $argv 0]
set top  [lindex $argv 1]
set xdc  [lindex $argv 2]
set src  [lrange $argv 3 end]
foreach f $src {
    set ext [string tolower [file extension $f]]
    switch -- $ext {
        ".vhd" - ".vhdl" {
            read_vhdl $f
        }
        ".sv" {
            read_verilog -sv $f
        }
        default {
            read_verilog $f
        }
    }
}
read_xdc ${xdc}
synth_design -top ${top} -part ${part}
write_verilog -mode timesim -nolib -sdf_anno true -force output/netlists/synth_timesim_netlist.v
write_sdf -process_corner slow -force output/netlists/synth_timesim_netlist.sdf
write_verilog -mode design -force output/netlists/synth_design_netlist.v
write_verilog -mode funcsim -force output/netlists/synth_funcsim_netlist.v
write_checkpoint -force checkpoints/synth.dcp
exit
