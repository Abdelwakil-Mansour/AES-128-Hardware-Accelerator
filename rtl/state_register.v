//==============================================================================
// Module: state_register
// Description: 128-bit state register for the AES iterative core.
//              Supports three operations via control signals:
//                1. Load plaintext (state_load)
//                2. Update from initial AddRoundKey (init_add_key)
//                3. Update from round output (state_update)
//
// Synthesizability: Standard flip-flop register with mux.
//==============================================================================

module state_register (
    input  wire         clk,
    input  wire         reset,
    input  wire         state_load,     // Load plaintext
    input  wire         state_update,   // Update from round output
    input  wire         init_add_key,   // Update from initial AddRoundKey
    input  wire [127:0] plaintext_in,   // Plaintext input
    input  wire [127:0] round_out_in,   // Round datapath output
    input  wire [127:0] init_ark_in,    // Initial AddRoundKey output
    output reg  [127:0] state_out       // Current state value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_out <= 128'd0;
        end else if (state_load) begin
            state_out <= plaintext_in;
        end else if (init_add_key) begin
            state_out <= init_ark_in;
        end else if (state_update) begin
            state_out <= round_out_in;
        end
    end

endmodule
