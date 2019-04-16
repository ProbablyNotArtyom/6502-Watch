//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-		
//                Variables		
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-		
		
		.var PATT1 = %11111111
		.var PATT2 = %00000000
		
		.var Emulated = false
		
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

		.var SW_LEFT	= %11111101
		.var SW_SELECT	= %11111011
		.var SW_RIGHT	= %11110111

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-	
//----------Zero Page Assignments-----------
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-											
		.var GTmp 			= $00
		.var GTmp2 			= $01
		.var GTmp3 			= $02
		.var GTmp4			= $03
		.var LCDX		 	= $04			// LCD position of the tetromino
		.var LCDY			= $05
		.var lastkey		= $06
		.var GTmp5 			= $07
		.var GTmp6			= $08
		.var LCDCursor		= $09
		.var LCDCursorH		= $0A
		.var GTmp7			= $0B
		.var GTmp8			= $0C
		.var GTmp9			= $0D
		.var GTmpA			= $0E
		.var ADDRS			= $0F
		.var ADDRSHI		= $10
		
		.var Score			= $11			// BCD encoded score value for easy printing
		.var ScoreH			= $12
		.var ScoreHH		= $30
		.var Level			= $13			// Current level, changes the delay time between drop events (incremented every ten lines)
		.var Lines			= $14			// Counter for the # of lines completed
		
		.var BlockID		= $15			// ID of the current tetromino, determines what mask and graphic is to be used
		.var BlockID_Next	= $16			// ID of the next tetromino, determines what mask and graphic is to be used
		.var BlockX			= $17			// Current X coordinate of the tetromino
		.var BlockY			= $18			// Current Y coordinate of the tetromino
											// The (X,Y) coordinate is aligned to the top leftmost corner of the 5x5 tetromino tile
		.var VScreen		= $19			// Pointer to the virtual screen position of the tetromino
		.var VScreenH		= $1A				
		.var V0Screen		= $1B			// Pointer to the virtual screen position (HH[-1]LL) 
		.var V0ScreenH		= $1C			
		.var V1Screen		= $2D			// Pointer to the virtual screen position (HH[-2]LL) 
		.var V1ScreenH		= $2E			
		.var BTiles			= $1F			// Pointer to the current tetromino's graphics data
		.var BTilesH		= $20
		.var B0Tiles		= $21			// Pointer to the extended graphics data of the tetromino
		.var B0TilesH		= $22
		
		.var IDSeed			= $23			// Seed for the ID generator
		.var TMPSeed		= $25			// Tmp for ID generator
		
		.var BlockID_B		= $26			// Buffer for the unrotated BlockID
		.var DropDelay		= $27		
		.var TLength		= $28			// Length of the current graphics tile
		.var CScreen		= $29
		.var CScreenH		= $2A
		.var C0Screen		= $2B
		.var C0ScreenH		= $2C
		.var CTiles			= $2D
		.var CTilesH		= $2E
		.var DropLVL		= $2F		
		.var LCount			= $31	
//- - - - - - - - - - - - - - - - - - - - -        
       
		.var Screen 	= $0200 	// Mirror for the Byte output of the LCD
		
		.var Collision	= $0500		// Collision table for tracking blocks
		
		
		