set netlist_file [lindex $::argv 0]
set sdf_file [lindex $::argv 1]

open_checkpoint synth.dcp

opt_design
place_design
route_design

write_checkpoint -force impl.dcp

# Export netlist, SDF et rapports necessaires

write_verilog -force -mode synth_stub $netlist_file
write_sdf -force $sdf_file

# BITSTREAM OUTPUT
write_bitstream -force output.bit

# REPORTS OUTPUT

report_utilization      -file ./reports/post_route_utilization.rpt
report_timing_summary   -file ./reports/post_route_timing_summary.rpt
report_timing           -max_paths 10 -file ./reports/post_route_timing.rpt
report_drc              -file ./reports/post_route_drc.rpt
report_power            -file ./reports/post_route_power.rpt
report_route_status     -file ./reports/post_route_routing.rpt

exit
