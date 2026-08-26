//==============================================================================
// Module: round_counter
// Description: 4-bit synchronous round counter for the AES-128 iterative core.
//              Counts from 0 to 10.
//
//   - Resets to 0 on round_reset
//   - Increments on round_enable (posedge clk)
//   - Output: 4-bit round_number
//
// Synthesizability: Standard synchronous counter.
//==============================================================================

module round_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       round_enable,
    input  wire       round_reset,
    output reg  [3:0] round_number
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            round_number <= 4'd0;
        end else if (round_reset) begin
            round_number <= 4'd0;
        end else if (round_enable) begin
            round_number <= round_number + 4'd1;
        end
    end

endmodule
