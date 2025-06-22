TOP = principal
TB_TOP = tb_principal
PART = xc7a35tcpg236-1

SRC = \
	./src/principal.sv \

TB_SRC = \
	./tb/tb_principal.sv \

SDF = netlist/synth_netlist.sdf
NETLIST = netlist/synth_netlist.v

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
	@echo "### [Behavioural] Elaboration"
	@echo
	xelab -debug typical -top ${TB_TOP} -snapshot snapshot_behavioural
	touch $@
	
.timestamp.bsim: .timestamp.bsim_elaborate
	@echo
	@echo "### [Behavioural] Simulation"
	@echo
	xsim snapshot_behavioural --tclbatch ./scripts/xsim_cfg.tcl
	touch $@

.timestamp.synth: ${SRC}
	@echo
	@echo "### Synthese RTL"
	@echo
	vivado -mode batch -nojournal -nolog -notrace \
		-source ./scripts/synthesis.tcl \
		-tclargs $(PART) $(SDF) $(NETLIST) $(TOP) $(SRC)
	touch $@

.timestamp.compile_synth_netlist: $(NETLIST) .timestamp.synth
	@echo
	@echo "### Compilation de la netlist post synth"
	@echo
	xvlog --sv -L unisims_ver $(NETLIST)
	xvlog /usr/local/Xilinx/Vivado/2024.2/data/verilog/src/glbl.v
	touch $@

.timestamp.elab_post_synth: .timestamp.tb_build .timestamp.compile_synth_netlist
	@echo
	@echo "### Elaboration simulation post synthèse"
	@echo
	xelab $(TB_TOP) glbl -debug typical -sdfmax /UUT=$(SDF) -s snapshot_postsynthesis -L unisims_ver
	touch $@

.timestamp.sim_post_synth: .timestamp.elab_post_synth 
	@echo
	@echo "### Simulation post synthèse"
	@echo
	xsim snaposhot_postsynthesis --tclbatch ./script/xsim_cfg.tcl

.PHONY: clean
clean:
	rm -f *.log
	rm -f *.pb
	rm -f *.jou
	rm -f .timestamp.*
	rm -f tb_snapshot.wdb
	rm -fr xsim.dir

.PHONY: build
build: .timestamp.build

.PHONY: sim_behavioural
sim_behavioural: .timestamp.bsim


