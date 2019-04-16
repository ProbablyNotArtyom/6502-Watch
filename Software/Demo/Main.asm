//------------------Origin------------------
				
			*=$C000				// For use with Symon
KStart:
//-----------------Imports------------------	

			#import "Variables.asm"

//------------------Start-------------------	

INIT:							// RAM test, I/O init																																												
			sei					// Disable IRQ
			cld					// Clear decimal flag
			ldx #$FF			// Load X with stack pointer
			txs					// Init stack pointer
			cld
			lda #$00
			sta ADDRS
			lda #$02
			sta ADDRSHI
			jsr RAMInit
			jsr LCDInit
			lda #$00			
			sta Offset				
			sta lastkey			
			sta ADDRS
			sta ScrollerX
			sta ScrollerY		
			lda #<STxt
			sta TextPointer
			lda #>STxt
			sta TextPointerH
			
Main:					
			lda #$A0
			sta Sprite0XBuff
			lda #$40
			sta Sprite1XBuff
			lda #$60
			sta Sprite2XBuff
			lda #$10
			sta Sprite3XBuff
			lda #$C0
			sta Sprite4XBuff
			lda #$80
			sta Sprite5XBuff
			lda #$D0
			sta Sprite6XBuff
			lda #$B0
			sta Sprite7XBuff
			lda #$12
			sta Sprite0YBuff
			lda #$A0
			sta Sprite1YBuff
			lda #$40
			sta Sprite2YBuff
			lda #$D0
			sta Sprite3YBuff
			lda #$70
			sta Sprite4YBuff
			lda #$C0
			sta Sprite5YBuff
			lda #$50
			sta Sprite6YBuff
			lda #$6A
			sta Sprite7YBuff
			lda #$00
			sta Sprite0ID
			sta Sprite2ID
			lda #$03
			sta Sprite3ID
			lda #$02
			sta Sprite4ID
			lda #$06
			sta Sprite1ID
			lda #$09
			sta Sprite5ID
			sta Sprite6ID
			lda #$0B
			sta Sprite7ID
			lda #$00
			sta TTick
			jmp Msk
			
M1:			jsr LCDClear					
Msk:			
			lda #$00
			sta SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			inc SpriteSEL
			jsr PSprite
			
						
			ldy Sprite0YBuff
			lda Sin,y
			sta Sprite0Y
			inc Sprite0YBuff
			ldy Sprite0XBuff
			lda XSin,y
			sta Sprite0X
			inc Sprite0XBuff
			
			ldy Sprite1YBuff
			lda Sin,y
			sta Sprite1Y
			inc Sprite1YBuff
			ldy Sprite1XBuff
			lda XSin,y
			sta Sprite1X
			inc Sprite1XBuff
						
			ldy Sprite2YBuff
			lda Sin,y
			sta Sprite2Y
			inc Sprite2YBuff
			ldy Sprite2XBuff
			lda XSin,y
			sta Sprite2X
			inc Sprite2XBuff
						
			ldy Sprite3YBuff
			lda Sin,y
			sta Sprite3Y
			inc Sprite3YBuff
			ldy Sprite3XBuff
			lda XSin,y
			sta Sprite3X
			inc Sprite3XBuff
						
			ldy Sprite4YBuff
			lda Sin,y
			sta Sprite4Y
			inc Sprite4YBuff
			ldy Sprite4XBuff
			lda XSin,y
			sta Sprite4X
			inc Sprite4XBuff
						
			ldy Sprite5YBuff
			lda Sin,y
			sta Sprite5Y
			inc Sprite5YBuff
			ldy Sprite5XBuff
			lda XSin,y
			sta Sprite5X
			inc Sprite5XBuff
						
			ldy Sprite6YBuff
			lda Sin,y
			sta Sprite6Y
			inc Sprite6YBuff
			ldy Sprite6XBuff
			lda XSin,y
			sta Sprite6X
			inc Sprite6XBuff
						
			ldy Sprite7YBuff
			lda Sin,y
			sta Sprite7Y
			inc Sprite7YBuff
			ldy Sprite7XBuff
			lda XSin,y
			sta Sprite7X
			inc Sprite7XBuff
			
			jsr Scroll
			jsr BDelay
			
			lda Sprite0ID
			pha
			inc Sprite0ID
			ldx Sprite0ID
			cpx #$06
			bne !+
			lda #$00		
			sta Sprite0ID		
					
