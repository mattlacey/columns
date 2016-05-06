Trionoids
===

This is columns clone for the Atari Falcon030. It may be ported to the ST, right now it's using the Falcon's true colour mode so a lot of the graphics routines and assets would have to be changed for that to happen.

How To Play
===
Trionoids drop down the screen in groups of three, you can switch their order by pressing up or down to 'rotate' in the associated direction and move the column of three left and right. Match 3 or more either horizontally, vertically or diagonally for the good stuff (points). Pressing fire drops the Trionoids faster. The game speeds up over time, so for the best score you need to drop them!

Controls
===

Action      | Joystick | Keyboard 
------------|----------|-------------
Rotate up   | Up       | Up Cursor
Rotate down | Down     | Down Cursor
Move left   | Left     | Left Cursor
Move right  | Right    | Right Cursor
Drop        | Fire     | Spacebar

Known bugs (as of 1.0)
===

* Occasionally gems won't be cleared properly - restarting the game will fix this
* Sound effects don't always work

Licence
===
Do whatever you want with the game or the source (see below), but don't sell it.

Thanks
===
Massive thanks to the [Dead Hackers Society](www.dhs.nu) for their DHS Falcon Demosystem which is used to set the screen modes and a whole lot more, and to Nyh! for his joystick code. Also thanks to Laurent S (Thados) and dml (www.leonik.net/dml/sec_atari.py) for invaluable advice.

Contact
===
Find me on IRC in #atariscne on IRCnet and ##Atari on Freenode. You can also find me on Twitter @LaceySnr, or [visit my website](http://www.laceysnr.com).

Code
===

The code is available on [GitHub](https://github.com/mattlacey/columns).

This is my first major assembly project so there's plenty of code that's nowhere near optimised, and even more that's absolutely horrible in terms of design. I've learned a lot, especially about how hard refactoring assembly code is ;)

This code should assemble without issue in Devpac 3.1.

