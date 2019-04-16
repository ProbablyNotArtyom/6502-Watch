# 6502-Watch
6502 powered wearable with an LCD screen, keyboard interface, and compact form factor, all running ehBasic to boot.

### About

The 6502 has been around for just about 40 years, yet still powers the hearts of many electrical systems in place today, such as many microcontrollers and embedded systems. In fact, WDC still manufactures the 6502 and 65xx series chips under the 65c02 and 65cxx. I've noticed that WDC also introduced more package variants of the 6502 and 6522, such as PLCC and QFP. Another thing I noticed was the fact that these form factors of the 65c02 are almost never used. Given that the only people buying these are hobbyists, that isn't too suprizing, as they dont offer much over the standard 40 pin DIP.What they do offer, however, is small package size. I went off to try and design the smallest 6502 SBC i could, and was pleasantly suprized with the results. What I ended up with was what i think is the smallest hobbyist 6502 SBC produced. Small enough, in fact, that you could easily wear it on your wrist! I then added the neat little Nokia 5110 LCD and a cool interface, and now have what I believe to be the only 6502-driven watch in existance.

This repository contains all of the KiCad project files for the hardware, and all of the assembly sources for my software. To build the software you will need KickAssembler.

### Hardware

 * 65c02 running @ 8MHz
 * 65c22 via controlling the LCD, keyboard, and buttons
 * Nokia 5110 LCD (84x48
 * 32k SRAM
 * 16k of mapped ROM
 * Full Commodore keyboard connector
 * 3.3v operation

### Software

The 6502 Watch runs a few key programs. It runs G'Mon (Generic Monitor) as a main development and tinkering utility. G'Mon supports viewing memory in single and batch, depositing memory in single or batch, jumping to programs, filling blocks of memory with a pattern byte, and moving blocks of memory. The version of G'Mon used on the watch is stripped down to the basics in order to fit it on the ROM along with EhBasic. EhBasic is included as the second main utility on the ROM. It was just barely able to fit into the ROM with everything else, like there are ~ 100 bytes left. EhBasic is modified to hook into the watch's main code, the Kernel. The Kernel contains all of the init routines and hardware interface routines, aswell as all of the links needed to stitch each utility together. The last piece of software on the ROM is the Watch Menu, which allows a way to select what program to run.

### More Information

 * [My Website](http://notartyoms-box.net/6502watch.html)
