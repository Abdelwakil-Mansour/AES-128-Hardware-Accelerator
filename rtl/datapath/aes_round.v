//==============================================================================
// Module: aes_round
// Description: Single AES encryption round datapath (FIPS-197 Section 5.1).
//
//   Normal round (rounds 1-9):
//     SubBytes → ShiftRows → MixColumns → AddRoundKey
//
//   Final round (round 10):
//     SubBytes → ShiftRows → AddRoundKey
//     (MixColumns is BYPASSED)
//
// The final_round control signal selects between normal and final round
// behavior via a mux on the MixColumns output.
//
// Synthesizability: Fully combinational.
//==============================================================================

module aes_round (
    input  wire [127:0] state_in,
    input  wire [127:0] round_key,
    input  wire         final_round,
    output wire [127:0] state_out
);

    //--------------------------------------------------------------------------
    // Internal wires for intermediate results
    //--------------------------------------------------------------------------
    wire [127:0] after_sub_bytes;
    wire [127:0] after_shift_rows;
    wire [127:0] after_mix_columns;
    wire [127:0] mix_or_bypass;

    //--------------------------------------------------------------------------
    // Stage 1: SubBytes
    //--------------------------------------------------------------------------
    sub_bytes u_sub_bytes (
        .state_in  (state_in),
        .state_out (after_sub_bytes)
    );

    //--------------------------------------------------------------------------
    // Stage 2: ShiftRows
    //--------------------------------------------------------------------------
    shift_rows u_shift_rows (
        .state_in  (after_sub_bytes),
        .state_out (after_shift_rows)
    );

    //--------------------------------------------------------------------------
    // Stage 3: MixColumns (bypassed on final round)
    //--------------------------------------------------------------------------
    mix_columns u_mix_columns (
        .state_in  (after_shift_rows),
        .state_out (after_mix_columns)
    );

    // MixColumns bypass mux: final round skips MixColumns
    assign mix_or_bypass = final_round ? after_shift_rows : after_mix_columns;

    //--------------------------------------------------------------------------
    // Stage 4: AddRoundKey
    //--------------------------------------------------------------------------
    add_round_key u_add_round_key (
        .state_in  (mix_or_bypass),
        .round_key (round_key),
        .state_out (state_out)
    );

endmodule
