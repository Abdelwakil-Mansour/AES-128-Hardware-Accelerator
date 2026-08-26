# AES-128 Hardware Accelerator Architecture Specification

## 1. System Overview

This project implements an AES-128 encryption hardware accelerator using an **Iterative Architecture**. The design focuses on balancing area and throughput by reusing a single 128-bit AES round datapath across all 10 rounds of the AES encryption process.

### Datapath Flow
1. **Plaintext Input**: The 128-bit plaintext is registered into the `State Register` on the first cycle.
2. **Initial Key Addition**: The initial state is XORed with the original 128-bit encryption key.
3. **Iterative Rounds (1-9)**: The state is passed through the `AES Round` datapath (SubBytes $\rightarrow$ ShiftRows $\rightarrow$ MixColumns $\rightarrow$ AddRoundKey) and the result is fed back into the `State Register`.
4. **Final Round (10)**: The state passes through the `AES Round` datapath with the `MixColumns` step bypassed.
5. **Ciphertext Output**: The final state is presented as the 128-bit ciphertext and a `done` signal is asserted.

## 2. Byte Ordering Convention

This is a **critical requirement** for ensuring correctness across all modules, testbenches, and documentation. We adopt a **Big-Endian** byte ordering convention, mapping directly to the NIST SP 800-38A specification.

For a 128-bit word `W[127:0]`, the bytes are read from left to right (most significant byte to least significant byte).

### Plaintext to State Matrix Mapping

AES organizes the 16 bytes into a 4x4 column-major state matrix. 
Given a 128-bit plaintext $P$, we map the bytes as follows:

| Byte Index (P) | Bit Range | State Matrix Position |
| :--- | :--- | :--- |
| Byte 0 | `[127:120]` | `State[0][0]` (Row 0, Col 0) |
| Byte 1 | `[119:112]` | `State[1][0]` (Row 1, Col 0) |
| Byte 2 | `[111:104]` | `State[2][0]` (Row 2, Col 0) |
| Byte 3 | `[103:96]` | `State[3][0]` (Row 3, Col 0) |
| Byte 4 | `[95:88]` | `State[0][1]` (Row 0, Col 1) |
| Byte 5 | `[87:80]` | `State[1][1]` (Row 1, Col 1) |
| Byte 6 | `[79:72]` | `State[2][1]` (Row 2, Col 1) |
| Byte 7 | `[71:64]` | `State[3][1]` (Row 3, Col 1) |
| Byte 8 | `[63:56]` | `State[0][2]` (Row 0, Col 2) |
| Byte 9 | `[55:48]` | `State[1][2]` (Row 1, Col 2) |
| Byte 10 | `[47:40]` | `State[2][2]` (Row 2, Col 2) |
| Byte 11 | `[39:32]` | `State[3][2]` (Row 3, Col 2) |
| Byte 12 | `[31:24]` | `State[0][3]` (Row 0, Col 3) |
| Byte 13 | `[23:16]` | `State[1][3]` (Row 1, Col 3) |
| Byte 14 | `[15:8]` | `State[2][3]` (Row 2, Col 3) |
| Byte 15 | `[7:0]` | `State[3][3]` (Row 3, Col 3) |

*State Matrix visualization:*
```
[ Byte 0   Byte 4   Byte 8   Byte 12 ]
[ Byte 1   Byte 5   Byte 9   Byte 13 ]
[ Byte 2   Byte 6   Byte 10  Byte 14 ]
[ Byte 3   Byte 7   Byte 11  Byte 15 ]
```

The 128-bit key and round keys follow the exact same mapping.

## 3. Module Hierarchy

The project is structured into three main domains: **Datapath**, **Key Schedule**, and **Control**.

```text
aes_top
├── controller          (FSM & round tracking)
├── state_register      (Holds 128-bit state between rounds)
├── key_register        (Holds 128-bit round key)
│
├── datapath            (AES Round)
│   └── aes_round
│       ├── sub_bytes   (Uses 16x shared S-Box)
│       ├── shift_rows
│       ├── mix_columns
│       └── add_round_key
│
└── key_schedule        (Key Expansion)
    └── key_expansion
        ├── rot_word
        ├── sub_word    (Uses 4x shared S-Box)
        └── rcon
```

## 4. Single Shared S-Box Implementation

The core will use a single standard S-box module (`sbox.v`). 
*   The `sub_bytes` module will instantiate 16 copies of the S-box.
*   The `sub_word` module will instantiate 4 copies of the S-box.
*   **Total S-boxes synthesized**: 20 S-boxes per AES core. No custom or duplicated S-box logic will be permitted.

## 5. Control Finite State Machine (FSM)

The controller oversees the AES encryption process, stepping through the rounds iteratively.

*   `IDLE`: Waits for the `start` signal.
*   `LOAD`: Captures `plaintext` into the `state_register` and `key` into the `key_register`.
*   `INITIAL_ADD_KEY`: Performs `State = State ^ Key`.
*   `ROUND`: Iterates through rounds 1 to 9. The round counter increments, `state_register` updates with the AES round result, and `key_register` updates with the next round key.
*   `FINAL_ROUND`: Round 10. Asserts a signal to bypass `MixColumns`. Updates the final state.
*   `DONE`: Asserts the `done` output signal and presents `ciphertext`. Returns to `IDLE`.

## 6. Verification and Top-Level Interfaces

The top-level module `aes_top` has the following interface:

```verilog
module aes_top (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] plaintext,
    output reg  [127:0] ciphertext,
    output reg          done
);
```

**Interface Behavior:**
*   `reset`: Synchronous, active-high reset. Clears all registers and forces FSM to `IDLE`.
*   `start`: Asserts for 1 cycle to begin encryption. The core will ignore subsequent `start` signals until encryption completes.
*   `done`: Asserts for 1 cycle when `ciphertext` is valid.
*   `ciphertext`: Valid exclusively when `done` is high. Otherwise, it may hold intermediate state or zeros.
