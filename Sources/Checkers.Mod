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

MODULE Checkers;  (*NW 4.10.90 / 10.3.2013*)
  IMPORT SYSTEM, Display, Viewers, Oberon, MenuViewers, TextFrames;

  TYPE Frame = POINTER TO FrameDesc;

    FrameDesc = RECORD (Display.FrameDesc)
        col: INTEGER
      END ;

  VAR i: INTEGER;
    checks: INTEGER;
    pat: ARRAY 17 OF INTEGER;

  PROCEDURE Restore(F: Frame);
  BEGIN Oberon.RemoveMarks(F.X, F.Y, F.W, F.H);
    Display.ReplConst(Display.black, F.X, F.Y, F.W, F.H, Display.replace); (*clear*)
    Display.ReplPattern(F.col, checks, F.X+1, F.Y, F.W-1, F.H-1, Display.paint)
  END Restore;

  PROCEDURE Handle(G: Display.Frame; VAR M: Display.FrameMsg);
    VAR G1: Frame;
  BEGIN
    CASE G OF Frame:
      CASE M OF
      Oberon.InputMsg:
        IF M.id = Oberon.track THEN Oberon.DrawMouseArrow(M.X, M.Y) END |
      Oberon.CopyMsg:
        Oberon.RemoveMarks(G.X, G.Y, G.W, G.H); NEW(G1); G1^ := G^; M.F := G1 |
      MenuViewers.ModifyMsg:
        IF (M.Y # G.Y) OR (M.H # G.H) THEN G.Y := M.Y; G.H := M.H; Restore(G) END
      END
    END
  END Handle;

  PROCEDURE Open*;
    VAR F: Frame; V: Viewers.Viewer; X, Y: INTEGER;
  BEGIN NEW(F); F.col := 14; F.handle := Handle;
    Oberon.AllocateUserViewer(Oberon.Par.vwr.X, X, Y);
    V := MenuViewers.New(
      TextFrames.NewMenu("CheckerViewer", "System.Close System.Copy System.Grow"),
      F, TextFrames.menuH, X, Y)
  END Open;

BEGIN checks := SYSTEM.ADR(pat); pat[0] := 1010H; i := 1;
  REPEAT pat[i] := 0FF00FFH; INC(i) UNTIL i = 9;
  REPEAT pat[i] := 0FF00FF00H; INC(i) UNTIL i = 17
END Checkers.
