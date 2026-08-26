//==============================================================================
// Testbench: tb_aes_round
// Description: Unit test for single AES round. Verifies round 1 output
//              against FIPS-197 Appendix B intermediate values.
//==============================================================================

`timescale 1ns / 1ps

module tb_aes_round;

    reg  [127:0] state_in;
    reg  [127:0] round_key;
    reg          final_round;
    wire [127:0] state_out;
    integer test_count, pass_count, fail_count;

    aes_round uut (
        .state_in    (state_in),
        .round_key   (round_key),
        .final_round (final_round),
        .state_out   (state_out)
    );

    task check_round;
        input [127:0] s_in;
        input [127:0] rk;
        input         is_final;
        input [127:0] expected;
        input [8*50-1:0] name;
        begin
            test_count = test_count + 1;
            state_in   = s_in;
            round_key  = rk;
            final_round = is_final;
            #1;
            if (state_out === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: %0s", name);
            end else begin
                $display("FAIL: %0s", name);
                $display("  State In:   %h", s_in);
                $display("  Round Key:  %h", rk);
                $display("  Final:      %b", is_final);
                $display("  Expected:   %h", expected);
                $display("  Actual:     %h", state_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("=== AES ROUND UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Test 1: FIPS-197 Appendix B — Round 1 (normal round)
        // Input state (after initial AddRoundKey): 00102030405060708090a0b0c0d0e0f0
        // Round key 1: d6aa74fdd2af72fadaa678f1d6ab76fe
        // Expected output: 89d810e8855ace682d1843d8cb128fe4
        check_round(
            128'h00102030405060708090a0b0c0d0e0f0,  // State in
            128'hd6aa74fdd2af72fadaa678f1d6ab76fe,  // Round key 1
            1'b0,                                    // Not final round
            128'h89d810e8855ace682d1843d8cb128fe4,  // Expected
            "FIPS-197 Round 1 (normal)"
        );

        // Test 2: FIPS-197 Appendix B — Round 2 (normal round)
        // Input: 89d810e8855ace682d1843d8cb128fe4
        // RK2:   b692cf0b643dbdf1be9bc5006830b3fe
        // Expected: 4915598f55e5d7a0daca94fa1f0a63f7
        check_round(
            128'h89d810e8855ace682d1843d8cb128fe4,
            128'hb692cf0b643dbdf1be9bc5006830b3fe,
            1'b0,
            128'h4915598f55e5d7a0daca94fa1f0a63f7,
            "FIPS-197 Round 2 (normal)"
        );

        // Test 3: FIPS-197 Appendix B — Round 10 (final round)
        // Input: bd6e7c3df2b5779e0b61216e8b10b689
        // RK10:  13111d7fe3944a17f307a78b4d2b30c5
        // Expected: 69c4e0d86a7b0430d8cdb78070b4c55a
        check_round(
            128'hbd6e7c3df2b5779e0b61216e8b10b689,
            128'h13111d7fe3944a17f307a78b4d2b30c5,
            1'b1,
            128'h69c4e0d86a7b0430d8cdb78070b4c55a,
            "FIPS-197 Round 10 (final)"
        );

        $display("");
        $display("AES ROUND Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
