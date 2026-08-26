//==============================================================================
// Testbench: tb_sub_bytes
// Description: Unit test for AES SubBytes using known FIPS-197 intermediate
//              values from Appendix B.
//==============================================================================

`timescale 1ns / 1ps

module tb_sub_bytes;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    integer test_count, pass_count, fail_count;

    sub_bytes uut (.state_in(state_in), .state_out(state_out));

    task check_sub;
        input [127:0] test_in;
        input [127:0] expected;
        input [8*40-1:0] name;
        begin
            test_count = test_count + 1;
            state_in = test_in;
            #1;
            if (state_out === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: %0s", name);
            end else begin
                $display("FAIL: %0s", name);
                $display("  Input:    %h", test_in);
                $display("  Expected: %h", expected);
                $display("  Actual:   %h", state_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("=== SUBBYTES UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Test 1: FIPS-197 Appendix B Round 1 — state after AddRoundKey (Round 0)
        // Input:  00102030405060708090a0b0c0d0e0f0
        // Expected SubBytes output: 63cab7040953d051cd60e0e7ba70e18c
        check_sub(
            128'h00102030405060708090a0b0c0d0e0f0,
            128'h63cab7040953d051cd60e0e7ba70e18c,
            "FIPS-197 Round 1 SubBytes"
        );

        // Test 2: All zeros
        // sbox(0x00) = 0x63 → all bytes become 0x63
        check_sub(
            128'h00000000000000000000000000000000,
            128'h63636363636363636363636363636363,
            "All-zero input"
        );

        // Test 3: Round 2 SubBytes from FIPS-197 Appendix B
        // Input:  89d810e8855ace682d1843d8cb128fe4
        // Output: a761ca9b97be8b45d8ad1a611fc97369
        check_sub(
            128'h89d810e8855ace682d1843d8cb128fe4,
            128'ha761ca9b97be8b45d8ad1a611fc97369,
            "FIPS-197 Round 2 SubBytes"
        );

        $display("");
        $display("SUBBYTES Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
