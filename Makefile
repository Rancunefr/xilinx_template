TOP = principal
TB_TOP = tb_principal
PART = xc7a35tcpg236-1

XDC = ./constr/Basys-3-Master.xdc 

SRC = \
	./src/principal.sv \
	./src/impulse.sv \
	./src/counter.sv

TB_SRC = \
	./tb/tb_principal.sv \

SYNTH_SDF = netlist/synth_netlist.sdf
SYNTH_NETLIST = netlist/synth_netlist.v

IMPL_SDF = netlist/impl_netlist.sdf
IMPL_NETLIST = netlist/impl_netlist.v

LIBS = unisims_ver
GLBL = /usr/local/Xilinx/Vivado/2024.2/data/verilog/src/glbl.v

all: sim_behavioural

.timestamp.src_build: ${SRC}
	@echo -e
	@tput setaf 2
	@printf "### Compilation (sources)"
	@tput sgr0
	@echo -e
	xvlog --sv ${SRC}
	touch $@

.timestamp.tb_build: ${TB_SRC}
	@echo -e
	@tput setaf 2
	@echo -e "### Compilation (testbench)"
	@tput sgr0
	@echo -e
	xvlog --sv ${TB_SRC}
	touch $@

.timestamp.bsim_elaborate: .timestamp.src_build .timestamp.tb_build
	@echo -e
	@tput setaf 2
	@echo -e "### Elaboration (behavioural simulation)"
	@tput sgr0
	@echo -e
	xelab -debug typical -top ${TB_TOP} -snapshot snapshot_behavioural
	touch $@
	
.timestamp.bsim: .timestamp.bsim_elaborate
	@echo -e
	@tput setaf 2
	@echo -e "### Simulation (behavioural)"
	@tput sgr0
	@echo -e
	VCD_FILE=waveforms_behavioural.vcd xsim snapshot_behavioural \
			 -tclbatch ./scripts/sim_vcd.tcl

	touch $@

.timestamp.synth: ${SRC} ${XDC}
	@echo -e
	@tput setaf 2
	@echo -e "### Synthesis"
	@tput sgr0
	@echo -e
	vivado -mode batch -nojournal -nolog -notrace \
		-source ./scripts/synthesis.tcl \
		-tclargs $(PART) $(SYNTH_SDF) $(SYNTH_NETLIST) $(TOP) $(XDC) $(SRC)
	touch $@

.timestamp.compile_synth_netlist: .timestamp.synth
	@echo -e
	@tput setaf 2
	@echo -e "### Netlist compilation (post synth)"
	@tput sgr0
	@echo -e
	xvlog --sv -L $(LIBS) $(SYNTH_NETLIST)
	xvlog $(GLBL)
	touch $@

.timestamp.elab_post_synth: .timestamp.tb_build .timestamp.compile_synth_netlist
	@echo -e
	@tput setaf 2
	@echo -e "### Elaboration (post synth simulation)"
	@tput sgr0
	@echo -e
	xelab $(TB_TOP) glbl -debug typical -sdfmax /UUT=$(SYNTH_SDF) -L $(LIBS) \
		-s snapshot_postsynthesis 	
	touch $@

.timestamp.sim_post_synth: .timestamp.elab_post_synth 
	@echo -e
	@tput setaf 2
	@echo -e "### Simulation (post synth)"
	@tput sgr0
	@echo -e
	VCD_FILE=waveforms_postsynthesis.vcd xsim snapshot_postsynthesis \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.impl:  .timestamp.synth 
	@echo -e
	@tput setaf 2
	@echo -e "### Implementation"
	@tput sgr0
	@echo -e
	vivado -mode batch -nojournal -nolog -notrace \
		-source scripts/implementation.tcl \
		-tclargs $(IMPL_NETLIST) $(IMPL_SDF)
	touch $@

.timestamp.elab_post_impl: .timestamp.impl 
	@echo -e
	@tput setaf 2
	@echo -e "### Elaboration (post implementation)"
	@tput sgr0
	@echo -e 
	@echo -e "Adding timescale to netlist..."
	@echo -e 
	@echo '`timescale 1ns/1ps' | cat - $(IMPL_NETLIST) > tmp_netlist.v && mv tmp_netlist.v $(IMPL_NETLIST)
	xvlog --sv $(TB_SRC)
	xvlog -L $(LIBS) $(IMPL_NETLIST)
	xvlog $(GLBL)
	xelab $(TB_TOP) glbl -sdfmax /DUT_principal=$(IMPL_SDF) \
		-L $(LIBS) --debug typical \
		-s snapshot_postimplementation
	touch $@

.timestamp.sim_post_impl: .timestamp.elab_post_impl 
	@echo -e
	@tput setaf 2
	@echo -e "### Simulation (post implementation)"
	@tput sgr0
	@echo -e 
	VCD_FILE=waveforms_postimplementation.vcd xsim snapshot_postimplementation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.binary: .timestamp.impl
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
	rm -f *.vcd
	rm -f *.dcp
	rm -f clockInfo.txt
	rm -f output.bin
	rm -f output.bit
	rm -f output.prm
	rm -fr netlist
	rm -fr xsim.dir
	rm -fr .Xil

.PHONY: build
build: .timestamp.build

.PHONY: sim_behavioural
sim_behavioural: .timestamp.bsim

.PHONY: sim_post_synthesis
sim_post_synthesis: .timestamp.sim_post_synth

.PHONY: sim_post_implementation
sim_post_implementation: .timestamp.sim_post_impl

.PHONY: implementation 
implementation: .timestamp.impl

.PHONY: synthesis
synthesis: .timestamp.synth

.PHONY: binary
binary: .timestamp.binary
