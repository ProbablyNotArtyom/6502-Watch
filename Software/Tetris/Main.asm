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
			sta Score			// Reset game vaiables
			sta ScoreH
			sta ScoreHH
			sta Lines
			lda #$02
			sta ADDRSHI
			jsr RAMInit
			jsr LCDInit
			jsr RNDInit
			lda #$FF
			sta DropLVL
			lda #$0D
			sta BlockID_Next
			
			lda #<Collision		// Write the collision table to memory
			sta GTmp5
			lda #>Collision
			sta GTmp6
			lda #<Table			
			sta GTmp3
			lda #>Table
			sta GTmp4
			ldy #$FF
			ldx #$00
Pct:		iny
			lda (GTmp3),y		// Load a byte of the bitmap
			sta (GTmp5),y
			cpx #$01			// If X != 1
			bne !+
			cpy #$30			// If Y
			bne Pct
			jmp INe			
!:			cpy #$FF			
			bne Pct				
			inc GTmp4			// Increase the High byte of the index		
			inc GTmp6		
			ldx #$01			// Set X == 1 so the second routine can start
			jmp Pct		
INe:
		.if (Emulated){	
			jmp Main	
		}		
			lda #<Title
			sta GTmp3
			lda #>Title
			sta GTmp4
			jsr WriteBMP
			
M0:			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB			
			lda PORTB
			ora #%11110001
			cmp #SW_SELECT
			bne M0
Main:			
			lda #<Game
			sta GTmp3
			lda #>Game
			sta GTmp4
			jsr WriteBMP
			
			lda #$01
			sta Level
			
			jsr BlockNew
!:			jsr BDelay
			jsr BlockDown
			jmp !-
					 		
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
			lda #%11000111		// Set Contrast
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
			jsr WriteBYTE		// Write the byte
			iny					// Increase the index
			cpx #$01			// Check if we're on the second loop
			beq !+
			cpy #$FF			
			bne CL1					
			ldx #$01			// Set X == 1 so the second routine can start
			jmp CL1				// Jump back to the loop
!:			cpy #$F8			
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
			
			ldx DropDelay		// Load X with #$FF
RS:			ldy #$FF			// Load Y with #$FF
!:			dey					// Decrease Y (Sub loop)
		.if (Emulated){
			rol $10
		}else{
			rol $10
			ror $10
			rol $10
			ror $10
			rol $10
			ror $10
			rol $10
			ror $10
			rol $10
			ror $10
			rol $10
			ror $10
		}
			cpy #$00			// Compare it to 0
			bne !-				// If Y =/= 0, loop again
			jsr Input
			dex					// After one full loop of Y, Decrease X by one
			cpx #$00			// Compare X to 0
			bne RS				// If X =/= 0, loop Y once more			
			pla 
			tay
			pla
			tax
			rts												

Input:		
			pha
			txa
			pha
!:			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB			
			lda PORTB
			ora #%11110001
			cmp #$FF
			beq !+
			cmp lastkey
			bne !+
			jmp IOe
!:			sta lastkey
			cmp #SW_SELECT
			bne !+
			jsr BlockRotate
			jmp IOe
			
!:			cmp #SW_LEFT
			bne !+
			jsr BlockLeft
			jmp IOe
			
!:			cmp #SW_RIGHT
			bne !+
			jsr BlockRight
			jmp IOe
IOe:			
!:			pla
			tax
			pla
			rts

//-------------Game Functions---------------					

GameEnd:
			jmp INIT
CHLines:
			lda Lines
			cmp #$0A
			bne !+
			inc Level		
			lda #$00		
			sta Lines		
!:			rts

CHLevel:
			ldy Level
			lda LDTbl,y
			sta DropLVL
			rts
			
