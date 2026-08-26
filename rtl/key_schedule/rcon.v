//==============================================================================
// Module: rcon
// Description: AES Round Constant (Rcon) lookup (FIPS-197 Section 5.2).
//              Returns the round constant for AES-128 key expansion.
//
//              Rcon[i] = [rc_i, 00, 00, 00]  (32 bits)
//              where rc_1 = 01, and rc_i = xtime(rc_{i-1})
//
//              For AES-128, rounds 1 through 10 are used.
//
// Synthesizability: Fully combinational.
//==============================================================================

module rcon (
    input  wire [3:0]  round,      // Round number: 1 to 10
    output reg  [31:0] rcon_out    // 32-bit round constant
);

    always @(*) begin
        case (round)
            4'd1:    rcon_out = 32'h01000000;
            4'd2:    rcon_out = 32'h02000000;
            4'd3:    rcon_out = 32'h04000000;
            4'd4:    rcon_out = 32'h08000000;
            4'd5:    rcon_out = 32'h10000000;
            4'd6:    rcon_out = 32'h20000000;
            4'd7:    rcon_out = 32'h40000000;
            4'd8:    rcon_out = 32'h80000000;
            4'd9:    rcon_out = 32'h1b000000;
            4'd10:   rcon_out = 32'h36000000;
            default: rcon_out = 32'h00000000;
        endcase
    end

endmodule
