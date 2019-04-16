
; minimal monitor for EhBASIC and 6502 simulator V1.05

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

	.feature labels_without_colons
	.include "basic.asm"

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

IO_AREA = $8800
ACIAdata	= IO_AREA		; simulated ACIA r/w port
ACIAstatus  = IO_AREA+1
ACIAcommand = IO_AREA+2
ACIAcontrol = IO_AREA+3

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

.segment "MONITOR"
	;.org	$FF00			; pretend this is in a 1/8K ROM

; reset vector points here
BOOT
RES_vec
	CLD				; clear decimal mode
	LDX	#$FF			; empty stack
	TXS				; set the stack

; set up vectors and interrupt code, copy them to page 2

	LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp
	LDA	LAB_vec-1,Y		; get byte from interrupt code
	STA	VEC_IN-1,Y		; save to RAM
	DEY				; decrement index/count
	BNE	LAB_stlp		; loop if more to do

; now do the signon message, Y = $00 here
	JSR $C018
LAB_signon
	LDA	LAB_mess,Y		; get byte from sign on message
	BEQ	LAB_nokey		; exit loop if done

	JSR	V_OUTP		; output character
	INY				; increment index
	BNE	LAB_signon		; loop, branch always

LAB_nokey
	JSR	V_INPT		; call scan input device
	BCC	LAB_nokey		; loop if no key

	AND	#$DF			; mask xx0x xxxx, ensure upper case
	CMP	#'W'			; compare with [W]arm start
	BEQ	LAB_dowarm		; branch if [W]arm start

	CMP	#'C'			; compare with [C]old start
	BNE	LAB_nokey		; loop if not [C]old start

	JMP	LAB_COLD		; do EhBASIC cold start

LAB_dowarm
	JMP	LAB_WARM		; do EhBASIC warm start

; byte out to ACIA
ACIAout
;	PHA
;A0
;	LDA $8801
;	AND #$10
;	BEQ A0
;	PLA
;	STA $8800
;	RTS


	CMP #$0A
	BEQ A2
	CMP #$0D
	BEQ A1
	JMP $C009
A1  
	JMP $C01E	
A2
	RTS

;
; byte in from ACIA. This subroutine will also force
; all lowercase letters to be uppercase.
;
ACIAin
	;LDA $8801
	;AND #$08
	;BEQ LAB_nobyw
	;LDA $8800
	LDA #$90
	JSR $C02D
	JSR $C021

	CMP #$03
	BNE A4
	JMP $C000
A4	
	CMP #$FF
	BEQ LAB_nobyw

	CMP	#'a'			; Is it < 'a'?
	BCC	@done			; Yes, we're done
	CMP	#'{'			; Is it >= '{'?
	BCS	@done			; Yes, we're done
	AND	#$5f			; Otherwise, mask to uppercase
@done
	SEC				; Flag byte received
	RTS

LAB_nobyw
	CLC				; flag no byte received
no_load				; empty load vector for EhBASIC
no_save				; empty save vector for EhBASIC
	RTS

; vector tables

LAB_vec
	.word	ACIAin		; byte in from simulated ACIA
	.word	ACIAout		; byte out to simulated ACIA
	.word	no_load		; null load vector for EhBASIC
	.word	no_save		; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	RTI

; EhBASIC NMI support

NMI_CODE
	RTI

END_CODE

; sign on string

LAB_mess
	.byte	"EhBASIC 2.2", $0D, $0A, "[C]old/[W]arm?", $00


; system vectors

.segment "VECTORS"
	;.org	$FFFA

	.word	NMI_vec		; NMI vector
	.word	RES_vec		; RESET vector
	.word	IRQ_vec		; IRQ vector

