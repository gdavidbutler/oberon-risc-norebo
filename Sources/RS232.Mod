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

MODULE RS232;   (*NW 3.1.2012*)
  IMPORT SYSTEM;
  CONST data = -56; stat = -52;

  PROCEDURE Send*(x: INTEGER);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(stat, 1);
    SYSTEM.PUT(data, x)
  END Send;

  PROCEDURE Rec*(VAR x: INTEGER);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(stat, 0);
    SYSTEM.GET(data, x)
  END Rec;

  PROCEDURE SendInt*(x: INTEGER);
    VAR i: INTEGER;
  BEGIN Send(1); i := 4;
    REPEAT i := i-1; Send(x);  x := ROR(x, 8) UNTIL i = 0
  END SendInt;

  PROCEDURE SendHex*(x: INTEGER);
    VAR i: INTEGER;
  BEGIN Send(2); i := 4;
    REPEAT i := i-1; Send(x);  x := ROR(x, 8) UNTIL i = 0
  END SendHex;

  PROCEDURE SendReal*(x: REAL);
    VAR i, u: INTEGER;
  BEGIN Send(3); u := ORD(x); i := 4;
    REPEAT i := i-1; Send(u);  u := ROR(u, 8) UNTIL i = 0
  END SendReal;

  PROCEDURE SendStr*(x: ARRAY OF CHAR);
    VAR i, k: INTEGER;
  BEGIN Send(4); i := 0;
    REPEAT k := ORD(x[i]); Send(k); INC(i) UNTIL k = 0
  END SendStr;

  PROCEDURE RecInt*(VAR x: INTEGER);
    VAR i, x0, y: INTEGER;
  BEGIN i := 4; x0 := 0;
    REPEAT i := i-1; Rec(y); x0 := ROR(x0+y, 8) UNTIL i = 0;
    x := x0
  END RecInt;

  PROCEDURE RecReal*(VAR x: REAL);
    VAR i, x0, y: INTEGER;
  BEGIN i := 4; x0 := 0;
    REPEAT i := i-1; Rec(y); x0 := ROR(x0+y, 8) UNTIL i = 0;
    x := SYSTEM.VAL(REAL, x0)
  END RecReal;

  PROCEDURE RecStr*(VAR x: ARRAY OF CHAR);
    VAR i, k: INTEGER;
  BEGIN i := 0;
    REPEAT Rec(k); x[i] := CHR(k); INC(i) UNTIL k = 0
  END RecStr;

  PROCEDURE Line*;
  BEGIN Send(6)
  END Line;

  PROCEDURE End*;
  BEGIN Send(7)
  END End;

BEGIN END RS232.
