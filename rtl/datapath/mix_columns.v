//==============================================================================
// Module: mix_columns
// Description: AES MixColumns transformation (FIPS-197 Section 5.1.3).
//              Operates on all four columns of the state matrix.
//              Each column is treated as a polynomial over GF(2^8) and
//              multiplied modulo x^4 + 1 with the fixed polynomial:
//                a(x) = {03}x^3 + {01}x^2 + {01}x + {02}
//
// GF(2^8) arithmetic:
//   Irreducible polynomial: x^8 + x^4 + x^3 + x + 1 = 0x11B
//   xtime(b) = (b << 1) XOR (0x1B if b[7] == 1)
//   Multiply by 02: xtime(b)
//   Multiply by 03: xtime(b) XOR b
//
// Synthesizability: Fully combinational.
//==============================================================================

module mix_columns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    //--------------------------------------------------------------------------
    // xtime function: multiply by {02} in GF(2^8)
    // xtime(b) = (b << 1) XOR (0x1B if MSB was set)
    //--------------------------------------------------------------------------
    function [7:0] xtime;
        input [7:0] b;
        begin
            xtime = {b[6:0], 1'b0} ^ (8'h1b & {8{b[7]}});
        end
    endfunction

    //--------------------------------------------------------------------------
    // Multiply by {03} in GF(2^8): mul3(b) = xtime(b) XOR b
    //--------------------------------------------------------------------------
    function [7:0] mul3;
        input [7:0] b;
        begin
            mul3 = xtime(b) ^ b;
        end
    endfunction

    //--------------------------------------------------------------------------
    // mix_single_column: Apply MixColumns matrix to one column
    //
    // | r0 |   | 02 03 01 01 |   | s0 |
    // | r1 | = | 01 02 03 01 | * | s1 |
    // | r2 |   | 01 01 02 03 |   | s2 |
    // | r3 |   | 03 01 01 02 |   | s3 |
    //--------------------------------------------------------------------------
    function [31:0] mix_single_column;
        input [31:0] col_in;
        reg [7:0] s0, s1, s2, s3;
        reg [7:0] r0, r1, r2, r3;
        begin
            s0 = col_in[31:24];
            s1 = col_in[23:16];
            s2 = col_in[15:8];
            s3 = col_in[7:0];

            r0 = xtime(s0) ^ mul3(s1) ^ s2        ^ s3;
            r1 = s0        ^ xtime(s1) ^ mul3(s2)  ^ s3;
            r2 = s0        ^ s1        ^ xtime(s2) ^ mul3(s3);
            r3 = mul3(s0)  ^ s1        ^ s2        ^ xtime(s3);

            mix_single_column = {r0, r1, r2, r3};
        end
    endfunction

    //--------------------------------------------------------------------------
    // Apply MixColumns to all four columns
    //--------------------------------------------------------------------------
    // State layout (column-major): bits [127:96] = col0, [95:64] = col1,
    //                              [63:32] = col2, [31:0] = col3

    assign state_out[127:96] = mix_single_column(state_in[127:96]);  // Column 0
    assign state_out[95:64]  = mix_single_column(state_in[95:64]);   // Column 1
    assign state_out[63:32]  = mix_single_column(state_in[63:32]);   // Column 2
    assign state_out[31:0]   = mix_single_column(state_in[31:0]);    // Column 3

endmodule
