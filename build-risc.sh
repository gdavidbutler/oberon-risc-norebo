#!/bin/sh

if test -e build-risc; then
  echo "Build directory already exists, delete it using 'rm -r build-risc' first."
  exit 1
fi
ROOT=$PWD
make
mkdir build-risc
cd build-risc

# build risc compiler with Bootstrap compiler
mkdir norebo
cd norebo
NOREBO_PATH=$ROOT/Norebo:$ROOT/RISC:$ROOT/Sources:$ROOT/Bootstrap $ROOT/run ORP.Compile Norebo.Mod Kernel.Mod FileDir.Mod Files.Mod Modules.Mod Fonts.Mod Texts.Mod RS232.Mod Oberon.Mod CoreLinker.Mod ORS.Mod ORB.Mod ORG.Mod ORP.Mod VDisk.Mod VFileDir.Mod VFiles.Mod VDiskUtil.Mod
for i in *.rsc;do mv $i `basename $i .rsc`.rsx;done
NOREBO_PATH=$ROOT/Bootstrap $ROOT/run CoreLinker.LinkSerial Modules InnerCore
for i in *.rsx;do mv $i `basename $i .rsx`.rsc;done
# Remove created symbol files so re-created in next stage
rm *.smb
cd ..

# build risc system with risc compiler
echo
mkdir oberon
cd oberon
NOREBO_PATH=$ROOT/RISC:$ROOT/Sources:../norebo $ROOT/run ORP.Compile Kernel.Mod FileDir.Mod Files.Mod Modules.Mod Input.Mod Display.Mod Viewers.Mod Fonts.Mod Texts.Mod Oberon.Mod MenuViewers.Mod TextFrames.Mod System.Mod Edit.Mod SCC.Mod ORS.Mod ORB.Mod ORG.Mod ORP.Mod ORTool.Mod Graphics.Mod GraphicFrames.Mod Draw.Mod GraphTool.Mod Rectangles.Mod Curves.Mod Blink.Mod Checkers.Mod EBNF.Mod Hilbert.Mod MacroTool.Mod Math.Mod PCLink1.Mod RS232.Mod Sierpinski.Mod Stars.Mod Tools.Mod Clipboard.Mod
for i in *.rsc;do mv $i `basename $i .rsc`.rsx;done
cd ..

# build risc image
echo
NOREBO_PATH=oberon:$ROOT/Bootstrap $ROOT/run CoreLinker.LinkDisk Modules Oberon.dsk
ARG=`(ls $ROOT/RISC; ls $ROOT/Sources; ls $ROOT/Fnt; ls oberon) | awk '{
  split($1, e, ".");
  if (e[2] == "rsx")
    printf("%s.rsx=>%s.rsc\n", e[1], e[1]);
  else
   printf("%s=>%s\n", $1, $1);
}'`
NOREBO_PATH=$ROOT/RISC:$ROOT/Sources:$ROOT/Fnt:oberon:$ROOT/Bootstrap $ROOT/run VDiskUtil.InstallFiles Oberon.dsk $ARG
