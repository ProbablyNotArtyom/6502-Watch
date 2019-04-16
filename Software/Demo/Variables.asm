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
		.var LCDX		 	= $04			// LCD position of the Sprite
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
		
		.var BlockID		= $11			// ID of the current Sprite, determines what mask and graphic is to be used
											// The (X,Y) coordinate is aligned to the top leftmost corner of the 5x5 Sprite tile
		.var VScreen		= $12			// Pointer to the virtual screen position of the Sprite
		.var VScreenH		= $13				
		.var V0Screen		= $14			// Pointer to the virtual screen position (HH[-1]LL) 
		.var V0ScreenH		= $15			
		.var V1Screen		= $16			// Pointer to the virtual screen position (HH[-2]LL) 
		.var V1ScreenH		= $17			
		.var BTiles			= $18			// Pointer to the current Sprite's graphics data
		.var BTilesH		= $19
		.var B0Tiles		= $1A			// Pointer to the extended graphics data of the Sprite
		.var B0TilesH		= $1B

		.var TLength		= $1C			// Length of the current graphics tile	
		.var SpriteSEL		= $1D			// Sprite # to be manipulated by the printing routines
		.var TTick			= $1E
		.var Offset			= $1F			// Left shift for the PChar routine
		
		.var Sprite0X		= $20
		.var Sprite1X		= $21
		.var Sprite2X		= $22
		.var Sprite3X		= $23
		.var Sprite4X		= $24
		.var Sprite5X		= $25
		.var Sprite6X		= $26
		.var Sprite7X		= $27
		.var Sprite0Y		= $28
		.var Sprite1Y		= $29
		.var Sprite2Y		= $2A
		.var Sprite3Y		= $2B
		.var Sprite4Y		= $2C
		.var Sprite5Y		= $2D
		.var Sprite6Y		= $2E
		.var Sprite7Y		= $2F
		.var Sprite0ID		= $30
		.var Sprite1ID		= $31
		.var Sprite2ID		= $32
		.var Sprite3ID		= $33
		.var Sprite4ID		= $34
		.var Sprite5ID		= $35
		.var Sprite6ID		= $36
		.var Sprite7ID		= $37
		.var Sprite0YBuff	= $38
		.var Sprite1YBuff	= $39
		.var Sprite2YBuff	= $3A
		.var Sprite3YBuff	= $3B
		.var Sprite4YBuff	= $3C
		.var Sprite5YBuff	= $3D
		.var Sprite6YBuff	= $3E
		.var Sprite7YBuff	= $3F
		.var Sprite0XBuff	= $40
		.var Sprite1XBuff	= $41
		.var Sprite2XBuff	= $42
		.var Sprite3XBuff	= $43
		.var Sprite4XBuff	= $44
		.var Sprite5XBuff	= $45
		.var Sprite6XBuff	= $46
		.var Sprite7XBuff	= $47
		
		.var ScrollerX		= $48
		.var ScrollerY		= $49
		.var ScrollTextL	= $4A
		.var ScrollTextH	= $4B
		.var TextPointer	= $4C
		.var TextPointerH	= $4D
//- - - - - - - - - - - - - - - - - - - - -        
       
		.var Screen 	= $0200 	// Mirror for the Byte output of the LCD
		
		
		