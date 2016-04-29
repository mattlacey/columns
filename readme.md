Columns
===

This is an almost-complete columns clone for the Atari Falcon030. It may be ported to the ST, right now it's using the Falcon's true colour mode so a lot of the graphis routines and assets would have to be changed for that to happen.

This is my first major assembly project so there's plenty of code that's nowhere near optimised, and even more that's absolutely horrible in terms of design. I've learned a lot, especially about how hard refactoring assembly code is ;)

This code should assemble without issue in Devpac 3.1.

Known bugs
===

* Occasionally gems won't be cleared properly - restarting the game will fix this
* Sound effects don't always work

Thanks
===

Massive thanks to the [Dead Hackers Society](www.dhs.nu) for their DHS Falcon Demosystem which is used to set the screen modes and a whole lot more, and to Nyh! for his joystick code. Also thanks to Laurent S (Thados) and dml (www.leonik.net/dml/sec_atari.py) for invaluable advice.
