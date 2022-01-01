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

MODULE  ORC;  (*Connection to RISC; NW 11.11.2013*)
  IMPORT SYSTEM, Files, Texts, Oberon, V24;
  CONST portno = 1; (*RS-232*)
    BlkLen = 255; pno = 1;
    REQ = 20X; REC = 21X; SND = 22X; CLS = 23X; ACK = 10X;
    Tout = 1000;

  VAR res: INTEGER;
    W: Texts.Writer;

  PROCEDURE Flush*;
    VAR ch: CHAR;
  BEGIN
    WHILE V24.Available(portno) > 0 DO V24.Receive(portno, ch, res); Texts.Write(W, ch) END ;
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Flush;

  PROCEDURE Open*;
    VAR ch: CHAR;
  BEGIN V24.Start(pno, 19200, 8, V24.ParNo, V24.Stop1, res);
    WHILE V24.Available(pno) > 0 DO V24.Receive(pno, ch, res) END ;
    IF res > 0 THEN Texts.WriteString(W, "open V24, error ="); Texts.WriteInt(W, res, 4)
    ELSE Texts.WriteString(W, "connection open")
    END ;
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Open;

  PROCEDURE TestReq*;
    VAR ch: CHAR;
  BEGIN V24.Send(pno, REQ, res); Rec(ch); Texts.WriteInt(W, ORD(ch), 4);
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END TestReq;

  PROCEDURE SendInt(x: INTEGER);
    VAR i: INTEGER;
  BEGIN i := 4;
    WHILE i > 0 DO
      DEC(i); V24.Send(portno, CHR(x), res); x := x DIV 100H
    END
  END SendInt;

  PROCEDURE Load*;  (*linked boot file  F.bin*)
    VAR i, m, n, w: INTEGER;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN (*input file name*)
      Texts.WriteString(W, S.s); F := Files.Old(S.s);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.ReadLInt(R, n); Files.ReadLInt(R, m); n := n DIV 4;
        Texts.WriteInt(W, n, 6); Texts.WriteString(W, " loading "); Texts.Append(Oberon.Log, W.buf);
        i := 0; SendInt(n*4); SendInt(m);
        WHILE i < n DO
          IF i + 1024 < n THEN m := i + 1024 ELSE m := n END ;
          WHILE i < m DO Files.ReadLInt(R, w); SendInt(w); INC(i) END ;
          Texts.Write(W, "."); Texts.Append(Oberon.Log, W.buf)
        END ;
        SendInt(0); Texts.WriteString(W, "done")
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END Load;

(* ------------ send and receive files ------------ *)

  PROCEDURE Rec(VAR ch: CHAR);   (*receive with timeout*)
    VAR time: INTEGER;
  BEGIN time := Oberon.Time() + 3000;
    LOOP
      IF V24.Available(pno) > 0 THEN V24.Receive(pno, ch, res); EXIT END ;
      IF Oberon.Time() >= time THEN ch := 0X; EXIT END
    END
  END Rec;

  PROCEDURE SendName(VAR s: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0; ch := s[0];
    WHILE ch > 0X DO V24.Send(pno, ch, res); INC(i); ch := s[i] END ;
    V24.Send(pno, 0X, res)
  END SendName;

  PROCEDURE Send*;
    VAR ch, code: CHAR;
      n, n0, L: INTEGER;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN V24.Send(pno, REQ, res); Rec(code);
    IF code = ACK THEN
      Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
      WHILE S.class = Texts.Name DO
        Texts.WriteString(W, S.s); F := Files.Old(S.s);
        IF F # NIL THEN
          V24.Send(pno, REC, res); SendName(S.s); Rec(code);
          IF code = ACK THEN
            Texts.WriteString(W, " sending ");
            L := Files.Length(F); Files.Set(R, F, 0);
            REPEAT (*send paket*)
              IF L > BlkLen THEN n := BlkLen ELSE n := L END ;
              n0 := n; V24.Send(pno, CHR(n), res); DEC(L, n);
              WHILE n > 0 DO Files.Read(R, ch); V24.Send(pno, ch, res); DEC(n) END ;
              Rec(code);
              IF code = ACK THEN Texts.Write(W, ".") ELSE Texts.Write(W, "*"); n := 0 END ;
              Texts.Append(Oberon.Log, W.buf)
            UNTIL n0 < BlkLen;
            Rec(code)
          ELSE Texts.WriteString(W, " no response"); Texts.WriteInt(W, ORD(code), 4)
          END
        ELSE Texts.WriteString(W, " not found")
        END ;
        Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf); Texts.Scan(S)
      END
    ELSE Texts.WriteString(W, " connection not open");
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END Send;

  PROCEDURE Receive*;
    VAR ch, code: CHAR;
      n, L, LL: INTEGER;
      F: Files.File; R: Files.Rider;
      orgname: ARRAY 32 OF CHAR;
      S: Texts.Scanner;
  BEGIN V24.Send(pno, REQ, res); Rec(code);
    IF code = ACK THEN
      Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
      WHILE S.class = Texts.Name DO
        Texts.WriteString(W, S.s); COPY(S.s, orgname);
        F := Files.New(S.s); Files.Set(R, F, 0); LL := 0;
        V24.Send(pno, SND, res); SendName(S.s); Rec(code);
        IF code = ACK THEN
          Texts.WriteString(W, " receiving ");
          REPEAT Rec(ch); L := ORD(ch); n := L;
            WHILE n > 0 DO V24.Receive(pno, ch, res); Files.Write(R, ch); DEC(n) END ;
            V24.Send(pno, ACK, res); LL := LL + L; Texts.Write(W, "."); Texts.Append(Oberon.Log, W.buf)
          UNTIL L < BlkLen;
          Files.Register(F); Texts.WriteInt(W, LL, 6)
        ELSE Texts.WriteString(W, " no response"); Texts.WriteInt(W, ORD(code), 4)
        END ;
        Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf); Texts.Scan(S)
      END
    ELSE Texts.WriteString(W, " connection not open");
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END Receive;

  PROCEDURE Close*;
  BEGIN V24.Send(pno, CLS, res);
    Texts.WriteString(W, "Server closed"); Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Close;

