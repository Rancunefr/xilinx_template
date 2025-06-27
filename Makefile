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

VIVADO_PATH = /tools/Xilinx/2025.1/Vivado

SYNTH_SIM_SDF =    netlist/synth_sim_netlist.sdf
SYNTH_SIM_NET =    netlist/synth_sim_netlist.v
SYNTH_DESIGN_NET = netlist/synth_design_netlist.v
IMPL_SIM_SDF =     netlist/impl_netlist.sdf
IMPL_SIM_NET =     netlist/impl_netlist.v
IMPL_DESIGN_NET =  netlist/impl_design_netlist.v

# LIBS = -L unisims_ver=sim_lib/unisims_ver      # Simulation fonctionnelle
LIBS = -L simprims_ver=sim_libs/simprims_ver     # Simulation temporelle

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
	if [ -n "${SRC_SVLOG}" ]; then xvlog -d XIL_TIMING --sv ${SRC_SVLOG} ; fi
	if [ -n "${SRC_VLOG}" ]; then xvlog -d XIL_TIMING ${SRC_VLOG} ; fi
	if [ -n "${SRC_VHDL}" ]; then xvhdl -d XIL_TIMING ${SRC_VHDL} ; fi
	touch $@

.timestamp.compile_tb: ${TB_SRC}
	$(call banner, "Compiling\ testbench")
	xvlog -d XIL_TIMING --sv ${TB_SRC}
	touch $@

.timestamp.behavioural_simulation: .timestamp.compile_src .timestamp.compile_tb
	$(call banner, "Behavioural\ Simulation")
	@mkdir -p waveforms
	xelab -d XIL_TIMING -snapshot behavioural_simulation \
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


.timestamp.post_synthesis_simulation: .timestamp.compile_tb .timestamp.synthesis .timestamp.simprims_ver
	$(call banner, "Post-Synthesis\ Simulation")
	@mkdir -p waveforms
	xvlog -d XIL_TIMING $(GLBL)
	xvlog -d XIL_TIMING $(LIBS) -sv netlists/synth_sim_netlist.v
	xelab -d XIL_TIMING -s post_synthesis_simulation \
		-debug typical \
		-sdfmax /tb_principal/DUT=netlists/synth_sim_netlist.sdf \
		$(LIBS) \
		$(TB_TOP) glbl 	
	VCD_FILE=waveforms/post_synthesis.vcd xsim \
			 post_synthesis_simulation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.post_implementation_simulation: .timestamp.compile_tb .timestamp.implementation .timestamp.simprims_ver
	$(call banner, "Post-Synthesis\ Simulation")
	@mkdir -p waveforms
	xvlog -d XIL_TIMING $(GLBL)
	xvlog -d XIL_TIMING $(LIBS) -sv netlists/impl_sim_netlist.v
	xelab -d XIL_TIMING -s post_implementation_simulation \
		-debug typical \
		-sdfmax /tb_principal/DUT=netlists/synth_sim_netlist.sdf \
		$(LIBS) \
		$(TB_TOP) glbl 	
	VCD_FILE=waveforms/post_implementation.vcd xsim \
			 post_implementation_simulation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.binary: .timestamp.implementation
	vivado -mode batch -source ./scripts/make_binary.tcl -tclargs output.bit output.bin
	touch $@

.timestamp.simprims_ver:
	vivado -mode batch -source ./scripts/make_simprims_ver.tcl 
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

.PHONY: mrproper
mrproper: clean
	rm -fr sim_libs

.PHONY: sim_behavioural
sim_behavioural: .timestamp.behavioural_simulation 

.PHONY: sim_post_synthesis
sim_post_synthesis: .timestamp.post_synthesis_simulation 

.PHONY: synthesis
synthesis: .timestamp.synthesis

.PHONY: implementation
implementation: .timestamp.implementation
	
.PHONY: binary
binary: .timestamp.binary
