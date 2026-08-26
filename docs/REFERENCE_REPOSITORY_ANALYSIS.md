# Reference Repository Analysis

This document analyzes four open-source AES Verilog implementations to extract best practices, identify weaknesses, and synthesize an optimal architecture for the AES-128 Iterative Hardware Accelerator.

The repositories analyzed are:
1. `Youssef-H23/AES_NTI`
2. `AhmedSobhy01/AES-Verilog`
3. `secworks/aes`
4. `michaelehab/AES-Verilog`

## 1. Youssef-H23/AES_NTI
*   **Architecture**: Implements standard iterative AES encryption and decryption.
*   **Strengths**: Good modularity and separation of key schedule from the main datapath. Explicit FSM state definitions. 
*   **Weaknesses**: The byte-ordering convention is not explicitly documented. Some testbenches rely heavily on manual visual inspection rather than being self-checking.
*   **Useful Ideas**: The clean separation of `sub_bytes`, `shift_rows`, and `mix_columns` modules makes debugging easier. We will adopt a similar strict module hierarchy.

## 2. AhmedSobhy01/AES-Verilog
*   **Architecture**: Seems to lean towards an academic presentation of AES steps.
*   **Strengths**: Often provides combinational versions of steps that can be easily mapped into an iterative path.
*   **Weaknesses**: Lacks robust FPGA-specific wrapper integration. The testbench coverage does not enforce full cycle-by-cycle checking across multiple edge cases.
*   **Useful Ideas**: Combinational datapath design inside the AES round module, leaving state registers to the top level. We will adopt a purely combinational AES round module wrapped by top-level state registers.

## 3. secworks/aes
*   **Architecture**: Highly professional, widely used 32-bit and 128-bit iterative core by Joachim Strömbergson.
*   **Strengths**: Exceptional documentation. Uses a clear Big-Endian byte-order approach matching NIST specs exactly. Provides AXI interface wrappers and very robust self-checking Python and Verilog testbenches. Supports many FPGA toolchains cleanly.
*   **Weaknesses**: The implementation can be very dense and optimized for area (e.g., 32-bit datapath option), which complicates readability for educational purposes.
*   **Useful Ideas**: Strict adherence to the NIST byte ordering, robust automated self-checking testbenches, and standard S-Box implementations. We will adopt their strict testbench philosophy and NIST byte ordering.

## 4. michaelehab/AES-Verilog
*   **Architecture**: Typical student/academic iterative approach.
*   **Strengths**: Simple FSM and standard 10-round iteration. Easy to trace the `state_register` updates.
*   **Weaknesses**: May instantiate too many S-boxes if the key expansion and datapath don't share resources effectively or if synthesis tools don't optimize them away.
*   **Useful Ideas**: Simple FSM implementation (`IDLE` $\rightarrow$ `LOAD` $\rightarrow$ `ROUND` $\rightarrow$ `DONE`). We will enhance this by separating the `INITIAL_ADD_KEY` and `FINAL_ROUND` to make the bypass of MixColumns mathematically explicit.

## Synthesis for Our Architecture
Based on the analysis, we will implement the following:
1.  **Byte Ordering**: We will strictly adopt the NIST Big-Endian mapping (similar to `secworks/aes`).
2.  **S-box Sharing**: We will enforce exactly 20 S-boxes (16 for datapath + 4 for key expansion) instantiated explicitly to prevent the synthesis tool from generating excess logic (improving upon typical student repos).
3.  **FSM Design**: We will use a highly explicit FSM with dedicated states for `INITIAL_ADD_KEY` and `FINAL_ROUND` to make cycle timing predictable and verifiable.
4.  **Verification**: We will completely reject manual waveform inspection and instead build a Python-verified, self-checking Verilog testbench that outputs a clear `PASS`/`FAIL` summary.
