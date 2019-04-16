//------------------Origin------------------
				
			*=RomStart				// For use with Symon
KStart:			
//----------------Jump Table----------------

Mntr:		jmp GMON
Bsic:		jmp BAS

A:			jmp LCDInit
B:			jmp Write
I:			jmp WriteINV
G:			jmp WriteBMP
D:			jmp Command
L:			jmp LCDHome
N:			jmp LCDClear
M:			jmp SETCursor
E:			jmp CReturn
H:			jmp GETKey	
J:			jmp BUFFClear
K:			jmp RAMInit
F:			jmp BDelay
C:			jmp Delay
O:			jmp *
P:			jmp *
Q:			jmp *
R:			jmp *
S:			jmp *

//-----------------EhBASIC------------------
BAS:		
		.if (STATE == 1) {	
		.import binary "ehbasic.bin"
		}
		
//-------------Initialization---------------

INIT:							// RAM test, I/O init																																												
			sei					// Disable IRQ
			cld					// Clear decimal flag
			ldx #$FF			// Load X with stack pointer
			txs					// Init stack pointer
			lda #<TestStart		// Load A with the low byte of the RAM TEST start address
			sta ADDRS			// Store it in ADDRS
			lda #>TestStart		// Load A with the high byte of the RAM TEST start address
			sta ADDRSHI			// Store it in ADDRSHI
			ldx #$00			// Flush X
			ldy #$00 			// Flush Y
IOInit:			
			lda #$FF			// Load A with #$FF
			sta DDRA			// Set data direction for VIA A port B to Output
			lda #$00
			sta DDRB			// Set data direction for VIA A port A to Input
			lda #$00			// Load A with #$00
			sta PORTA			// Set VIA A port A to low
			sta PORTB			// Set VIA A port B to low
			lda #<WAT
			sta NMIlo
			lda #>WAT
			sta NMIhi
        .if (Emulated) {
            jmp GMON
        }
LCD:	
			jsr LCDInit			// Initialize the LCD	
			jmp WAT
			
//----------------Functions-----------------	
	
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
			lda #%00010000		// Set X = 0
			jsr Command
			lda #%10000000		// Set Y = 0
			jsr Command			
			
			jsr LCDClear		// Clear the LCD
			pla
			rts					// Return
			
LCDHome:
			pha
			jsr LCDClear
			lda #%00100000		// Function set, H == 0
			jsr Command
			lda #%00010000		// Set X = 0
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
			lda #$00
			jsr SETCursor
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
			
			ldx #$00
!:			lda #$20
			sta Screen,x
			inx
			cpx #$54
			bne !-
			pla			
			tay			
			pla			
			tax			
			pla				
			rts			
						
WriteINV:			
			sta GTmp5			// Save the input
			tya					// Push Y to the Stack
			pha			
			txa		
			pha		
								
			jsr CCheck					
			lda GTmp5			// Restore the input					
			ldx LCDCursor
			sta Screen,x						
					
        .if (Emulated){
            pha
!:          lda $8801
	        and #$10
	        beq !-
	        pla
	        sta $8800
	        pla				
			tax				
			pla			
			tay			
			rts
        }
	
			tay					// Transfer input to y to use as an index for a lookup table
			lda MappL,y			// Load the low byte of the graphic 
			sta GTmp5			// Store it in GTmp
			lda MappH,y			// Load the high byte of the graphic
			sta GTmp6			// Store it in GTmp2
			ldy #$00			// Load Y with 0 for the loop
			
!:			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			eor #$FF
			jsr WriteBYTE		// Write a single byte
			cpy #$06
			bne !-
							
			pla				
			tax				
			pla			
			tay			
			rts					// Return
			
Write:			
			sta GTmp5			// Save the input
			tya					// Push Y to the Stack
			pha			
			txa		
			pha			
			lda GTmp5			// Restore the input					
			
			ldx LCDCursor
			sta Screen,x			
				
        .if (Emulated){
            pha
!:          lda $8801
	        and #$10
	        beq !-
	        pla
	        sta $8800
	        pla				
			tax				
			pla			
			tay			
			rts
        }
		
			tay					// Transfer input to y to use as an index for a lookup table
			lda MappL,y			// Load the low byte of the graphic 
			sta GTmp5			// Store it in GTmp
			lda MappH,y			// Load the high byte of the graphic
			sta GTmp6			// Store it in GTmp2
			ldy #$00
			
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
							
			jsr CCheck				
							
			pla				
			tax				
			pla			
			tay			
			rts					// Return
			
