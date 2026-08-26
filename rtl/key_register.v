//==============================================================================
// Module: key_register
// Description: 128-bit key register for the AES iterative core.
//              Supports two operations:
//                1. Load initial key (key_load)
//                2. Update from key expansion (key_update)
//
// Synthesizability: Standard flip-flop register with mux.
//==============================================================================

module key_register (
    input  wire         clk,
    input  wire         reset,
    input  wire         key_load,       // Load initial key
    input  wire         key_update,     // Update from key expansion
    input  wire [127:0] key_in,         // Initial key input
    input  wire [127:0] key_expand_in,  // Key expansion output
    output reg  [127:0] key_out         // Current key value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            key_out <= 128'd0;
        end else if (key_load) begin
            key_out <= key_in;
        end else if (key_update) begin
            key_out <= key_expand_in;
        end
    end

endmodule
