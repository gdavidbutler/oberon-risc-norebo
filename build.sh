#!/bin/sh

if test -e build1 -o -e build2 -o -e build3; then
  echo "Build directories already exist, delete them using 'make clean' first."
  exit 1
fi

make

ROOT="$PWD"
COMPILE="ORP.Compile Norebo.Mod Kernel.Mod FileDir.Mod Files.Mod Modules.Mod Fonts.Mod Texts.Mod RS232.Mod Oberon.Mod CoreLinker.Mod ORS.Mod ORB.Mod ORG.Mod ORP.Mod VDisk.Mod VFileDir.Mod VFiles.Mod VDiskUtil.Mod"
LINK="CoreLinker.LinkSerial Modules InnerCore"

echo '=== Stage 1 ==='
mkdir build1
cd build1
NOREBO_PATH=$ROOT/Norebo:$ROOT/Host:$ROOT/Sources:$ROOT/Bootstrap ../run $COMPILE
for i in *.rsc;do mv $i `basename $i .rsc`.rsx;done
NOREBO_PATH=$ROOT/Bootstrap ../run $LINK
for i in *.rsx;do mv $i `basename $i .rsx`.rsc;done
# Remove created symbol files so re-created in stage 2
rm *.smb
cd ..

echo
echo '=== Bootstrap Check === '
diff -r Bootstrap build1 && echo 'OK: Bootstrap and Stage 1 are identical.'

echo
echo '=== Stage 2 ==='
mkdir build2
cd build2
NOREBO_PATH=$ROOT/Norebo:$ROOT/Host:$ROOT/Sources:$ROOT/build1 ../run $COMPILE
for i in *.rsc;do mv $i `basename $i .rsc`.rsx;done
NOREBO_PATH=$ROOT/build1 ../run $LINK
for i in *.rsx;do mv $i `basename $i .rsx`.rsc;done
# Hide symbol files
for i in *.smb;do mv $i `basename $i .smb`.smx;done
cd ..

echo
echo '=== Stage 3 ==='
mkdir build3
cd build3
NOREBO_PATH=$ROOT/Norebo:$ROOT/Host:$ROOT/Sources:$ROOT/build2 ../run $COMPILE
for i in *.rsc;do mv $i `basename $i .rsc`.rsx;done
NOREBO_PATH=$ROOT/build2 ../run $LINK
for i in *.rsx;do mv $i `basename $i .rsx`.rsc;done
cd ..

echo
echo '=== Verification === '
# Unhide symbol files
cd build2
for i in *.smx;do mv $i `basename $i .smx`.smb;done
cd ..
diff -r build2 build3 && echo 'OK: Stage 2 and Stage 3 are identical.'