PRScore:						
			pha				
			tya				
			pha				

			lda #$05								
			sta TLength								
			lda #<Tiles+150
			sta B0Tiles
			lda #$F7							
			sta B0TilesH										
			lda #13
			sta LCDX										
													
			lda ScoreHH			
			and #%00001111			
			tay			
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH		
			lda #12
			sta LCDY	
			jsr PBlock_CL											
													
			lda ScoreH				
			and #%11110000				
			lsr				
			lsr				
			lsr				
			lsr				
			tay
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH
			lda #08
			sta LCDY
			jsr PBlock_CL			
			lda ScoreH			
			and #%00001111			
			tay			
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH		
			lda #12
			sta LCDY	
			jsr PBlock_CL			
						
			lda Score				
			and #%11110000				
			lsr				
			lsr				
			lsr				
			lsr				
			tay
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH
			lda #16
			sta LCDY
			jsr PBlock_CL			
			lda Score		
			and #%00001111			
			tay			
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH		
			lda #20
			sta LCDY
			jsr PBlock_CL			
	
			pla				
			tay				
			pla				
			rts				
									
PRLevel:
			pha				
			tya				
			pha				

			lda #$05								
			sta TLength								
			lda #<Tiles+150
			sta B0Tiles
			lda #$F7							
			sta B0TilesH										
			lda #01
			sta LCDX													
						
			lda Level				
			and #%11110000				
			lsr				
			lsr				
			lsr				
			lsr				
			tay
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH
			lda #16
			sta LCDY
			jsr PBlock_CL			
			lda Level		
			and #%00001111			
			tay			
			lda NTblL,y
			sta BTiles
			lda NTblH,y
			sta BTilesH		
			lda #20
			sta LCDY
			jsr PBlock_CL			
	
			pla				
			tay				
			pla				
			rts		
			
BlockSlam:
			pha
			lda #$01
			sta DropDelay
			pla
			rti 
			
BlockErase:						// Erases a tetromino		
			pha			
			tya			
			pha			
			txa			
			pha			
									
			ldy BlockID
			lda TTblL,y			// Get the low byte of the block's graphics pointer
			sta BTiles
			lda TTblH,y			// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda TETblL,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda TETblH,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH			
						
			ldy BlockX
			lda BSTblX,y		// Use the Block X position to find the Y screen position of the block
			sta LCDY
			ldy BlockY
			lda BSTblY,y		// Use the Block Y position to find the X screen position of the block
			sta LCDX
			jsr EBlock		
						
			pla			
			tax			
			pla			
			tay			
			pla			
			rts			
						
BlockPrint:						// Prints a block at the current (BlockX, BlockY) position			
			pha			
			tya			
			pha			
			txa			
			pha			
						
			ldy BlockID
			lda TTblL,y			// Get the low byte of the block's graphics pointer
			sta BTiles
			lda TTblH,y			// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda TETblL,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda TETblH,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH			
						
			ldy BlockX
			lda BSTblX,y		// Use the Block X position to find the Y screen position of the block
			sta LCDY
			ldy BlockY
			lda BSTblY,y		// Use the Block Y position to find the X screen position of the block
			sta LCDX
			jsr PBlock	
			
			pla			
			tax			
			pla			
			tay			
			pla			
			rts			
							
BlockRight:						// Moves the tetromino right one space
			jsr ECData
			inc BlockX
			jsr CCData
			bcs !+
			dec BlockX
			jsr BlockErase
			inc BlockX
			jsr PCData
			jsr BlockPrint
			rts
!:			dec BlockX
			jsr PCData
			rts					

BlockLeft:						// Moves the tetromino left one space
			jsr ECData
			dec BlockX
			jsr CCData
			bcs !+
			inc BlockX
			jsr BlockErase
			dec BlockX
			jsr PCData
			jsr BlockPrint
			rts
!:			inc BlockX
			jsr PCData
			rts

BlockDown:						// Moves the tetromino down one space
			pha					
			jsr ECData		
			dec BlockY
			jsr CCData
			bcs !+
			inc BlockY
			jsr BlockErase
			dec BlockY
			jsr PCData
			jsr BlockPrint
			pla
			rts			
!:			inc BlockY
			jsr PCData
			jsr BlockNew
			pla
			rts
			
