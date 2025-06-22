TOP = principal
TB_TOP = tb_principal
PART = xc7a35tcpg236-1

XDC = ./constr/Basys-3-Master.xdc 

SRC = \
	./src/principal.sv \
	./src/impulse.sv

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
	@echo
	@echo "### Compilation des sources"
	@echo
	xvlog --sv ${SRC}
	touch $@

.timestamp.tb_build: ${TB_SRC}
	@echo
	@echo "### Compilation du testbench"
	@echo
	xvlog --sv ${TB_SRC}
	touch $@

.timestamp.bsim_elaborate: .timestamp.src_build .timestamp.tb_build
	@echo
	@echo "### Elaboration simulation behavioural"
	@echo
	xelab -debug typical -top ${TB_TOP} -snapshot snapshot_behavioural
	touch $@
	
.timestamp.bsim: .timestamp.bsim_elaborate
	@echo
	@echo "### Simulation Behavioural"
	@echo
	VCD_FILE=waveforms_behavioural.vcd xsim snapshot_behavioural \
			 -tclbatch ./scripts/sim_vcd.tcl

	touch $@

.timestamp.synth: ${SRC} ${XDC}
	@echo
	@echo "### Synthese RTL"
	@echo
	vivado -mode batch -nojournal -nolog -notrace \
		-source ./scripts/synthesis.tcl \
		-tclargs $(PART) $(SYNTH_SDF) $(SYNTH_NETLIST) $(TOP) $(XDC) $(SRC)
	touch $@

.timestamp.compile_synth_netlist: .timestamp.synth
	@echo
	@echo "### Compilation de la netlist post synth"
	@echo
	xvlog --sv -L $(LIBS) $(SYNTH_NETLIST)
	xvlog $(GLBL)
	touch $@

.timestamp.elab_post_synth: .timestamp.tb_build .timestamp.compile_synth_netlist
	@echo
	@echo "### Elaboration simulation post synthèse"
	@echo
	xelab $(TB_TOP) glbl -debug typical -sdfmax /UUT=$(SYNTH_SDF) -L $(LIBS) \
		-s snapshot_postsynthesis 	
	touch $@

.timestamp.sim_post_synth: .timestamp.elab_post_synth 
	@echo
	@echo "### Simulation post synthèse"
	@echo
	VCD_FILE=waveforms_postsynthesis.vcd xsim snapshot_postsynthesis \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

.timestamp.impl:  .timestamp.synth 
	@echo
	@echo "### Implementation"
	@echo
	vivado -mode batch -nojournal -nolog -notrace \
		-source scripts/implementation.tcl \
		-tclargs $(IMPL_NETLIST) $(IMPL_SDF)
	touch $@

.timestamp.elab_post_impl: .timestamp.impl 
	@echo
	@echo "### Elaboration post implementation"
	@echo 
	@echo "Ajout de la timescale à la netlist..."
	@echo 
	@echo '`timescale 1ns/1ps' | cat - $(IMPL_NETLIST) > tmp_netlist.v && mv tmp_netlist.v $(IMPL_NETLIST)
	xvlog --sv $(TB_SRC)
	xvlog -L $(LIBS) $(IMPL_NETLIST)
	xvlog $(GLBL)
	xelab $(TB_TOP) glbl -sdfmax /UUT=$(IMPL_SDF) \
		-L $(LIBS) --debug typical \
		-s snapshot_postimplentation
	touch $@

.timestamp.sim_post_impl: .timestamp.elab_post_impl 
	@echo
	@echo "### Simulation post implementation"
	@echo 
	VCD_FILE=waveforms_postimplementation.vcd xsim snapshot_postimplentation \
			 -tclbatch ./scripts/sim_vcd.tcl
	touch $@

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
	rm -fr netlist
	rm -fr xsim.dir
	rm -fr .Xil

.PHONY: build
build: .timestamp.build

.PHONY: sim_behavioural
sim_behavioural: .timestamp.bsim

.PHONY: sim_postsynth
sim_postsynth: .timestamp.sim_post_synth

.PHONY: sim_postimpl
sim_postimpl: .timestamp.sim_post_impl

.PHONY: impl 
impl: .timestamp.impl

.PHONY: synth
synth: .timestamp.synth 
