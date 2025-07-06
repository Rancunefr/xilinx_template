include settings.mk

# Use bash for all recipe commands. The Makefile relies on bash features such
# as the `|&` pipe operator which are not available in POSIX `sh`.
SHELL := /usr/bin/env bash

LIB_UNISIMS_VER  = -L unisims_ver                            # Simulation fonctionnelle
LIB_SIMPRIMS_VER = -L simprims_ver=sim_libs/simprims_ver     # Simulation temporelle
GLBL = "${VIVADO_PATH}/data/verilog/src/glbl.v"

SRC = ${SRC_VLOG} ${SRC_SVLOG} ${SRC_VHDL}

VIVADO = vivado -mode batch -nojournal -nolog -notrace 
XVLOG = xvlog --nolog -d XIL_TIMING
XELAB = xelab --nolog -d XIL_TIMING
XSIM = xsim --nolog 

define banner
	@echo -e
	@tput setaf 2
	@echo "### $(1)"
	@tput sgr0
	@echo -e
endef

HL = awk '{\
  gsub("ERROR",   "\033[31m&\033[0m");\
  gsub("WARNING", "\033[33m&\033[0m");\
  gsub("INFO",    "\033[97m&\033[0m");\
  print }'

all: src

.timestamp.compile_src: ${SRC}
	@$(call banner, "Compiling\ sources")
	@if [ -n "${SRC_SVLOG}" ]; then $(XVLOG) --sv ${SRC_SVLOG} |& ${HL}; fi
	@if [ -n "${SRC_VLOG}" ]; then $(XVLOG) ${SRC_VLOG} |& ${HL}; fi
	@if [ -n "${SRC_VHDL}" ]; then xvhdl -d XIL_TIMING ${SRC_VHDL} |& ${HL}; fi
	@touch $@

.timestamp.compile_tb: ${TB_SRC}
	@$(call banner, "Compiling\ testbench")
	@$(XVLOG) --sv ${TB_SRC} |& ${HL}
	@touch $@

.timestamp.behavioural_simulation: .timestamp.compile_src .timestamp.compile_tb
	@$(call banner, "Behavioural\ Simulation")
	@mkdir -p output/waveforms
	@$(XELAB) -snapshot behavioural_simulation \
		-debug typical \
		-top ${TB_TOP} |& ${HL}
	@VCD_FILE=output/waveforms/behavioural.vcd $(XSIM) \
			 behavioural_simulation \
			 -tclbatch ./scripts/sim_vcd.tcl |& ${HL}
	touch $@

.timestamp.synthesis: ${SRC} ${XDC} ${SRC_IP} 
	@$(call banner, "Synthesis")
	@mkdir -p output/netlists
	@mkdir -p checkpoints
	@$(VIVADO) -source ./scripts/synthesis.tcl \
		-tclargs $(PART) $(TOP) $(XDC) $(SRC) $(SRC_IP) |& ${HL}
	@touch $@

