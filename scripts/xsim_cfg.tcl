log_wave -recursive *
open_vcd ./test.vcd
log_vcd [get_object /*]
run all
close_vcd
exit
