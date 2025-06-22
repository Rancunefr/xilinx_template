log_wave -recursive *
open_vcd waveforms_postsynthesis.vcd
log_vcd [get_object /*]
run all
close_vcd
exit
