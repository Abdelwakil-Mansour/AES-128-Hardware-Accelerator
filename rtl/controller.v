//==============================================================================
// Module: controller
// Description: AES-128 iterative core FSM controller.
//
// States:
//   IDLE         - Waiting for start signal
//   INIT_ADD_KEY - Perform initial AddRoundKey (state = plaintext XOR key)
//                  and compute round key 1
//   ROUND        - Execute AES rounds 1-10
//   DONE         - Assert done, output ciphertext
//
// Transaction sequence:
//   1. IDLE: Wait for start=1. On start: capture plaintext & key, go to INIT_ADD_KEY
//   2. INIT_ADD_KEY: state_reg = plaintext XOR key, key_reg = key_expansion(key, 1)
//                    round_counter = 1, go to ROUND
//   3. ROUND: Feed state_reg and key_reg through AES round datapath
//             Update state_reg with round output
//             Compute next round key, update key_reg
//             Increment round counter
//             If round_counter was 10: go to DONE (final_round asserted)
//             Else: stay in ROUND
//   4. DONE: Assert done=1, register ciphertext. Go to IDLE.
//
// Synthesizability: Standard synchronous FSM.
//==============================================================================

module controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [3:0] round_number,
    output reg        state_load,
    output reg        key_load,
    output reg        state_update,
    output reg        key_update,
    output reg        init_add_key,
    output reg        round_enable,
    output reg        round_reset,
    output reg        final_round,
    output reg        done_flag,
    output reg        cipher_valid,
    output wire       busy
);

    //--------------------------------------------------------------------------
    // State encoding
    //--------------------------------------------------------------------------
    localparam [2:0] S_IDLE         = 3'd0;
    localparam [2:0] S_INIT_ADD_KEY = 3'd1;
    localparam [2:0] S_ROUND        = 3'd2;
    localparam [2:0] S_DONE         = 3'd3;

    reg [2:0] current_state;
    reg [2:0] next_state;

    //--------------------------------------------------------------------------
    // Busy signal: asserted whenever not in IDLE
    //--------------------------------------------------------------------------
    assign busy = (current_state != S_IDLE);

    //--------------------------------------------------------------------------
    // State register (sequential)
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    //--------------------------------------------------------------------------
    // Next state logic (combinational)
    //--------------------------------------------------------------------------
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;

        case (current_state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_INIT_ADD_KEY;
                end
            end

            S_INIT_ADD_KEY: begin
                next_state = S_ROUND;
            end

            S_ROUND: begin
                if (round_number == 4'd10) begin
                    next_state = S_DONE;
                end else begin
                    next_state = S_ROUND;
                end
            end

            S_DONE: begin
                next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    //--------------------------------------------------------------------------
    // Output logic (combinational)
    //--------------------------------------------------------------------------
    always @(*) begin
        // Default all outputs to inactive
        state_load   = 1'b0;
        key_load     = 1'b0;
        state_update = 1'b0;
        key_update   = 1'b0;
        init_add_key = 1'b0;
        round_enable = 1'b0;
        round_reset  = 1'b0;
        final_round  = 1'b0;
        done_flag    = 1'b0;
        cipher_valid = 1'b0;

        case (current_state)
            S_IDLE: begin
                if (start) begin
                    state_load  = 1'b1;  // Load plaintext into state register
                    key_load    = 1'b1;  // Load key into key register
                    round_reset = 1'b1;  // Reset round counter to 0
                end
            end

            S_INIT_ADD_KEY: begin
                init_add_key = 1'b1;  // state_reg = plaintext XOR key
                key_update   = 1'b1;  // key_reg = key_expansion(key, round 1)
                round_enable = 1'b1;  // Increment round counter: 0 → 1
            end

            S_ROUND: begin
                state_update = 1'b1;  // state_reg = round output
                key_update   = 1'b1;  // key_reg = next round key
                round_enable = 1'b1;  // Increment round counter
                // Final round detection
                if (round_number == 4'd10) begin
                    final_round = 1'b1;    // Bypass MixColumns
                    key_update  = 1'b0;    // No key update needed after round 10
                end
            end

            S_DONE: begin
                done_flag    = 1'b1;  // Assert done
                cipher_valid = 1'b1;  // Ciphertext is valid
            end

            default: begin
                // All outputs remain at default (inactive)
            end
        endcase
    end

endmodule
