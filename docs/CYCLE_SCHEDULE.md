# AES-128 Cycle Schedule

This document outlines the cycle-by-cycle execution of the AES-128 Iterative Hardware Accelerator.

The architecture is designed to complete one 128-bit encryption block in exactly **13 clock cycles** from the assertion of `start`.

## Cycle-by-Cycle Breakdown

Assume `start` is asserted on the rising edge of **Cycle 0**.

| Cycle | FSM State | Action & State/Key Updates |
| :--- | :--- | :--- |
| **0** | `IDLE` | FSM detects `start == 1`. Next state will be `LOAD`. |
| **1** | `LOAD` | Capture `plaintext` into `state_register`. Capture `key` into `key_register`. |
| **2** | `INITIAL_ADD_KEY`| Combinational `AddRoundKey` (Round 0). `state_register` loaded with `Plaintext ^ Key0`. FSM moves to `ROUND`. Round counter = 1. |
| **3** | `ROUND 1` | `state_register` updated with output of Round 1. `key_register` updated with Key1. |
| **4** | `ROUND 2` | `state_register` updated with output of Round 2. `key_register` updated with Key2. |
| **5** | `ROUND 3` | `state_register` updated with output of Round 3. `key_register` updated with Key3. |
| **6** | `ROUND 4` | `state_register` updated with output of Round 4. `key_register` updated with Key4. |
| **7** | `ROUND 5` | `state_register` updated with output of Round 5. `key_register` updated with Key5. |
| **8** | `ROUND 6` | `state_register` updated with output of Round 6. `key_register` updated with Key6. |
| **9** | `ROUND 7` | `state_register` updated with output of Round 7. `key_register` updated with Key7. |
| **10** | `ROUND 8` | `state_register` updated with output of Round 8. `key_register` updated with Key8. |
| **11** | `ROUND 9` | `state_register` updated with output of Round 9. `key_register` updated with Key9. FSM moves to `FINAL_ROUND`. |
| **12** | `FINAL_ROUND` | `MixColumns` is bypassed. `state_register` updated with output of Round 10. `key_register` updated with Key10. FSM moves to `DONE`. |
| **13** | `DONE` | `done` signal is asserted. `ciphertext` output is valid (driven directly from `state_register`). FSM returns to `IDLE` on next edge. |

## Notes on Implementation
- The round counter increments on each transition within the `ROUND` state.
- The `key_expansion` logic operates purely rotationally in a combinational path within the cycle, providing the next round key directly to the `key_register` D-input before the rising edge of the next cycle.
- Total latency: **13 cycles**. 
- Throughput calculation: `Throughput = 128 bits * (Clock Frequency) / 13 cycles`