BlockRotate:					// Rotates a block CW
			pha
			tya
			pha
			
			jsr ECData
			ldy BlockID
			lda RTbl,y			// Lookup how many rotations are left in this blocks cycle
			cmp #$00
			bne R0				// If there are still cycles left, then branch to continue
			lda BlockID
			pha
			lda BlockID_B
			sta BlockID
			jsr CCData
			bcs !+
			pla
			sta BlockID
			jsr BlockErase
			lda BlockID_B
			sta BlockID
			jsr PCData
			jsr BlockPrint
			jmp Re
!:			pla
			sta BlockID
			jsr PCData
			jmp Re				// Exit the routine
R0:			inc BlockID
			jsr CCData
			bcs !+
			dec BlockID
			jsr BlockErase
			inc BlockID
			jsr PCData
			jsr BlockPrint
			jmp Re
!:			dec BlockID
			jsr PCData
			jmp Re
			
Re:			pla
			tay
			pla
			rts

BlockNew:						// Creates a new tetromino and sets up it's graphics data
			pha
			tya
			pha
			
			jsr CLine			// Check if any lines have been formed
			
			lda #%10000000		// Set X = 0
			jsr Command
			lda #%01000000		// Set Y = 0
			jsr Command
			lda #$03
			jsr WriteBYTE
			
			lda BlockID_Next
			pha
			jsr IDGen
			tay
			lda BTbl,y			// Use the random number as an index to get the next blockID
			sta BlockID_Next
			pla
			sta BlockID
			sta BlockID_B
			lda #07
			sta LCDX
			lda #31
			sta LCDY
			
			ldy BlockID
			lda TTblL,y			// Get the low byte of the block's graphics pointer
			sta BTiles
			lda TTblH,y			// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda TETblL,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda TETblH,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH
			
			jsr PBlock
			jsr EBlock			// Erase the last thing that was in the "Next Piece" display
			
			ldy BlockID_Next	// Print the next tetromino
			sty BlockID
			lda TTblL,y			// Get the low byte of the block's graphics pointer
			sta BTiles
			lda TTblH,y			// Get the high byte of the block's graphics pointer
			sta BTilesH
			lda TETblL,y		// Get the low byte of the block's graphics pointer
			sta B0Tiles
			lda TETblH,y		// Get the high byte of the block's graphics pointer
			sta B0TilesH
			
			lda #07
			sta LCDX
			lda #31
			sta LCDY
			jsr PBlock			// Print the next piece in the "Next Piece" display
			
			ldy BlockID_B
			sty BlockID
			
			lda #4
			sta BlockX
			lda #16
			sta BlockY
			lda #75
			sta LCDX
			lda #17
			sta LCDY
			
			jsr CCData
			bcc !+				
			jmp GameEnd			// Unable to print another tetromino, end the game
!:			jsr PCData
			jsr BlockPrint
			
			lda DropLVL
			sta DropDelay
			
			pla
			tay
			pla
			rts
RNDInit:
			ldx #$89
			stx IDSeed
			dex
			stx IDSeed+1
			rts

IDGen:							// Generates a "random" Block ID
			lda IDSeed 		
			and #%00000111
			cmp #$07
			bne !+
			jsr NEWSeed
			jmp IDGen
!:			pha
			jsr NEWSeed
			pla
			rts

NEWSeed:
			lda IDSeed
			and #%00000010
			sta TMPSeed
			lda IDSeed+1
			and #%00000010
			eor TMPSeed
			clc
			beq !+
			sec
!:			ror IDSeed
			ror IDSeed+1
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
	
			lda #$09			// For normal blocks, the tile length is 9 bytes
			ldy BlockID
			cpy #$11			// If the BlockID is == 11, (Iu), then the tile length is extended to 12 bytes
			bne !+
			lda #$0C
!:			sta TLength
PBep:
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

EBlock:		
			lda LCDX		
			pha		
			lda LCDY		
			pha		
	
			lda #$09			// For normal blocks, the tile length is 9 bytes
			ldy BlockID
			cpy #$11			// If the BlockID is == 11, (Iu), then the tile length is extended to 12 bytes
			bne !+
			lda #$0C
!:			sta TLength

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
									
