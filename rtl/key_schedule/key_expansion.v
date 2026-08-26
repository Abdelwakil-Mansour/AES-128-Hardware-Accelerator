//==============================================================================
// Module: key_expansion
// Description: AES-128 on-the-fly key expansion (FIPS-197 Section 5.2).
//              Computes the next 128-bit round key from the current round key
//              and the round number.
//
// Algorithm for AES-128 (Nk=4):
//   For each round i (1 to 10):
//     temp = key_in[31:0]  (word 3 = rightmost 32 bits)
//     temp = SubWord(RotWord(temp)) XOR Rcon[i]
//     w0_new = key_in[127:96] XOR temp
//     w1_new = key_in[95:64]  XOR w0_new
//     w2_new = key_in[63:32]  XOR w1_new
//     w3_new = key_in[31:0]   XOR w2_new
//     key_out = {w0_new, w1_new, w2_new, w3_new}
//
// Key word ordering:
//   key[127:96] = W[4i]   (word 0)
//   key[95:64]  = W[4i+1] (word 1)
//   key[63:32]  = W[4i+2] (word 2)
//   key[31:0]   = W[4i+3] (word 3)
//
// Synthesizability: Fully combinational.
//==============================================================================

module key_expansion (
    input  wire [127:0] key_in,       // Current round key
    input  wire [3:0]   round_number, // Round number (1-10)
    output wire [127:0] key_out       // Next round key
);

    //--------------------------------------------------------------------------
    // Extract four 32-bit words from current key
    //--------------------------------------------------------------------------
    wire [31:0] w0 = key_in[127:96];
    wire [31:0] w1 = key_in[95:64];
    wire [31:0] w2 = key_in[63:32];
    wire [31:0] w3 = key_in[31:0];

    //--------------------------------------------------------------------------
    // Key schedule function: RotWord → SubWord → XOR Rcon
    //--------------------------------------------------------------------------
    wire [31:0] rot_out;
    wire [31:0] sub_out;
    wire [31:0] rcon_val;
    wire [31:0] temp;

    rot_word u_rot_word (
        .word_in  (w3),
        .word_out (rot_out)
    );

    sub_word u_sub_word (
        .word_in  (rot_out),
        .word_out (sub_out)
    );

    rcon u_rcon (
        .round    (round_number),
        .rcon_out (rcon_val)
    );

    assign temp = sub_out ^ rcon_val;

    //--------------------------------------------------------------------------
    // Compute new key words
    //--------------------------------------------------------------------------
    wire [31:0] w0_new = w0 ^ temp;
    wire [31:0] w1_new = w1 ^ w0_new;
    wire [31:0] w2_new = w2 ^ w1_new;
    wire [31:0] w3_new = w3 ^ w2_new;

    assign key_out = {w0_new, w1_new, w2_new, w3_new};

endmodule
