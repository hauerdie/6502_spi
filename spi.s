; Copyright (c) 2015, Dieter Hauer
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice, this
;    list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

					.setcpu		"6502"
		
					.export _spiRead
					.export _spiWrite
					.export _spiBegin
					.export _spiEnd
					.export _spiInit
		
					VIA1_BASE   = $8100
					PRA  = VIA1_BASE+1
					DDRA = VIA1_BASE+3
					
					MOSI = (1 << 2)
					MISO = (1 << 3)
					CLK  = (1 << 4)
					CS   = (1 << 5)
		
					.data
temp:				.byte 00	; used for shift in/out bits via carry, put into zeropage for minor speedup

					.code		

_spiInit:			pha
					lda #CLK
					eor #$FF
					and PRA
					ora #CS
					sta PRA
					lda DDRA
					ora #MOSI
					ora #CS
					ora #CLK
					sta DDRA
					pla
					rts


_spiEnd:			pha
					lda PRA
					ora #CS	
					sta PRA
					pla
					rts
	
	
_spiBegin: 			pha
					lda #CS
					eor #$FF
					and PRA
					sta PRA
					pla
					rts			

_spiRead:
					tya
					pha
					txa
					pha
					lda #$00
					sta temp
					lda #MOSI
					ora PRA
					sta PRA
					ldy #8
@loop:				lda #CLK
					ora PRA
					sta PRA
					ldx PRAs
					lda #CLK
					eor PRA
					sta PRA
					clc
					txa
					and #MISO
					beq @skip
					sec
@skip:				rol temp
					dey
					bne @loop
					pla
					tax
					pla
					tay
					lda temp
					rts


_spiWrite:			sta temp
					tya
					pha
					lda temp
					ldy #8
@loop:				lda #MOSI
					asl temp
					bcc @is_low
					ora PRA
					sta PRA
					jmp @is_high
@is_low:			lda	#MOSI
					eor #$FF
					and PRA
					sta PRA
@is_high:			lda #CLK
					ora PRA
					sta PRA
					lda #CLK
					eor PRA
					sta PRA
					dey
					bne @loop
					pla
					tay
					rts		

