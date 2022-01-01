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

MODULE GraphTool;  (*NW  8.8.2013*)
  IMPORT Files, Texts, Oberon;

  CONST Context = 0; Line = 1; Caption = 2; Macro = 3; Rectangles = 4;
  VAR W: Texts.Writer;

  PROCEDURE DecGraph*;
    VAR ch: CHAR;
      class, col, fno, cat, inx, libno: BYTE;
      xy, wh: INTEGER;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "decode "); Texts.WriteString(W, S.s);
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
      F := Files.Old(S.s);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.Read(R, ch);
        IF ch = 0F8X THEN
          Files.ReadByte(R, class);
          WHILE NOT R.eof AND (class < 255) DO
            Texts.WriteInt(W, class, 4);
            IF class = Context THEN
              Files.ReadByte(R, cat); Files.ReadByte(R, inx); Texts.WriteInt(W, cat, 4); Texts.WriteInt(W, inx, 4);
              Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
              IF cat = 2 THEN Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name) END
            ELSE Files.ReadInt(R, xy);
              Texts.WriteInt(W, xy * 10000H DIV 10000H, 5); Texts.WriteInt(W, xy DIV 10000H, 5);
              Files.ReadInt(R, wh);
              Texts.WriteInt(W, wh * 10000H DIV 10000H, 5); Texts.WriteInt(W, wh DIV 10000H, 5);
              Files.ReadByte(R, col); Files.Read(R, ch); Texts.WriteInt(W, col, 5); Texts.Write(W, "|");
              IF class = Line THEN
              ELSIF class = Caption THEN
                Files.ReadByte(R, fno);  Texts.WriteInt(W, fno, 5); Texts.Write(W, " ");
                Files.ReadString(R, name); Texts.WriteString(W, name)
              ELSIF class = Macro THEN
                Files.ReadByte(R, libno); Files.ReadString(R, name);
                Texts.WriteInt(W, libno, 4); Texts.Write(W, " "); Texts.WriteString(W, name)
              ELSIF class = Rectangles THEN
                Files.ReadByte(R, fno); Texts.WriteInt(W, fno, 4); Files.ReadByte(R, fno); Texts.WriteInt(W, fno, 4);
                Files.ReadByte(R, fno); Texts.WriteInt(W, fno, 4)
              ELSE Texts.WriteString(W, "other class ="); Texts.WriteInt(W, class, 4)
              END
            END ;
            Texts.WriteLn(W); Files.ReadByte(R, class)
          END
        ELSE Texts.WriteString(W, " not a graphics file")
        END
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END DecGraph;

  PROCEDURE DecGraph1*;
    VAR ch: CHAR;
      class, col, fno, len, lw, vers, cat, inx, libno: BYTE;
      xy, wh: INTEGER;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "decode "); Texts.WriteString(W, S.s);
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
      F := Files.Old(S.s);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.Read(R, ch);
        IF ch = 0FAX THEN
          Files.ReadByte(R, class);
          WHILE NOT R.eof AND (class < 255) DO
            Texts.WriteInt(W, class, 4);
            IF class = Context THEN
              Files.ReadByte(R, cat); Files.ReadByte(R, inx); Texts.WriteInt(W, cat, 4); Texts.WriteInt(W, inx, 4);
              Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
              IF cat = 2 THEN Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name) END
            ELSE Files.ReadInt(R, xy);
              Texts.WriteInt(W, xy * 10000H DIV 10000H, 5); Texts.WriteInt(W, xy DIV 10000H, 5);
              Files.ReadInt(R, wh);
              Texts.WriteInt(W, wh * 10000H DIV 10000H, 5); Texts.WriteInt(W, wh DIV 10000H, 5);
              Files.ReadByte(R, col); Texts.WriteInt(W, col, 5); Texts.Write(W, "|");
              IF class = Line THEN
              ELSIF class = Caption THEN
                Files.ReadByte(R, fno);  Texts.WriteInt(W, fno, 5); Texts.Write(W, " ");
                Files.ReadString(R, name); Texts.WriteString(W, name)
              ELSIF class = Macro THEN
                Files.ReadByte(R, libno); Files.ReadString(R, name);
                Texts.WriteInt(W, libno, 4); Texts.Write(W, " "); Texts.WriteString(W, name)
              ELSIF class = Rectangles THEN
                Files.ReadByte(R, len); Texts.WriteInt(W, len, 4);
                Files.ReadByte(R, lw); Texts.WriteInt(W, lw, 4);
                Files.ReadByte(R, vers); Texts.WriteInt(W, vers, 4)
              ELSE Texts.WriteString(W, "other class ="); Texts.WriteInt(W, class, 4)
              END
            END ;
            Texts.WriteLn(W); Files.ReadByte(R, class)
          END
        ELSE Texts.WriteString(W, " not a graphics file")
        END
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END DecGraph1;

  PROCEDURE DecLibrary1*;
    VAR ch: CHAR;
      class, col, fno, cat, inx, libno, len, lnw, vers: BYTE;
      xy, wh: INTEGER;
      name: ARRAY 32 OF CHAR;
      F: Files.File; R: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "decode library1 "); Texts.WriteString(W, S.s);
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
      F := Files.Old(S.s);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.Read(R, ch);
        IF ch = 0FBX THEN
          Files.ReadByte(R, class);
          WHILE (class < 255) AND NOT R.eof  DO
            WHILE class < 255  DO
              Texts.WriteInt(W, class, 4);
              IF class = Context THEN
                Files.ReadByte(R, cat); Files.ReadByte(R, inx); Texts.WriteInt(W, cat, 4); Texts.WriteInt(W, inx, 4);
                Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
                IF cat = 2 THEN Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name) END
              ELSE Files.ReadInt(R, xy);
                Texts.WriteInt(W, xy * 10000H DIV 10000H, 5); Texts.WriteInt(W, xy DIV 10000H, 5);
                Files.ReadInt(R, wh);
                Texts.WriteInt(W, wh * 10000H DIV 10000H, 5); Texts.WriteInt(W, wh DIV 10000H, 5);
                Files.ReadByte(R, col); Texts.WriteInt(W, col, 5);
                IF class = Line THEN
                ELSIF class = Caption THEN
                  Texts.Write(W, "|"); Files.ReadByte(R, fno);  Texts.WriteInt(W, fno, 5); Texts.Write(W, " ");
                  Files.ReadString(R, name); Texts.WriteString(W, name)
                ELSIF class = Rectangles THEN
                  Texts.Write(W, "|"); Files.ReadByte(R, len); Texts.WriteInt(W, len, 4);
                  Files.ReadByte(R, lnw); Texts.WriteInt(W, lnw, 4);
                  Files.ReadByte(R, vers); Texts.WriteInt(W, vers, 4)
                ELSE Texts.WriteString(W, "other class ="); Texts.WriteInt(W, class, 4)
                END
              END ;
              Texts.WriteLn(W); Files.ReadByte(R, class)
            END ;
            (*end macro*) Texts.WriteString(W, "---");
            Files.ReadInt(R, wh); Texts.WriteInt(W, wh MOD 10000H, 5); Texts.WriteInt(W, wh DIV 10000H, 5);
            Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
            Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf); Files.ReadByte(R, class)
          END
        ELSE Texts.WriteString(W, " not a graphics library")
        END
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END DecLibrary1;

  PROCEDURE ConvertFontname(VAR x: ARRAY OF CHAR);
  BEGIN (* Syntax --> Oberon *)
    IF (x[0] = "S") AND (x[1] = "y") AND (x[2] = "n") AND (x[3] = "t") AND (x[4] = "a") AND (x[5] = "x") THEN
      x[0] := "O"; x[1] := "b"; x[2] := "e"; x[3] := "r"; x[4] := "o"; x[5] := "n"
    END
  END ConvertFontname;

  PROCEDURE ConvertLibrary*;
    VAR ch: CHAR;
      class, col, fno, cat, inx, libno, len, lnw, vers: BYTE;
      xy, wh: INTEGER;
      name: ARRAY 32 OF CHAR;
      F, G: Files.File; R, Q: Files.Rider;
      S: Texts.Scanner;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, "convert library "); Texts.WriteString(W, S.s);
      F := Files.Old(S.s);
      IF F # NIL THEN
        Texts.Scan(S); G := Files.New(S.s);
        Texts.WriteString(W, " => "); Texts.WriteString(W, S.s);
        Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
        Files.Set(R, F, 0); Files.Set(Q, G, 0); Files.Read(R, ch);
        IF ch = 0FDX THEN
          Files.Write(Q, 0FBX); Files.ReadByte(R, class);
          WHILE (class < 255) AND NOT R.eof  DO
            WHILE class < 255  DO
              Files.WriteByte(Q, class);
              IF class = Context THEN
                Files.ReadByte(R, cat); Files.ReadByte(R, inx); Texts.WriteInt(W, cat, 4); Texts.WriteInt(W, inx, 4);
                Files.WriteByte(Q, cat); Files.WriteByte(Q, inx);
                Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name);
                IF cat = 0 THEN (*font*) ConvertFontname(name) END ;
                Files.WriteString(Q, name);
                IF cat = 2 THEN (*class*) Files.ReadString(R, name); Texts.Write(W, " "); Texts.WriteString(W, name); Files.WriteString(Q, name) END ;
                Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
              ELSE Files.ReadInt(R, xy); Files.WriteInt(Q, xy); Files.ReadInt(R, wh); Files.WriteInt(Q, wh);
                Files.ReadByte(R, col); Files.Read(R, ch); Files.WriteByte(Q, 1);
                IF class = Line THEN
                ELSIF class = Caption THEN
                  Files.ReadByte(R, fno); Files.WriteByte(Q, fno); Files.ReadString(R, name); Files.WriteString(Q, name)
                ELSIF class = Rectangles THEN
                  Files.ReadByte(R, len); Files.WriteByte(Q, len); Files.ReadByte(R, len);
                  Files.ReadByte(R, lnw); Files.WriteByte(Q, lnw);
                  Files.ReadByte(R, vers); Files.WriteByte(Q, vers)
                ELSE Texts.WriteString(W, "alien class "); Texts.WriteInt(W, class, 4)
                END
              END ;
              Files.ReadByte(R, class)
            END ;
            Files.WriteByte(Q, 255); (*end macro*) Files.ReadInt(R, wh); Files.WriteInt(Q, wh);
            Files.ReadString(R, name); Files.WriteString(Q, name);
            Texts.WriteString(W, name); Texts.WriteInt(W, wh MOD 10000H, 4); Texts.WriteInt(W, wh DIV 10000H, 4);
            Texts.WriteLn(W); Files.ReadByte(R, class)
          END
        ELSE Texts.WriteString(W, " not a graphics library")
        END ;
        Files.Register(G); Texts.WriteString(W, " done")
      ELSE Texts.WriteString(W, " not found")
      END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END ConvertLibrary;

BEGIN Texts.OpenWriter(W); Texts.WriteString(W, "GraphTool 8.8.2013");
  Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf);
END GraphTool.
