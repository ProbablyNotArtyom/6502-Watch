Start_OS:	
			sei
			jsr LCDHome
			.if (BootMessage) jmp MonitorBoot 
			jmp Main

		.var CMDNumber	= $07		// Number of commands 
			
//------------Monitor Functions--------------		
												
KEYin:								// Waits for a key input
		.if (Emulated) {
!:			lda ACIA1sta          
			and #$08
			beq !-
			lda ACIA1dat   
			rts                    
		} else {
			lda #$60
			jsr Delay
			jsr GETKey
			cmp #$FF
			beq KEYin
			rts
		}
BRKChk:								// Checks for a break condition (Run/Stop Key)
			pha
        .if (Emulated) {
            pla            
            rts
        } else {
			jsr GETKey
			cmp #$04
			beq !+
			pla
			rts
!:			jmp Main
        }

PRWord:        						// Prints word AAXX   
			jsr PRByte				
			txa
PRByte:		pha						// Prints byte AA	
			lsr						
			lsr						
			lsr						
			lsr						
			jsr PRHex						
			pla					
PRHex:		and #%00001111			// Prints digit A
			tay
			lda HEX,y				
			jmp Write				
															
//-----------------Monitor-------------------	

MonitorBoot:      
			lda #$00
			jsr SETCursor  
			ldx #$00
!:			lda Porttxt,x
			cmp #$00
			beq Main
			jsr Write
			inx			
			jmp !-  			  
Main:		
			jsr BFlush
			ldx #$FF
			txs
Input:		ldy #$00				// Set Y to zero to start tracking input length
			sty Parse
			jsr CReturn
			lda #MONPrompt
			jsr Write
			jsr BFlush				// Empty the input buffer
Input1:		jsr KEYin				// Input the current key
			
		.if (Emulated){
			cmp #$7B
			bcs !+
			cmp #$61
			bcc !+
			and #%11011111
!:			
			cmp #$1B 				// Escape (Emulator)
		} else {  
			cmp #$03			  	// F1 (F1)
		}
			bne !+           
			jsr LCDHome
            jmp BAS

!:          cmp #$0D				// Is it an enter (Carridge Return)?
			beq Input4				// If yes, then we are done inputing text
			cmp #$08				// If not, then check if it is a backspace			
			beq Input3				// If it is, then skip to the backspace routine			
Input2:		cpy #$FF				// Is the input length about to be a full page long?
			bne !+					// If not, then continue to input characters
			jmp Input4				// If so, then exit the input routine		
!:			sta Buffer,y			// Store the input in the buffer
			jsr Write
			iny						// Increase the character pointer
			jmp Input1				// Input another character
			
Input3:		cpy #$00        	      
            beq Input1	        	// If there are no characters in the buffer, then skip the backspace routine
            lda #$00
            sta Buffer,y
            dey                  	// Purge the last input character
            
            ldx LCDCursor
            dex
            txa
            jsr SETCursor
            lda #$20
            jsr Write
            ldx LCDCursor
            dex
            txa
            jsr SETCursor
            
            jmp Input1
Input4:		lda #$0D	
			sta Buffer,y	
Main1:																						
			ldy #$FF				// Reset X for indexed addressing in the loop
			
Main2:		
			iny
Main3:		lda	Buffer,y			// Grab a character from the input buffer
			cpy #$FF
			beq Main1
			ldx #$FF					
!:			inx						// Increase index for the command finder loop
			cpx #CMDNumber			// Has the loop already compared the input to all of the avalible digits?
			beq !+					// If so, then the hex input is over
			cmp	CMD,x				// Compare it to the avalible commands
			bne !-
			jmp Main5
!:			ldx #$FF
!:			inx
			cpx #16
			beq Main2
			cmp HEX,x
			bne !-
			
			lda #$00
			sta WORDInput
			sta WORDInput_H
			dey
