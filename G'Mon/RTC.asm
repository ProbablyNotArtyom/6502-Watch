//- - - - - - - - - - RTC - - - - - - - - - -

RTCWrite:
			ldy #$8 
RTCWrite1:	lsr 
			pha
      		bcc RTCWrite2
      		lda PORTA
      		ora #RTC_IO_B
      		sta PORTA
      		jmp RTCWrite3
RTCWrite2:  lda PORTA
      		and #255-RTC_IO_B
      		sta PORTA
RTCWrite3:  lda PORTB
      		ora #RTC_SC_B
      		sta PORTB
      		dey   
      		beq RTCWrite4      
      		lda PORTB
      		and #255-RTC_SC_B
      		sta PORTB
      		pla 
      		jmp RTCWrite1
RTCWrite4:	pla
      		lda DDRA      
      		and #255-RTC_IO_B
      		sta DDRA
      		lda PORTA      
      		and #255-RTC_IO_B
      		sta PORTA
      		lda PORTB      
      		and #255-RTC_SC_B
      		sta PORTB
      		rts
									
WrCmd:
			pha            			// save data
			lda PORTA
			ora #RTC_CE_B
			sta PORTA      			// set CE to 1
			txa          			// move cmd to A
			jsr RTCWrite         		// write cmd to RTC
			lda DDRA
			ora #RTC_IO_B
			sta DDRA     			// set IO pin to output
			pla         			// restore data byte   
			jsr RTCWrite         		// write data to RTC
			lda PORTA
			and #255-RTC_CE_B
			sta PORTA      			// set CE = 0
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			rts

RTCCmd:
			pha            			// save command
			lda PORTA
			ora #RTC_CE_B
			sta PORTA      			// set CE to 1
			pla          			// restore command
			jsr RTCWrite
			jsr RTCRead
			pha          			// save data
			lda PORTA
			and #255-RTC_CE_B
			sta PORTA      			// set CE = 0
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			pla            			// restore data
			rts

//-----------------------------------------------
// read in a byte from the RTC to A
//-----------------------------------------------

RTCRead:
			ldx #$00         		// data byte
			ldy #8
RTCRead1:	lda PORTA      			// read IO
			and #RTC_IO_B      		// mask IO bit
			clc          			// Clear carry.
			beq RTCRead2
			sec          			// Set Carry Flag
RTCRead2:	txa          			// get data
			ror          			// Rotate data into bit.
			tax          			// save data
			lda PORTB
			ora #RTC_SC_B
			sta PORTB      			// set sc to 1
			nop
			nop
			lda PORTB
			and #255-RTC_SC_B
			sta PORTB      			// set sc to 0
			dey            			// 8 bits
			bne RTCRead1
			txa            			// put data in A
			rts

RTCReadcal:      
			lda PORTA
			ora #RTC_CE_B
			sta PORTA      			// set CE to 1
			lda #$BF         		// burts mode read calendar
			jsr RTCWrite
			jsr RTCRead
			sta RTCSec         		// sec
			jsr RTCRead
			sta RTCMin         		// min
			jsr RTCRead
			sta RTCHr        		// hr
			jsr RTCRead
			sta RTCDay        		// day
			jsr RTCRead
			sta RTCMon         		// month
			jsr RTCRead
			sta RTCDow         		// dow
			jsr RTCRead
			sta RTCYr         		// yr
			jsr RTCRead
			sta RTCWpr         		// WP
			lda PORTA
			and #255-RTC_CE_B
			sta PORTA      			// set CE = 0
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			rts

RTCWritecal:      
			ldx #$8E         		// write WP byte
			lda #$00         		// turn WP off
			jsr WrCmd
			lda PORTA
			ora #RTC_CE_B
			sta PORTA      			// set CE to 1
			lda #$BE         		// burts mode write calendar
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCSec        		// secs
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCMin         		// mins
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCHr         		// hrs
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCDay         		// day
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCMon         		// month
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCDow         		// dow
			jsr RTCWrite
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCYr         		// yr
			jsr RTCWrite   
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			lda RTCWpr         		// write protect
			jsr RTCWrite
			lda PORTA
			and #255-RTC_CE_B
			sta PORTA      			// set CE = 0
			lda DDRA
			ora #RTC_IO_B
			sta DDRA      			// set IO to output
			rts

RTCInit:   
			lda DDRA
			ora #RTC_CE_B
			sta DDRA      			// set CE to output
			lda PORTA
			ora #RTC_CE_B
			sta PORTA      			// set CE = 1
			lda DDRB
			ora #RTC_SC_B
			sta DDRB      			// set SC to output
			lda PORTB
			and #255-RTC_SC_B
			sta PORTB      			// set CE = 0
			lda DDRA      
			ora #RTC_IO_B
			sta DDRA      			// set data to output
			lda PORTA      
			and #255-RTC_IO_B
			sta PORTA      			// set data to 0
			lda PORTA
			and #255-RTC_CE_B
			sta PORTA      			// set CE = 1
			ldx #$90         		// write charger control reg
			lda #$00         		// turn trickle charger off
			jsr WrCmd         		//
			ldx #$8E         		// write WP byte
			lda #$00         		// turn WP off
			jsr WrCmd
			lda #$81         		// read seconds
			jsr RTCCmd
			and #$7F         		// turn off clk halt bit
			ldx #$80         		// seconds
			jsr WrCmd         		// enable clock
			ldx #$8E         		// write WP byte
			lda #$80         		// turn WP off
			jsr WrCmd
			rts