!:			lda Sprite2ID
			pha
			inc Sprite2ID
			ldx Sprite2ID
			cpx #$06
			bne !+
			lda #$00		
			sta Sprite2ID		
					
!:			lda Sprite3ID
			pha
			inc Sprite3ID
			ldx Sprite3ID
			cpx #$06
			bne !+
			lda #$00		
			sta Sprite3ID		
					
!:			lda Sprite4ID
			pha
			inc Sprite4ID
			ldx Sprite4ID
			cpx #$06
			bne !+
			lda #$00		
			sta Sprite4ID		
				
!:			lda TTick
			cmp #$01
			bne M2

			lda Sprite1ID
			pha
			dec Sprite1ID
			ldx Sprite1ID
			cpx #$05
			beq !+		
			jmp Ms2	
!:			dec TTick		
			lda #$07		
			sta Sprite1ID		
			jmp Ms2	
					
M2:			lda Sprite1ID
			pha
			inc Sprite1ID
			ldx Sprite1ID
			cpx #$0D
			beq !+
			jmp Ms2
!:			inc TTick		
			lda #$0B		
			sta Sprite1ID		
			jmp Ms2	
			
Ms2:		lda TTick
			cmp #$01
			bne M3

			lda Sprite5ID
			pha
			dec Sprite5ID
			ldx Sprite5ID
			cpx #$05
			beq !+		
			jmp Ms3		
!:			dec TTick		
			lda #$07		
			sta Sprite5ID		
			jmp Ms3	
					
M3:			lda Sprite5ID
			pha
			inc Sprite5ID
			ldx Sprite5ID
			cpx #$0D
			beq !+
			jmp Ms3
!:			inc TTick		
			lda #$0B		
			sta Sprite5ID		
			jmp Ms3
			
Ms3:		lda TTick
			cmp #$01
			bne M4

			lda Sprite6ID
			pha
			dec Sprite6ID
			ldx Sprite6ID
			cpx #$05
			beq !+		
			jmp Ms4	
!:			dec TTick		
			lda #$07		
			sta Sprite6ID		
			jmp Ms4	
					
M4:			lda Sprite6ID
			pha
			inc Sprite6ID
			ldx Sprite6ID
			cpx #$0D
			beq !+
			jmp Ms4
!:			inc TTick		
			lda #$0B		
			sta Sprite6ID		
			jmp Ms4
			
Ms4:		lda TTick
			cmp #$01
			bne M5

			lda Sprite7ID
			pha
			dec Sprite7ID
			ldx Sprite7ID
			cpx #$05
			beq !+		
			jmp M1		
!:			dec TTick		
			lda #$07		
			sta Sprite7ID		
			jmp M1		
					
M5:			lda Sprite1ID
			pha
			inc Sprite7ID
			ldx Sprite7ID
			cpx #$0D
			beq !+
			jmp M1
!:			inc TTick		
			lda #$0B		
			sta Sprite7ID		
			jmp M1	
			
			
