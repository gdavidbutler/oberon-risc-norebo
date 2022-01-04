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

MODULE Clipboard;
  IMPORT SYSTEM, Texts, Viewers, TextFrames, Oberon;

  CONST control = -24; data = -20;

  PROCEDURE Copy(T: Texts.Text; beg, end: INTEGER);
    VAR R: Texts.Reader;
      ch: CHAR;
  BEGIN
    Texts.OpenReader(R, T, beg);
    SYSTEM.PUT(control, end - beg);
    WHILE beg < end DO
      Texts.Read(R, ch);
      SYSTEM.PUT(data, ch);
      beg := beg + 1
    END
  END Copy;

  PROCEDURE CopySelection*;
    VAR T: Texts.Text;
      beg, end, time: INTEGER;
  BEGIN
    Oberon.GetSelection(T, beg, end, time);
    IF time >= 0 THEN Copy(T, beg, end) END
  END CopySelection;

  PROCEDURE CopyViewer*;
    VAR V: Viewers.Viewer;
      F: TextFrames.Frame;
  BEGIN
    V := Oberon.MarkedViewer();
    IF (V # NIL) AND (V.dsc # NIL) AND (V.dsc.next IS TextFrames.Frame) THEN
      F := V.dsc.next(TextFrames.Frame);
      Copy(F.text, 0, F.text.len)
    END
  END CopyViewer;

  PROCEDURE Paste*;
    VAR W: Texts.Writer;
      V: Viewers.Viewer;
      F: TextFrames.Frame;
      len, i: INTEGER;
      ch: CHAR;
  BEGIN
    V := Oberon.FocusViewer;
    IF (V # NIL) AND (V.dsc # NIL) AND (V.dsc.next IS TextFrames.Frame) THEN
      SYSTEM.GET(control, len);
      IF len > 0 THEN
        Texts.OpenWriter(W);
        FOR i := 1 TO len DO
          SYSTEM.GET(data, ch);
          Texts.Write(W, ch)
        END;
        F := V.dsc.next(TextFrames.Frame);
        Texts.Insert(F.text, F.carloc.pos, W.buf);
        TextFrames.SetCaret(F, F.carloc.pos + len)
      END
    END
  END Paste;

END Clipboard.
