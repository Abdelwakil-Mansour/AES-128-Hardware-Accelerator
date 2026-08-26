//==============================================================================
// Module: aes_top
// Description: AES-128 iterative encryption accelerator — top level.
//
//              Architecture: Single AES round datapath reused across 10 rounds.
//              One clock cycle per round → 12 cycle total latency.
//
// Interface:
//   clk        — System clock
//   reset      — Active-high synchronous/asynchronous reset
//   start      — Pulse high for 1 cycle to begin encryption
//   key        — 128-bit encryption key (sampled on start)
//   plaintext  — 128-bit plaintext (sampled on start)
//   ciphertext — 128-bit ciphertext (valid when done=1)
//   done       — Asserted for 1 cycle when encryption completes
//   busy       — Asserted while encryption is in progress
//
// Transaction sequence (12 cycles):
//   Cycle 0:  IDLE → start=1 → load plaintext & key
//   Cycle 1:  INIT_ADD_KEY → state = plaintext XOR key, compute round key 1
//   Cycles 2-11: ROUND → execute AES rounds 1-10 (final_round on round 10)
//   Cycle 12: DONE → assert done=1, ciphertext valid
//
// State and byte ordering: FIPS-197 column-major convention.
//   plaintext[127:120] = state[0][0] (byte 0)
//   plaintext[7:0]     = state[3][3] (byte 15)
//
// Synthesizability: Fully synthesizable synchronous RTL.
//==============================================================================

module aes_top (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [127:0] key,
    input  wire [127:0] plaintext,
    output reg  [127:0] ciphertext,
    output reg          done,
    output wire         busy
);

    //==========================================================================
    // Internal signals
    //==========================================================================

    // Controller outputs
    wire        ctrl_state_load;
    wire        ctrl_key_load;
    wire        ctrl_state_update;
    wire        ctrl_key_update;
    wire        ctrl_init_add_key;
    wire        ctrl_round_enable;
    wire        ctrl_round_reset;
    wire        ctrl_final_round;
    wire        ctrl_done_flag;
    wire        ctrl_cipher_valid;

    // Round counter
    wire [3:0]  round_number;

    // Register outputs
    wire [127:0] state_reg_out;
    wire [127:0] key_reg_out;

    // Datapath outputs
    wire [127:0] round_state_out;  // AES round output
    wire [127:0] init_ark_out;     // Initial AddRoundKey output
    wire [127:0] next_round_key;   // Key expansion output

    //==========================================================================
    // Controller (FSM)
    //==========================================================================
    controller u_controller (
        .clk          (clk),
        .reset        (reset),
        .start        (start),
        .round_number (round_number),
        .state_load   (ctrl_state_load),
        .key_load     (ctrl_key_load),
        .state_update (ctrl_state_update),
        .key_update   (ctrl_key_update),
        .init_add_key (ctrl_init_add_key),
        .round_enable (ctrl_round_enable),
        .round_reset  (ctrl_round_reset),
        .final_round  (ctrl_final_round),
        .done_flag    (ctrl_done_flag),
        .cipher_valid (ctrl_cipher_valid),
        .busy         (busy)
    );

    //==========================================================================
    // Round Counter
    //==========================================================================
    round_counter u_round_counter (
        .clk          (clk),
        .reset        (reset),
        .round_enable (ctrl_round_enable),
        .round_reset  (ctrl_round_reset),
        .round_number (round_number)
    );

    //==========================================================================
    // State Register
    //==========================================================================
    state_register u_state_register (
        .clk          (clk),
        .reset        (reset),
        .state_load   (ctrl_state_load),
        .state_update (ctrl_state_update),
        .init_add_key (ctrl_init_add_key),
        .plaintext_in (plaintext),
        .round_out_in (round_state_out),
        .init_ark_in  (init_ark_out),
        .state_out    (state_reg_out)
    );

    //==========================================================================
    // Key Register
    //==========================================================================
    key_register u_key_register (
        .clk          (clk),
        .reset        (reset),
        .key_load     (ctrl_key_load),
        .key_update   (ctrl_key_update),
        .key_in       (key),
        .key_expand_in(next_round_key),
        .key_out      (key_reg_out)
    );

    //==========================================================================
    // Initial AddRoundKey (plaintext XOR key, used in INIT_ADD_KEY state)
    //==========================================================================
    add_round_key u_init_add_round_key (
        .state_in  (state_reg_out),
        .round_key (key_reg_out),
        .state_out (init_ark_out)
    );

    //==========================================================================
    // AES Round Datapath (reused for rounds 1-10)
    //==========================================================================
    aes_round u_aes_round (
        .state_in    (state_reg_out),
        .round_key   (key_reg_out),
        .final_round (ctrl_final_round),
        .state_out   (round_state_out)
    );

    //==========================================================================
    // Key Expansion (on-the-fly, computes next round key)
    //==========================================================================
    key_expansion u_key_expansion (
        .key_in       (key_reg_out),
        .round_number (round_number + 4'd1),
        .key_out      (next_round_key)
    );

    //==========================================================================
    // Output Registration
    //==========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ciphertext <= 128'd0;
            done       <= 1'b0;
        end else begin
            done <= ctrl_done_flag;
            if (ctrl_cipher_valid) begin
                ciphertext <= state_reg_out;
            end
        end
    end

endmodule
