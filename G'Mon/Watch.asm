Watch:
			lda #<Border
			sta GTmp3
			lda #>Border
			sta GTmp4
			jsr WriteBMP
			lda #$00
			sta TEST
			
			lda #29
			jsr SETCursor
			ldx #$00
!:			lda Scr00,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-
			
!:			lda #43
			jsr SETCursor
			ldx #$00
!:			lda Scr01,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-
			
!:			lda #57
			jsr SETCursor
			ldx #$00
!:			lda Scr02,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-

!:			lda #$00
			sta TEST
			lda #$28
			jsr SETCursor
			lda #'<'
			jsr Write		
W1:			
			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB			
			lda #$FF
			jsr Delay
			lda PORTB
			cmp lastkey
			beq W1
			sta lastkey
			
			ora #%11110001
			cmp #SW_UP
			bne !+
			
			lda TEST
			cmp #$00
			beq !+		
			dec TEST		
			ldx TEST
			inx
			lda CSXTbl,x
			jsr SETCursor
			lda #$20
			jsr Write
			dex
			lda CSXTbl,x
			jsr SETCursor
			lda #'<'
			jsr Write
			jmp W1	
			
!:			cmp #SW_DOWN
			bne !+
			
			lda TEST		
			cmp #$02		
			beq !+		
			inc TEST							
			ldx TEST
			dex
			lda CSXTbl,x
			jsr SETCursor
			lda #$20
			jsr Write
			inx
			lda CSXTbl,x
			jsr SETCursor
			lda #'<'
			jsr Write		
			jmp W1	
			
!:			cmp #SW_SELECT
			beq !+
			jmp W1
			
!:			ldx TEST
			lda PRTbl,x
			sta GTmp
			dec GTmp
			lda PRTbh,x
			pha
			lda GTmp
			pha
			lda #$FF
			jsr Delay
			lda #$41
			sta lastkey
			rts	

Setting:
			lda #<Border
			sta GTmp3
			lda #>Border
			sta GTmp4
			jsr WriteBMP
			lda #$00
			sta TEST
			
			lda #29
			jsr SETCursor
			ldx #$00
!:			lda Scr10,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-
			
!:			lda #43
			jsr SETCursor
			ldx #$00
!:			lda Scr11,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-
			
!:			lda #57
			jsr SETCursor
			ldx #$00
!:			lda Scr12,x
			inx
			cmp #$00
			beq !+
			jsr Write
			jmp !-

!:			lda #$03
			sta TEST
			lda #$28
			jsr SETCursor
			lda #'<'
			jsr Write				
W2:			
			lda #$FF
			sta DDRB
			sta PORTB
			lda #$00
			sta DDRB			
			lda #$FF
			jsr Delay
			lda PORTB
			cmp lastkey
			beq W2
			sta lastkey
			
			ora #%11110001
			cmp #SW_UP
			bne !+
			
			lda TEST
			cmp #$03
			beq !+		
			dec TEST		
			ldx TEST
			inx
			lda CSXTbl,x
			jsr SETCursor
			lda #$20
			jsr Write
			dex
			lda CSXTbl,x
			jsr SETCursor
			lda #'<'
			jsr Write
			jmp W2			
			
!:			cmp #SW_DOWN
			bne !+
			
			lda TEST		
			cmp #$05		
			beq !+		
			inc TEST							
			ldx TEST
			dex
			lda CSXTbl,x
			jsr SETCursor
			lda #$20
			jsr Write
			inx
			lda CSXTbl,x
			jsr SETCursor
			lda #'<'
			jsr Write		
			jmp W2	
			
!:			cmp #SW_SELECT
			bne W2
			
			ldx TEST
			lda PRTbl,x
			sta GTmp
			dec GTmp
			lda PRTbh,x
			pha
			lda GTmp
			pha
			lda #$FF
			jsr Delay
			lda #$41
			sta lastkey
			rts				

TS01:
			jmp*
							
//---------------Misc Lookups----------------				

CSXTbl:
			.byte $28, $36, $44, $28, $36, $44
			
PRTbl:		.byte <GMON, <BAS, <Setting, <$E825, <INIT, <Watch		
PRTbh:		.byte >GMON, >BAS, >Setting, >$E825, >INIT, >Watch		
PRTbX:		.byte %10011011, %10010010, %10010101, %10010011, %10010011, %10011001
PRTbY:		.byte %01000001, %01000010, %01000011, %01000001, %01000010, %01000011
			
Scr00:		.text "CLOCK"
			.byte $00
Scr01:		.text "BASIC"
			.byte $00
Scr02:		.text "SETTINGS"
			.byte $00
			
Scr10:		.text "SET TIME"
			.byte $00
Scr11:		.text "SET DATE"
			.byte $00
Scr12:		.text "RETURN"
			.byte $00
			