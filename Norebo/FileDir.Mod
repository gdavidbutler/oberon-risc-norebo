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

MODULE FileDir;
  IMPORT SYSTEM, Norebo;

  CONST FnLength* = 32;

  TYPE FileName*  = ARRAY FnLength OF CHAR;
    EntryHandler* = PROCEDURE (name: FileName; unused: INTEGER; VAR continue: BOOLEAN);

  PROCEDURE Enumerate*(prefix: ARRAY OF CHAR; proc: EntryHandler);
    VAR name: FileName;
      continue: BOOLEAN;
      i: INTEGER;
      pfx, nmx: CHAR;
  BEGIN continue := TRUE;
    Norebo.SysReq(Norebo.filedirEnumerateBegin, 0, 0, 0);
    Norebo.SysReq(Norebo.filedirEnumerateNext, SYSTEM.ADR(name), 0, 0);
    WHILE continue AND (Norebo.res = 0) DO
      i := 0;
      REPEAT pfx := prefix[i]; nmx := name[i]; INC(i)
      UNTIL (pfx # nmx) OR (pfx = 0X);
      IF pfx = 0X THEN proc(name, 0, continue) END;
      Norebo.SysReq(Norebo.filedirEnumerateNext, SYSTEM.ADR(name), 0, 0)
    END;
    Norebo.SysReq(Norebo.filedirEnumerateEnd, 0, 0, 0)
  END Enumerate;

  PROCEDURE Init*;
  END Init;

END FileDir.