CCData:								// Checks if a block can be moved to a position without collision // C = 1 (collision) c = 0 (Safe)					
			pha
			tya
			pha
					
			lda #$01
			sta GTmp4
			sta GTmp5
			lda BlockX
			sta GTmp6
		
			ldy BlockID
			lda CTblL,y
			sta CTiles
			lda CTblH,y
			sta CTilesH
			
			ldy BlockY
			iny
			iny
			sty GTmp3
CC0:		ldx BlockX
			lda CSTblL,y			
			sta CScreen			
			lda CSTblH,y			
			sta CScreenH			
			ldy #$00					
			sty GTmp7				
!:			ldy GTmp7
			lda (CTiles),y						
			cmp #$20						
			beq CC1
			
			ldy GTmp6
			lda (CScreen),y
			cmp #$20
			bne	CCe
			ldy GTmp7
			lda (CTiles),y
			
CC1:		inc GTmp7
			inc GTmp6
			lda GTmp5
			inc GTmp5
			cmp #$03
			bne !-
			lda #$01
			sta GTmp5
			lda GTmp4
			inc GTmp4
			cmp #$03
			beq CCe0
			dec GTmp3
			ldx GTmp3
			lda CSTblL,x			
			sta CScreen			
			lda CSTblH,x			
			sta CScreenH
			lda BlockX
			sta GTmp6
			jmp !-		
			
CCe0:		clc
			jmp !+
CCe:		sec			
!:			pla
			tay
			pla
			rts
			
PCData:								// Checks if a block can be moved to a position without collision // C = 1 (collision) c = 0 (Safe)					
			pha
			tya
			pha
			
			lda #$01
			sta GTmp4
			sta GTmp5
			lda BlockX
			sta GTmp6
			
			ldy BlockID
			lda CTblL,y
			sta CTiles
			lda CTblH,y
			sta CTilesH

			ldy BlockY
			iny
			iny
			sty GTmp3
PC0:		ldx BlockX
			lda CSTblL,y			
			sta CScreen			
			lda CSTblH,y			
			sta CScreenH			
			ldy #$00					
			sty GTmp7				
!:			ldy GTmp7
			lda (CTiles),y						
			cmp #$20						
			beq PC1
			ldy GTmp6
			sta (CScreen),y
			
PC1:		inc GTmp7
			inc GTmp6
			lda GTmp5
			inc GTmp5
			cmp #$03
			bne !-
			lda #$01
			sta GTmp5
			lda GTmp4
			inc GTmp4
			cmp #$03
			beq PCe0
			dec GTmp3
			ldx GTmp3
			lda CSTblL,x			
			sta CScreen			
			lda CSTblH,x			
			sta CScreenH
			lda BlockX
			sta GTmp6
			jmp !-		
			
PCe0:		pla
			tay
			pla
			rts
		
ECData:								// Checks if a block can be moved to a position without collision // C = 1 (collision) c = 0 (Safe)					
			pha
			tya
			pha
			
			lda #$01
			sta GTmp4
			sta GTmp5
			lda BlockX
			sta GTmp6

			ldy BlockID
			lda CTblL,y
			sta CTiles
			lda CTblH,y
			sta CTilesH

			ldy BlockY
			iny
			iny
			sty GTmp3
EC0:		ldx BlockX
			lda CSTblL,y			
			sta CScreen			
			lda CSTblH,y			
			sta CScreenH			
			ldy #$00					
			sty GTmp7				
!:			ldy GTmp7
			lda (CTiles),y						
			cmp #$20						
			beq EC1
			lda #$20
			ldy GTmp6
			sta (CScreen),y
			
EC1:		inc GTmp7
			inc GTmp6
			lda GTmp5
			inc GTmp5
			cmp #$03
			bne !-
			lda #$01
			sta GTmp5
			lda GTmp4
			inc GTmp4
			cmp #$03
			beq ECe0
			dec GTmp3
			ldx GTmp3
			lda CSTblL,x			
			sta CScreen			
			lda CSTblH,x			
			sta CScreenH
			lda BlockX
			sta GTmp6
			jmp !-		
			
ECe0:		pla
			tay
			pla
			rts

CLine:		
			pha
			tya
			pha
			
			lda #$00
			sta GTmp2
			sta LCount
			lda #$01
			sta GTmp3
