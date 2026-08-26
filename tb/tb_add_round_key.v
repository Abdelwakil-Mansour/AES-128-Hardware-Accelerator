//==============================================================================
// Testbench: tb_add_round_key
// Description: Unit test for AES AddRoundKey (128-bit XOR).
//==============================================================================

`timescale 1ns / 1ps

module tb_add_round_key;

    reg  [127:0] state_in;
    reg  [127:0] round_key;
    wire [127:0] state_out;
    integer test_count, pass_count, fail_count;

    add_round_key uut (
        .state_in  (state_in),
        .round_key (round_key),
        .state_out (state_out)
    );

    task check_ark;
        input [127:0] s_in;
        input [127:0] rk;
        input [127:0] expected;
        input [8*40-1:0] name;
        begin
            test_count = test_count + 1;
            state_in  = s_in;
            round_key = rk;
            #1;
            if (state_out === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: %0s", name);
            end else begin
                $display("FAIL: %0s", name);
                $display("  State:    %h", s_in);
                $display("  Key:      %h", rk);
                $display("  Expected: %h", expected);
                $display("  Actual:   %h", state_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("=== ADDROUNDKEY UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Test 1: FIPS-197 initial AddRoundKey
        // PT:  00112233445566778899aabbccddeeff
        // Key: 000102030405060708090a0b0c0d0e0f
        // Out: 00102030405060708090a0b0c0d0e0f0
        check_ark(
            128'h00112233445566778899aabbccddeeff,
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00102030405060708090a0b0c0d0e0f0,
            "FIPS-197 initial AddRoundKey"
        );

        // Test 2: XOR with zeros (identity)
        check_ark(
            128'hdeadbeefcafebabe1234567890abcdef,
            128'h00000000000000000000000000000000,
            128'hdeadbeefcafebabe1234567890abcdef,
            "XOR with zeros (identity)"
        );

        // Test 3: XOR with self (all zeros)
        check_ark(
            128'habcdef0123456789abcdef0123456789,
            128'habcdef0123456789abcdef0123456789,
            128'h00000000000000000000000000000000,
            "XOR with self (zero result)"
        );

        $display("");
        $display("ADDROUNDKEY Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
