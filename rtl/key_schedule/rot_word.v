//==============================================================================
// Module: rot_word
// Description: AES RotWord function (FIPS-197 Section 5.2).
//              Performs a circular left rotation of a 32-bit word by one byte.
//
//              Input:  [a0, a1, a2, a3]
//              Output: [a1, a2, a3, a0]
//
// Synthesizability: Purely combinational (wire routing only).
//==============================================================================

module rot_word (
    input  wire [31:0] word_in,
    output wire [31:0] word_out
);

    assign word_out = {word_in[23:0], word_in[31:24]};

endmodule
