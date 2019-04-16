//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-		
//                Variables		
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-		
		
		.var PATT1 = %11111111
		.var PATT2 = %00000000
		
//- - - - - - - - 6522 VIA - - - - - - - - - 

		.var PORTB  = $A000				// VIA A 
		.var PORTA  = $A001
		.var DDRB   = $A002
		.var DDRA   = $A003
		.var T1CL   = $A004
		.var T1CH   = $A005
		.var T1LL   = $A006
		.var T1LH   = $A007
		.var T2LL   = $A008
		.var T2CL   = $A008
		.var T2CH   = $A009
		.var SHIFT  = $A00A
		.var ACR    = $A00B
		.var PCR    = $A00C
		.var IFR    = $A00D
		.var IER    = $A00E
		.var ORAX   = $A00F
		
	.if (Emulated) {	
		.eval PORTB  = $5040			// VIA A
		.eval PORTA  = $5041
		.eval DDRB   = $5042
		.eval DDRA   = $5043
		.eval T1CL   = $5044
		.eval T1CH   = $5045
		.eval T1LL   = $5046
		.eval T1LH   = $5047
		.eval T2LL   = $5048
		.eval T2CL   = $5048
		.eval T2CH   = $5049
		.eval SHIFT  = $504A
		.eval ACR    = $504B
		.eval PCR    = $504C
		.eval IFR    = $504D
		.eval IER    = $504E
		.eval ORAX   = $504F
	}

//- - - - - - - - - - LCD - - - - - - - - - -

		.var LCD_CLK	= %00000001
		.var LCD_DATA	= %00000010
		.var LCD_RS		= %00000100
		.var LCD_RESET	= %00001000
		.var LCD_CE		= %00010000
		
//- - - - - - - - - -MMC- - - - - - - - - -	
										
		.var SD_CLK		= %00000001
		.var SD_MISO	= %00000010
		.var SD_MOSI	= %10000000
		.var SD_CS		= %00100000
		
		.var SW_UP		= %11111101
		.var SW_SELECT	= %11111011
		.var SW_DOWN	= %11110111
		
//- - - - - - - - - - RTC - - - - - - - - - -
		
		.var RTC_CE_B	= %01000000		// PA6
		.var RTC_SC_B	= %00000001		// PB1
		.var RTC_IO_B	= %10000000		// PA6					
		
		.var ACIA1dat		= $8800
		.var ACIA1sta		= $8801
		.var ACIA1cmd		= $8802
		.var ACIA1ctl		= $8803

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-	
//----------Zero Page Assignments-----------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-									
		.var IRQlo 			= $00
		.var IRQhi 			= $01
		.var NMIlo 			= $02
		.var NMIhi 			= $03
//- - - - - - - - - Monitor - - - - - - - -	
		.var N1L			= $04		// length of first number from floating point input routine
		.var N2L			= $05		// length of second number from floating point input routine		
		.var SIGN			= $06		// sign buffer from floating point input routine
		.var Pullfrom		= $07		// Inidrect value for the ASCIItoFP routine to decide where to pull the strings from
		.var Pullfrom_H		= $08
		.var XOut			= $09		// Exponent output from the ASCIItoFP routine
		.var M1Out			= $0A		// Mantissa output byte 1
		.var M2Out			= $0B		// Mantissa output byte 2
		.var M3Out			= $0C		// Mantissa output byte 3
		.var NBuff			= $0D		// Buffer for loader in ASCIItoFP
		.var INLength		= $0E		// Length of the input for ASCIItoFP
//- - - - - - - - - - - - - - - - - - - - - 		
		.var ADDRS			= $09
		.var ADDRSHI 		= $0A
		.var TEST 			= $0B
		.var GTmp 			= $0C
		.var GTmp2 			= $0D
		.var GTmp3 			= $0E
		.var GTmp4			= $0F
		.var LCDCursor		= $30
		.var LCDX		 	= $11
		.var LCDY			= $12
		.var lastkey		= $13
		.var actkey 		= $14
		.var CGRAMCursor    = $15
		.var GTmp5 			= $16
		.var GTmp6			= $17
//- - - - - - - - - Monitor - - - - - - - -			
		.var Parse			= $20		// The location that the currently executing command was at in the input buffer	
		.var WORDInput		= $21
		.var WORDInput_H	= $22
		.var LISTEnd		= $23
		.var LISTEnd_H		= $24
//- - - - - - - - - -RTC- - - - - - - - - -		
		.var RTCSec		= $25      // Seconds
		.var RTCMin		= $26      // Minutes
		.var RTCHr		= $27      // Hours
		.var RTCDay		= $28      // Day #
		.var RTCMon		= $29      // Month #
		.var RTCDow		= $2A      // Day of Week
		.var RTCYr		= $2B      // Year #
		.var RTCWpr		= $2C      // Write protect
//- - - - - Floating Point (WOZ) - - - - - 		
		.var sign   = $40
      	.var x2     = $41         	// exponent 2
    	.var m2     = $42         	// mantissa 2
    	.var x1     = $45         	// exponent 1
      	.var m1     = $46         	// mantissa 1
      	.var e      = $49         	// scratch
      	.var zz     = $4D
      	.var t      = $51
      	.var sexp   = $55
      	.var int    = $59
      	
      	.var ovflo  = $5A           // overflow byte for the accumulator when it is shifted left or multiplied by ten.
        .var msb    = $5B           // most-significant byte of the accumulator.
        .var nmsb   = $5C           // next-most-significant byte of the accumulator.
        .var nlsb   = $5D           // next-least-significant byte of the accumulator.
        .var lsb    = $5E           // least-significant byte of the accumulator.
        .var bexp   = $5F           // contains the binary exponent, bit seven is the sign bit.
        .var char   = $60           // used to store the character input from the keyboard.
        .var mflag  = $61           // set to $ff when a minus sign is entered.
        .var dpflag = $62           // decimal point flag, set when decimal point is entered.
        .var esign  = $63           // set to $ff when a minus sign is entered for the exponent.
        .var mem    = $5A           // start of memory used by the conversion program
        .var acc    = $5A           // ???
        .var accb   = $6A           // ???
        .var temp   = $64           // temporary storage location.
        .var eval   = $65           // value of the decimal exponent entered after the "e."
        .var dexp   = $71           // current value of the decimal exponent.
        .var bcda   = $7A           // bcd accumulator (5 bytes)
        .var bcdn   = $7F           // ???
//- - - - - - - - - - - - - - - - - - - - -        
        .var MBuffer    = $E0		// Output for FPtoASCII, goes until $FF and copies over the scanresult from keyboard scan 

		.var Scanresult = $F0		// Temp. scan output for the keyboard routine

		.var Screen 	= $0200 	// Mirror for the character output of the LCD, 6x14 Characters, 84 (0x54) bytes long
									// Used to simulate a tile-mapped screen for the monitor
		.var Buffer		= $0300		// Monitor input buffer
