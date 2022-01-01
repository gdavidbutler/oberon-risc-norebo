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

MODULE Files;  (*derived from NW 11.1.86 / 22.9.93 / 25.5.95 / 25.12.95 / 15.8.2013*)
  IMPORT SYSTEM, Kernel, FileDir, Norebo;

  TYPE File* = POINTER TO FileDesc;

    Rider* =
      RECORD eof*: BOOLEAN;
        res*: INTEGER;
        file: File;
        pos: INTEGER;
      END ;

    FileDesc =
      RECORD handle, pos: INTEGER;
        registered: BOOLEAN;
        name: FileDir.FileName;
      END ;

  PROCEDURE Check(s: ARRAY OF CHAR;
        VAR name: FileDir.FileName; VAR res: INTEGER);
    VAR i: INTEGER; ch: CHAR;
  BEGIN ch := s[0]; i := 0;
    IF (ch >= "A") AND (ch <= "Z") OR (ch >= "a") AND (ch <= "z") THEN
      REPEAT name[i] := ch; INC(i); ch := s[i]
      UNTIL NOT ((ch >= "0") AND (ch <= "9") OR (ch >= "A") AND (ch <= "Z")
        OR (ch >= "a") AND (ch <= "z") OR (ch = ".")) OR (i = FileDir.FnLength);
      IF i = FileDir.FnLength THEN res := 4
      ELSIF ch = 0X THEN res := 0;
        WHILE i < FileDir.FnLength DO name[i] := 0X; INC(i) END
      ELSE res := 5
      END
    ELSIF ch = 0X THEN name[0] := 0X; res := -1
    ELSE res := 3
    END
  END Check;

  PROCEDURE Old*(name: ARRAY OF CHAR): File;
    VAR res: INTEGER;
      f: File;
      namebuf: FileDir.FileName;
  BEGIN f := NIL; Check(name, namebuf, res);
    IF res = 0 THEN
      Norebo.SysReq(Norebo.filesOld, SYSTEM.ADR(namebuf), 0, 0);
      IF Norebo.res >= 0 THEN
        NEW(f); f.handle := Norebo.res; f.pos := 0; f.name := namebuf; f.registered := TRUE;
      END
    END
    RETURN f
  END Old;

  PROCEDURE New*(name: ARRAY OF CHAR): File;
    VAR res: INTEGER;
      f: File;
      namebuf: FileDir.FileName;
  BEGIN f := NIL; Check(name, namebuf, res);
    IF res <= 0 THEN
      Norebo.SysReq(Norebo.filesNew, SYSTEM.ADR(namebuf), 0, 0);
      IF Norebo.res >= 0 THEN
        NEW(f); f.handle := Norebo.res; f.pos := 0; f.name := namebuf; f.registered := FALSE
      END
    END
    RETURN f
  END New;

  PROCEDURE Register*(f: File);
  BEGIN
    IF (f # NIL) AND (f.name[0] # 0X) AND NOT f.registered THEN
      Norebo.SysReq(Norebo.filesRegister, f.handle, 0, 0);
      f.registered := TRUE; f.pos := -1
    END
  END Register;

  PROCEDURE Close*(f: File);
  BEGIN
    IF f # NIL THEN Norebo.SysReq(Norebo.filesClose, f.handle, 0, 0) END
  END Close;

  PROCEDURE Purge*(f: File);
  BEGIN
    IF f # NIL THEN Norebo.SysReq(Norebo.filesPurge, f.handle, 0, 0) END
  END Purge;

  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);
    VAR namebuf: FileDir.FileName;
  BEGIN Check(name, namebuf, res);
    IF res = 0 THEN
      Norebo.SysReq(Norebo.filesDelete, SYSTEM.ADR(namebuf), 0, 0);
      IF Norebo.res < 0 THEN res := 2 END
    END
  END Delete;

  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);
    VAR oldbuf, newbuf: FileDir.FileName;
  BEGIN Check(old, oldbuf, res);
    IF res = 0 THEN
      Check(new, newbuf, res);
      IF res = 0 THEN
        Norebo.SysReq(Norebo.filesRename, SYSTEM.ADR(oldbuf), SYSTEM.ADR(newbuf), 0);
        IF Norebo.res < 0 THEN res := 2 END
      END
    END
  END Rename;

  PROCEDURE Length*(f: File): INTEGER;
  BEGIN Norebo.SysReq(Norebo.filesLength, f.handle, 0, 0)
    RETURN Norebo.res
  END Length;

  PROCEDURE Date*(f: File): INTEGER;
  BEGIN Norebo.SysReq(Norebo.filesDate, f.handle, 0, 0)
    RETURN Norebo.res
  END Date;

  (*---------------------------Read---------------------------*)

  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);
    VAR a, b: INTEGER;
  BEGIN  r.file := f; r.eof := FALSE; r.res := 0;
    IF pos >= 0 THEN r.pos := pos ELSE r.pos := 0 END
  END Set;

  PROCEDURE Pos*(VAR r: Rider): INTEGER;
  BEGIN RETURN r.pos
  END Pos;

  PROCEDURE Base*(VAR r: Rider): File;
  BEGIN RETURN r.file
  END Base;

  PROCEDURE ReadRaw(VAR r: Rider; adr, siz: INTEGER);
  BEGIN
    IF r.pos # r.file.pos THEN
      Norebo.SysReq(Norebo.filesSeek, r.file.handle, r.pos, 0);
    END;
    Norebo.SysReq(Norebo.filesRead, r.file.handle, adr, siz);
    INC(r.pos, Norebo.res); r.file.pos := r.pos;
    r.eof := Norebo.res < siz
  END ReadRaw;

  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);
  BEGIN ReadRaw(r, SYSTEM.ADR(x), SYSTEM.SIZE(BYTE))
  END ReadByte;

  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);
  BEGIN ASSERT(n <= LEN(x)); ReadRaw(r, SYSTEM.ADR(x), n)
  END ReadBytes;

  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);
  BEGIN ReadRaw(r, SYSTEM.ADR(ch), SYSTEM.SIZE(CHAR))
  END Read;

  PROCEDURE ReadInt*(VAR r: Rider; VAR x: INTEGER);
  BEGIN ReadRaw(r, SYSTEM.ADR(x), SYSTEM.SIZE(INTEGER))
  END ReadInt;

  PROCEDURE ReadSet*(VAR r: Rider; VAR s: SET);
  BEGIN ReadInt(r, SYSTEM.VAL(INTEGER, s))
  END ReadSet;

  PROCEDURE ReadReal*(VAR r: Rider; VAR x: REAL);
  BEGIN ReadInt(r, SYSTEM.VAL(INTEGER, x))
  END ReadReal;

  PROCEDURE ReadString*(VAR r: Rider; VAR x: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0; Read(r, ch);
    WHILE ch # 0X DO
      IF i < LEN(x)-1 THEN x[i] := ch; INC(i) END ;
      Read(r, ch)
    END ;
    x[i] := 0X
  END ReadString;

  PROCEDURE ReadNum*(VAR r: Rider; VAR x: INTEGER);
    VAR n, y: INTEGER; b: BYTE;
  BEGIN n := 32; y := 0; ReadByte(r, b);
    WHILE b >= 80H DO y := ROR(y + b-80H, 7); DEC(n, 7); ReadByte(r, b) END ;
    IF n <= 4 THEN x := ROR(y + b MOD 10H, 4) ELSE x := ASR(ROR(y + b, 7), n-7) END
  END ReadNum;

  (*---------------------------Write---------------------------*)

  PROCEDURE WriteRaw(VAR r: Rider; adr, siz: INTEGER);
  BEGIN
    IF r.pos # r.file.pos THEN
      Norebo.SysReq(Norebo.filesSeek, r.file.handle, r.pos, 0);
    END;
    Norebo.SysReq(Norebo.filesWrite, r.file.handle, adr, siz);
    INC(r.pos, Norebo.res); r.file.pos := r.pos;
    r.eof := Norebo.res < siz
  END WriteRaw;

  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);
  BEGIN WriteRaw(r, SYSTEM.ADR(x), SYSTEM.SIZE(BYTE))
  END WriteByte;

  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);
  BEGIN ASSERT(n <= LEN(x)); WriteRaw(r, SYSTEM.ADR(x), n)
  END WriteBytes;

  PROCEDURE Write*(VAR r: Rider; ch: CHAR);
  BEGIN WriteRaw(r, SYSTEM.ADR(ch), SYSTEM.SIZE(CHAR))
  END Write;

  PROCEDURE WriteInt*(VAR r: Rider; x: INTEGER);
  BEGIN WriteRaw(r, SYSTEM.ADR(x), SYSTEM.SIZE(INTEGER))
  END WriteInt;

  PROCEDURE WriteSet*(VAR r: Rider; s: SET);
  BEGIN WriteInt(r, ORD(s))
  END WriteSet;

  PROCEDURE WriteReal*(VAR r: Rider; x: REAL);
  BEGIN WriteInt(r, ORD(x))
  END WriteReal;

  PROCEDURE WriteString*(VAR r: Rider; x: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0;
    REPEAT ch := x[i]; Write(r, ch); INC(i) UNTIL ch = 0X
  END WriteString;

  PROCEDURE WriteNum*(VAR r: Rider; x: INTEGER);
  BEGIN
    WHILE (x < -40H) OR (x >= 40H) DO WriteByte(r, x MOD 80H + 80H); x := ASR(x, 7) END ;
    WriteByte(r, x MOD 80H)
  END WriteNum;

  (*---------------------------System use---------------------------*)

  PROCEDURE Init*;
  BEGIN Kernel.Init; FileDir.Init
  END Init;

  PROCEDURE RestoreList*; (*after mark phase of garbage collection*)
  END RestoreList;

END Files.