Sin:		.byte $06, $06, $06, $06, $06, $06, $06, $07, $07, $08, $08, $09, $09, $0a, $0a, $0b
			.byte $0c, $0c, $0d, $0e, $0f, $0f, $10, $11, $11, $12, $13, $14, $14, $15, $15, $16
			.byte $17, $17, $18, $18, $18, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19
			.byte $19, $19, $18, $18, $17, $17, $16, $16, $15, $15, $14, $13, $13, $12, $11, $10
			.byte $10, $0f, $0e, $0e, $0d, $0c, $0b, $0b, $0a, $0a, $09, $08, $08, $07, $07, $07
			.byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $07, $07, $08
			.byte $08, $09, $09, $0a, $0a, $0b, $0c, $0c, $0d, $0e, $0f, $0f, $10, $11, $11, $12
			.byte $13, $14, $14, $15, $15, $16, $17, $17, $18, $18, $18, $19, $19, $19, $19, $19
			.byte $19, $19, $19, $19, $19, $19, $19, $19, $18, $18, $17, $17, $16, $16, $15, $15
			.byte $14, $13, $13, $12, $11, $10, $10, $0f, $0e, $0e, $0d, $0c, $0b, $0b, $0a, $0a
			.byte $09, $08, $08, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
			.byte $06, $06, $06, $07, $07, $08, $08, $09, $09, $0a, $0a, $0b, $0c, $0c, $0d, $0e
			.byte $0f, $0f, $10, $11, $11, $12, $13, $14, $14, $15, $15, $16, $17, $17, $18, $18
			.byte $18, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19, $19, $18, $18
			.byte $17, $17, $16, $16, $15, $15, $14, $13, $13, $12, $11, $10, $10, $0f, $0e, $0e
			.byte $0d, $0c, $0b, $0b, $0a, $0a, $09, $08, $08, $07, $07, $07, $06, $06, $06, $06
			.byte $06, $06
XSin:		.byte $03, $03, $03, $03, $03, $04, $04, $05, $05, $06, $07, $07, $08, $09, $0a, $0c
			.byte $0d, $0e, $0f, $11, $12, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22, $24
			.byte $26, $27, $29, $2b, $2c, $2e, $30, $31, $33, $34, $36, $38, $39, $3a, $3c, $3d
			.byte $3e, $3f, $41, $42, $43, $44, $44, $45, $46, $46, $47, $47, $48, $48, $48, $48
			.byte $49, $48, $48, $48, $48, $47, $47, $46, $46, $45, $44, $44, $43, $42, $41, $3f
			.byte $3e, $3d, $3c, $3a, $39, $37, $36, $34, $33, $31, $30, $2e, $2c, $2b, $29, $27
			.byte $25, $24, $22, $20, $1f, $1d, $1b, $1a, $18, $17, $15, $13, $12, $11, $0f, $0e
			.byte $0d, $0c, $0a, $09, $08, $07, $07, $06, $05, $05, $04, $04, $03, $03, $03, $03
			.byte $03, $03, $03, $03, $03, $04, $04, $05, $05, $06, $07, $07, $08, $09, $0a, $0c
			.byte $0d, $0e, $0f, $11, $12, $14, $15, $17, $18, $1a, $1b, $1d, $1f, $20, $22, $24
			.byte $26, $27, $29, $2b, $2c, $2e, $30, $31, $33, $34, $36, $38, $39, $3a, $3c, $3d
			.byte $3e, $3f, $41, $42, $43, $44, $44, $45, $46, $46, $47, $47, $48, $48, $48, $48
			.byte $49, $48, $48, $48, $48, $47, $47, $46, $46, $45, $44, $44, $43, $42, $41, $3f
			.byte $3e, $3d, $3c, $3a, $39, $37, $36, $34, $33, $31, $30, $2e, $2c, $2b, $29, $27
			.byte $25, $24, $22, $20, $1f, $1d, $1b, $1a, $18, $17, $15, $13, $12, $11, $0f, $0e
			.byte $0d, $0c, $0a, $09, $08, $07, $07, $06, $05, $05, $04, $04, $03, $03, $03, $03












Scroll:					
			pha			
			tya			
			pha					
			lda ScrollerY
			sta LCDY
			lda ScrollerX
			sta LCDX
			ldy #$00
			
			lda TextPointer
			sta ScrollTextL
			lda TextPointerH
			sta ScrollTextH
S1:			
			lda (ScrollTextL),y
			jsr PChar
			bcs S2		
					
			lda ScrollTextL			// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda ScrollTextH		
			adc #$01		
			sta ScrollTextH		
!:			clc
			lda ScrollTextL
			adc #$01
			sta ScrollTextL
			jmp S1

