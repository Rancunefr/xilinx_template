# Vivado Make‑based FPGA Project Template

A minimal yet complete template for building, simulating, implementing and programming  
Xilinx FPGAs (e.g. the **Basys‑3** board) from the command line with **GNU Make**.  
It wraps the usual Vivado Tcl flow in a **portable Makefile** so that every development step can be reproduced with a single shell command and is automatically **time‑stamped for incremental builds**.

---

## Folder layout

```
.
├── constr/          # XDC constraints (board‑/pinout‑specific)
├── ip/              # IP catalog, config files and sources
├── output/          # (auto‑generated) Reports, bitfiles, simulations
│   ├── netlists/
│   ├── reports/
│   └── waveforms/
├── sim_libs         # (auto-generated) Time annotated library for time simulations
├── scripts/         # Helper Tcl scripts used by the Makefile
├── src/             # Project sources (SystemVerilog, Verilog or VHDL)
├── tb/              # Test‑bench sources
├── Makefile         # The automation core
└── settings.mk      # Settings file

```

## Prerequisites

| Tool                | Version tested | Notes                                                                  |
|---------------------|----------------|------------------------------------------------------------------------|
| Vivado Design Suite | 2025.1         | Needs the **xvlog/xelab/xsim** tools for simulation.                   |
| GNU make            | 4.0 +          | Most Linux distros.                                                    |
| Bash                | 4.x            | The Makefile relies on simple Bash self‑printing.                      |
| Awk                 | 5.x            | Needed for errors and warning highlighting.                              |
| Gtkwave             |                | Need for waveforms visualisation.                                      |

> **Tip** – Windows users can run the flow unchanged under **WSL2** or Git‑Bash as long as Vivado is in `$PATH`.

## Quick start

```bash
# 1. Clone your copy of the template
git clone <repo‑url> my_fpga_proj
cd my_fpga_proj

# 2. Adapt project variables (device, RTL list, top level) in settings.mk
$EDITOR settings.mk

# 3. Build everything from RTL to bitstream
make impl
```

The first run may take a few minutes while Vivado creates its internal project infrastructure. Subsequent invocations are incremental.

## Typical targets

| Target               | What it does                                                     |
|----------------------|------------------------------------------------------------------|
| `make`               | Alias for `make src`                                             |
| `make src`           | **Compiles RTL sources only** (syntax / lint check).             |
| `make tb`            | Compiles **test‑bench sources** and elaborates the sim model.    |
| `make synth`         | RTL → netlist (synthesis only).                                  |
| `make impl`          | Synthesis + place‑and‑route + timing reports.                    |
| `make binary`        | Generates the `.bin` file (post‑impl).                           |
| `make sim`           | Behavioural simulation with the test bench.                      |
| `make synth_timesim` | Post‑synthesis timing simulation (SDF annotated).                |
| `make synth_funcsim` | Post‑synthesis functional simulation.                            |
| `make impl_timesim`  | Post‑implementation timing simulation (SDF annotated).           |
| `make impl_funcsim`  | Post‑implementation functional simulation.                       |
| `make upload`        | Programs the FPGA via Vivado HW manager.                         |
| `make clean`         | Removes generated files, except the sim_libs.                    |
| `make distclean`     | Full cleanup (like a fresh clone).                               |

All higher‑level targets are “pseudo‑PHONY”; they expand into internal `.timestamp.*` files so Make can skip steps whose inputs have not changed.

## Configuration

Open the `settings.mk` file – it holds the only variables you usually edit:

```make
PART        = xc7a35tcpg236-1               # FPGA device (Basys‑3)
XDC         = ./constr/Basys-3-Master.xdc   # Constraints

TOP         = principal                     # Project top entity
TB_TOP      = tb_principal                  # Test‑bench top

SRC_SVLOG   = ./src/principal.sv \          # SystemVerilog source files
                ./src/impulse.sv \
                ./src/counter.sv
SRC_VHDL    =                               # VHDL source files
SRC_VLG     =                               # Verilog source files

TB_SRC      = ./tb/tb_principal.sv          # TestBench source file (SystemVerilog)
```