(* ------------ Oberon-0 commands ------------ *)

  PROCEDURE RecByte(VAR ch: CHAR);
    VAR T: INTEGER; ch0: CHAR;
  BEGIN T := Oberon.Time() + Tout;
    REPEAT UNTIL (V24.Available(portno) > 0) OR (Oberon.Time() >= T);
    IF V24.Available(portno) > 0 THEN V24.Receive(portno, ch, res) ELSE ch := 0X END ;
  END RecByte;

  PROCEDURE RecInt(VAR x: INTEGER);
      VAR i, k, T: INTEGER; ch: CHAR;
  BEGIN i := 4; k := 0;
    REPEAT
      DEC(i); V24.Receive(portno, ch, res);
      k := SYSTEM.ROT(ORD(ch)+k, -8)
    UNTIL i = 0;
    x := k
  END RecInt;

  PROCEDURE SR*;  (*send, then receive sequence of items*)
    VAR S: Texts.Scanner; i, k: INTEGER; ch, xch: CHAR;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    WHILE (S.class # Texts.Char) AND (S.c # "~") DO
      IF S.class = Texts.Int THEN Texts.WriteInt(W, S.i, 6); SendInt(S.i)
      ELSIF S.class = Texts.Real THEN
        Texts.WriteReal(W, S.x, 12); SendInt(SYSTEM.VAL(INTEGER, S.x))
      ELSIF S.class IN {Texts.Name, Texts.String} THEN
        Texts.Write(W, " "); Texts.WriteString(W, S.s); i := 0;
        REPEAT ch := S.s[i]; V24.Send(portno, ch, res); INC(i) UNTIL ch = 0X
      ELSIF S.class = Texts.Char THEN Texts.Write(W, S.c)
      ELSE Texts.WriteString(W, "bad value")
      END ;
      Texts.Scan(S)
    END ;
    Texts.Write(W, "|"); (*Texts.Append(Oberon.Log, W.buf);*)
    (*receive input*)
    REPEAT RecByte(xch);
      IF xch = 0X THEN Texts.WriteString(W, " timeout"); Flush
      ELSIF xch = 1X THEN RecInt(k); Texts.WriteInt(W, k, 6)
      ELSIF xch = 2X THEN RecInt(k); Texts.WriteHex(W, k)
      ELSIF xch = 3X THEN RecInt(k); Texts.WriteReal(W, SYSTEM.VAL(REAL, k), 15)
      ELSIF xch = 4X THEN Texts.Write(W, " "); V24.Receive(portno, ch, res);
        WHILE ch > 0X DO Texts.Write(W, ch); V24.Receive(portno, ch, res) END
      ELSIF xch = 5X THEN V24.Receive(portno, ch, res); Texts.Write(W, ch)
      ELSIF xch = 6X THEN Texts.WriteLn(W)
      ELSIF xch = 7X THEN Texts.Write(W, "~"); xch := 0X
      ELSIF xch = 8X THEN RecByte(ch); Texts.WriteInt(W, ORD(ch), 4); Texts.Append(Oberon.Log, W.buf)
      ELSE xch := 0X
      END
    UNTIL xch = 0X;
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END SR;

BEGIN Texts.OpenWriter(W);
END ORC.