S2:			lda #$00
			sta LCDX
			lda lastkey
			sta Offset

			inc lastkey
			inc lastkey
			lda lastkey
			sta Offset
				
			lda lastkey	
			cmp #$06	
			bne S3	
			lda #$00			
			sta Offset			
			sta lastkey			
						
			lda TextPointer			// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda TextPointerH		
			adc #$01		
			sta TextPointerH		
!:			clc
			lda TextPointer
			adc #$01
			sta TextPointer			
						
S3:			pla	
			tay	
			pla	
			rts	
			
STxt:
		.text "                 THIS LITTLE PROGRAM DEMONSTRATES EIGHT ANIMATED SOFTWARE SPRITES PLUS A SMOOTHED SCROLLING TEXT.   "			
		.text "THE SPRITE SYSTEM TRACKS THE POSITION OF ANY TILE PLACED ON THE BITMAP SCREEN. IT IS SIMPLE TO ADD AND CONTROL SPRITES VIA MANIPULATION OF SOFTWARE REGISTERS.   "			
		.text "MOST OF THE CPU TIME IS TAKEN UP BY THE LENGTHY LCD BITBANGING ROUTINES. ONCE A HARDWARE INTERFACE IS IN PLACE, THERE SHOULD BE ENOUGH CPU TIME TO CREATE A GAME USING FULL SPRITE LOGIC.   "
//----------------Functions-----------------	

RAMInit:														
			ldx #$00													
Ra1:		lda	#$00
			sta (ADDRS,x)		// Store byte
						
			lda ADDRS			// Load accumulator with low byte of current test address
			cmp #$FF			// Compare with #$FF to see if it is time to cycle the high byte
			bne !+				// if A =/= #$FF goto end. else continue
			inc ADDRSHI			// Increase current test address high byte
!:			inc ADDRS			// Store #$00 in the low byte				
		
			lda ADDRSHI			// Compare High byte of current address to 80
			cmp #80
			bne Ra1																										
			rts	
			
LCDInit:              
			pha          
			lda DDRA								
			ora #%00011111		// Set the VIA bits to be outputs								
			sta DDRA          
            lda PORTA
            and #%11110110		// Set CLK and RES low
            sta PORTA
            nop					// Delay for a bit
            nop
			lda PORTA
			ora #$00001000		// Set RES high
			sta PORTA
			nop					// Delay a little bit more
			nop
			
			lda #%00100001		// Function set, H == 1
			jsr Command
			lda #%11010001		// Set Contrast
			jsr Command
			lda #%00100000		// Function set, H == 0
			jsr Command
			lda #%00001100		// Set Display Config
			jsr Command
			lda #%10000000		// Set X = 0
			jsr Command
			lda #%01000000		// Set Y = 0
			jsr Command			
			
			jsr LCDClear		// Clear the LCD
			pla
			rts					// Return

LCDHome:
			pha
			jsr LCDClear
			lda #%00100000		// Function set, H == 0
			jsr Command
			lda #%10000000		// Set X = 0
			jsr Command
			lda #%01000000		// Set Y = 0
			jsr Command
			pla
			rts

LCDClear:
			pha
			txa
			pha
			tya
			pha
			ldy #$00
			ldx #$00
			lda #%10000000		// Set X = 0
			jsr Command
			lda #%01000000		// Set Y = 0
			jsr Command
CL1:		lda #$00
			sta Screen,y
			jsr WriteBYTE		// Write the byte
			iny					// Increase the index
			cpx #$01			// Check if we're on the second loop
			beq !+
			cpy #$FF			
			bne CL1					
			ldx #$01			// Set X == 1 so the second routine can start
			jmp CL1				// Jump back to the loop
!:			sta $0300,y
			cpy #$F8			
			bne CL1
			
			pla			
			tay			
			pla			
			tax			
			pla				
			rts									
									
Command:
			sta GTmp			// Save input				
			tya					// Push y to the stack	
			pha																				
			lda DDRA								
			ora #%00011111		// Set the VIA bits to be outputs								
			sta DDRA							
			lda #%00111000		// Set LCD_RS bit to character input mode (High)						
			sta PORTA			// Output it							