C0:			ldy GTmp3				// Increase the line pointer
			lda CSTblL,y
			sta CScreen
			lda CSTblH,y
			sta CScreenH
			ldy #$01
C1:			lda (CScreen),y			// Check the line for spaces
			cmp #$01
			bne C3					// If a space is found, then skip the rest of the line
			iny 
			cpy #$0B				// Check if the end of the line has been reached
			bne C1					// If not, then loop again
			lda GTmp3
			pha
			jsr ELine
			sed
			inc Lines
			cld
			inc LCount
			pla
			sta GTmp3
C3:			inc GTmp3				// Increase the index for the line number
			lda GTmp3
			cmp #19					// See if the top line has been parsed yet
			bne C0					// If not, then parse the next line
			
CLe:		brk
			ldy LCount
			lda SCTbl,y
			sed			
			clc
			adc ScoreH
			sta ScoreH
			bcc !+
			clc
			inc ScoreHH
!:			cld
			jsr CHLines
			jsr CHLevel
			jsr PRScore
			jsr PRLevel

			pla
			tay
			pla
			rts								
						
ELine:								// Speedcode that erases a line of graphics data																	
			pha																
			tya															
			pha																
																			
			ldy #$01							
			lda #$20							
!:			sta (CScreen),y							
			iny							
			cpy #$0B							
			bne !-		
				
			lda PTblL+1
			sta VScreen		
			lda PTblH+1		
			sta VScreenH	
			
			lda #$01 
			sta LCDY
			ldy GTmp3
			lda BSTblY,y
			tay
			sty LCDX
			lda #$01
			sta (VScreen),y
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX
			iny		
			sta (VScreen),y
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX	
			iny	
			sta (VScreen),y	
			jsr SETCursor_3b
			jsr WriteBYTE
				
			lda PTblL+2				// Set up the screen vector	GTmp2
			sta VScreen		
			lda PTblH+2		
			sta VScreenH	
			
			lda #$01 
			sta LCDY
			ldy GTmp3
			lda BSTblY,y
			tay
			sty LCDX
			lda #$00
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX
			iny		
			sta (VScreen),y
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX	
			iny	
			sta (VScreen),y	
			jsr SETCursor_3b
			jsr WriteBYTE	
			
			lda PTblL+3
			sta VScreen		
			lda PTblH+3	
			sta VScreenH	
			
			lda #$01 
			sta LCDY
			ldy GTmp3
			lda BSTblY,y
			tay
			sty LCDX
			lda #$80
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX
			iny		
			sta (VScreen),y
			jsr SETCursor_3b
			jsr WriteBYTE
			inc LCDX	
			iny	
			sta (VScreen),y	
			jsr SETCursor_3b
			jsr WriteBYTE
							
SLine:								// Speedcode that shifts the contents of the lcd down to the current BlockX position (in GTmp3)	
			lda PTblL+1
			sta VScreen		
			lda PTblH+1		
			sta VScreenH	
			
			lda GTmp3
			pha
SC:			inc GTmp3
			ldy GTmp3				// Increase the line pointer
			cpy #19
			beq SCe
			lda CSTblL,y
			sta CScreen
			lda CSTblH,y
			sta CScreenH
			dey
			lda CSTblL,y
			sta C0Screen
			lda CSTblH,y
			sta C0ScreenH
			ldy #$01
!:			lda (CScreen),y			
			sta (C0Screen),y		
			iny	
			cpy #$0B		
			bne !-		
			jmp SC		
SCe:		dey
			lda CSTblL,y
			sta CScreen
			lda CSTblH,y
			sta CScreenH
			lda #$20							
			ldy #$01					
!:			sta (CScreen),y							
			iny							
			cpy #$0B							
			bne !-	
			pla						// Restore original line number
			sta GTmp3	
			
			lda #$01 
			sta LCDY
			ldy GTmp3
			iny
			lda BSTblY,y
			tay
			sty LCDX
