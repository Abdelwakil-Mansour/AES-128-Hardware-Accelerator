//==============================================================================
// Module: sub_bytes
// Description: AES SubBytes transformation (FIPS-197 Section 5.1.1).
//              Substitutes all 16 bytes of the 128-bit state using the
//              shared AES S-box module.
//
// Byte ordering: Column-major (FIPS-197 convention).
//   state[127:120] = S[0][0], state[119:112] = S[1][0], ...
//   state[7:0]     = S[3][3]
//
// Synthesizability: Fully combinational. No latches, no clocks.
//==============================================================================

module sub_bytes (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    // Generate 16 S-box instances — one per byte of the state
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sbox
            sbox u_sbox (
                .in  (state_in [((15 - i) * 8) + 7 : (15 - i) * 8]),
                .out (state_out[((15 - i) * 8) + 7 : (15 - i) * 8])
            );
        end
    endgenerate

endmodule
