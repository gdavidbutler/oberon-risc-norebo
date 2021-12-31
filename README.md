# Oberon RISC Norebo (Project Norebo)

Norebo is a hack to run some _Project Oberon 2013_ software on a
POSIX system command line. Programs that use the GUI obviously
won't work, but e.g. the compiler runs.

## License

This repository is licensed under GPL v3 (see LICENSE).

The file `required-copyright-and-permission-notice.txt` is included, as required,
but *only* applies to the initial fork of this repository and the first commit of
original files in the `Sources` and `SourcesVerilog` directories from:

* http://people.inf.ethz.ch/wirth/ProjectOberon/
* http://www.projectoberon.com

If you want to use the orginal license, use the original source.

## Contents

* `Runtime/` RISC5 emulator and operating system interface.
* `Bootstrap/` pre-compiled modules to bootstrap Norebo.
* `Norebo/` Norebo-specific, modified and new modules.
* `Sources/` source code from Project Oberon 2013.
* `SourcesVerilog/` source verilog code from Project Oberon 2013.
* `Host/` Host-specific, modified and new modules.
* `build.sh` Script to build Bootstrap.

## End-of-line

Oberon (the O/S not the language, e.g. Texts.Mod, Edit.Mod, etc.)
uses ASCII CR (0D hex) for end-of-line.
This is quite inconvenient for GIT and friends (diff, etc.).

To leverage common cross developemnt tools, texts are stored
in the repository using ASCII LF (0A hex) for end-of-line.

The procedure VDiskUtil.InstallFiles converts LF to CR.

## PO2013 image build tools

This repository also contains tools to build PO2013 filesystem images.
Use it like so:

    ./build-host.sh

This will compile Sources and create a runnable disk image
`build/Oberon.dsk`. The disk image can be run
on the [Project Oberon RISC emulator].

Supporting Oberon modules are stored in `Norebo`: a virtual file
system (`VDiskUtil`/`VFile`) and a static linker for the Inner Core.
All this is based on code from PO2013.

## File handling

New files are always created in the current directory. Old files are
first looked up in the current directory and if they are not found,
they are searched for in the path defined by the `OBERON_PATH`
environment variable. Files found via `OBERON_PATH` are always opened
read-only.

## Bugs

Probably many.

Files are not integrated with the garbage collector. If you don't
close a file, it will remain open until Norebo exits.

Most runtime errors do not print a diagnostic message. Here's a table
of exit codes:

 Exit code | Meaning
----------:|:------------------------------
      1..7 | possibly a Modules error
         5 | (also) unknown command
       101 | array index out of range
       102 | type guard failure
       103 | array or string copy overflow
       104 | access via NIL pointer
       105 | illegal procedure call
       106 | integer division by zero
       107 | assertion violated

[Project Oberon RISC emulator]: https://github.com/pdewacht/oberon-risc-emu
