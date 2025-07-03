open_hw_manager
connect_hw_server
open_hw_target

set dev [lindex [get_hw_devices] 0]
current_hw_device $dev
refresh_hw_device -update_hw_probes false $dev

set_property PROGRAM.FILE {output/output.bin} $dev
program_hw_devices $dev

close_hw_target
disconnect_hw_server
close_hw_manager

exit

