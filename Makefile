# Makefile

# === PARAMÈTRES DU PROJET ===
PROJECT_NAME = mon_projet
PART = xc7a35tcpg236-1        # FPGA
TOP_MODULE = principal        # Nom du module top
TB_MODULE  = tb_principal     # Nom du testbench

VIVADO = vivado -mode batch -source

# === COMMANDES ===
.PHONY: all create build sim sim_vcd gtkwave clean program

all: build

create:
	rm -fr build
	$(VIVADO) scripts/create_project.tcl -tclargs $(PROJECT_NAME) $(PART) $(TOP_MODULE)

build: create
	$(VIVADO) scripts/build.tcl -tclargs $(PROJECT_NAME)

sim:
	$(VIVADO) scripts/simulate.tcl -tclargs $(TB_MODULE)

sim_vcd: sim
	make gtkwave

gtkwave:
	gtkwave ./build/wave.vcd scripts/gtkwave_config.gtkw &

program:
	$(VIVADO) scripts/program.tcl -tclargs $(PROJECT_NAME) $(TOP_MODULE)

clean:
	rm -rf build/*
