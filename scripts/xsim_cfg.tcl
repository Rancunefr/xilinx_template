log_wave -recursive *
open_vcd ./sim_waveforms.vcd
log_vcd [get_object /*]
run all
close_vcd
exit
