//==============================================================================
// Module: add_round_key
// Description: AES AddRoundKey transformation (FIPS-197 Section 5.1.4).
//              XOR of 128-bit state with 128-bit round key.
//
// Synthesizability: Purely combinational (128 XOR gates).
//==============================================================================

module add_round_key (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    output wire [127:0] state_out
);

    assign state_out = state_in ^ round_key;

endmodule