* **PART** and **XDC** must match your board or target device.  
* Add or remove files in `SRC_*` or `TB_SRC` as you grow the project.  
* Extra compile flags, simulation TCL, or bitfile compression options can be set in the Makefile.

## Example 1 : Design workflow

```bash
# 1. Quick syntax check of RTL + TB
make src tb

# 2. Implementation & timing closure
make impl
$EDITOR output/reports/impl_report_timing_summary.rpt &

# 3. Final binary file when timing is satisfied
make binary

# 5. Program board (USB)
make upload
```

Because every step is time‑stamped, you can interrupt and resume the flow; Make will pick up exactly where it left off.

## Example 2 : Simulation workflow ( behavioural )

```bash
# 1. Quick syntax check of RTL + TB
make src tb

# 2. Behavioural simulation:
make sim

# 3. View waveforms
gtkwave output/waveforms/behavioural.vcd
```

## Example 3 : Post synthesis time simulation workflow

```bash
# 1. Quick syntax check of RTL + TB
make src tb

# 2. Behavioural simulation:
make synth_timesim 

# 3. View waveforms
gtkwave output/waveforms/behavioural.vcd
```

## Troubleshooting

| Symptom                                | Likely cause / fix                                            |
|----------------------------------------|---------------------------------------------------------------|
| `command not found: xvlog`             | Vivado is not in `$PATH`; source `settings64.sh`.             |
| Unresolved unit, file not found        | Check that the filename is listed in `SRC_*`.                 |
| `upload` hangs at "Open device failed" | Cable or board not detected – Did you turn the board on ?     |
| Simulation runs but waveform empty     | Ensure `TB_TOP` matches the real test‑bench module/entity.    |

## Using IPs

If you want to use IPs in your project, well ... you'll have to know a bit more.
First, you can retrieve the list of available IPs with :

```bash
make ip_update_catalog
```

This will generate a new file called ip/catalog.txt. In this file, one can find entries for each IP in the Xilinx Vivado catalog. For example :

```
>>> xilinx.com:ip:clk_wiz:6.0 (FREE)
clk_wiz
The Clocking Wizard creates an HDL file (Verilog or VHDL) that contains a clocking circuit customized to the user's clocking requirements.
```

You may also get a template file containing all available config options for a given IP:

```bash
 IP_NAME="clk_wiz" make ip_create_template
```

A new file will appear in ip/config_templates with all available options for your IP and their default values. 

```bash
cat ip/config_templates/clk_wiz.txt

clk_wiz
CONFIG.AUTO_PRIMITIVE : MMCM
CONFIG.AXI_DRP : false
CONFIG.CALC_DONE : empty
CONFIG.CDDCDONE_PORT : cddcdone
CONFIG.CDDCREQ_PORT : cddcreq
CONFIG.CLKFB_IN_N_PORT : clkfb_in_n
CONFIG.CLKFB_IN_PORT : clkfb_in
CONFIG.CLKFB_IN_P_PORT : clkfb_in_p
CONFIG.CLKFB_IN_SIGNALING : SINGLE
[...]
```

If you want to instantiate this IP, you can copy this file inside the folder ip/configs and name it as you wish. For example :

```bash
cp ip/config_templates/clk_wiz.txt ip/configs/clocky
```

You can, of course, change all the settings you need, but be aware not to touch the first line. It it now time to generate our customized instance :

```bash
make ip_generate_instances
```

This will read all the files inside ip/configs and generate the corresponding instances inside the ip folder.

You can now instanciate our 'clocky' module in your project. A template can be found in the file :

```
./ip/clock/clocky.veo 
```
One last thing: to make sure your IP is compiled with your project, don't forget to add its xci file to the SRC_IP variable, in settings.mk :

```
SRC_IP = ./ip/clocky/clocky.xci 
```

Have fun :)





## License

This template is released under the **MIT License** – see `LICENSE` for the full text. 
Feel free to use and adapt it in both academic and commercial projects.

---

*Happy hacking – and may your timing reports be green!*
