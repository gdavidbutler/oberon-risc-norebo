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

`timescale 1ns / 1ps  // NW 9.11.2016

module LeftShifter(
input [31:0] x,
input [4:0] sc,
output [31:0] y);

// shifter for LSL
wire [1:0] sc0, sc1;
wire [31:0] t1, t2;

assign sc0 = sc[1:0];
assign sc1 = sc[3:2];

assign t1 = (sc0 == 3) ? {x[28:0], 3'b0} :
    (sc0 == 2) ? {x[29:0], 2'b0} :
    (sc0 == 1) ? {x[30:0], 1'b0} : x;
assign t2 = (sc1 == 3) ? {t1[19:0], 12'b0} :
    (sc1 == 2) ? {t1[23:0], 8'b0} :
    (sc1 == 1) ? {t1[27:0], 4'b0} : t1;
assign y = sc[4] ? {t2[15:0], 16'b0} : t2;
endmodule