Write_NS:			
			sta GTmp5			// Save the input
			tya					// Push Y to the Stack
			pha			
			txa		
			pha												
			lda GTmp5			// Restore the input					
			
			ldx LCDCursor
			sta Screen,x			
						
			tay					// Transfer input to y to use as an index for a lookup table
			lda MappL,y			// Load the low byte of the graphic 
			sta GTmp5			// Store it in GTmp
			lda MappH,y			// Load the high byte of the graphic
			sta GTmp6			// Store it in GTmp2
            ldy #$00
			
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte
			lda (GTmp5),y		// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			iny
			jsr WriteBYTE		// Write a single byte

			jsr CCheck_NS				
			
			pla	
			tax				
			pla			
			tay			
			rts					// Return
		
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
        .if (Emulated) rts											
			sta GTmp			// Save input				
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
			rts					// Return

WriteBMP:						// Writes a bitmap to the screen. GTmp3(L) and GTmp4(H) must contain a pointer to the bitmap
        .if (Emulated) rts			
            pha
			txa
			pha
			tya
			pha
			jsr LCDHome
			ldy #$00
			ldx #$00
WB1:		lda (GTmp3),y		// Load a byte of the bitmap
			jsr WriteBYTE		// Write the byte
			iny					// Increase the index
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
			ldx #$01			// Set X == 1 so the second routine can start
			jmp WB1				// Jump back to the loop

CCheck:			
			pha	
			lda LCDCursor			
			cmp #$53			
			beq !+			
			inc LCDCursor			
			pla
			rts			
!:			
        .if (Emulated) rts
            jsr Scroll				
			pla
			rts
			
CCheck_NS:			
			pha	
			lda LCDCursor			
			cmp #$53			
			beq !+			
			inc LCDCursor			
			pla
			rts			
!:			lda #$00				
			jsr SETCursor				
			pla
			rts
	
SETCursor:
			sta LCDCursor
			txa
			pha
			lda #%00001100		// Set Display Config to modify x and y
			jsr Command
			ldx LCDCursor
			lda CTableX,x
			jsr Command
			ldx LCDCursor
			lda CTableY,x
			jsr Command
			pla
			tax
			rts	

Scroll:						
			pha				
			txa				
			pha				
			lda #$00				
			jsr SETCursor				
			ldx #14						
!:			lda Screen,x						
			jsr Write_NS						
			inx						
			cpx #28						
			bne !-														
											
			lda #14				
			jsr SETCursor				
			ldx #28						
!:			lda Screen,x						
			jsr Write_NS						
			inx						
			cpx #42						
			bne !-						
								
			lda #28				
			jsr SETCursor				
			ldx #42						
!:			lda Screen,x						
			jsr Write_NS						
			inx						
			cpx #56						
			bne !-						
								
			lda #42				
			jsr SETCursor				
			ldx #56						
!:			lda Screen,x						
			jsr Write_NS						
			inx						
			cpx #70						
			bne !-						
								
			lda #56			
			jsr SETCursor				
			ldx #70						
!:			lda Screen,x						
			jsr Write_NS						
			inx						
			cpx #84						
			bne !-						
														
			lda #70
			jsr SETCursor
			ldx #70
!:			lda #$20
			jsr Write_NS				
			inx				
			cpx #84				
			bne !-				
			lda #70	
			jsr SETCursor	
			pla				
			tax				
			pla				
			rts				
							
Delay:          				// Delay for X milliseconds (Accumulator is loaded with # of ms to be delayed)
			sta GTmp      		// Store input Valur in temporary storage
            txa           
            pha           
            tya           
            pha           
		.if (Clock > 1){
			lda #Clock
			sta GTmp6
        }
            
D1:			ldx GTmp      		// Pull input value from storage into X
            ldy #190      		// Load Y with #190
!:			dey           		// Decrease y (First trimmer loop)
            bne !-     			// JMP back 190 times              
