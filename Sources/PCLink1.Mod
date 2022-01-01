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

MODULE PCLink1;  (*NW 25.7.2013  for Oberon on RISC*)
  IMPORT SYSTEM, Files, Texts, Oberon;

  CONST data = -56; stat = -52;
    BlkLen = 255;
    REQ = 20H; REC = 21H; SND = 22H; ACK = 10H; NAK = 11H;

  VAR T: Oberon.Task;
    W: Texts.Writer;

  PROCEDURE Rec(VAR x: BYTE);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(stat, 0);
    SYSTEM.GET(data, x)
  END Rec;

  PROCEDURE RecName(VAR s: ARRAY OF CHAR);
    VAR i: INTEGER; x: BYTE;
  BEGIN i := 0; Rec(x);
    WHILE x > 0 DO s[i] := CHR(x); INC(i); Rec(x) END ;
    s[i] := 0X
  END RecName;

  PROCEDURE Send(x: BYTE);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(stat, 1);
    SYSTEM.PUT(data, x)
  END Send;

  PROCEDURE Task;
    VAR len, n, i: INTEGER;
      x, ack, len1, code: BYTE;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      buf: ARRAY 256 OF BYTE;
  BEGIN
    IF  SYSTEM.BIT(stat, 0) THEN (*byte available*)
      Rec(code);
        IF code = SND THEN  (*send file*)
          LED(20H); RecName(name); F := Files.Old(name);
          IF F # NIL THEN
            Texts.WriteString(W, "sending "); Texts.WriteString(W, name);
            Texts.Append(Oberon.Log, W.buf);
            Send(ACK); len := Files.Length(F); Files.Set(R, F, 0);
            REPEAT
              IF len >= BlkLen THEN len1 := BlkLen ELSE len1 := len END ;
              Send(len1); n := len1; len := len - len1;
              WHILE n > 0 DO Files.ReadByte(R, x); Send(x); DEC(n) END ;
              Rec(ack);
              IF ack # ACK THEN  len1 := 0 END
            UNTIL len1 < BlkLen;
            Texts.WriteString(W, " done"); Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
          ELSE Send(11H)
          END
        ELSIF code = REC THEN (*receive file*)
          LED(30H); RecName(name); F := Files.New(name);
          IF F # NIL THEN
            Texts.WriteString(W, "receiving "); Texts.WriteString(W, name);
            Texts.Append(Oberon.Log, W.buf);
            Files.Set(R, F, 0); Send(ACK);
            REPEAT Rec(x); len := x; i := 0;
              WHILE i < len DO Rec(x); buf[i] := x; INC(i) END ;
              i := 0;
              WHILE i < len DO Files.WriteByte(R, buf[i]); INC(i) END ;
              Send(ACK)
            UNTIL len < 255;
            Files.Register(F); Send(ACK);
            Texts.WriteString(W, " done"); Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
          ELSE Send(NAK)
          END
        ELSIF code = REQ THEN Send(ACK)
        END ;
      LED(0)
    END
  END Task;

  PROCEDURE Run*;
  BEGIN Oberon.Install(T); Texts.WriteString(W, "PCLink started");
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Run;

  PROCEDURE Stop*;
  BEGIN Oberon.Remove(T); Texts.WriteString(W, "PCLink stopped");
    Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END Stop;

BEGIN Texts.OpenWriter(W); T := Oberon.NewTask(Task, 0)
END PCLink1.
