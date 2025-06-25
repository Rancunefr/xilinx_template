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

TB_SRC = \
	./tb/tb_principal.sv \

VIVADO_PATH = /usr/local/Xilinx/Vivado/2024.2

SYNTH_SIM_SDF =    netlist/synth_sim_netlist.sdf
SYNTH_SIM_NET =    netlist/synth_sim_netlist.v
SYNTH_DESIGN_NET = netlist/synth_design_netlist.v
IMPL_SIM_SDF =     netlist/impl_netlist.sdf
IMPL_SIM_NET =     netlist/impl_netlist.v
IMPL_DESIGN_NET =  netlist/impl_design_netlist.v

LIBS = unisims_ver
GLBL = $(VIVADO_PATH)/data/verilog/src/glbl.v
SRC = ${SRC_VLOG} ${SRC_SVLOG} ${SRV_VHDL}
define banner
	@echo -e
	@tput setaf 2
	@echo "### $(1)"
	@tput sgr0
	@echo -e
endef

all: sim_behavioural

.timestamp.compile_src: ${SRC}
	$(call banner, "Compiling\ sources")
	if [ -n "${SRC_SVLOG}" ]; then xvlog --sv ${SRC_SVLOG} ; fi
	if [ -n "${SRC_VLOG}" ]; then xvlog ${SRC_VLOG} ; fi
	if [ -n "${SRC_VHDL}" ]; then xvhdl ${SRC_VHDL} ; fi
	touch $@

.timestamp.compile_tb: ${TB_SRC}
	$(call banner, "Compiling\ testbench")
	xvlog --sv ${TB_SRC}
	touch $@

.timestamp.behavioural_simulation: .timestamp.compile_src .timestamp.compile_tb
	$(call banner, "Behavioural\ Simulation")
	@mkdir -p waveforms
	xelab -snapshot behavioural_simulation \
		-debug typical \
		-top ${TB_TOP} 
	VCD_FILE=waveforms/behavioural.vcd xsim \
			 behavioural_simulation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.synthesis: ${SRC} ${XDC}
	$(call banner, "Synthesis")
	@mkdir -p netlists
	@mkdir -p checkpoints
	vivado -mode batch -nojournal -nolog -notrace \
		-source ./scripts/synthesis.tcl \
		-tclargs $(PART) $(TOP) $(XDC) $(SRC)
	touch $@

.timestamp.implementation:  .timestamp.synthesis 
	$(call banner, "Implementation")
	@mkdir -p reports
	@rm -fr reports/*
	vivado -mode batch -nojournal -nolog -notrace \
		-source scripts/implementation.tcl 
	touch $@


.timestamp.post_synthesis_simulation: .timestamp.synthesis
	$(call banner, "Post-Synthesis\ Simulation")
	@mkdir -p waveforms
	xvlog $(GLBL)
	xvlog --sv -L $(LIBS) netlists/synth_sim_netlist.v
	xelab -s post_synthesis_simulation \
		-debug typical \
		-sdfmax /DUT=netlists/synth_sim_netlist.sdf \
		-L $(LIBS) \
		$(TB_TOP) glbl 	
	VCD_FILE=waveforms/post_synthesis.vcd xsim \
			 post_synthesis_simulation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.binary: .timestamp.implementation
	vivado -mode batch -source ./scripts/make_binary.tcl -tclargs output.bit output.bin
	touch $@

.PHONY:upload
upload: .timestamp.binary
	vivado -mode batch -source ./scripts/upload.tcl

.PHONY: clean
clean:
	rm -f *.log
	rm -f *.pb
	rm -f *.jou
	rm -f .timestamp.*
	rm -f *.wdb
	rm -f clockInfo.txt
	rm -f output.bin
	rm -f output.bit
	rm -f output.prm
	rm -fr xsim.dir
	rm -fr .Xil
	rm -fr reports
	rm -fr checkpoints
	rm -fr waveforms
	rm -fr netlists

.PHONY: sim_behavioural
sim_behavioural: .timestamp.behavioural_simulation 

.PHONY: synthesis
synthesis: .timestamp.synthesis

.PHONY: implementation
implementation: .timestamp.implementation
	
.PHONY: binary
binary: .timestamp.binary
