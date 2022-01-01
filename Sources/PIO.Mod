(*
 * Oberon - language, compiler and system
 * Copyright (C) 2022 G. David Butler <gdb@dbSystems.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *)
(*
 * Project Oberon, Revised Edition 2013
 * Copyright (C)2013 Niklaus Wirth (NW), Juerg Gutknecht (JG), Paul Reed (PR/PDR).
 *
 * Permission to use, copy, modify, and/or distribute this software and its
 * accompanying documentation (the "Software") for any purpose with or
 * without fee is hereby granted, provided that the above copyright notice
 * and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
 * WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.
 *)

MODULE PIO;   (*NW 16.10.2014  PIC Input/Output for RISC*)
  IMPORT SYSTEM;

(* PIC interface, output:
  D0  =  PIC B7  data out
  D1  =  PIC B6  clk  out
  D2  =  PIC A4  data in *)

  CONST gpio = -32; gpoc = -28;  (*I/O addresses*)

  PROCEDURE del(i: INTEGER);
  BEGIN
    REPEAT DEC(i) UNTIL i = 0
  END del;

  PROCEDURE Send*(x: INTEGER);
    VAR i: INTEGER;
  BEGIN (*send byte*)
    FOR i := 0 TO 7 DO
      SYSTEM.PUT(gpio, x MOD 2 + 2); del(60); SYSTEM.PUT(gpio, x MOD 2); del(25); x := x DIV 2
    END ;
    SYSTEM.PUT(gpio, 0); del(100)
  END Send;

  PROCEDURE Receive*(VAR x: INTEGER);
    VAR i, x0: INTEGER;
  BEGIN (*receive byte*) x0 := 0;
    REPEAT UNTIL NOT SYSTEM.BIT(gpio, 2);
    FOR i := 0 TO 7 DO
      SYSTEM.PUT(gpio, 2); del(60);
      IF SYSTEM.BIT(gpio, 2) THEN x0 := x0 + 100H END ;
      SYSTEM.PUT(gpio, 0); del(25); x0 := ROR(x0, 1)
    END ;
    x := x0
  END Receive;

  PROCEDURE Reset*;
  BEGIN SYSTEM.PUT(gpio, 0); SYSTEM.PUT(gpoc, 3)  (*set bit 0, 1 to output*)
  END Reset;

BEGIN Reset
END PIO.
