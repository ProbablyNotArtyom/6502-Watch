# 6502-Watch
6502 powered wearable with an LCD screen, keyboard interface, and compact form factor, all running ehBasic to boot.

### About

The 6502 has been around for just about 40 years, yet still powers the hearts of many electrical systems in place today, such as many microcontrollers and embedded systems. In fact, WDC still manufactures the 6502 and 65xx series chips under the 65c02 and 65cxx. I've noticed that WDC also introduced more package variants of the 6502 and 6522, such as PLCC and QFP. Another thing I noticed was the fact that these form factors of the 65c02 are almost never used. Given that the only people buying these are hobbyists, that isn't too suprizing, as they dont offer much over the standard 40 pin DIP.What they do offer, however, is small package size. I went off to try and design the smallest 6502 SBC i could, and was pleasantly suprized with the results. What I ended up with was what i think is the smallest hobbyist 6502 SBC produced. Small enough, in fact, that you could easily wear it on your wrist! I then added the neat little Nokia 5110 LCD and a cool interface, and now have what I believe to be the only 6502-driven watch in existance.

This repository contains all of the KiCad project files for the hardware, and all of the assembly sources for my software. To build the software you will need KickAssembler.

### Hardware

The watch is pretty standard as far as 6502 hardware goes:

 * 65c02 running @ 8MHz
 * 65c22 (controls LCD, keyboard, and buttons)
 * Nokia 5110 LCD (84x48)
 * 32k SRAM
 * 16k ROM
 * C64 Keyboard Connector

Probably the strangest bit there is the full size C64 keyboard connector along the top of the watch. I had wanted to have some form of keyboard input, but most options are entirely out of reach of the poor 6502. The only way i could come up with is to use a preexisting matrix keyboard; I happened to have a lot of unused commodore keyboards, so that's what ended up on there.

The part that ties everything together is really the tiny Nokia LCD. It's interfaced through SPI, which i had to bitbang through the 6522 VIA. The VIA also interfaces with the keyboard, and the face buttons. An interesting thing to note here is that the VIA only has 16 i/o pins, which in this case are all needed to interface just with the keyboard alone. I was able to use some of those pins for both the keyboard and the LCD without causing any sort of corruption with a bit of luck, and a lot more trial and error.

### Software

The watch has a few different things on its ROM. The primary thing is G'Mon, a machine monitor i wrote for the 6502. It  supports viewing memory in single and batch, depositing memory in single or batch, jumping to programs, filling blocks of memory with a pattern byte, and moving blocks of memory. I had to strip a few of the less useful commands out in order to fit it on the ROM with everything else. The secondary thing on there is Lee Davidson's Enhanced Basic. I was just barely able to fit into the ROM with everything else, like there are only around 100 bytes free. EhBasic has been modified to hook into the watch's main code, but other than that it's a completely normal version of EhBasic!

The thing that greets you when you start up the watch is the watch interface. Clever name, i know. It just provides a graphical menu you can move through to select what you want to run. This is the only place where the face buttons are actually used, at least on purpose. The topmost button is what brings up the menu. Interesting bit about that: its connected directly to the NMI pin on the 6502, so it can be used to get back to the watch menu from almost anywhere on the thing (unless you crash the 6502).

In my sources, there is a big blob of code that handles interfacing with the watch hardware; It's called the kernel there, but its less of a kernel and more of a library everything else references. Some of the more interesting things in there are the SPI bitbanging stuff for the LCD, and the matrix scanning and decoding routine for the keyboard.

Speaking of sources, they are all uploaded on here, of course. All the assembler code is written to be assembled using KickAssembler, and makes quite heavy use of its macro capabilities, so i doubt it would be fun to try and assemble with anything else. Here i have also included the EhBasic sources that i have modified; They have been modified to be assembled with KickAssembler. Everything builds at the same time, just run the ./Compile.sh script and it will spit out a ROM image. If for some reason you feel the need to fiddle with it, then make sure to go to Configuration.asm: That's the header that holds a bunch of the miscellaneous variables, like the location of the ROM in memory.

If you every wanted to run the software yourself, then you can do that as well. If you set the Emulated variable in the config file to true, then it will build a ROM for use with Symon.

### Other Software Toys

I have written a few extra programs to show what the hardware itself can do. The first thing is a little sprite demo that has 8 animated software sprites bouncing around the screen, plus a text scroller along the top. The visibility is quite poor with it, as the LCD sure does take its time with updating the pixels, which causes everything moving to be a little blurry. To combat this I had to wait a bit after each frame for the LCD to update, which means that the demo itself runs a little slower than it actually could on the hardware. A video of this demo in action is in the Demos section.

Did i mention it runs Tetris? Because yea, it sure does. I wrote a version of Tetris for the watch not long after realizing it was probably the only practical thing that it could feasibly do. Its a pretty standard Tetris clone, following pretty much all of the mechanics of the original versions. This means having the scoring system, having the progressive levels, all the tetrominoes, etc. Its controlled using the face buttons, using the navigation buttons as left & right, the center button as rotate, and the NMI button as the drop button. At the moment I don't have actual recordings of Tetris running on the watch, mostly because i am too lazy to do that much work for a project that was finished nearly 2 and a half years as of this write-up, but i do have the graphics assets i made for it, and have put them together into what it looks like while. If you don't believe that I wrote Tetris for it, then don't worry, just take a look at the sources that i have included with the project's main downloads.

### More Information

 * [My Website](http://notartyoms-box.net/6502watch.html)
