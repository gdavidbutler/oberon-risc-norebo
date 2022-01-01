// Project Oberon, Revised Edition 2013
// Copyright (C)2013 Niklaus Wirth (NW), Juerg Gutknecht (JG), Paul Reed (PR/PDR).
//
// Permission to use, copy, modify, and/or distribute this software and its
// accompanying documentation (the "Software") for any purpose with or
// without fee is hereby granted, provided that the above copyright notice
// and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
// WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
// CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
// AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.

`timescale 1ns / 1ps  // NW 31.10.10

module Divider(
  input clk, run,
  output stall,
  input [31:0] x, y,  // x >= 0, y > 0
  output [31:0] quot, rem);

reg [4:0] S;  // state
reg [31:0] R, Q;
wire [31:0] r0, r1, r2, q0, q1, d;

assign stall = run & ~(S == 31);
assign r0 = (S == 0) ? 0 : R;
assign d = r1 - y;
assign r1 = {r0[30:0], q0[31]};
assign r2 = d[31] ? r1 : d;
assign q0 = (S == 0) ? x : Q;
assign q1 = {q0[30:0], ~d[31]};
assign rem = r2;
assign quot = q1;

always @ (posedge(clk)) begin
  R <= r2; Q <= q1;
  S <= run ? S+1 : 0;
end
endmodule
