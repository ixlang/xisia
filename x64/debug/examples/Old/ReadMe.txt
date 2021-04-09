Linley Compiler 4.8.2

Get it at:

http://kidev.com

Browse (or better yet, join) the forums at:

http://kidev.com/devforum



These examples are to supplement other examples
found for Linley.

Most of the examples were orginally written by
Kinex.  Some were written by me.

The changes that I made in the process of conversion
to version 4.8.2 included:

- Removal of ExitProcess where not needed
  (no longer needed; use PostQuitMessage)

- Removal of line continuation (not needed, but nice.)

- Removal of the keyword 'internal' (use frame instead)

- Change of 'PE.GUI' to 'PE GUI'

- Removal of .Address

- Addition of a title line.

Notice that there are two directories.
LnlCmdLine and LnlIDE.

The versions in LnlCmdLine are raw code,
without any project formatting.  Use the
command line to compile these versions.

The versions in LnlIDE are useable in the IDE.


I believe that all programs are in working order,
with maybe the exception of two.

IAssembler.lnl. Inline assembly is not supported 
in this version, but I leave it in the hopes that 
support will be continued in the future.

You will need to get rid of the keyword internal
in VBEmulated.h in order to compile UseIncludes.lnl.

Linley is a great new language and is growing
stronger.  

Hats off to Kinex and all he has done so far.

Mark
