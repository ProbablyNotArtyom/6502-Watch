			sta GTmp5			// Save the input
			tya					// Push Y to the Stack
			pha			
			txa		
			pha			

			jsr SETCursor

			lda LCDY
			lsr
			lsr
			lsr
			pha
			tay					// Divide by 8
			
			lda PTblL,y			// Set up the screen vector	
			sta GTmp3		
			lda PTblH,y		
			sta GTmp4		
			iny	
			lda PTblL,y			// Set up the screen vector	
			sta GTmp9		
			lda PTblH,y		
			sta GTmpA	
								
			ldy LCDY					
			pla
			sta LCDY
			lda PTbl1,y					
			sta GTmp6			// Grab the number of ASLs needed to get the character to the input position					
			pha			
						
			lda GTmp5			// Restore the input								
			and #%00001111		// Get the decimal value						
			tay
			lda CTbl,y
			sta GTmp7			// Get the location of the graphics array
			lda #>Char
			sta GTmp8
			ldy #$00					
			sty GTmp5					
P1:			ldx #$00					
			stx GTmp2					

			ldy GTmp5			
			lda (GTmp7),y			// Write 6 consecutive bytes (1 5x8 character) from the address to the screen
			cmp #$00
			beq P2
!:			ldx GTmp6
			cpx #$00
			beq !+
			asl
			rol GTmp2
			dec GTmp6
			jmp !-

!:			jsr SETCursor_3b
			ldy LCDX
			ora (GTmp3),y			
			sta (GTmp3),y			
			jsr WriteBYTE		
			inc LCDY		
			jsr SETCursor_3b		// Set the cursor to the byte below the main one		
			lda GTmp2
			ora (GTmp9),y
			sta (GTmp9),y
			jsr WriteBYTE
			dec LCDY
			jsr SETCursor_3b
			inc GTmp5			
			inc LCDX			
			pla	
			pha
			sta GTmp6	
			jmp P1		
					