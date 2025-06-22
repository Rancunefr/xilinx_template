log_wave -recursive *
open_vcd waveforms_behavioural.vcd
log_vcd [get_object /*]
run all
close_vcd
exit
