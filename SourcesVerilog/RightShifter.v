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

module RightShifter(
input [31:0] x,
input [4:0] sc,
input md,
output [31:0] y);

// shifter for ASR and ROR
wire [1:0] sc0, sc1;
wire [31:0] s1, s2;

assign sc0 = sc[1:0];
assign sc1 = sc[3:2];

assign s1 = (sc0 == 3) ? {(md ? x[2:0] : {3{x[31]}}), x[31:3]} :
    (sc0 == 2) ? {(md ? x[1:0] : {2{x[31]}}), x[31:2]} :
    (sc0 == 1) ? {(md ? x[0] : x[31]), x[31:1]} : x;

assign s2 = (sc1 == 3) ? {(md ? s1[11:0] : {12{s1[31]}}), s1[31:12]} :
    (sc1 == 2) ? {(md ? s1[7:0] : {8{s1[31]}}), s1[31:8]} :
    (sc1 == 1) ? {(md ? s1[3:0] : {4{s1[31]}}), s1[31:4]} : s1;
assign y = sc[4] ? {(md ? s2[15:0] : {16{s2[31]}}), s2[31:16]} : s2;
endmodule