MNT:		iny
			lda Buffer,y
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq Main3				// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			
			txa				
			ldx #$04
!:			asl WORDInput	
			rol WORDInput_H	
			dex	
			bne !-	
			ora WORDInput	
			sta WORDInput			
			jmp MNT												
Main4:													
Main5:		sty Parse
			txa
			asl
			tax								
			lda #>Main7				// Push high byte of return address		
			pha			
			lda #<Main7-1			// Push low byte of return address	
			pha			
Main6:          				  	// RTS into the command by pushing the address of the code into the stack
            lda JCMD,x
            sta GTmp 
            inx
            lda JCMD,x
            pha
            lda GTmp 
            pha
            rts           
Main7:
			jmp Input
BFlush:
			ldx #$FF
			lda #$00
!:			inx
			sta Buffer,x
			cpx #$FF
			bne !-
			rts

//-------------Monitor Funtions--------------

View:		
			jsr CReturn				// Call a Carridge Return
			lda WORDInput_H			// Load the high byte of the input into A
			ldx WORDInput			// Load the low byte of the input into A
			jsr PRWord				// Print the full word
			lda #$20				
			jsr Write				// Write a space
			lda #'-'
			jsr Write				// Write a dash
V0:			lda #$20
			jsr Write				// Write a space
			ldx #$00
			lda (WORDInput,x)		// Load the Data from the input position
			jsr PRByte				// Print the byte
			jsr IAddr				// Increase the address pointer
			jsr BRKChk				// Check for break
			rts						// Return from the loop
			
Range:		
			ldy #$00
			sty LISTEnd_H			// Set the alt input to zero to ready it for bitshifting
			sty LISTEnd
			ldy Parse				// Load the location of the parse cursor
R0:			iny						// Increase the index to get the next character (should be the start of the ending value input)
			lda Buffer,y			// Load the value from the buffer
			ldx #$FF				// Loop to find 
!:			inx						// Increase index 
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq R1					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			
			txa						// Transfer the input digit to A
			ldx #$04				// Load X with 4 for the loop
!:			asl LISTEnd				// Shift LISTEnd into LISTEnd_H
			rol LISTEnd_H	
			dex						// Decrease X for loop
			bne !-					// Loop to shift the word left by one hex char (ex. D2FB -> 2FB0)
			ora LISTEnd				// Insert the input digit into the word (ex. 2FB0 -> 2FBx, where x is the input)
			sta LISTEnd			
			jmp R0					// Jump back to get more digits
R1:			sty Parse				// After the hex input is over, Store the Parse cursor in Parse
R2:			lda WORDInput			// Load the low byte of the address
			cmp LISTEnd				// Is it equal to the low byte of the ending address?
			bne !+					// If not, skip to continue the loop
			lda WORDInput_H			// If so, then compare the high bytes
			cmp LISTEnd_H		
			bne !+					// If they are equal, then the loop is over
			jmp View				// Jmp to View to print the last byte (with header) then return
!:			jsr View				// Print the header and the first byte
			ldy #$FF				
			sty GTmp				// Put FF into GTmp
!:			
			lda WORDInput			// Load a with the low byte of the current hex address
			cmp LISTEnd				// Compare it with the low byte of the end address
			bne R3					// If not equal, then branch to R3 to print a byte
			lda WORDInput_H			// If equal, then check the high bytes
			cmp LISTEnd_H		
			bne R3					// If not equal, then branch to R3 to print a byte
			jmp V0	 				// If equal, then jmp to V0 to print the last trailing byte (without header)

R3:			jsr V0					// Print a byte and increase the current address
			ldy GTmp				// Load the line length counter from GTmp
			iny						// Increase it
			sty GTmp				// Store it back
			cpy #$0E				// If the line is full (16 bytes printed), jmp to R2 to start a new one
			bne !-					// If not, then go around the loop again
			jmp R2		

Deposit:	
			ldy #$00
			sty LISTEnd_H
			sty LISTEnd
			ldy Parse
