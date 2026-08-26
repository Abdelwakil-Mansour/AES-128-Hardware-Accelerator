# Final Engineering Review

**What is definitely correct?**
The core AES-128 algorithm implementation is mathematically and cyclically correct. The FSM precisely manages the iterative rounds, the byte ordering perfectly matches the NIST specification, and all 10 round keys are generated on-the-fly correctly. The final-round MixColumns bypass works correctly. The Known-Answer Tests (KAT) for FIPS-197 and NIST SP 800-38A blocks pass flawlessly.

**What was actually measured?**
The clock cycle latency was measured precisely in simulation as exactly 13 cycles from the assertion of `start` to the assertion of `done` (1 cycle to load, 1 cycle for initial AddRoundKey, 10 rounds, 1 output cycle).

**What has only been statically inspected?**
The FPGA wrapper and the `.sdc` timing constraints. The structural validity of the RTL for synthesis.

**What remains unverified?**
The behavior of the design at high clock frequencies (e.g., >100 MHz) in actual silicon. The actual resource utilization (LUTs/FFs) because synthesis tools (Yosys/Quartus) were unavailable in the local environment.

**What could still fail on FPGA?**
The critical path is likely the combination of `S-Box -> ShiftRows -> MixColumns -> AddRoundKey`. Without Static Timing Analysis, we cannot guarantee the design meets timing at a specific requested frequency. Wait-state handling on the AXI wrapper (if added later) could cause integration issues. 

**What assumptions were made?**
We assumed a generic FPGA target. We assumed the synthesis tool will not maliciously duplicate the explicitly instantiated `sbox` modules. We assumed synchronous active-high resets are preferred for the target FPGA.

**What limitations remain?**
The design does not support Decryption, AES-192, or AES-256. It does not include side-channel countermeasures (e.g., masking), making it vulnerable to DPA/CPA attacks if deployed in a hostile physical environment.

**What should be fixed before presentation?**
Nothing functional. However, real Synthesis/STA numbers should be collected on a machine with Quartus installed before presenting to an academic or industrial audience.

**What would a professional RTL engineer criticize?**
A professional would note the lack of pipeline registers. While an iterative architecture saves area, the combinational path through the entire AES round and key expansion within a single cycle severely limits the Maximum Frequency ($F_{max}$). A professional would recommend at least adding a pipeline register between `MixColumns` and `AddRoundKey`, or pipelining the `S-Box` memory read if block RAMs are used instead of combinational logic.
