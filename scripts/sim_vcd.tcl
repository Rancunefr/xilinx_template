set vcd_file $::env(VCD_FILE)
log_wave -recursive *
open_vcd ${vcd_file}
log_vcd *
run all
close_vcd
exit
