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

MODULE Norebo;
  IMPORT SYSTEM;

  CONST sysreq = -4; sysarg1 = -8; sysarg2 = -12; sysarg3 = -16;
    noreboHalt* = 1;
    noreboArgc* = 2;
    noreboArgv* = 3;
    noreboTrap* = 4;
    filesNew* = 11;
    filesOld* = 12;
    filesRegister* = 13;
    filesClose* = 14;
    filesSeek* = 15;
    filesTell* = 16;
    filesRead* = 17;
    filesWrite* = 18;
    filesLength* = 19;
    filesDate* = 20;
    filesDelete* = 21;
    filesPurge* = 22;
    filesRename* = 23;
    filedirEnumerateBegin* = 31;
    filedirEnumerateNext* = 32;
    filedirEnumerateEnd* = 33;

  VAR res*: INTEGER;

  PROCEDURE SysReq*(req, arg1, arg2, arg3: INTEGER);
  BEGIN
    SYSTEM.PUT(sysarg1, arg1);
    SYSTEM.PUT(sysarg2, arg2);
    SYSTEM.PUT(sysarg3, arg3);
    SYSTEM.PUT(sysreq, req);
    SYSTEM.GET(sysreq, res)
  END SysReq;

  PROCEDURE Halt*(exitcode: INTEGER);
  BEGIN SysReq(noreboHalt, exitcode, 0, 0)
  END Halt;

  PROCEDURE Trap*(trap, modname, pos: INTEGER);
  BEGIN SysReq(noreboTrap, trap, modname, pos);
  END Trap;

  PROCEDURE ParamCount*(): INTEGER;
  BEGIN SysReq(noreboArgc, 0, 0, 0)
    RETURN res
  END ParamCount;

  PROCEDURE ParamStr*(n: INTEGER; VAR param: ARRAY OF CHAR);
  BEGIN SysReq(noreboArgv, n, SYSTEM.ADR(param), LEN(param))
  END ParamStr;

END Norebo.
