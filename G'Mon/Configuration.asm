
//-----------------System-------------------

		.var Emulated  	= false
		
		.var TestStart 	= $0200					// Starting address of the ram test
		.var TestEnd   	= $2000					// Ending address of the ram test
		.var RomStart  	= $C000					// Location of the start of the ROM (origin point)
		.var RomSize   	= 16					// Size of the rom in Kilobytes
		.var Clock		= 1						// Clock speed of the machine in MHz

//-----------------Monitor------------------

		.var BootMessage = true					// Set to display the Boot message on startup of the monitor	
		.var MONText	 = "G'MON V.1"			// Header shown on boot of the monitor (MAX. 20 bytes)
		.var MONPrompt 	 = '>'					// Prompt character the Monitor uses to signify input
		.var TMONPrompt  = true					// Wether or not to show the prompt in the monitor
		
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//               Evaluations
//               (no touchy)
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

		.var HexRomSize = RomSize*1024
		
		.if (Emulated) {
			.eval (RomStart = $C000)
		}

		.var STATE = cmdLineVars.get("STATE")		// Grab the STATE input from the command line
		.if (STATE == 0){							// If STATE == 0, then create the tmp file and write the EhBasic configuration string to it
			.var brkFile = createFile("tmp")		
			.eval brkFile.writeln("ROM1: start = $"+toHexString(BAS)+", size = $3F00, fill = no;")
		}
		
		.macro Lw(char){
			.if (char <= 26) {
			.byte (char | %01100000)
			}
		}
		
		#import "Variables.asm"
		#import "Kernal.asm" 
