//==============================================================================
// Testbench: tb_mix_columns
// Description: Unit test for AES MixColumns using known vectors from
//              FIPS-197 and other standard AES test data.
//==============================================================================

`timescale 1ns / 1ps

module tb_mix_columns;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    integer test_count, pass_count, fail_count;

    mix_columns uut (.state_in(state_in), .state_out(state_out));

    task check_mix;
        input [127:0] test_in;
        input [127:0] expected;
        input [8*32-1:0] name;
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
        $display("=== MIXCOLUMNS UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Test 1: FIPS-197 Section 5.1.3 example
        // Input column: {db, 13, 53, 45} → Output: {8e, 4d, a1, bc}
        // Full state: column 0 only, rest zeros
        check_mix(
            128'hdb135345_00000000_00000000_00000000,
            128'h8e4da1bc_00000000_00000000_00000000,
            "FIPS-197 MixCol example col"
        );

        // Test 2: Another known column
        // Input: {d4, bf, 5d, 30} → Output: {04, 66, 81, e5}
        check_mix(
            128'hd4bf5d30_00000000_00000000_00000000,
            128'h046681e5_00000000_00000000_00000000,
            "Known column {d4,bf,5d,30}"
        );

        // Test 3: All zeros — MixColumns of zeros is zeros
        check_mix(
            128'h00000000000000000000000000000000,
            128'h00000000000000000000000000000000,
            "All-zero state"
        );

        // Test 4: FIPS-197 Appendix B Round 1 MixColumns
        // After ShiftRows:  6360b75953e1517ce004cd7b8c0970c3
        // After MixColumns: 5f72641557f5bc92f7be3b291db9f91a
        check_mix(
            128'h6360b75953e1517ce004cd7b8c0970c3,
            128'h5f72641557f5bc92f7be3b291db9f91a,
            "FIPS-197 Round 1 MixColumns"
        );

        $display("");
        $display("MIXCOLUMNS Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
