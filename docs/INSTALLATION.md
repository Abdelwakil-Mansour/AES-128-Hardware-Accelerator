# Installation Guide

This guide explains how to set up the necessary tools to compile, simulate, and synthesize the AES-128 Hardware Accelerator.

## 1. Open-Source Toolchain (Option A)

This toolchain is recommended for most users as it is completely free, runs quickly, and is ideal for RTL development and verification.

### Linux (Ubuntu/Debian)

Most open-source tools can be easily installed via the package manager.

```bash
# Update package lists
sudo apt update

# Install Git and Make
sudo apt install git make

# Install Icarus Verilog (Simulator) and GTKWave (Waveform Viewer)
sudo apt install iverilog gtkwave

# Install Verilator (Optional, for advanced linting/simulation)
sudo apt install verilator

# Install Yosys (Synthesis)
sudo apt install yosys
```

**Verification:**
After installation, verify the tools are in your PATH:
```bash
iverilog -V
gtkwave --version
yosys -V
```

### Windows

For Windows users, we highly recommend using **WSL2 (Windows Subsystem for Linux)** with Ubuntu, and following the Linux instructions above.

Alternatively, for native Windows installation:
1.  **Icarus Verilog & GTKWave:** Download the Windows installer from [bleyer.org/icarus](http://bleyer.org/icarus/).
2.  **Yosys:** Download the Windows release from [YosysHQ OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build). Extract the archive and add the `bin` directory to your System PATH environment variable.
3.  **Make:** Install via MSYS2 or use `mingw32-make`.

---

## 2. Intel Quartus / ModelSim Toolchain (Option B)

This toolchain is required if you intend to program a specific Intel FPGA or perform proprietary Static Timing Analysis on the target device.

### Installation (Linux & Windows)

1.  **Download:** Go to the [Intel FPGA Software Download Center](https://www.intel.com/content/www/us/en/software-download/home.html).
2.  **Select Edition:** Choose "Quartus Prime Lite Edition" (Free) or Standard/Pro if you have a license.
3.  **Components:** Ensure you select:
    *   Quartus Prime (includes Timing Analyzer)
    *   ModelSim - Intel FPGA Edition (or Questa)
    *   Device support for your specific FPGA family (e.g., Cyclone V, MAX 10).
4.  **Install:** Run the installer and follow the GUI prompts.

### Environment Setup

To use the tools from the command line, you must add them to your `PATH`.

**Windows:**
1. Search for "Environment Variables" in the Start Menu.
2. Edit the `Path` variable and add:
   * `C:\intelFPGA_lite\<version>\quartus\bin64`
   * `C:\intelFPGA_lite\<version>\modelsim_ase\win32aloem`

**Linux:**
Add the following to your `~/.bashrc`:
```bash
export PATH=$PATH:/home/<user>/intelFPGA_lite/<version>/quartus/bin
export PATH=$PATH:/home/<user>/intelFPGA_lite/<version>/modelsim_ase/linuxaloem
```

**Common Installation Problems:**
*   **ModelSim fails to launch on Linux (missing 32-bit libraries):** ModelSim requires 32-bit libraries on Linux. Run `sudo dpkg --add-architecture i386` followed by `sudo apt update` and install the required libraries like `libc6:i386`, `libncurses5:i386`, `libxext6:i386`, `libxft2:i386`.
*   **Command not found:** Ensure you restarted your terminal after editing your PATH or `~/.bashrc`.