D2:			dex           		// Decrease x (Input value, # of milliseconds)
            beq D3		   		// If X == 0 , goto D2
            nop           		// Else, NOP
            ldy #198      		// Load y with 198 (Second trimmer loop)
!:          dey           		// Decrease y 
            bne !-     			// JMP back 198 times
            jmp D2     			// Jump back to L2 

D3:             			
		.if (Clock > 1){	
			dec GTmp6	
			lda GTmp6	
			cmp #$00	
			bne D1	
		}	
			pla           
            tay           
            pla           
            tax           
            lda GTmp      		// Load A with input value for return
			rts 		

CReturn:						// Carridge return
        .if (Emulated) {
            pha
            lda #$0D
            jsr Write
            lda #$0A
            jsr Write
            pla
            rts
        } else {
			pha
			txa
			pha
			clc
			ldx LCDCursor
			cpx #70
			bcs !+
			lda CRTbl,x
			jsr SETCursor
			pla
			tax
			pla
			rts
!:			jsr Scroll
			pla
			tax
			pla
			rts
        }
			
BUFFClear:	
			pha
			txa
			pha
			lda #$00			// Load A with #$00
			jsr SETCursor		// Set cursor position to 0
			lda #$20			// Load A with #$20	(Ascii code for space)
			ldx #00				// Load X with #00
!:			sta $0250,x			// Write A to screen
			inx					// Increase X
			cpx #80				// Compare X with #80 (Size of screen)
			bne !-				// If X =/= 0 , repeat 
			pla
			tax
			pla								
			rts						
			
BDelay:							// Dealy for a lot of cycles
			txa
			pha
			tya 
			pha
			
			ldx #$FF			// Load X with #$FF
RS:			ldy #$FF			// Load Y with #$FF
!:			dey					// Decrease Y (Sub loop)
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

GETKey:     					// PORTBB = ROWS     PORTAB = COLUMNS
        .if (Emulated) {
!:			lda ACIA1sta          
			and #$08
			beq !-
			lda ACIA1dat   
			rts          
}
			pha
			txa
			pha
			tya
			pha
			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB
			lda #$FF
			sta DDRA
			lda #%11111110		
		    sta PORTA
		    lda PORTB
			ora #%00000100		// Ignore control keys
		    sta Scanresult
		    lda #%11111101               
		    sta PORTA
		    lda PORTB
			ora #%00001000		// Get rid of left shift
		    sta Scanresult+1
   			lda #%11111011
    		sta PORTA
    		ldy PORTB
    		sty Scanresult+2
    		lda #%11110111
    		sta PORTA
    		ldy PORTB
    		sty Scanresult+3
    		lda #%11101111
    		sta PORTA
    		ldy PORTB
    		sty Scanresult+4
    		lda #%11011111
    		sta PORTA
    		ldy PORTB
    		sty Scanresult+5
    		lda #%10111111
    		sta PORTA
    		lda PORTB
    		ora #%00010000		// Get rid of right shift
    		sta Scanresult+6
    		lda #%01111111
    		sta PORTA
    		ldy PORTB
    		sty Scanresult+7
    		
    		ldx #$FF
!:    		inx
    		lda Scanresult,x
    		cpx #$08
    		beq LE
    		cmp #$FF
    		beq !-
    		pha
    		txa
    		pha   		
    		lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB
    		lda #%11111101		// Scan for left shift
    		sta PORTA
    		lda PORTB
    		and #%00001000
    		cmp #$00
    		bne !+
    		pla
    		tax
    		pla
    		jmp SKB1
!:			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB
			lda #%10111111		// scan for right shift
			sta PORTA
			lda PORTB
			and #%00010000
			cmp #$00
			bne !+
			pla
			tax
			pla
			jmp SKB1
!:			pla					// Evaluate keyboard without shift
			tax
			pla
			jmp KB1
  			
NJMP:
			pla			
			tax			
			pla			
			jmp KB1			
SJMP:			
			pla 
			tax
			pla
			jmp SKB1

LE:			pla					// Restore registers
			tay
			pla
			tax
			pla					
			lda #$FF			// Set lastkey to #$FF to indicate that there was no key press												
			sta lastkey																
			rts								
								// X has the Row number	(Binary)			