!:			lda PORTA
			and #%11101111		// Set the enable bit low
			sta PORTA			// Output it
			ldy #$FF			// Setup Y for the output loop													
!:			lda PORTA			
			and #%11111101		// Set the Data line low to ready it for bit-shifting 
			sta PORTA			// Output it
			lda #$00			// Load A with zero for input
			clc					// Clear Carry
			asl GTmp			// Shift next bit of The input into Carry	
			rol					// Rol the bit into A
			clc					// Clear carry to make sure bit 0 of A == 0
			rol					// Rol A to put the data bit in the correct location
			ora PORTA			// Or it with the output
			sta PORTA			// Output the data bit
			inc	PORTA			// Pulse the Clock to latch the data
			dec	PORTA					
			iny 				// Increase the index
			cpy #$08			// If Y == 8, then all of the bits have been output
			bne !-				// If not, then jmp to output another bit				
!:			
			lda #%00111000
			sta PORTA
			pla								
			tay					// Pull Y from the stack			
			rts					// Return									
												
WriteBYTE: 													
			sta GTmp			// Save input				
			pha		
			tya					// Push y to the stack	
			pha											
			lda DDRA								
			ora #%00011111		// Set the VIA bits to be outputs								
			sta DDRA							
			lda #%00111100		// Set LCD_RS bit to character input mode (High)						
			sta PORTA			// Output it							
!:			lda PORTA
			and #%11101111		// Set the enable bit low
			sta PORTA			// Output it
			ldy #$FF			// Setup Y for the output loop													
!:			lda PORTA			
			and #%11111101		// Set the Data line low to ready it for bit-shifting 
			sta PORTA			// Output it
			lda #$00			// Load A with zero for input
			clc					// Clear Carry
			asl GTmp			// Shift next bit of The input into Carry	
			rol					// Rol the bit into A
			clc					// Clear carry to make sure bit 0 of A == 0
			rol					// Rol A to put the data bit in the correct location
			ora PORTA			// Or it with the output
			sta PORTA			// Output the data bit
			inc	PORTA			// Pulse the Clock to latch the data
			dec	PORTA					
			iny 				// Increase the index
			cpy #$08			// If Y == 8, then all of the bits have been output
			bne !-				// If not, then jmp to output another bit				
!:			
			lda #%00111000
			sta PORTA
			pla								
			tay					// Pull Y from the stack			
			pla		
			rts					// Return									
												
WriteBMP:						// Writes a bitmap to the screen. GTmp3(L) and GTmp4(H) must contain a pointer to the bitmap
			pha
			txa
			pha
			tya
			pha
			jsr LCDHome
			lda #<Screen
			sta GTmp5
			lda #>Screen
			sta GTmp6
			ldy #$FF
			ldx #$00
WB1:		iny
			lda (GTmp3),y		// Load a byte of the bitmap
			sta (GTmp5),y
			jsr WriteBYTE		// Write the byte
			cpx #$01			// If X != 1
			bne !+
			cpy #$F8			// If Y
			bne WB1
			pla			
			tay			
			pla			
			tax			
			pla				
			rts
			
!:			cpy #$FF			
			bne WB1				
			inc GTmp4			// Increase the High byte of the index		
			inc GTmp6		
			ldx #$01			// Set X == 1 so the second routine can start
			jmp WB1				// Jump back to the loop								
												
SETCursor:
			pha
			lda LCDX								
			ora #%10000000								
			jsr Command								
			lda LCDY					
			asl					
			asl					
			asl					
			ora #%01000000								
			jsr Command							
			pla							
			rts							
										
SETCursor_3b:
			pha
			lda LCDX								
			ora #%10000000								
			jsr Command								
			lda LCDY									
			ora #%01000000								
			jsr Command							
			pla							
			rts							
												
BDelay:							// Dealy for a lot of cycles
			txa
			pha
			tya 
			pha
			
			ldx #$40			// Load X with #$FF
