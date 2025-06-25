set lib_dir  "./libs" 
file mkdir  $lib_dir

compile_simlib \
    -simulator xsim \
    -language verilog \
	-family artix7 \
    -library unisim \
    -directory $lib_dir \
    -force
quit
