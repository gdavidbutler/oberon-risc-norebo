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

MODULE MacroTool;  (*NW  6.8.2013*)
  IMPORT Texts, Oberon, Graphics, GraphicFrames;
  VAR W: Texts.Writer;

  PROCEDURE OpenMacro*;
    VAR F: GraphicFrames.Frame; sel: Graphics.Object;
  BEGIN (*expand selected macro to caret position*)
    F := GraphicFrames.Selected();
    IF F # NIL THEN
      sel := F.graph.sel;
      IF (sel # NIL) AND (sel IS Graphics.Macro) THEN
        GraphicFrames.Deselect(F);
        Graphics.OpenMac(sel(Graphics.Macro).mac, F.graph, F.mark.x - F.x, F.mark.y - F.y);
        GraphicFrames.Draw(F)
      END
    END
  END OpenMacro;

  PROCEDURE MakeMacro*;  (*lib mac*)
    (*compose macro from selected elements into caret area*)
    VAR newMac: BOOLEAN;
      machead: Graphics.MacHead;
      F: GraphicFrames.Frame;
      L: Graphics.Library;
      S: Texts.Scanner;
      Lname, Mname: ARRAY 32 OF CHAR;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Lname := S.s; Texts.Scan(S);
      IF (S.class  = Texts.Name) OR (S.class = Texts.String) AND (S.len <= 8) THEN
        F := GraphicFrames.Focus(); Mname := S.s;
        IF (F # NIL) AND (F.graph.sel # NIL) THEN
          Graphics.GetLib(Lname, FALSE, L);
          IF L = NIL THEN
            Texts.WriteString(W, "new library "); Texts.WriteString(W, Lname); Texts.WriteLn(W);
            L := Graphics.NewLib(Lname)
          END ;
          Graphics.MakeMac(F.graph, machead);
          IF machead # NIL THEN
            machead.name := Mname; Graphics.InsertMac(machead, L, newMac); Texts.WriteString(W, Mname);
            IF newMac THEN Texts.WriteString(W, " inserted in ") ELSE Texts.WriteString(W, " replaced in ") END ;
            Texts.WriteString(W, Lname)
          ELSE Texts.WriteString(W, " empty macro")
          END ;
          Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
        END
      END
    END
  END MakeMacro;

  PROCEDURE LoadLibrary*;  (*lib file name*)
    VAR S: Texts.Scanner; L: Graphics.Library;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
      Texts.WriteString(W, S.s); Graphics.GetLib(S.s, FALSE, L);
      IF L # NIL THEN Texts.WriteString(W, " loaded") ELSE Texts.WriteString(W, " not found") END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END LoadLibrary;

  PROCEDURE StoreLibrary*;  (*lib file name*)
    VAR i: INTEGER; S: Texts.Scanner; L: Graphics.Library;
  BEGIN Texts.OpenScanner(S, Oberon.Par.text, Oberon.Par.pos); Texts.Scan(S);
    IF S.class = Texts.Name THEN
       Graphics.StoreLib(L, S.s); Texts.WriteString(W, S.s);
       IF L # NIL THEN Texts.WriteString(W, " stored") ELSE Texts.WriteString(W, " not found") END ;
      Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
    END
  END StoreLibrary;

BEGIN Texts.OpenWriter(W); Texts.WriteString(W, "MacroTool - NW 6.8.2013");
  Texts.WriteLn(W); Texts.Append(Oberon.Log, W.buf)
END MacroTool.