RS:			ldy #$FF			// Load Y with #$FF
!:			dey					// Decrease Y (Sub loop)
			rol $10
			cpy #$00			// Compare it to 0
			bne !-				// If Y =/= 0, loop again
			dex					// After one full loop of Y, Decrease X by one
			cpx #$00			// Compare X to 0
			bne RS				// If X =/= 0, loop Y once more			
			pla 
			tay
			pla
			tax
			rts												

//-------------Demo Functions---------------					
PSprite:
			pha
			tya
			pha
			ldy SpriteSEL
			lda Sprite0X,y		// Get the ID of the active Sprite
			sta LCDX
			ldy SpriteSEL
			lda Sprite0Y,y		// Get the ID of the active Sprite
			sta LCDY
			ldy SpriteSEL
			lda Sprite0ID,y		// Get the ID of the active Sprite
			sta BlockID
			tay
			lda STbl1L,y		// Get the low byte of the block's graphics pointer
			sta BTiles
			lda STbl1H,y		// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda STbl2L,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda STbl2H,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH
			
			lda #12
			sta TLength
			jsr PBlock
			pla
			tay
			pla
			rts

ESprite:
			pha
			tya
			pha
			ldy SpriteSEL
			lda Sprite0X,y		// Get the ID of the active Sprite
			sta LCDX
			ldy SpriteSEL
			lda Sprite0Y,y		// Get the ID of the active Sprite
			sta LCDY
			ldy SpriteSEL
			lda Sprite0ID,y		// Get the ID of the active Sprite
			sta BlockID
			tay
			lda STbl1L,y		// Get the low byte of the block's graphics pointer
			sta BTiles
			lda STbl1H,y		// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda STbl2L,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda STbl2H,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH
			
			lda #12
			sta TLength
			jsr EBlock
			pla
			tay
			pla
			rts
			
EBlock:		
			lda LCDX		
			pha		
			lda LCDY		
			pha		

			jsr SETCursor

			lda LCDY
			lsr
			lsr
			lsr
			pha
			tay					// Divide by 8
			
			lda PTblL,y			// Set up the screen vector	GTmp2
			sta VScreen		
			lda PTblH,y		
			sta VScreenH	
			iny	
			lda PTblL,y			// Set up the screen vector	GTmp9
			sta V0Screen		
			lda PTblH,y		
			sta V0ScreenH
			iny	
			lda PTblL,y			// Set up the screen vector	GTmp9
			sta V1Screen		
			lda PTblH,y		
			sta V1ScreenH
								
			ldy LCDY					
			pla
			sta LCDY
			lda PTbl1,y					
			sta GTmp6			// Grab the number of ASLs needed to get the character to the input position					
			pha			
						
			ldy #$00					
			sty GTmp5					

E1:			lda #$00
			sta GTmp3
			ldy GTmp5
			lda (B0Tiles),y			
			sta GTmp2					
			cpy TLength
			beq E3		
			lda (BTiles),y			// Write 6 consecutive bytes (1 5x8 character) from the address to the screen GTmp7
!:			ldx GTmp6
			cpx #$00
			beq !+
			asl
			rol GTmp2
			rol GTmp3
			dec GTmp6
			jmp !-

!:			jsr SETCursor_3b
			ldy LCDX
			eor (VScreen),y			
			sta (VScreen),y			
			jsr WriteBYTE		
			inc LCDY		
			jsr SETCursor_3b		// Set the cursor to the byte below the main one		
			lda GTmp2
			eor (V0Screen),y
			sta (V0Screen),y
			jsr WriteBYTE
			inc LCDY
			jsr SETCursor_3b
			lda GTmp3
			eor (V1Screen),y			
			sta (V1Screen),y			
			jsr WriteBYTE		
			dec LCDY
			dec LCDY
			jsr SETCursor_3b
			inc GTmp5			
			inc LCDX			
			pla	
			pha
			sta GTmp6	
			jmp E1	
E3:			pla			
			pla		
			sta LCDY		
			pla 		
			sta LCDX				
			rts								
									
PBlock_CL:	
			lda LCDX		
			pha		
			lda LCDY		
			pha
			jmp PBep
