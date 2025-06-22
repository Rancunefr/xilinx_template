TB_TOP = tb_principal

SRC = \
	./src/principal.sv \

TB_SRC = \
	./tb/tb_principal.sv \


.timestamp.build: ${SRC}
	@echo
	@echo "### BUILD"
	@echo
	xvlog --sv ${SRC} ${TB_SRC}
	touch .timestamp.build

.timestamp.bsim_elaborate: .timestamp.build
	@echo
	@echo "### [TB] ELABORATION (Behavioural simulation)"
	@echo
	xelab -debug typical -top ${TB_TOP} -snapshot tb_snapshot
	touch .timestamp.bsim_elaborate
	
.timestamp.bsim: .timestamp.bsim_elaborate
	@echo
	@echo "### [TB] SIMULATION (Behavioural simulation)"
	@echo
	xsim tb_snapshot --tclbatch ./scripts/xsim_cfg.tcl
	touch .timestamp.bsim

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

.PHONY: sim_elaborate
bsim_elaborate: .timestamp.bsim_elaborate

.PHONY: sim
bsim: .timestamp.bsim

