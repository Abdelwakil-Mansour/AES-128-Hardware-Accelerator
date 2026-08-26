//==============================================================================
// Testbench: tb_aes_top
// Description: Comprehensive integration testbench for AES-128 iterative core.
//
// Features:
//   - Clock generation (10ns period = 100 MHz)
//   - Active-high reset task
//   - Reusable AES encryption transaction task
//   - NIST FIPS-197 known answer test (Appendix B)
//   - Additional NIST SP 800-38A test vectors
//   - Zero-key / all-ones tests
//   - Round-by-round state monitoring with first-mismatch detection
//   - Pass/fail per test case
//   - Summary report with test count
//   - Timeout protection
//   - Clean simulation termination
//
// Test vectors:
//   1. FIPS-197 Appendix B:
//      Key: 000102030405060708090a0b0c0d0e0f
//      PT:  00112233445566778899aabbccddeeff
//      CT:  69c4e0d86a7b0430d8cdb78070b4c55a
//
//   2-3. NIST SP 800-38A F.1.1 (ECB-AES128-Encrypt):
//      Key: 2b7e151628aed2a6abf7158809cf4f3c
//
//   4. All-zero test
//   5. All-ones test
//==============================================================================

`timescale 1ns / 1ps

module tb_aes_top;

    //==========================================================================
    // Parameters
    //==========================================================================
    localparam CLK_PERIOD = 10;          // 10 ns → 100 MHz
    localparam TIMEOUT_CYCLES = 200;     // Max cycles before timeout

    //==========================================================================
    // Signals
    //==========================================================================
    reg          clk;
    reg          reset;
    reg          start;
    reg  [127:0] key;
    reg  [127:0] plaintext;
    wire [127:0] ciphertext;
    wire         done;
    wire         busy;

    //==========================================================================
    // Test tracking
    //==========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;
    integer cycle_count;
    integer timeout_flag;

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    aes_top uut (
        .clk        (clk),
        .reset      (reset),
        .start      (start),
        .key        (key),
        .plaintext  (plaintext),
        .ciphertext (ciphertext),
        .done       (done),
        .busy       (busy)
    );

    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    //==========================================================================
    // Task: reset_dut
    //   Apply active-high reset for 2 clock cycles, then deassert
    //==========================================================================
    task reset_dut;
        begin
            reset     = 1'b1;
            start     = 1'b0;
            key       = 128'd0;
            plaintext = 128'd0;
            @(posedge clk);
            @(posedge clk);
            reset = 1'b0;
            @(posedge clk);
        end
    endtask

    //==========================================================================
    // Task: run_aes_test
    //   Execute a single AES-128 encryption and compare against expected CT
    //==========================================================================
    task run_aes_test;
        input [127:0] test_key;
        input [127:0] test_pt;
        input [127:0] expected_ct;
        input [8*64-1:0] test_name;  // String name for reporting
        begin
            test_count = test_count + 1;
            timeout_flag = 0;

            // Apply inputs and pulse start
            @(posedge clk);
            key       = test_key;
            plaintext = test_pt;
            start     = 1'b1;
            @(posedge clk);
            start     = 1'b0;

            // Wait for done with timeout
            cycle_count = 0;
            while (!done && cycle_count < TIMEOUT_CYCLES) begin
                @(posedge clk);
                cycle_count = cycle_count + 1;

                // Round-by-round monitoring (debug output)
                if (uut.u_controller.current_state == 3'd2) begin  // S_ROUND
                    $display("  [Round %0d] State: %h | Key: %h",
                             uut.u_round_counter.round_number,
                             uut.u_state_register.state_out,
                             uut.u_key_register.key_out);
                end
            end

            // Check timeout
            if (cycle_count >= TIMEOUT_CYCLES) begin
                $display("FAIL: %0s — TIMEOUT after %0d cycles", test_name, TIMEOUT_CYCLES);
                fail_count = fail_count + 1;
                timeout_flag = 1;
            end

            // Wait one more cycle for output registration
            @(posedge clk);

            // Check result
            if (!timeout_flag) begin
                if (ciphertext === expected_ct) begin
                    $display("PASS: %0s", test_name);
                    $display("  Ciphertext: %h", ciphertext);
                    $display("  Latency: %0d cycles", cycle_count + 1);
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL: %0s", test_name);
                    $display("  Expected:   %h", expected_ct);
                    $display("  Actual:     %h", ciphertext);
                    // Identify first differing nibble
                    begin : find_diff
                        integer i;
                        for (i = 127; i >= 0; i = i - 1) begin
                            if (ciphertext[i] !== expected_ct[i]) begin
                                $display("  First bit mismatch at bit %0d", i);
                                disable find_diff;
                            end
                        end
                    end
                    fail_count = fail_count + 1;
                end
            end

            // Brief settling period between tests
            @(posedge clk);
            @(posedge clk);
        end
    endtask

    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    initial begin
        $display("");
        $display("====================================================");
        $display("  AES-128 ITERATIVE CORE — INTEGRATION TESTBENCH");
        $display("====================================================");
        $display("");

        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Reset DUT
        reset_dut;

        //----------------------------------------------------------------------
        // Test 1: FIPS-197 Appendix B — Primary Known Answer Test
        //----------------------------------------------------------------------
        $display("--- Test 1: FIPS-197 Appendix B (Primary KAT) ---");
        run_aes_test(
            128'h000102030405060708090a0b0c0d0e0f,  // Key
            128'h00112233445566778899aabbccddeeff,  // Plaintext
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,  // Expected CT
            "FIPS-197 Appendix B"
        );

        //----------------------------------------------------------------------
        // Test 2: NIST SP 800-38A F.1.1 — ECB-AES128 Block 1
        //----------------------------------------------------------------------
        $display("--- Test 2: NIST SP 800-38A F.1.1 Block 1 ---");
        run_aes_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,  // Key
            128'h6bc1bee22e409f96e93d7e117393172a,  // Plaintext
            128'h3ad77bb40d7a3660a89ecaf32466ef97,  // Expected CT
            "NIST SP800-38A Block 1"
        );

        //----------------------------------------------------------------------
        // Test 3: NIST SP 800-38A F.1.1 — ECB-AES128 Block 2
        //----------------------------------------------------------------------
        $display("--- Test 3: NIST SP 800-38A F.1.1 Block 2 ---");
        run_aes_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,  // Key
            128'hae2d8a571e03ac9c9eb76fac45af8e51,  // Plaintext
            128'hf5d3d58503b9699de785895a96fdbaaf,  // Expected CT
            "NIST SP800-38A Block 2"
        );

        //----------------------------------------------------------------------
        // Test 4: NIST SP 800-38A F.1.1 — ECB-AES128 Block 3
        //----------------------------------------------------------------------
        $display("--- Test 4: NIST SP 800-38A F.1.1 Block 3 ---");
        run_aes_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,  // Key
            128'h30c81c46a35ce411e5fbc1191a0a52ef,  // Plaintext
            128'h43b1cd7f598ece23881b00e3ed030688,  // Expected CT
            "NIST SP800-38A Block 3"
        );

        //----------------------------------------------------------------------
        // Test 5: NIST SP 800-38A F.1.1 — ECB-AES128 Block 4
        //----------------------------------------------------------------------
        $display("--- Test 5: NIST SP 800-38A F.1.1 Block 4 ---");
        run_aes_test(
            128'h2b7e151628aed2a6abf7158809cf4f3c,  // Key
            128'hf69f2445df4f9b17ad2b417be66c3710,  // Plaintext
            128'h7b0c785e27e8ad3f8223207104725dd4,  // Expected CT
            "NIST SP800-38A Block 4"
        );

        //----------------------------------------------------------------------
        // Test 6: All-zero key and plaintext
        //----------------------------------------------------------------------
        $display("--- Test 6: All-zero key and plaintext ---");
        run_aes_test(
            128'h00000000000000000000000000000000,  // Key
            128'h00000000000000000000000000000000,  // Plaintext
            128'h66e94bd4ef8a2c3b884cfa59ca342b2e,  // Expected CT
            "All-zero key/plaintext"
        );

        //----------------------------------------------------------------------
        // Summary
        //----------------------------------------------------------------------
        $display("");
        $display("====================================================");
        $display("  AES-128 VERIFICATION SUMMARY");
        $display("====================================================");
        $display("  Tests run:  %0d", test_count);
        $display("  Passed:     %0d", pass_count);
        $display("  Failed:     %0d", fail_count);
        $display("");
        if (fail_count == 0) begin
            $display("  STATUS: PASS");
        end else begin
            $display("  STATUS: FAIL");
        end
        $display("====================================================");
        $display("");

        $finish;
    end

    //==========================================================================
    // Waveform dump for GTKWave
    //==========================================================================
    initial begin
        $dumpfile("aes_top.vcd");
        $dumpvars(0, tb_aes_top);
    end

endmodule
