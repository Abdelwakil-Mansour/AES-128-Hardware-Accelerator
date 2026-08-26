//==============================================================================
// Module: sub_word
// Description: AES SubWord function (FIPS-197 Section 5.2).
//              Applies the S-box substitution to each of the four bytes
//              of a 32-bit word.
//
//              IMPORTANT: This module reuses the SAME sbox.v module
//              used by the SubBytes datapath. There is NO separate S-box
//              implementation for key expansion.
//
// Synthesizability: Fully combinational.
//==============================================================================

module sub_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

    // Four S-box instances — one per byte
    sbox u_sbox_0 (.in(word_in[31:24]), .out(word_out[31:24]));
    sbox u_sbox_1 (.in(word_in[23:16]), .out(word_out[23:16]));
    sbox u_sbox_2 (.in(word_in[15:8]),  .out(word_out[15:8]));
    sbox u_sbox_3 (.in(word_in[7:0]),   .out(word_out[7:0]));

endmodule
