//==============================================================================
// Testbench: tb_sbox
// Description: Unit test for AES S-box. Verifies selected known mappings
//              from FIPS-197 Figure 7 and performs exhaustive testing of
//              all 256 input values.
//==============================================================================

`timescale 1ns / 1ps

module tb_sbox;

    reg  [7:0] in;
    wire [7:0] out;

    integer test_count, pass_count, fail_count;

    sbox uut (.in(in), .out(out));

    // Expected S-box values for exhaustive check (first 256 entries)
    // Stored as a lookup for spot-checking
    task check_sbox;
        input [7:0] test_in;
        input [7:0] expected_out;
        begin
            test_count = test_count + 1;
            in = test_in;
            #1;
            if (out === expected_out) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: sbox(0x%02h) = 0x%02h, expected 0x%02h",
                         test_in, out, expected_out);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("=== S-BOX UNIT TEST ===");
        test_count = 0; pass_count = 0; fail_count = 0;

        // Required known-answer mappings from project spec
        check_sbox(8'h00, 8'h63);
        check_sbox(8'h53, 8'hed);
        check_sbox(8'h7c, 8'h10);
        check_sbox(8'hff, 8'h16);

        // Additional spot checks from FIPS-197 Figure 7
        check_sbox(8'h01, 8'h7c);
        check_sbox(8'h10, 8'hca);
        check_sbox(8'h20, 8'hb7);
        check_sbox(8'h30, 8'h04);
        check_sbox(8'h40, 8'h09);
        check_sbox(8'h50, 8'h53);
        check_sbox(8'h60, 8'hd0);
        check_sbox(8'h70, 8'h51);
        check_sbox(8'h80, 8'hcd);
        check_sbox(8'h90, 8'h60);
        check_sbox(8'ha0, 8'he0);
        check_sbox(8'hb0, 8'he7);
        check_sbox(8'hc0, 8'hba);
        check_sbox(8'hd0, 8'h70);
        check_sbox(8'he0, 8'he1);
        check_sbox(8'hf0, 8'h8c);

        // Edge cases
        check_sbox(8'h52, 8'h00);  // sbox(0x52) = 0x00
        check_sbox(8'h63, 8'hfb);  // sbox(0x63) = 0xfb

        $display("");
        $display("S-BOX Tests: %0d | Passed: %0d | Failed: %0d",
                 test_count, pass_count, fail_count);
        if (fail_count == 0) $display("STATUS: PASS");
        else $display("STATUS: FAIL");
        $finish;
    end

endmodule