.timestamp.implementation:  .timestamp.synthesis 
	@$(call banner, "Implementation")
	@mkdir -p output/reports
	@rm -fr output/reports/*
	@$(VIVADO) -source scripts/implementation.tcl |& ${HL}
	@touch $@

.timestamp.synth_timesim: .timestamp.compile_tb .timestamp.synthesis .timestamp.simprims_ver
	@$(call banner, "Post-Synthesis\ Time\ Simulation")
	@mkdir -p output/waveforms
	@$(XVLOG) $(GLBL) |& ${HL}
	@$(XVLOG) $(LIB_SIMPRIMS_VER) -sv output/netlists/synth_timesim_netlist.v |& ${HL}
	@$(XELAB) -s snapshot_synth_timesim \
		-debug typical \
		-sdfmax /tb_principal/DUT=output/netlists/synth_timesim_netlist.sdf \
		$(LIB_SIMPRIMS_VER) \
		$(TB_TOP) glbl |& ${HL} 	
	@VCD_FILE=output/waveforms/synth_timesim.vcd $(XSIM) \
			 snapshot_synth_timesim \
			 -tclbatch ./scripts/sim_vcd.tcl |& ${HL}
	@touch $@

.timestamp.impl_timesim: .timestamp.compile_tb .timestamp.implementation .timestamp.simprims_ver
	@$(call banner, "Post-Implementation\ \ Time\ Simulation")
	@mkdir -p output/waveforms
	@$(XVLOG) $(GLBL) |& ${HL}
	@$(XVLOG) $(LIB_SIMPRIMS_VER) -sv output/netlists/impl_timesim_netlist.v |& ${HL}
	@$(XELAB) -s snapshot_impl_timesim \
		-debug typical \
		-sdfmax /tb_principal/DUT=output/netlists/impl_timesim_netlist.sdf \
		$(LIB_SIMPRIMS_VER) \
		$(TB_TOP) glbl |& ${HL} 	
	@VCD_FILE=output/waveforms/impl_timesim.vcd $(XSIM) \
			 snapshot_impl_timesim \
			 -tclbatch ./scripts/sim_vcd.tcl |& ${HL}
	@touch $@

.timestamp.synth_funcsim: .timestamp.compile_tb .timestamp.synthesis
	@$(call banner, "Post-Synthesis\ Func.\ Simulation")
	@mkdir -p output/waveforms
	@$(XVLOG) $(GLBL) |& ${HL}
	@$(XVLOG) $(LIB_SIMPRIMS_VER) -sv output/netlists/synth_funcsim_netlist.v |& ${HL}
	@$(XELAB) -s snapshot_synth_funcsim \
		-debug typical \
		$(LIB_UNISIMS_VER) \
		$(TB_TOP) glbl |& ${HL} 	
	@VCD_FILE=output/waveforms/synth_funcsim.vcd $(XSIM) \
			 snapshot_synth_funcsim \
			 -tclbatch ./scripts/sim_vcd.tcl |& ${HL}
	@touch $@

.timestamp.impl_funcsim: .timestamp.compile_tb .timestamp.implementation
	@$(call banner, "Post-Implementation\ Func.\ Simulation")
	@mkdir -p output/waveforms
	@$(XVLOG) $(GLBL) |& ${HL}
	@$(XVLOG) $(LIB_SIMPRIMS_VER) -sv output/netlists/impl_funcsim_netlist.v |& ${HL}
	@$(XELAB) -s snapshot_impl_funcsim \
		-debug typical \
		$(LIB_UNISIMS_VER) \
		$(TB_TOP) glbl |& ${HL} 	
	@VCD_FILE=output/waveforms/impl_funcsim.vcd $(XSIM) \
			 snapshot_impl_funcsim \
			 -tclbatch ./scripts/sim_vcd.tcl |& ${HL}
	@touch $@

.timestamp.binary: .timestamp.implementation
	@$(call banner, "Building\ binary")
	@$(VIVADO) -source ./scripts/make_binary.tcl \
		-tclargs output/output.bit output/output.bin |& ${HL}
	@touch $@

.timestamp.simprims_ver:
	@$(call banner, "Building\ simprims_ver")
	@$(VIVADO) -source ./scripts/make_simprims_ver.tcl |& ${HL} 
	@touch $@

.PHONY: upload
upload: .timestamp.binary
	@$(call banner, "Uploading ...")
	@$(VIVADO) -source ./scripts/upload.tcl |& $(HL)

.PHONY: ip_update_catalog
ip_update_catalog:
	@$(call banner, "Updating IP catalog ...")
	@mkdir -p ./ip
	@rm -f ./ip/catalog.txt
	@$(VIVADO) -source ./scripts/ip_update_catalog.tcl \
		-tclargs ${PART} |& ${HL}

.PHONY: ip_create_template
ip_create_config:
	@if [ -z "$(IP_NAME)" ]; then \
		echo "Usage : IP_NAME=\"name_of_the_ip\" make ip_create_template"; \
	else \
		echo "Creating IP config template for $(IP_NAME) ..." ; \
		mkdir -p ./ip/config_templates ; \
		$(VIVADO) -source ./scripts/ip_create_template.tcl \
			-tclargs ${PART} ${IP_NAME} |& $(HL) ;\
	fi

.PHONY: ip_generate_instances
ip_generate_instances:
	@$(call banner, "Creating IP instances ...")
	@mkdir -p ./ip
	@if [ -d ./ip/configs ]; then \
		for cfg in ./ip/configs/*; do \
			[ -f "$$cfg" ] || continue; \
			inst=$$(basename $$cfg); \
			echo " >> Generating $$inst"; \
			rm -fr ./ip/$$inst ; \
			$(VIVADO) -source ./scripts/ip_generate_instance.tcl \
				-tclargs ${PART} $$cfg $$inst |& $(HL) ; \
		done; \
	else \
		echo "No ./ip/configs directory"; \
	fi

.PHONY: clean
clean:
	rm -f *.log
	rm -f *.pb
	rm -f *.jou
	rm -f .timestamp.*
	rm -f *.wdb
	rm -f clockInfo.txt
	rm -f xsim.ini
	rm -f xsim.ini.bak
	rm -f xsim.ini.map
	rm -f .cxl.*
	rm -fr xsim.dir
	rm -fr .Xil
	rm -fr output
	rm -fr checkpoints
	rm -fr .cxl

.PHONY: distclean
distclean: clean
	rm -fr sim_libs

.PHONY: sim
sim: .timestamp.behavioural_simulation 

.PHONY: synth_timesim
synth_timesim: .timestamp.synth_timesim

.PHONY: impl_timesim
impl_timesim: .timestamp.impl_timesim 

.PHONY: impl_funcsim
impl_funcsim: .timestamp.impl_funcsim 

.PHONY: synth_funcsim
synth_funcsim: .timestamp.synth_funcsim 

.PHONY: synth
synth: .timestamp.synthesis

.PHONY: impl
impl: .timestamp.implementation
	
.PHONY: binary
binary: .timestamp.binary

.PHONY: tb
tb: .timestamp.compile_tb

.PHONY: src
src: .timestamp.compile_src

