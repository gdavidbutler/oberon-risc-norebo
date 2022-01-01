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

MODULE RISC;     (*NW 22.9.07 / 1.11.2013*)
  IMPORT SYSTEM, Texts, Oberon;
  CONST
    MOV = 0; LSL = 1; ASR = 2; ROR = 3; AND = 4; ANN = 5; IOR = 6; XOR = 7;
    ADD = 8; SUB = 9;  MUL = 10; Div = 11;

  VAR IR: INTEGER;   (*instruction register*)
    PC: INTEGER;   (*program counter*)
    N, Z: BOOLEAN;  (*condition flags*)
    R: ARRAY 16 OF INTEGER;
    H: INTEGER;  (*aux register for division*)

  PROCEDURE Execute*(VAR M: ARRAY OF INTEGER; pc: INTEGER;
      VAR S: Texts.Scanner; VAR W: Texts.Writer);
    VAR a, b, op, im: INTEGER;  (*instruction fields*)
      adr, A, B, C, n: INTEGER;
      MemSize: INTEGER;
  BEGIN PC := 0; R[13] := pc * 4; R[14] := LEN(M)*4; n := 0;
    REPEAT (*interpretation cycle*)
      IR := M[PC]; INC(PC); INC(n);
      a := IR DIV 1000000H MOD 10H;
      b := IR DIV 100000H MOD 10H;
      op := IR DIV 10000H MOD 10H;
      im := IR MOD 10000H;
      IF NOT ODD(IR DIV 80000000H) THEN  (* not p:  register instruction*)
        B := R[b];
        IF NOT ODD(IR DIV 40000000H) THEN (* not q*) C := R[IR MOD 10H]
        ELSIF NOT ODD(IR DIV 10000000H) THEN (*q and not v*) C := im
        ELSE (*q and v*) C := im + 0FFFF0000H
        END ;
        CASE op OF
            MOV: IF NOT ODD(IR DIV 20000000H) THEN A := C ELSE A := H END |
            LSL: A := SYSTEM.LSH(B, C) |
            ASR: A := ASH(B, -C) |
            ROR: A := SYSTEM.ROT(B, -C) |
            AND: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) * SYSTEM.VAL(SET, C)) |
            ANN: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) - SYSTEM.VAL(SET, C)) |
            IOR: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) + SYSTEM.VAL(SET, C)) |
            XOR: A := SYSTEM.VAL(INTEGER, SYSTEM.VAL(SET, B) / SYSTEM.VAL(SET, C)) |
            ADD: A := B + C |
            SUB: A := B - C |
            MUL: A := B * C |
            Div: A := B DIV C; H := B MOD C
         END ;
         R[a] := A; N := A < 0; Z := A = 0
      ELSIF NOT ODD(IR DIV 40000000H) THEN (*p and not q: memory instruction*)
        adr := (R[b] + IR MOD 100000H) DIV 4;
        IF NOT ODD(IR DIV 20000000H) THEN
          IF adr >= 0 THEN (*load*) R[a] := M[adr]; N := A < 0; Z := A = 0
          ELSE (*input*)
            IF adr = -1 THEN (*ReadInt*) Texts.Scan(S); R[a] := S.i;
            ELSIF adr = -2 THEN (*eot*)  Z := S.class # Texts.Int
            END
          END
        ELSE
          IF adr >= 0 THEN (*store*) M[adr] := R[a];
          ELSE (*output*)
            IF adr = -1 THEN Texts.WriteInt(W, R[a], 4)
            ELSIF adr = -2 THEN Texts.Write(W, CHR(R[a] MOD 80H))
            ELSIF adr = -3 THEN Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
            END
          END
        END
      ELSE (* p and  q: branch instruction*)
        IF (a = 0) AND N OR (a = 1) AND Z OR (a = 5) AND N OR (a = 6) AND (N OR Z) OR (a = 7) OR
            (a = 8) AND NOT N OR (a = 9) AND NOT Z OR (a = 13) AND NOT N OR (a = 14) AND NOT (N OR Z) THEN
          IF ODD(IR DIV 10000000H) THEN R[15] := PC * 4 END ;
          IF ODD(IR DIV 20000000H) THEN PC := (PC + (IR MOD 1000000H)) MOD 40000H
          ELSE PC := R[IR MOD 10H] DIV 4
          END
        END
      END
    UNTIL (PC = 0) OR (n = 100000);
    Texts.WriteInt(W, n, 8);
    IF n = 100000 THEN Texts.WriteString(W, " aborted") END ;
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Execute;
END RISC.