KB1:    	eor #$FF 			// A has the Column number (Linear)
    		jsr LtoB			// Convert A to Binary
    		
    		cmp #$FF
    		beq LE
    		
    		cpx #$00
    		bne !+
    		tax
    		lda B0,x
    		jmp KDN
    		
!:    		cpx #$01
    		bne !+
    		tax
    		lda B1,x
    		jmp KDN
    		
!:    		cpx #$02
    		bne !+
    		tax
    		lda B2,x
    		jmp KDN
    		
!:    		cpx #$03
    		bne !+
    		tax
    		lda B3,x
    		jmp KDN
    		
!:    		cpx #$04
    		bne !+
    		tax
    		lda B4,x
    		jmp KDN
    		
!:    		cpx #$05
    		bne !+
    		tax
    		lda B5,x
    		jmp KDN
    		
!:    		cpx #$06
    		bne !+
    		tax
    		lda B6,x
    		jmp KDN
    		
!:    		cpx #$07
			bne !+
			tax
    		lda B7,x
    		jmp KDN
    		
!:			jmp LE
					
!:			pla
			tay
			pla
			tax
			pla
			lda #$FF
			rts
			
								// X has the Row number	(Binary)			
SKB1:    	eor #$FF 			// A has the Column number (Linear)
    		jsr LtoB			// Convert A to Binary
    		
    		cmp #$FF
    		beq LE
    		
    		cpx #$00
    		bne !+
    		tax
    		lda SB0,x
    		jmp KDN
    		
!:    		cpx #$01
    		bne !+
    		tax
    		lda SB1,x
    		jmp KDN
    		
!:    		cpx #$02
    		bne !+
    		tax
    		lda SB2,x
    		jmp KDN
    		
!:    		cpx #$03
    		bne !+
    		tax
    		lda SB3,x
    		jmp KDN
    		
!:    		cpx #$04
    		bne !+
    		tax
    		lda SB4,x
    		jmp KDN
    		
!:    		cpx #$05
    		bne !+
    		tax
    		lda SB5,x
    		jmp KDN
    		
!:    		cpx #$06
    		bne !+
    		tax
    		lda SB6,x
    		jmp KDN
    		
!:    		cpx #$07
			bne !+
			tax
    		lda SB7,x
    		jmp KDN
    		
!:			jmp LE
					
!:			pla
			tay
			pla
			tax
			pla
			lda #$FF
			rts			
			
KDN:		
			cmp lastkey
			beq !-
			
			sta actkey	
			sta lastkey	
			pla
			tay
			pla
			tax
			pla
			lda actkey
			rts
			
LtoB:
			cmp #%00000001
			bne !+
			lda #$00
			rts
!:			cmp #%00000010
			bne !+
			lda #$01
			rts
!:			cmp #%00000100
			bne !+
			lda #$02
			rts
!:			cmp #%00001000
			bne !+
			lda #$03
			rts
!:			cmp #%00010000
			bne !+
			lda #$04
			rts
!:			cmp #%00100000
			bne !+
			lda #$05
			rts
!:			cmp #%01000000
			bne !+
			lda #$06
			rts
!:			cmp #%10000000
			bne !+
			lda #$07
			rts
!:								// No key was pressed, Return FF																			
			lda #$FF																	
			rts																				

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
			cmp #>TestEnd
			bne Ra1																										
			rts																
																																											
													
//-----------------Handlers------------------

IRQ:		sei					// Handler for IRQ
			pha				
			txa				
			pha				
			tya				
			pha							
			jmp (IRQlo)			// Jump to software IRQ vector					
ENDirq:		pla				
			tay				
			pla				
			tax				
			pla								
			cli								
			rti
			
NMI:		
			jmp WAT

//------------------Watch-------------------			

WAT:
		#import "Watch.asm"
	
//-----------------Monitor------------------			
		
GMON:			
		#import "G'Mon.asm"			
				
//---------------Misc Tables----------------					
KEnd:		
			*=$F700	
MS:
Char:
		.import binary "Assets/FONT.bin"			
		
