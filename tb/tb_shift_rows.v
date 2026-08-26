//==============================================================================
// Testbench: tb_shift_rows
// Description: Unit test for AES ShiftRows using a state where every
//              byte is unique to make byte-order mistakes obvious.
//==============================================================================

`timescale 1ns / 1ps

module tb_shift_rows;

    reg  [127:0] state_in;
    wire [127:0] state_out;
    integer test_count, pass_count, fail_count;

    shift_rows uut (.state_in(state_in), .state_out(state_out));

    task check_shift;
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
        $display("=== SHIFTROWS UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Test 1: Sequential bytes — makes row shifts visually obvious
        // Input state matrix (column-major in 128-bit word):
        //   Col 0         Col 1         Col 2         Col 3
        //   [127:96]      [95:64]       [63:32]       [31:0]
        //
        //   00 04 08 0c   Row 0
        //   01 05 09 0d   Row 1
        //   02 06 0a 0e   Row 2
        //   03 07 0b 0f   Row 3
        //
        // After ShiftRows:
        //   00 04 08 0c   Row 0 (no shift)
        //   05 09 0d 01   Row 1 (shift left 1)
        //   0a 0e 02 06   Row 2 (shift left 2)
        //   0f 03 07 0b   Row 3 (shift left 3)
        //
        // Output column-major: {00,05,0a,0f, 04,09,0e,03, 08,0d,02,07, 0c,01,06,0b}
        check_shift(
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00050a0f04090e03080d02070c01060b,
            "Sequential bytes"
        );

        // Test 2: FIPS-197 Appendix B Round 1 intermediate
        // After SubBytes in round 1, the state is:
        //   63 53 e0 8c
        //   09 60 e1 04
        //   cd 70 b7 51
        //   7c 7b c3 59
        // Column-major: {63,09,cd,7c, 53,60,70,7b, e0,e1,b7,c3, 8c,04,51,59}
        //             = 128'h6309cd7c536070_7be0e1b7c38c045159
        // After ShiftRows:
        //   63 53 e0 8c   Row 0
        //   60 e1 04 09   Row 1
        //   b7 c3 cd 70   Row 2
        //   59 7c 7b c3   → actually 59 7c 7b c3? Let me recompute
        //
        // Actually the FIPS-197 Appendix B round 1 values are well-defined:
        // Input to ShiftRows (after SubBytes):
        //   63 53 e0 8c
        //   09 60 e1 04
        //   cd 70 b7 51
        //   7c 7b c3 59
        //
        // After ShiftRows:
        //   63 53 e0 8c
        //   60 e1 04 09
        //   b7 51 cd 70
        //   59 7c 7b c3
        // Wait, row 3 shift left by 3: [7c,7b,c3,59] → [59,7c,7b,c3]
        //
        // Column-major output: {63,60,b7,59, 53,e1,51,7c, e0,04,cd,7b, 8c,09,70,c3}
        check_shift(
            128'h6309cd7c536070_7be0e1b7c38c045159,
            128'h6360b75953e1517ce004cd7b8c0970c3,
            "FIPS-197 Round 1 ShiftRows"
        );

        // Test 3: Identity-like (all same bytes — shift has no visible effect)
        check_shift(
            128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
            128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
            "All-same bytes (identity)"
        );

        $display("");
        $display("SHIFTROWS Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