Dp0:		iny
			lda Buffer,y
			cmp #$20
			bne !+
			iny
			lda Buffer,y
			cmp #$20
			beq Dp2
			dey
			lda Buffer,y
!:			cmp #$0D
			bne !+
			jmp Dp2
!:			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq Dp1					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-

			txa				
			ldx #$04
!:			asl LISTEnd	
			dex	
			bne !-	
			ora LISTEnd	
			sta LISTEnd			
			jmp Dp0
Dp1:		
			ldx #$00
			lda LISTEnd
			sta (WORDInput,x)
			jsr IAddr
			jmp Dp0
Dp2:		ldx #$00
			lda LISTEnd
			sta (WORDInput,x)
			jmp IAddr
		
Goto:		
			lda #>Main7				// Push the return address to the stack so RTS will bring the code back
			pha
			lda #<Main7-1
			pha
			jmp (WORDInput)			// Jmp to the input address

MErr:			
			jsr CReturn				// Error routine
			ldx #$00
!:			lda Er0,x
			cmp #$00
			beq !+			
			jsr Write
			inx
			jmp !-
!:			pla						// Pull the return values put in by the jsr in order to keep the stack from filling up
			pla	
			jmp Main				// Return to the Monitor and dont execute other commands in the string
			
Fill:			
			ldy #$00
			sty GTmp3
			sty GTmp4
			sty LISTEnd
			sty LISTEnd_H
			ldy Parse
			iny
!:			lda Buffer,y			// Load A with the first value in the input buffer
			iny						// Increase the index
			cpy #$0D
			beq MErr
			cmp #'-'				// Compare it with the option signifier ("-")
			bne !-					// Loop back until we have found any options					
					
F1:			lda Buffer,y
			iny
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq F2					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			sty Parse
			
			txa				
			ldx #$04
!:			asl LISTEnd	
			rol LISTEnd_H	
			dex	
			bne !-	
			ora LISTEnd	
			sta LISTEnd			
			ldy Parse			
			jmp F1	
			
F2:			dey
			lda Buffer,y
			cmp #':'
			bne MErr
			iny
			
F3:			lda Buffer,y
			iny
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq F4					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			sty Parse
			
			txa				
			ldx #$04
!:			asl GTmp3	
			rol GTmp4	
			dex	
			bne !-	
			ora GTmp3	
			sta GTmp3			
			ldy Parse			
			jmp F3	

F4:			ldx #$00
			lda WORDInput	
			sta (LISTEnd,x)	
			lda LISTEnd
			cmp #$FF
			bne !+
			inc LISTEnd_H
!:			inc LISTEnd			
					
			lda LISTEnd		
			cmp GTmp3		
			bne F4		
			lda LISTEnd_H	
			cmp GTmp4	
			bne F4	
			rts

MoErr:			
			jsr CReturn				// Error routine
			ldx #$00
!:			lda Er0,x
			cmp #$00
			beq !+			
			jsr Write
			inx
			jmp !-
!:			pla						// Pull the return values put in by the jsr in order to keep the stack from filling up
			pla	
			jmp Main				// Return to the Monitor and dont execute other commands in the string		
Move:		
			ldy #$00
			sty GTmp3
			sty GTmp4
			sty LISTEnd
			sty LISTEnd_H
			ldy Parse
			iny
!:			lda Buffer,y			// Load A with the first value in the input buffer
			iny						// Increase the index
			cpy #$0D
			beq MoErr
			cmp #'-'				// Compare it with the option signifier ("-")
			bne !-					// Loop back until we have found any options				
					
M1:			lda Buffer,y
			iny
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq M2					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			sty Parse
			
			txa				
			ldx #$04
!:			asl LISTEnd	
			rol LISTEnd_H	
			dex	
			bne !-	
			ora LISTEnd	
			sta LISTEnd			
			ldy Parse			
			jmp M1	
			