BTBL:   	//    0    1    2    3    4    5    6    7
B0:			.byte $31, $08, $FF, $04, $20, $FF, $51, $32 //0
B1:			.byte $33, $57, $41, $FF, $5A, $53, $45, $34 //1
B2:			.byte $35, $52, $44, $58, $43, $46, $54, $36 //2
B3:			.byte $37, $59, $47, $56, $42, $48, $55, $38 //3
B4:			.byte $39, $49, $4A, $4E, $4D, $4B, $4F, $30 //4 
B5:			.byte $2B, $50, $4C, $2C, $2E, $3A, $40, $2D //5
B6:			.byte $5C, $2A, $3B, $2F, $FF, $3D, $FF, $13 //6
B7:			.byte $08, $0D, $FF, $FF, $03, $04, $05, $06 //7

SBTBL:   	//    0    1    2    3    4    5    6    7
SB0:		.byte $21, $08, $FF, $04, $20, $FF, $51, $22 //0
SB1:		.byte $23, $57, $41, $FF, $5A, $53, $45, $24 //1
SB2:		.byte $25, $52, $44, $58, $43, $46, $54, $26 //2
SB3:		.byte $27, $59, $47, $56, $42, $48, $55, $28 //3
SB4:		.byte $29, $49, $4A, $4E, $4D, $4B, $4F, $20 //4 
SB5:		.byte $2B, $50, $4C, $3C, $3E, $5B, $40, $2D //5
SB6:		.byte $5C, $2A, $5D, $3F, $FF, $3D, $F7, $13 //6
SB7:		.byte $08, $0D, $FF, $FF, $03, $04, $05, $06 //7		

CRTbl:
			.byte $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
			.byte $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C
			.byte $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A
			.byte $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38
			.byte $46, $46, $46, $46, $46, $46, $46, $46, $46, $46, $46, $46, $46, $46
	
			*=$FA00					
Char2:			
		.import binary "Assets/FONT2.bin"			
Border:		
		.import binary "Assets/Border.bin"						
									
		.var  H1Char	= >Char				// There is a bug in the current version of KickAssembler that doesn't allow the preprocessor to do operations to the taken high byte of a label
		.eval H1Char	= H1Char + 1		// Ex. if the TEST label is at $3A52, the output of ">TEST+1" should be $3B, but the real output is $3A
		.var  H1Char2	= >Char2			// Doing the operations seperately works around the issue
		.eval H1Char2	= H1Char2 + 1			
MappL:
			.byte <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char
			.byte <Char, <Char2+228, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char														//  , (CR)
			.byte <Char, <Char, <Char, <Char, <Char+164, <Char+80, <Char+74, <Char+92, <Char+98, <Char+104, <Char+116, <Char+68, <Char+128, <Char+134						//  , , , , (Space), !, ", #, $, %, &, ', (, )
			.byte <Char+122, <Char+158, <Char+182, <Char+152, <Char+188, <Char+170, <Char2+0, <Char2+6, <Char2+12, <Char2+18, <Char2+24, <Char2+30, <Char2+36, <Char2+42	// *, +, (,), -, ., /, 0, 1, 2, 3, 4, 5, 6, 7 
			.byte <Char2+48, <Char2+54, <Char+218, <Char+224, <Char+194, <Char+212, <Char+200, <Char+206, <Char+86, <Char+0, <Char+6, <Char+12, <Char+18, <Char+24			// 8, 9, :, ;, <, =, >, ?, @, A, B, C, D, E
			.byte <Char+30, <Char+36, <Char+42, <Char+48, <Char+54, <Char+60, <Char+66, <Char+72, <Char+78, <Char+84, <Char+90, <Char+96, <Char+102, <Char+108				// F, G, H, I, J, K, L, M, N, O, P, Q, R, S
			.byte <Char+114, <Char+120, <Char+126, <Char+132, <Char+138, <Char+144, <Char+150, <Char+156, <Char+176, <Char+162, <Char+110, <Char, <Char, <Char+168			// T, U, V, W, X, Y, Z, [, \, ], ^, _, `, a
			.byte <Char+174, <Char+180, <Char+186, <Char+192, <Char+198, <Char+204, <Char+210, <Char+216, <Char+222, <Char+228, <Char+234, <Char+240, <Char+246, <Char+252	// b, c, d, e, f, g, h, i, j, k, l, m, n, o
			.byte <Char+2, <Char+8, <Char+14, <Char+20, <Char+26, <Char+32, <Char+38, <Char+44, <Char+50, <Char+56, <Char+62, <Char+140, <Char, <Char+146					// p, q, r, s, t, u, v, w, x, y, z, {, |, }
			.byte <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char
			.byte <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char
			.byte <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char, <Char
