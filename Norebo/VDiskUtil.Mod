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
(* Project Norebo
 * Copyright (C)2019 Peter De Wachter
 *
 * Released under the following notice:
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

MODULE VDiskUtil;
  IMPORT Files, VDisk, VFileDir, VFiles, Texts, Oberon;

  VAR W: Texts.Writer;
      S: ARRAY 3 OF RECORD
           l: INTEGER;
           s: ARRAY 6 OF CHAR;
         END;

  PROCEDURE EndLine;
  BEGIN Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
  END EndLine;

  PROCEDURE OldVDisk*(name: ARRAY OF CHAR): VDisk.VDisk;
    VAR V: VDisk.VDisk;
      f: Files.File;
  BEGIN V := NIL; f := Files.Old(name);
    IF f # NIL THEN
      VDisk.Open(V, f);
      VFileDir.Init(V)
    END ;
    RETURN V
  END OldVDisk;

  PROCEDURE InstallFile*(v: VDisk.VDisk; srcname, dstname: ARRAY OF CHAR);
    VAR f: Files.File;
      g: VFiles.File;
      Rf: Files.Rider;
      Rg: VFiles.Rider;
      b: BYTE;
      l, s: INTEGER;
      i, j: INTEGER;
  BEGIN
    Texts.WriteString(W, "  copying "); Texts.WriteString(W, srcname);
    Texts.WriteString(W, " => "); Texts.WriteString(W, dstname);
    Texts.Append(Oberon.Log, W.buf);
    f := Files.Old(srcname);
    IF f # NIL THEN g := VFiles.New(v, dstname);
      l := 0; WHILE dstname[l] # 00X DO INC(l); END;
      s := 0; WHILE s < LEN(S) DO
        i := l; j := S[s].l;
        WHILE (i > 0) AND (j > 0) AND (dstname[i - 1] = S[s].s[j - 1]) DO DEC(i); DEC(j); END;
        IF j = 0 THEN s := LEN(S); ELSE INC(s); END
      END;
      Files.Set(Rf, f, 0); VFiles.Set(Rg, g, 0); Files.ReadByte(Rf, b);
      IF j = 0 THEN
        WHILE NOT Rf.eof DO
          IF b = 0AH THEN b := 0DH; END;
          VFiles.WriteByte(Rg, b); Files.ReadByte(Rf, b);
        END;
      ELSE
        WHILE NOT Rf.eof DO VFiles.WriteByte(Rg, b); Files.ReadByte(Rf, b); END;
      END;
      Files.Close(f); VFiles.Register(g); VFiles.Close(g)
    ELSE Texts.WriteString(W, " failed")
    END;
    EndLine
  END InstallFile;

  PROCEDURE InstallFiles*;
    VAR S: Texts.Scanner;
      name: ARRAY 32 OF CHAR;
      V: VDisk.VDisk;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      V := OldVDisk(S.s);
      IF V # NIL THEN Texts.Scan(S);
        WHILE S.class = Texts.Name DO
          name := S.s; Texts.Scan(S);
          IF (S.class = Texts.Char) AND (S.c = "=") THEN Texts.Scan(S);
            IF (S.class = Texts.Char) AND (S.c = ">") THEN Texts.Scan(S);
              IF S.class = Texts.Name THEN
                InstallFile(V, name, S.s); Texts.Scan(S)
              END
            END
          END
        END
      END
    END
  END InstallFiles;

BEGIN
  Texts.OpenWriter(W);
  S[0].s := ".Mod";  S[0].l := 4;
  S[1].s := ".Text"; S[1].l := 5;
  S[2].s := ".Tool"; S[2].l := 5;
END VDiskUtil.
