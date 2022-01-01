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

`timescale 1ns / 1ps  // 1.2.2018
// register file, triple-port

module Registers(
  input clk,wr,
  input [3:0] rno0, rno1, rno2,
  input [31:0] din,
  output [31:0] dout0, dout1, dout2);
genvar i;
generate    //triple port register file, duplicated LUT array
	for (i = 0; i < 32; i = i+1)
	begin: rf32
	RAM16X1D # (.INIT(16'h0000))
	rfb(
	.DPO(dout1[i]), // data out
	.SPO(dout0[i]),
	.A0(rno0[0]),   // R/W address, controls D and SPO
	.A1(rno0[1]),
	.A2(rno0[2]),
	.A3(rno0[3]),
	.D(din[i]),  // data in
	.DPRA0(rno1[0]), // read-only adr, controls DPO
	.DPRA1(rno1[1]),
	.DPRA2(rno1[2]),
	.DPRA3(rno1[3]),
	.WCLK(clk),
	.WE(wr));

	RAM16X1D # (.INIT(16'h0000))
	rfc(
	.DPO(dout2[i]), // data out
	.SPO(),
	.A0(rno0[0]),   // R/W address, controls D and SPO
	.A1(rno0[1]),
	.A2(rno0[2]),
	.A3(rno0[3]),
	.D(din[i]),  // data in
	.DPRA0(rno2[0]), // read-only adr, controls DPO
	.DPRA1(rno2[1]),
	.DPRA2(rno2[2]),
	.DPRA3(rno2[3]),
	.WCLK(clk),
	.WE(wr));
	end
endgenerate
endmodule
