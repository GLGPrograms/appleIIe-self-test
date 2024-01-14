# Apple IIe built-in self test

This is a reverse engineered code of the `$C400-C7FF` ROM area for an Apple IIe.
This ROM area covers the internal self test routine, which can be triggered by
"Ctrl - Alt - Solid Apple" keypress.
This code is contained inside the so called "Diagnostics ROM" (also known as
CD ROM for its position in the chip grid onto the board), together with part of
the Applesoft BASIC interpreter.

See the "Apple Ile Technical Reference Manual" for more information.

## How to assemble

I decided to leave the code formatting unchanged out of the disassebler
([virtual 6502](https://www.masswerk.at/6502/)), keeping addresses and binary
code to better put in connection ROM data with the code.
If you need to re-assemble it, just throw away the first 18 columns (skipping
comments) and adapt the obtained code to your assembler (some of them like
`:` after labels, some others do not like EQU and prefer `=`, ...).
Inside this repository you can find a python script that can produce code
compliant with [acme](https://github.com/meonwax/acme) 6502 assembler, but feel
free to adapt it for your most loved assembler.

If you use or you want to try with [acme](https://github.com/meonwax/acme)
assembler, just type

```bash
cat self-test.asm | python3 asm2acme.py > self-test_acme.asm
acme --cpu 6502 --color -o self-test_acme.bin self-test_acme.asm
```

## Copyright

[Fair use](https://en.wikipedia.org/wiki/Fair_use) applied to abandonware is
invoked.

The disassembly work is distribute under terms of the Creative Commons
Attribution 4.0 license.