!:			
			lda (VScreen),y
			dey
			dey
			dey
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE
			iny
			iny
			iny
			iny				
			cpy #84				
			bne !-				
			dey			
			dey			
			dey			
			dey	
			lda #$01			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE					
								
			lda PTblL+2
			sta VScreen		
			lda PTblH+2		
			sta VScreenH			
			lda #$02
			sta LCDY
			ldy GTmp3
			iny
			lda BSTblY,y
			tay
			sty LCDX
!:			lda (VScreen),y
			dey
			dey
			dey
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE
			iny
			iny
			iny
			iny				
			cpy #84				
			bne !-				
			dey			
			dey			
			dey			
			lda #$00			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
						
			lda PTblL+3
			sta VScreen		
			lda PTblH+3	
			sta VScreenH			
			lda #$03 
			sta LCDY
			ldy GTmp3
			iny
			lda BSTblY,y
			tay
			sty LCDX
!:			lda (VScreen),y
			dey
			dey
			dey
			sta (VScreen),y
			jsr SETCursor_3b
			jsr WriteBYTE
			iny
			iny
			iny
			iny				
			cpy #84				
			bne !-				
			dey			
			dey			
			dey			
			lda #$00			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
						
			lda PTblL+4
			sta VScreen		
			lda PTblH+4		
			sta VScreenH			
			lda #$04 
			sta LCDY
			ldy GTmp3
			iny
			lda BSTblY,y
			tay
			sty LCDX
!:			lda (VScreen),y
			dey
			dey
			dey
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE
			iny
			iny
			iny
			iny				
			cpy #84				
			bne !-				
			dey			
			dey			
			dey			
			lda #$80			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE			
			iny			
			sta (VScreen),y
			sty LCDX
			jsr SETCursor_3b
			jsr WriteBYTE
			
			lda GTmp3
			pha
			lda #<Screen
			sta GTmp3
			lda #>Screen
			sta GTmp4
			jsr WriteBMP
			pla
			sta GTmp3
			
			pla
			tay
			pla
			rts
										
//---------------Misc Tables----------------					
KEnd:
			*=$F600
MS:
Tiles:
		.import binary "Assets/Tiles0.bin"
Title:		
		.import binary "Assets/Title.bin"		
Game:		
		.import binary "Assets/Game.bin"										
Table:									
		.import binary "Assets/Collision.bin"									
										
		.var  Screen1 = >Screen			// Bug workaround					
		.eval Screen1 = Screen1+1								
		.var  Tiles1 = >Tiles								
		.eval Tiles1 = Tiles1+1								
		.var  Collision1 = >Collision								
		.eval Collision1 = Collision1+1								
PTbl1:
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			.byte $00, $01, $02, $03, $04, $05, $06, $07
			
PTblL:		.byte <Screen, <Screen+84, <Screen+168, <Screen+252, <Screen+80, <Screen+164										
PTblH:		.byte >Screen, >Screen, >Screen, >Screen, Screen1, Screen1
NTblL:		.byte <Tiles+80, <Tiles+86, <Tiles+92, <Tiles+98, <Tiles+104, <Tiles+110, <Tiles+116, <Tiles+122, <Tiles+128, <Tiles+134
NTblH:		.byte Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1
TTblL:		.byte <Tiles, <Tiles+18, <Tiles+36, <Tiles+54, <Tiles+72, <Tiles+90, <Tiles+108, <Tiles+126, <Tiles+144, <Tiles+162
			.byte <Tiles+180, <Tiles+198, <Tiles+216, <Tiles+234, <Tiles+252, <Tiles+14, <Tiles+32, <Tiles+50, <Tiles+62
TTblH:		.byte >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles
			.byte >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1
TETblL:		.byte <Tiles+9, <Tiles+27, <Tiles+45, <Tiles+63, <Tiles+81, <Tiles+99, <Tiles+117, <Tiles+135, <Tiles+153, <Tiles+171
			.byte <Tiles+189, <Tiles+207, <Tiles+225, <Tiles+243, <Tiles+5, <Tiles+23, <Tiles+41, <Tiles+150, <Tiles+71
TETblH:		.byte >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles, >Tiles
			.byte >Tiles, >Tiles, >Tiles, >Tiles, Tiles1, Tiles1, Tiles1, Tiles1, Tiles1
