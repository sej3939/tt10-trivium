/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
    // EXTRA IO FOR TESTING ONLY (take out for final)
    input reg key[79:0],
    input reg iv[79:0],
    output wire keystream_bit
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = 8'b00000000;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;
    
    trivium trivium_ASIC (
        .clk(clk),
        .rst(rst_n),
        .enable(ena),
        .key(key),
        .iv(iv),
        .keystream_bit(keystream_bit)
);

endmodule