M2:			dey
			lda Buffer,y
			cmp #':'
			bne MoErr
			iny
			
M3:			lda Buffer,y
			iny
			ldx #$FF
!:			inx						// Increase index for the command finder loop
			cpx #$10				// Has the loop already compared the input to all of the avalible digits?
			beq M4					// If so, then the hex input is over
			cmp	HEX,x				// Compare it to the avalible commands
			bne !-
			sty Parse
			
			txa				
			ldx #$04
!:			asl GTmp3	
			rol GTmp4	
			dex	
			bne !-	
			ora GTmp3	
			sta GTmp3			
			ldy Parse			
			jmp M3	
			
M4:			ldy #$00			
M5:			lda (LISTEnd),y
			sta (WORDInput),y
			
			lda LISTEnd
			cmp GTmp3
			bne !+
			lda LISTEnd_H
			cmp GTmp4
			bne !+
			rts
									
!:			lda LISTEnd				// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda LISTEnd_H		
			adc #$01		
			sta LISTEnd_H		
!:			clc
			lda LISTEnd
			adc #$01
			sta LISTEnd
			lda WORDInput			// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda WORDInput_H		
			adc #$01		
			sta WORDInput_H		
!:			clc
			lda WORDInput
			adc #$01
			sta WORDInput			
			jmp M5
			
EERR:			
			jsr CReturn				// If @ isn't the first command issued, then exit routine W/ error
			ldx #$00
!:			lda Er0,x
			cmp #$00
			beq !+			
			jsr Write
			inx
			jmp !-
!:			pla						// Pull the return values put in by the jsr in order to keep the stack from filling up
			pla	
			jmp Main				// Return to the Monitor and dont execute other commands in the string
IAddr:								// Increase the address pointer routine							
			lda WORDInput			// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda WORDInput_H		
			adc #$01		
			sta WORDInput_H		
!:			clc
			lda WORDInput
			adc #$01
			sta WORDInput
			rts						// Return to code			
DAddr:								// Decrease the address pointer routine					
			lda WORDInput			// Load A with Addrptr		
			cmp #$00				// See if Decreasing it will cause an underflow
			bne !+					// If it won't, then decrease the low byte and continue
			sec						// If it will, then decrease the high byte and the low byte causing the low byte to underflow as #$FF, thus decreasing the memory page			
			lda WORDInput_H		
			sbc #$01		
			sta WORDInput_H		
!:			sec
			lda WORDInput
			sbc #$01
			sta WORDInput
			rts						
													
Version:			
			jsr CReturn			
			jmp MonitorBoot				
						
//---------------Lookup Tables---------------

Er0:
			.text " ?FORMAT ERROR"	// Error report string
			.byte $00				// Terminator byte
HEX:     
			.text "0123456789ABCDEF"// Hex -> ASCII lookup string
CMD:       
			.byte $0D               // Enter (CR)                       		| [HHHH]		 					- Hex dump address 
            .byte $2E               // .										| [HHHH][.HHHH] 					- Hex dump address range
            .byte $3A               // :										| [HHHH][:DD] 		 				- Poke data
            .byte $47               // g - Go									| [HHHH][G] 		 				- Execute code (jmp to address)
            .byte $56               // v - Version								| [V] 		 						- Print version string
            .byte $4D				// m - Move block							| [HHHH][M][-XXXX:YYYY]				- Move block XXXX through YYYY to memory starting at HHHH 
            .byte $57				// w - Fill block							| [HH][M][-XXXX:YYYY]				- Fill block XXXX through YYYY with byte HH
JCMD:      																									
			.word View-1			// Enter (CR)
            .word Range-1			// .
            .word Deposit-1			// :
            .word Goto-1			// G
            .word Version-1			// V
            .word Move-1			// M
            .word Fill-1			// W
Porttxt:        
			.text MONText
            .byte $00				// Terminator byte
            