PBlock:		
			lda LCDX		
			pha		
			lda LCDY		
			pha		
	
PBep:		jsr SETCursor

			lda LCDY
			lsr
			lsr
			lsr
			pha
			tay					// Divide by 8
			
			lda PTblL,y			// Set up the screen vector	GTmp2
			sta VScreen		
			lda PTblH,y		
			sta VScreenH	
			iny	
			lda PTblL,y			// Set up the screen vector	GTmp9
			sta V0Screen		
			lda PTblH,y		
			sta V0ScreenH
			iny	
			lda PTblL,y			// Set up the screen vector	GTmp9
			sta V1Screen		
			lda PTblH,y		
			sta V1ScreenH
								
			ldy LCDY					
			pla
			sta LCDY
			lda PTbl1,y					
			sta GTmp6			// Grab the number of ASLs needed to get the character to the input position					
			pha			
						
			ldy #$00					
			sty GTmp5					

P1:			lda #$00
			sta GTmp3
			ldy GTmp5
			lda (B0Tiles),y			
			sta GTmp2					
			cpy TLength
			beq P3		
			lda (BTiles),y			// Write 6 consecutive bytes (1 5x8 character) from the address to the screen GTmp7
!:			ldx GTmp6
			cpx #$00
			beq !+
			asl
			rol GTmp2
			rol GTmp3
			dec GTmp6
			jmp !-
			
!:			jsr SETCursor_3b
			ldy LCDX
			ora (VScreen),y			
			sta (VScreen),y			
			jsr WriteBYTE		
			inc LCDY		
			jsr SETCursor_3b		// Set the cursor to the byte below the main one		
			lda GTmp2
			ora (V0Screen),y
			sta (V0Screen),y
			jsr WriteBYTE
			inc LCDY		
			jsr SETCursor_3b		// Set the cursor to the byte below the main one		
			lda GTmp3
			ora (V1Screen),y
			sta (V1Screen),y
			jsr WriteBYTE
			dec LCDY
			dec LCDY
			jsr SETCursor_3b
			inc GTmp5			
			inc LCDX			
			pla	
			pha
			sta GTmp6	
			jmp P1	
P3:			pla			
			pla		
			sta LCDY		
			pla 		
			sta LCDX				
			rts										
									
PChar:		sta GTmp5
			pha		
			tya		
			pha		
			txa		
			pha		
			ldy GTmp5
			
			lda CTblL,y		// Get the low byte of the block's graphics pointer
			sta BTiles
			lda CTblH,y		// Get the high byte of the block's graphics pointer
			sta BTilesH
			
			ldy ScrollerY
			sty LCDY
			ldy ScrollerX
			sty LCDX
			jsr SETCursor_3b

			ldy ScrollerY
			
			lda PTblL,y			// Set up the screen vector	GTmp2
			sta VScreen		
			lda PTblH,y		
			sta VScreenH	

			lda Offset
			sta GTmp5
			lda #$00
			sta Offset

Pc1:		ldy GTmp5					
			cpy #$06
			beq Pc3		
			lda (BTiles),y			// Write 6 consecutive bytes (1 5x8 character) from the address to the screen GTmp7
			
!:			jsr SETCursor_3b
			ldy LCDX
			ora (VScreen),y			
			sta (VScreen),y			
			jsr WriteBYTE		
			inc GTmp5			
			inc LCDX			
			lda LCDX			
			cmp #84			
			bne !+			
			lda #$00			
			sta LCDX			
			sec			
			jmp Pc4			
!:			pla	
			pha
			sta GTmp6	
			jmp Pc1	
Pc3:		clc		
Pc4:		lda LCDX
			sta ScrollerX
			pla								
			tax				
			pla				
			tay							
			pla			
			rts				
													
//---------------Misc Tables----------------					
KEnd:
			*=$F600
MS:
Tiles:
		.import binary "Assets/Tiles.bin"
		
		.var  Screen1 = >Screen			// Bug workaround					
		.eval Screen1 = Screen1+1								
		.var  Tiles1 = >Tiles								
		.eval Tiles1 = Tiles1+1								
								
