# Vivado Make‑based FPGA Project Template

A minimal yet complete template for building, simulating, implementing and programming  
Xilinx 7‑series FPGAs (e.g. the **Basys‑3** board) from the command line with **GNU Make**.  
It wraps the usual Vivado Tcl flow in a **portable Makefile** so that every development step can be reproduced with a single shell command and is automatically **time‑stamped for incremental builds**.

## Table of contents
1. [Folder layout](#folder-layout)  
2. [Prerequisites](#prerequisites)  
3. [Quick start](#quick-start)  
4. [Typical targets](#typical-targets)  
5. [Configuration](#configuration)  
6. [Example workflow](#example-workflow)  
7. [Troubleshooting](#troubleshooting)  
8. [License](#license)

---

## Folder layout

```
.
├── constr/          # XDC constraints (board‑/pinout‑specific)
├── output/          # Auto‑generated reports, bitfiles, simulations
│   ├── netlists/
│   ├── reports/
│   └── waveforms/
├── scripts/         # Helper Tcl scripts (launch sim, create VCD, …)
├── src/             # RTL (SystemVerilog, Verilog or VHDL)
├── tb/              # Test‑bench sources
└── Makefile         # The automation core
```

## Prerequisites

| Tool               | Version tested | Notes                                                                  |
|--------------------|----------------|------------------------------------------------------------------------|
| Vivado Design Suite| 2023.2 (any 2019.2 +) | Needs the **xvlog/xelab/xsim** tools for simulation.                   |
| GNU make           | 4.0 +          | Most Linux distros and macOS (via Homebrew).                           |
| Bash               | 4.x            | The Makefile relies on simple Bash self‑printing.                      |

> **Tip** – Windows users can run the flow unchanged under **WSL2** or Git‑Bash as long as Vivado is in `$PATH`.

## Quick starT

```bash
# 1. Clone your copy of the template
git clone <repo‑url> my_fpga_proj
cd my_fpga_proj

# 2. Adapt project variables (device, RTL list, top level) in Makefile
$EDITOR Makefile

# 3. Build everything from RTL to bitstream
make all
```

The first run may take a few minutes while Vivado creates its internal project infrastructure. Subsequent invocations are incremental.

## Typical targets

| Target               | What it does                                                     |
|----------------------|------------------------------------------------------------------|
| `make all`           | Full flow: compile ➜ synth ➜ impl ➜ bitstream.                   |
| `make src`           | **Compiles RTL sources only** (syntax / lint check).             |
| `make tb`            | Compiles **test‑bench sources** and elaborates the sim model.    |
| `make synth`         | RTL → netlist (synthesis only).                                  |
| `make impl`          | Synthesis + place‑and‑route + timing reports.                    |
| `make binary`        | Generates the `.bit` file (post‑impl).                           |
| `make sim`           | Behavioural simulation of the test bench (`tb/`).                |
| `make synth_timesim` | Post‑synthesis functional + timing simulation.                   |
| `make impl_timesim`  | Post‑implementation timing simulation (SDF annotated).           |
| `make upload`        | Programs the FPGA via Vivado HW manager (needs a Digilent cable).|
| `make clean`         | Removes generated files but keeps build time‑stamps.             |
| `make distclean`     | Full cleanup (like a fresh clone).                               |

All higher‑level targets are “pseudo‑PHONY”; they expand into internal `.timestamp.*` files so Make can skip steps whose inputs have not changed.

## Configuration

Open the **first lines** of `Makefile` – they hold the only variables you usually edit:

```make
PART        = xc7a35tcpg236-1          # FPGA device (Basys‑3)
XDC         = ./constr/Basys-3-Master.xdc
TOP         = principal                # RTL top entity
TB_TOP      = tb_principal             # Test‑bench top
SRC_SVLOG   = ./src/principal.sv               ./src/impulse.sv               ./src/counter.sv
SRC_VHDL    =
SRC_VLG     =
TB_SRC      = ./tb/tb_principal.sv
```

* **PART** and **XDC** must match your board or target device.  
* Add or remove files in `SRC_*` or `TB_SRC` as you grow the project.  
* Extra compile flags, simulation TCL, or bitfile compression options can be set further down the file.

## Example workflow

```bash
# 1. Quick syntax check of RTL + TB
make src tb

# 2. Run behavioural test bench
make sim            # Watches VCD at output/waveforms/behav.vcd

# 3. Implementation & timing closure
make impl
firefox output/reports/impl_report_timing_summary.rpt &

# 4. Final bitfile when timing is satisfied
make binary

# 5. Program board (USB JTAG)
make upload
```

Because every step is time‑stamped, you can interrupt and resume the flow; Make will pick up exactly where it left off.

## Troubleshooting

| Symptom                                | Likely cause / fix                                            |
|----------------------------------------|---------------------------------------------------------------|
| `command not found: xvlog`             | Vivado is not in `$PATH`; source `settings64.sh`.             |
| Unresolved unit, file not found        | Check that the filename is listed in `SRC_*`.                 |
| `upload` hangs at "Open device failed" | Cable or board not detected – verify JTAG connection.         |
| Simulation runs but waveform empty     | Ensure `TB_TOP` matches the real test‑bench module/entity.    |

## License

This template is released under the **MIT License** – see `LICENSE` for the full text. Feel free to use and adapt it in both academic and commercial projects.

---

*Happy hacking – and may your timing reports be green!*
