	*= $0801
	!addr keycode = $40
	!addr offset = $42
	!addr notelow = $44
	!addr notehigh = $46
	!addr octave = $48
	!addr counter = $4a
	!addr keypressed = $4c

	lda #48
	sta octave ;2*24 (12 note frequencies * 2 bytes(high/low))

	;lower keys note pointer offsets
	lda #00
	sta $0c ;z
	lda #02
	sta $0d ;s
	lda #04
	sta $17 ;x
	lda #06
	sta $12 ;d
	lda #08
	sta $14 ;c
	lda #10
	sta $1f ;v
	lda #12
	sta $1a ;g
	lda #14
	sta $1c ;b
	lda #16
	sta $1d ;h
	lda #18
	sta $27 ;n
	lda #20
	sta $22 ;j
	lda #22
	sta $24 ;m

	;upper keys note pointer offsets
	lda #24
	sta $3e ;q
	lda #26
	sta $3b ;2
	lda #28
	sta $09 ;w
	lda #30
	sta $08 ;3
	lda #32
	sta $0e ;e
	lda #34
	sta $11 ;r
	lda #36
	sta $10 ;5
	lda #38
	sta $16 ;t
	lda #40
	sta $13 ;6
	lda #42
	sta $19 ;y
	lda #44
	sta $18 ;7
	lda #46
	sta $1e ;u

	lda #$00
	sta $d020
	sta $d021

	lda #$35
	sta $01

	sei

	lda #$7f
	sta $dc0d
	sta $dd0d

	lda $dc0d
	lda $dd0d

	lda #$01
	sta $d01a

	lda #$1b
	sta $d011

	lda #$00
	sta $d012

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	cli

mainloop:
	jmp mainloop

irq:
	pha
	txa
	pha
	tya
	pha

	asl $d019

	jsr cynth

	pla
	tay
	pla
	tax
	pla

	rti

cynth:
	lda #$37
	sta $01

	jsr $ff9f

	lda #$35
	sta $01

	lda $cb
	sta keycode

	cmp #$2b
	beq octaveup

	cmp #$2c
	beq octavedown

	cmp #$40
	bne keydown
	beq keyup
	
	rts

keyup:
	lda #$00
	sta keypressed
	sta counter
	
	lda #16
	sta $d404

	rts

keydown:
	lda #$01
	sta keypressed
	
	jsr getnote
	jsr playnote
	jsr updateui

	inc counter

	rts

octaveup:
	lda octave
	adc #24
	sta octave

	rts

octavedown:
	lda octave
	sbc #24
	sta octave
	
	rts

getnote:
	ldy #$00
	lda (keycode), y
	sta offset
	adc octave
	tax

	lda frequencies,x
	sta notelow

	lda frequencies+1,x
	sta notehigh

	rts

playnote:
	lda #$0f
	sta $d418 ;volume

	lda #17
	sta $d404 ;control register voice 1

	lda #$00
	sta $d405 ;attack/decay

	lda #250
	sta $d406 ;sustain/release

	lda notelow
	sta $d400 ;voice 1 frequency low

	lda notehigh
	sta $d401 ;voice 1 frequency high

	rts

updateui:
	lda keycode
	sta $d020
	
	lda #$00
	sta $d021

	rts

	*= $1000
frequencies:
	!word $022d ;c-1
	!word $024e ;c#1
	!word $0271 ;d-1
	!word $0296 ;d#1
	!word $02be ;e-1
	!word $02e7 ;f-1
	!word $0314 ;f#1
	!word $0342 ;g-1
	!word $0374 ;g#1
	!word $03a9 ;a-1
	!word $03e0 ;a#1
	!word $041b ;b-1

	!word $045a ;c-2
	!word $049c ;c#2
	!word $04e2 ;d-2
	!word $052c ;d#2
	!word $057b ;e-2
	!word $05cf ;f-2
	!word $0627 ;f#2
	!word $0685 ;g-2
	!word $06e8 ;g#2
	!word $0751 ;a-2
	!word $07c1 ;a#2
	!word $0837 ;b-2

	!word $08b4 ;c-3
	!word $0938 ;c#3
	!word $09c4 ;d-3
	!word $0a59 ;d#3
	!word $0af7 ;e-3
	!word $0b9d ;f-3
	!word $0c4e ;f#3
	!word $0d0a ;g-3
	!word $0dd0 ;g#3
	!word $0ea2 ;a-3
	!word $0f81 ;a#3
	!word $106d ;b-3

	!word $1167 ;c-4
	!word $1270 ;c#4
	!word $1389 ;d-4
	!word $14b2 ;d#4
	!word $15ed ;e-4
	!word $173b ;f-4
	!word $189c ;f#4
	!word $1a13 ;g-4
	!word $1ba0 ;g#4
	!word $1d44 ;a-4
	!word $1f02 ;a#4
	!word $20da ;b-4

	!word $22ce ;c-5
	!word $24e0 ;c#5
	!word $2711 ;d-5
	!word $2964 ;d#5
	!word $2bda ;e-5
	!word $2e76 ;f-5
	!word $3139 ;f#5
	!word $3426 ;g-5
	!word $3740 ;g#5
	!word $3a89 ;a-5
	!word $3e04 ;a#5
	!word $41b4 ;b-5

	!word $459c ;c-6
	!word $49c0 ;c#6
	!word $4e23 ;d-6
	!word $52c8 ;d#6

keys:
	!scr "c-"
	!scr "c#"
	!scr "d-"
	!scr "d#"
	!scr "e-"
	!scr "f-"
	!scr "f#"
	!scr "g-"
	!scr "g#"
	!scr "a-"
	!scr "a#"
	!scr "b-"
	
	*= $0400
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "                                        "
	!scr "cutoff:00 resonance:00 filter:00        "
	!scr "attack:00 decay:00 sustain:00 release:00"
	!scr "waveform:pulse lp:00 bp:00 hp:00        "
	!scr "key:000 octave:0 frequency:0000 vol:16  "