PTbl1:
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			
PTblL:		.byte <Screen, <Screen+84, <Screen+168, <Screen+252, <Screen+80, <Screen+164										
PTblH:		.byte >Screen, >Screen, >Screen, >Screen, Screen1, Screen1
CTblL:		.byte <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles
			.byte <Tiles, <Tiles+72, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles, <Tiles															//  , (CR)
			.byte <Tiles, <Tiles, <Tiles, <Tiles, <Tiles+72, <Tiles+78, <Tiles+74, <Tiles+92, <Tiles+98, <Tiles+104, <Tiles+116, <Tiles+68, <Tiles+128, <Tiles+134							//  , , , , (Space), !, ", #, $, %, &, ', (, )
			.byte <Tiles+122, <Tiles+158, <Tiles+182, <Tiles+152, <Tiles+162, <Tiles+162, <Tiles+0, <Tiles+6, <Tiles+12, <Tiles+18, <Tiles+24, <Tiles+30, <Tiles+36, <Tiles+42				// *, +, (,), -, ., /, 0, 1, 2, 3, 4, 5, 6, 7 
			.byte <Tiles+48, <Tiles+54, <Tiles+218, <Tiles+224, <Tiles+194, <Tiles+212, <Tiles+200, <Tiles+156, <Tiles+86, <Tiles+80, <Tiles+86, <Tiles+92, <Tiles+98, <Tiles+104			// 8, 9, :, ;, <, =, >, ?, @, A, B, C, D, E
			.byte <Tiles+110, <Tiles+116, <Tiles+122, <Tiles+128, <Tiles+134, <Tiles+140, <Tiles+146, <Tiles+152, <Tiles+158, <Tiles+164, <Tiles+170, <Tiles+176, <Tiles+182, <Tiles+188	// F, G, H, I, J, K, L, M, N, O, P, Q, R, S
			.byte <Tiles+194, <Tiles+200, <Tiles+206, <Tiles+212, <Tiles+218, <Tiles+224, <Tiles+230																						// T, U, V, W, X, Y, Z
CTblH:		.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1
			.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1		//  , (CR)
			.byte Tiles1, Tiles1, Tiles1, Tiles1, >Tiles, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1		//  , , , , (Space), !, ", #, $, %, &, ', (, )
			.byte Tiles1, Tiles1, Tiles1, Tiles1, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1		// *, +, (,), -, ., /, 0, 1, 2, 3, 4, 5, 6, 7 
			.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1		// 8, 9, :, ;, <, =, >, ?, @, A, B, C, D, E
			.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1		// F, G, H, I, J, K, L, M, N, O, P, Q, R, S
			.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1																// T, U, V, W, X, Y, Z
STbl1L:		.byte <Tiles+0, <Tiles+12, <Tiles+24, <Tiles+36, <Tiles+48, <Tiles+60, <Tiles+168, <Tiles+180, <Tiles+192, <Tiles+204, <Tiles+216, <Tiles+228, <Tiles+240
STbl1H:		.byte >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles
STbl2L:		.byte <Tiles+84, <Tiles+96, <Tiles+108, <Tiles+120, <Tiles+132, <Tiles+144, <Tiles+252, <Tiles+8, <Tiles+20, <Tiles+32, <Tiles+44, <Tiles+56, <Tiles+68
STbl2H:		.byte >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1
ME:
//-----------------Vectors------------------	
	          	
			*=$FFFa
			
			.byte <INIT, >INIT, <INIT, >INIT, <INIT, >INIT					// NMI, Reset, and IRQ Vectors Lo, Hi
			
//-----------------Compiler-----------------

			.var KSize = (KEnd - KStart) + (ME - MS)
			.var KPCS = (KSize / $4000)*100

			.print ""
			.print "   Theta-65 Demo   "
			.print "-------------------"
			.print " Pseudon 2017 v0.1"
			.print ""
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Extra Information "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "$"+toHexString(KSize)+" used of $C000"
			.print toIntString(KPCS)+"% Full"
			.print toIntString($4000-KSize)+" Bytes Free"

			