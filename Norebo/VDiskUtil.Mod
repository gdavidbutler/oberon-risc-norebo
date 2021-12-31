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
        WHILE (i > 0) & (j > 0) & (dstname[i - 1] = S[s].s[j - 1]) DO DEC(i); DEC(j); END;
        IF j = 0 THEN s := LEN(S); ELSE INC(s); END
      END;
      Files.Set(Rf, f, 0); VFiles.Set(Rg, g, 0); Files.ReadByte(Rf, b);
      IF j = 0 THEN
        WHILE ~Rf.eof DO
          IF b = 0AH THEN b := 0DH; END;
          VFiles.WriteByte(Rg, b); Files.ReadByte(Rf, b);
        END;
      ELSE
        WHILE ~Rf.eof DO VFiles.WriteByte(Rg, b); Files.ReadByte(Rf, b); END;
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
          IF (S.class = Texts.Char) & (S.c = "=") THEN Texts.Scan(S);
            IF (S.class = Texts.Char) & (S.c = ">") THEN Texts.Scan(S);
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
