# scripts/build.tcl

set proj_name [lindex $argv 0]

open_project ./build/$proj_name.xpr

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1
wait_on_run impl_1

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
