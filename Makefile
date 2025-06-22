
SRC = src/principal.sv
TB_SRC = tb/tb_principal.sv

build_tb:
	xvlog --sv ${SRC} {TB_SRC}

tb_elaborate: 
	xelab -debug typical -top tb_principal -snapshot tb_snapshot
	
tb_sim:
	xsim tb_snapshot --tcl-batch ./scripts/xsim_cfg.tcl


