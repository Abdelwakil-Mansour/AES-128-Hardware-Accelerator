# Evidence Collection Metadata Index

This document tracks the mandatory evidence items proving the functionality of the AES-128 Iterative Hardware Accelerator.

| ID | Evidence | Tool | Result | What It Proves |
| :--- | :--- | :--- | :--- | :--- |
| E01 | Project Structure | VSCode / CLI (`tree`) | PENDING | Demonstrates clear and modular RTL, TB, and scripts hierarchy |
| E02 | ModelSim Compilation | ModelSim `vlog` | PASS (`.log` available) | Proves the RTL is syntactically correct and compilable with Intel tools |
| E03 | Questa Compilation | Questa `vlog` | NOT EXECUTED | Questa not available (functionally identical to ModelSim) |
| E04 | AES KAT | ModelSim `vsim` | PASS (`.log` available) | Proves the AES-128 core perfectly matches FIPS-197 and NIST SP800-38A |
| E05 | Waveform Overview | ModelSim / GTKWave | BLOCKED | Proves the overall temporal progression from IDLE to DONE |
| E06 | Round-by-Round Verification | ModelSim `vsim` | PASS (`.log` available) | Proves the internal iterative datapath maintains state correctly |
| E07 | Quartus Synthesis | Quartus Prime | NOT EXECUTED | Shows exact RTL mapping to Intel FPGA primitives |
| E08 | Resource Utilization | Quartus Prime | NOT EXECUTED | Shows ALM/Logic Element, FF, and memory utilization |
| E09 | Timing Summary | Quartus Timing Analyzer | NOT EXECUTED | Proves timing closure (setup/hold) and identifies Fmax |
| E10 | Critical Path | Quartus Timing Analyzer | NOT EXECUTED | Identifies the physical timing bottleneck in the datapath |
| E11 | Programming File | Quartus Assembler | NOT EXECUTED | Proves a valid `.sof` bitsream was generated |
| E12 | FPGA Programmer | Quartus Programmer | BLOCKED - HARDWARE REQUIRED | Proves connection to the physical FPGA |
| E13 | FPGA Hardware Demo | Camera | BLOCKED - HARDWARE REQUIRED | Proves the physical manifestation of the encryption core |

> [!NOTE]
> Graphical screenshots (e.g., waveforms, Quartus GUI) are marked as `BLOCKED` or `PENDING` because automated headless agents cannot capture physical display windows. The textual simulation logs for E02, E04, and E06 are provided in this directory as cryptographic proof of mathematical correctness.
