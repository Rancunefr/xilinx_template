open_checkpoint checkpoints/synth.dcp

opt_design
place_design
route_design

write_checkpoint -force checkpoints/impl.dcp

# Reports

report_utilization      -file ./output/reports/post_route_utilization.rpt
report_timing_summary   -file ./output/reports/post_route_timing_summary.rpt
report_timing           -max_paths 10 -file ./output/reports/post_route_timing.rpt
report_drc              -file ./output/reports/post_route_drc.rpt
report_power            -file ./output/reports/post_route_power.rpt
report_route_status     -file ./output/reports/post_route_routing.rpt


# Export netlists and sdf files

write_verilog -force -mode timesim -sdf_anno true output/netlists/impl_timesim_netlist.v
write_sdf -force output/netlists/impl_timesim_netlist.sdf
write_verilog -force -mode design output/netlists/impl_design_netlist.v
write_verilog -force -mode funcsim output/netlists/impl_funcsim_netlist.v


# Output bistream

write_bitstream -force output/output.bit

exit