MappH:			
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char
			.byte >Char, >Char2, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char						//  , (CR)
			.byte >Char, >Char, >Char, >Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char			//  , , , , (Space), !, ", #, $, %, &, ', (, )
			.byte H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, >Char2, >Char2, >Char2, >Char2, >Char2, >Char2, >Char2, >Char2		// *, +, (,), -, ., /, 0, 1, 2, 3, 4, 5, 6, 7 
			.byte >Char2, >Char2, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, >Char, >Char, >Char, >Char, >Char				// 8, 9, :, ;, <, =, >, ?, @, A, B, C, D, E
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char						// F, G, H, I, J, K, L, M, N, O, P, Q, R, S
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, H1Char, >Char, H1Char, >Char, >Char, >Char					// T, U, V, W, X, Y, Z, [, \, ], ^, _, `, a
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char						// b, c, d, e, f, g, h, i, j, k, l, m, n, o
			.byte H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char, H1Char		// p, q, r, s, t, u, v, w, x, y, z, {, |, }
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char
			.byte >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char, >Char
CTableX:
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
			.byte $80, $86, $8C, $92, $98, $9E, $A4, $AA, $B0, $B6, $BC, $C2, $C8, $CE
CTableY:
			.byte $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
			.byte $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
			.byte $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42
			.byte $43, $43, $43, $43, $43, $43, $43, $43, $43, $43, $43, $43, $43, $43
			.byte $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
			.byte $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45
		
ME:			
//-----------------Vectors------------------	
	          	
			*=$FFFa
			
			.byte <NMI, >NMI, <INIT, >INIT, <IRQ, >IRQ						// NMI, Reset, and IRQ Vectors Lo, Hi
			
//-----------------Compiler-----------------

			.var KSize = (KEnd - KStart) + (ME - MS)
			.var KPCS = (KSize / HexRomSize)*100

		.if (STATE == 1){
			.print ""
			.print "  Theta-65 Kernal "
			.print "-------------------"
			.print " Pseudon 2017 v0.8"
			.print ""
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Funtion Addresses"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "LCDInit     = $"+toHexString(A)
			.print "Write       = $"+toHexString(B)
			.print "WriteINV    = $"+toHexString(I)
			.print "WriteBMP    = $"+toHexString(G)
			.print "Command     = $"+toHexString(D)
			.print "LCDHome     = $"+toHexString(L)
			.print "LCDClear    = $"+toHexString(N)
			.print "SETCursor   = $"+toHexString(M)
			.print "CReturn     = $"+toHexString(E)
			.print "GETKey      = $"+toHexString(H)
			.print "BUFFClear   = $"+toHexString(J)
			.print "RamInit     = $"+toHexString(K)	
			.print "BDelay      = $"+toHexString(F)
			.print "Delay       = $"+toHexString(C)	
			.print "=-=-=-=-=-=-=-=-=-="
			.print "   O/S Addresses"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "EhBasic     = $"+toHexString(Bsic)
			.print "Monitor J   = $"+toHexString(Mntr)
			.print "WatchMenu   = $"+toHexString(Watch)
			.print "Char        = $"+toHexString(Char)
			.print "Char2       = $"+toHexString(Char2)
			.print "=-=-=-=-=-=-=-=-=-="
			.print " Extra Information "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "$"+toHexString(KSize)+" used of $"+toHexString(HexRomSize)
			.print toIntString(KPCS)+"% Full"
			.print toIntString(HexRomSize-KSize)+" Bytes Free"
			.print "=-=-=-=-=-=-=-=-=-="
			.print "    System Info    "
			.print "=-=-=-=-=-=-=-=-=-="
			.print "ROM Start   = $"+toHexString(RomStart)
			.print "ROM Size    = "+toIntString(RomSize)+"Kb"
		}
			
