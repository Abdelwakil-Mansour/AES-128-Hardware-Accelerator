//==============================================================================
// Module: shift_rows
// Description: AES ShiftRows transformation (FIPS-197 Section 5.1.2).
//
//   Row 0: No shift
//   Row 1: Circular left shift by 1 byte
//   Row 2: Circular left shift by 2 bytes
//   Row 3: Circular left shift by 3 bytes
//
// State byte ordering (column-major, FIPS-197):
//
//   Input state matrix (4x4 bytes):
//   ┌────────────┬────────────┬────────────┬────────────┐
//   │ S[0][0]    │ S[0][1]    │ S[0][2]    │ S[0][3]    │  Row 0
//   │ [127:120]  │ [95:88]    │ [63:56]    │ [31:24]    │
//   ├────────────┼────────────┼────────────┼────────────┤
//   │ S[1][0]    │ S[1][1]    │ S[1][2]    │ S[1][3]    │  Row 1
//   │ [119:112]  │ [87:80]    │ [55:48]    │ [23:16]    │
//   ├────────────┼────────────┼────────────┼────────────┤
//   │ S[2][0]    │ S[2][1]    │ S[2][2]    │ S[2][3]    │  Row 2
//   │ [111:104]  │ [79:72]    │ [47:40]    │ [15:8]     │
//   ├────────────┼────────────┼────────────┼────────────┤
//   │ S[3][0]    │ S[3][1]    │ S[3][2]    │ S[3][3]    │  Row 3
//   │ [103:96]   │ [71:64]    │ [39:32]    │ [7:0]      │
//   └────────────┴────────────┴────────────┴────────────┘
//
// Synthesizability: Purely combinational (wire routing only).
//==============================================================================

module shift_rows (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    //--------------------------------------------------------------------------
    // Extract individual bytes from input state (column-major)
    //--------------------------------------------------------------------------
    // Column 0
    wire [7:0] s00 = state_in[127:120];  // S[0][0]
    wire [7:0] s10 = state_in[119:112];  // S[1][0]
    wire [7:0] s20 = state_in[111:104];  // S[2][0]
    wire [7:0] s30 = state_in[103:96];   // S[3][0]
    // Column 1
    wire [7:0] s01 = state_in[95:88];    // S[0][1]
    wire [7:0] s11 = state_in[87:80];    // S[1][1]
    wire [7:0] s21 = state_in[79:72];    // S[2][1]
    wire [7:0] s31 = state_in[71:64];    // S[3][1]
    // Column 2
    wire [7:0] s02 = state_in[63:56];    // S[0][2]
    wire [7:0] s12 = state_in[55:48];    // S[1][2]
    wire [7:0] s22 = state_in[47:40];    // S[2][2]
    wire [7:0] s32 = state_in[39:32];    // S[3][2]
    // Column 3
    wire [7:0] s03 = state_in[31:24];    // S[0][3]
    wire [7:0] s13 = state_in[23:16];    // S[1][3]
    wire [7:0] s23 = state_in[15:8];     // S[2][3]
    wire [7:0] s33 = state_in[7:0];      // S[3][3]

    //--------------------------------------------------------------------------
    // Apply ShiftRows
    //--------------------------------------------------------------------------
    // Row 0: no shift        → s00, s01, s02, s03
    // Row 1: shift left by 1 → s11, s12, s13, s10
    // Row 2: shift left by 2 → s22, s23, s20, s21
    // Row 3: shift left by 3 → s33, s30, s31, s32

    //--------------------------------------------------------------------------
    // Reassemble output state (column-major)
    //--------------------------------------------------------------------------
    // Column 0: row0=s00, row1=s11, row2=s22, row3=s33
    // Column 1: row0=s01, row1=s12, row2=s23, row3=s30
    // Column 2: row0=s02, row1=s13, row2=s20, row3=s31
    // Column 3: row0=s03, row1=s10, row2=s21, row3=s32

    assign state_out = {
        s00, s11, s22, s33,   // Column 0 (bits [127:96])
        s01, s12, s23, s30,   // Column 1 (bits [95:64])
        s02, s13, s20, s31,   // Column 2 (bits [63:32])
        s03, s10, s21, s32    // Column 3 (bits [31:0])
    };

endmodule
