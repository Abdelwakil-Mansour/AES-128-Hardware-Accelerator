# Reproducibility Guide

This guide ensures that any user can cleanly reproduce the simulation and synthesis results of the AES-128 core starting from a fresh clone.

## 1. Clone the Repository

First, obtain the source code and navigate into the project directory:

```bash
git clone <repository_url>
cd aes-128-accelerator
```

## 2. RTL Compilation & Verification (Simulation)

To prove the core functions correctly, run the full testbench suite using Icarus Verilog:

```bash
make sim
```
*Expected Output:* The simulator will compile the RTL and run the self-checking testbench against the NIST FIPS-197 Known Answer Tests. You should see "ALL TESTS PASSED".

To run only the top-level integration test:
```bash
make test
```

## 3. Waveform Inspection

To visually inspect the signals during encryption:

```bash
make wave
```
*Expected Output:* GTKWave will open and load `sim/waveforms/aes_top.vcd` (or equivalent VCD file in `sim/`).

## 4. Open-Source Synthesis

To evaluate the logic required without proprietary FPGA software, run Yosys generic synthesis:

```bash
make synth
```
*Expected Output:* Yosys will parse the RTL, optimize the design, and generate a generic synthesis report. 

> [!NOTE]
> The logs generated in `synthesis/reports/` (if any) or printed to the console represent a generic gate-level mapping. These numbers are an excellent baseline but do *not* exactly equate to specific FPGA logic elements (LEs/ALMs) from Intel Quartus.

## 5. Cleanup

To return the repository to a clean state:

```bash
make clean
```
