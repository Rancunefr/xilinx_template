open_checkpoint checkpoints/synth.dcp

opt_design
place_design
route_design

write_checkpoint -force checkpoints/impl.dcp

# Export netlist, SDF et rapports necessaires

write_verilog -force -mode timesim -sdf_anno true netlists/impl_sim_netlist.v
write_sdf -force netlists/impl_sim_netlist.sdf
write_verilog -force -mode design netlists/impl_design_netlist.v


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