BTbl:		.byte $00, $04, $08, $0A, $0B, $0D, $11
BSTblX:		.byte $05, $08, $0B, $0E, $11, $14, $17, $1A, $1D, $20, $23
BSTblY:		.byte $1B, $1E, $21, $24, $27, $2A, $2D, $30, $33, $36, $39, $3C, $3F, $42, $45, $48, $4B, $4E, $51
CTblL:		.byte <Tu, <Tr, <Td, <Tl, <Ju, <Jr, <Jd, <Jl, <Zu, <Zr, <O, <Su, <Sr, <Lu, <Lr, <Ld, <Ll, <Iu, <Ir
CTblH:		.byte >Tu, >Tr, >Td, >Tl, >Ju, >Jr, >Jd, >Jl, >Zu, >Zr, >O, >Su, >Sr, >Lu, >Lr, >Ld, >Ll, >Iu, >Ir
RTbl:		.byte $03, $02, $01, $00, $03, $02, $01, $00, $01, $00, $00, $01, $00, $03, $02, $01, $00, $01, $00
CSTblL:		.byte <Collision+32, <Collision+16, <Collision, <Collision+240, <Collision+224, <Collision+208, <Collision+192, <Collision+176, <Collision+160
			.byte <Collision+144, <Collision+128, <Collision+112, <Collision+96, <Collision+80, <Collision+64, <Collision+48, <Collision+32, <Collision+16, <Collision
CSTblH:		.byte Collision1, Collision1, Collision1, >Collision, >Collision, >Collision, >Collision, >Collision, >Collision
			.byte >Collision, >Collision, >Collision, >Collision, >Collision, >Collision, >Collision, >Collision, >Collision, >Collision
SCTbl:		.byte $00, %00000001, %00000010, %00000100, %00000001
LDTbl:		.byte $00, $FF, $EF, $DF, $CF, $BF, $AF, $9F, $8F, $7F, $6F, $5F, $4F, $3F, $2F, $1F, $0F
//------------------CData-------------------	
	
Tu:			.text " a "
			.text "aaa"
			.text "   "
Tr:			.text " a "
			.text " aa"
			.text " a "
Td:			.text "   "
			.text "aaa"
			.text " a "
Tl:			.text " a "
			.text "aa "
			.text " a "

Ju:			.text " a "
			.text " a "
			.text "aa "
Jr:			.text "a  "
			.text "aaa"
			.text "   "
Jd:			.text " aa"
			.text " a "
			.text " a "
Jl:			.text "   "
			.text "aaa"
			.text "  a"
			
Zu:			.text "   "
			.text "aa "
			.text " aa"
Zr:			.text "  a"
			.text " aa"
			.text " a "
			
O:			.text "   "
			.text "aa "
			.text "aa "
			
Su:			.text "   "
			.text " aa"
			.text "aa "
Sr:			.text " a "
			.text " aa"
			.text "  a"		
	
Lu:			.text " a "
			.text " a "
			.text " aa"
Lr:			.text "   "
			.text "aaa"
			.text "a  "
Ld:			.text "aa "
			.text " a "
			.text " a "
Ll:			.text "  a"
			.text "aaa"
			.text "   "
			
Iu:			.text " a "
			.text " a "
			.text " a "
			.text " a "
Ir:			.text "    "
			.text "aaaa"
			.text "    "   

ME:
//-----------------Vectors------------------	
	          	
			*=$FFFa
			
			.byte <BlockSlam, >BlockSlam, <INIT, >INIT, <BlockSlam, >BlockSlam					// NMI, Reset, and IRQ Vectors Lo, Hi
			
//-----------------Compiler-----------------

			.var KSize = (KEnd - KStart) + (ME - MS)
			.var KPCS = (KSize / $4000)*100

			.print ""
			.print "  Theta-65 Tetris  "
			.print "-------------------"
			.print " Pseudon 2017 v0.1"
			.print ""
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Extra Information "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "$"+toHexString(KSize)+" used of $C000"
			.print toIntString(KPCS)+"% Full"
			.print toIntString($4000-KSize)+" Bytes Free"

			