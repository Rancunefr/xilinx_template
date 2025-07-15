PART = xc7a35tcpg236-1
XDC = ./constr/Basys-3-Master.xdc 

TOP = principal
TB_TOP = tb_principal

SRC_SVLOG = \
	./src/principal.sv \
	./src/impulse.sv \
	./src/counter.sv

SRC_VHDL =

SRC_VLG = 

SRC_IP = ./ip/clocky/clocky.xci  

TB_SRC = ./tb/tb_principal.sv

VIVADO_PATH = /tools/Xilinx/2025.1/Vivado

