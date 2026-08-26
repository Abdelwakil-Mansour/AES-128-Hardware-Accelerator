//==============================================================================
// Testbench: tb_key_expansion
// Description: Unit test for AES-128 key expansion verifying all 10 round keys
//              against FIPS-197 Appendix A.1.
//
// Key: 2b7e151628aed2a6abf7158809cf4f3c
//
// Expected round keys (from FIPS-197 Appendix A.1):
//   RK0:  2b7e1516 28aed2a6 abf71588 09cf4f3c
//   RK1:  a0fafe17 88542cb1 23a33939 2a6c7605
//   RK2:  f2c295f2 7a96b943 5935807a 7359f67f
//   RK3:  3d80477d 4716fe3e 1e237e44 6d7a883b
//   RK4:  ef44a541 a8525b7f b671253b db0bad00
//   RK5:  d4d1c6f8 7c839d87 caf2b8bc 11f915bc
//   RK6:  6d88a37a 110b3efd dbf98641 ca0093fd
//   RK7:  4e54f70e 5f5fc9f3 84a64fb2 4ea6dc4f
//   RK8:  ead27321 b58dbad2 312bf560 7f8d292f
//   RK9:  ac7766f3 19fadc21 28d12941 575c006e
//   RK10: d014f9a8 c9ee2589 e13f0cc8 b6630ca6
//==============================================================================

`timescale 1ns / 1ps

module tb_key_expansion;

    reg  [127:0] key_in;
    reg  [3:0]   round_number;
    wire [127:0] key_out;

    integer test_count, pass_count, fail_count;

    key_expansion uut (
        .key_in       (key_in),
        .round_number (round_number),
        .key_out      (key_out)
    );

    // Expected round keys from FIPS-197 Appendix A.1
    reg [127:0] expected_keys [0:10];

    task check_key;
        input [3:0]   rnd;
        input [127:0] prev_key;
        input [127:0] expected;
        begin
            test_count = test_count + 1;
            key_in = prev_key;
            round_number = rnd;
            #1;
            if (key_out === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: Round key %0d = %h", rnd, key_out);
            end else begin
                $display("FAIL: Round key %0d", rnd);
                $display("  Expected: %h", expected);
                $display("  Actual:   %h", key_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("=== KEY EXPANSION UNIT TEST ===");
        $display("Key: 2b7e151628aed2a6abf7158809cf4f3c");
        $display("");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Initialize expected round keys
        expected_keys[0]  = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        expected_keys[1]  = 128'ha0fafe1788542cb123a339392a6c7605;
        expected_keys[2]  = 128'hf2c295f27a96b9435935807a7359f67f;
        expected_keys[3]  = 128'h3d80477d4716fe3e1e237e446d7a883b;
        expected_keys[4]  = 128'hef44a541a8525b7fb671253bdb0bad00;
        expected_keys[5]  = 128'hd4d1c6f87c839d87caf2b8bc11f915bc;
        expected_keys[6]  = 128'h6d88a37a110b3efddbf98641ca0093fd;
        expected_keys[7]  = 128'h4e54f70e5f5fc9f384a64fb24ea6dc4f;
        expected_keys[8]  = 128'head27321b58dbad2312bf5607f8d292f;
        expected_keys[9]  = 128'hac7766f319fadc2128d12941575c006e;
        expected_keys[10] = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;

        // Verify iterative key expansion (each round uses previous key)
        check_key(4'd1,  expected_keys[0],  expected_keys[1]);
        check_key(4'd2,  expected_keys[1],  expected_keys[2]);
        check_key(4'd3,  expected_keys[2],  expected_keys[3]);
        check_key(4'd4,  expected_keys[3],  expected_keys[4]);
        check_key(4'd5,  expected_keys[4],  expected_keys[5]);
        check_key(4'd6,  expected_keys[5],  expected_keys[6]);
        check_key(4'd7,  expected_keys[6],  expected_keys[7]);
        check_key(4'd8,  expected_keys[7],  expected_keys[8]);
        check_key(4'd9,  expected_keys[8],  expected_keys[9]);
        check_key(4'd10, expected_keys[9],  expected_keys[10]);

        $display("");
        $display("KEY EXPANSION Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
