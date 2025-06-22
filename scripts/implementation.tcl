set netlist_file [lindex $::argv 0]
set sdf_file [lindex $::argv 1]

# On suppose que synth.dcp existe dans le répertoire courant
open_checkpoint synth.dcp

opt_design
place_design
route_design

write_checkpoint -force impl.dcp

# Export netlist, SDF et rapports necessaires

write_verilog -force -mode synth_stub $netlist_file
write_sdf -force $sdf_file

exit
