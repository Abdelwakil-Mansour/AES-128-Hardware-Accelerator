# Tool Dependencies

This document lists the required and optional tools needed to work with this project.

## Option A: Open-Source Flow (Recommended for Development)

### Required Tools
*   **Git:** For version control and cloning the repository.
*   **Make:** For build automation and running the scripts easily.
*   **Icarus Verilog (`iverilog`):** For compiling and simulating the Verilog RTL.
*   **Yosys:** For generic open-source logic synthesis and linting.

### Optional Tools
*   **GTKWave:** For viewing `.vcd` waveform files generated during simulation.
*   **Verilator:** For high-performance simulation and strict linting.
*   **openFPGALoader / dfu-util:** For programming compatible open-source FPGA development boards.

---

## Option B: Intel / Proprietary Flow (Required for Hardware Deployment)

### Required Tools
*   **Intel Quartus Prime:** The primary IDE for compiling the design to an Intel FPGA bitstream (`.sof` or `.pof`), placing and routing, and running the Timing Analyzer.
*   **ModelSim (or Questa):** The vendor-supported simulation environment for running accurate simulations, including post-synthesis gate-level simulations.

### Optional Tools
*   **Quartus Programmer:** Usually bundled with Quartus, used specifically for flashing the FPGA over JTAG/USB-Blaster.
