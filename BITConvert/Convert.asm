			
			*=$8000			
							
		.var Count		= $00				
		.var Count_H	= $01			
		.var Output		= $02			
		.var Output_H	= $03			
		.var Outbuff	= $04			
		.var Out		= $05			
		.var Tmp		= $06		
		.var Column		= $07		
		.var Last		= $08		
		.var Last_H		= $09		
		.var Tmp2		= $0A	
		.var CRCNT		= $0B
		
		*=$8100
INIT:
		sei
		lda #<DATA
		sta Count
		lda #>DATA
		sta Count_H
		lda #$00
		sta Output
		sta Outbuff
		sta Out
		sta Tmp
		sta Tmp2
		sta CRCNT
		lda #$40
		sta Output_H
		
		ldx #$00
		ldy #$00
M0:		
		lda Count		
		sta Last		
		lda Count_H		
		sta Last_H		
Main:	
		ldy Tmp2
		lda (Count),y
		clc
		lsr
		ror Outbuff
		
		
		inc Tmp		
		lda Tmp
		cmp #$08
		beq M1
		
		ldx #$FF
!:		inx		
		jsr IAddr		
		cpx #83		
		bne !-		
		jmp Main		
		
M1:		
		ldy #$00
		sty Tmp
		lda Outbuff
		sta (Output),Y
		sty Outbuff
		jsr IAddrO		
		
		ldy Tmp2
		cpy #83
		beq !+
		
		lda Last
		sta Count
		lda Last_H
		sta Count_H
		
		iny
		sty Tmp2
		jmp Main
!:		
		inc CRCNT
		lda CRCNT
		cmp #$06
		bne !+
		jmp $FFCC
!:		ldy #$00
		sty Tmp2				
			
		ldx #$FF
!:		inx		
		jsr IAddr		
		cpx #83		
		bne !-	
		ldx #$00
			
		jmp M0	
				 		
				
		
		
		
IAddr:								// Increase the address pointer routine							
			lda Count				// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda Count_H		
			adc #$01		
			sta Count_H		
!:			clc
			lda Count
			adc #$01
			sta Count
			rts						// Return to code		
IAddrO:								// Increase the address pointer routine							
			lda Output				// Load A with Addrptr		
			cmp #$FF				// See if increasing it will cause an overflow
			bne !+					// If it won't, then increase the low byte and continue
			clc						// If it will, then increase the high byte and the low byte causing the low byte to overflow as #$00, thus increasing the memory page			
			lda Output_H		
			adc #$01		
			sta Output_H		
!:			clc
			lda Output
			adc #$01
			sta Output
			rts				
					
DATA:		
		.import binary "INPUT.bin"
		  	

			
