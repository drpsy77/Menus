
;
; This is a simple display module
; called by the C part of the program
;



;
; We define the adress of the TEXT screen.
;
#define DISPLAY_ADRESS $BB80


;
; We use a table of bytes to avoid the multiplication 
; by 40. We could have used a multiplication routine
; but introducing table accessing is not a bad thing.
; In order to speed up things, we precompute the real
; adress of each start of line. Each table takes only
; 28 bytes, even if it looks impressive at first glance.
;

; This table contains lower 8 bits of the adress

_ScreenAdressLow
	.byt <(DISPLAY_ADRESS+40*0)
	.byt <(DISPLAY_ADRESS+40*1)
	.byt <(DISPLAY_ADRESS+40*2)
	.byt <(DISPLAY_ADRESS+40*3)
	.byt <(DISPLAY_ADRESS+40*4)
	.byt <(DISPLAY_ADRESS+40*5)
	.byt <(DISPLAY_ADRESS+40*6)
	.byt <(DISPLAY_ADRESS+40*7)
	.byt <(DISPLAY_ADRESS+40*8)
	.byt <(DISPLAY_ADRESS+40*9)
	.byt <(DISPLAY_ADRESS+40*10)
	.byt <(DISPLAY_ADRESS+40*11)
	.byt <(DISPLAY_ADRESS+40*12)
	.byt <(DISPLAY_ADRESS+40*13)
	.byt <(DISPLAY_ADRESS+40*14)
	.byt <(DISPLAY_ADRESS+40*15)
	.byt <(DISPLAY_ADRESS+40*16)
	.byt <(DISPLAY_ADRESS+40*17)
	.byt <(DISPLAY_ADRESS+40*18)
	.byt <(DISPLAY_ADRESS+40*19)
	.byt <(DISPLAY_ADRESS+40*20)
	.byt <(DISPLAY_ADRESS+40*21)
	.byt <(DISPLAY_ADRESS+40*22)
	.byt <(DISPLAY_ADRESS+40*23)
	.byt <(DISPLAY_ADRESS+40*24)
	.byt <(DISPLAY_ADRESS+40*25)
	.byt <(DISPLAY_ADRESS+40*26)
	.byt <(DISPLAY_ADRESS+40*27)

; This table contains hight 8 bits of the adress
_ScreenAdressHigh
	.byt >(DISPLAY_ADRESS+40*0)
	.byt >(DISPLAY_ADRESS+40*1)
	.byt >(DISPLAY_ADRESS+40*2)
	.byt >(DISPLAY_ADRESS+40*3)
	.byt >(DISPLAY_ADRESS+40*4)
	.byt >(DISPLAY_ADRESS+40*5)
	.byt >(DISPLAY_ADRESS+40*6)
	.byt >(DISPLAY_ADRESS+40*7)
	.byt >(DISPLAY_ADRESS+40*8)
	.byt >(DISPLAY_ADRESS+40*9)
	.byt >(DISPLAY_ADRESS+40*10)
	.byt >(DISPLAY_ADRESS+40*11)
	.byt >(DISPLAY_ADRESS+40*12)
	.byt >(DISPLAY_ADRESS+40*13)
	.byt >(DISPLAY_ADRESS+40*14)
	.byt >(DISPLAY_ADRESS+40*15)
	.byt >(DISPLAY_ADRESS+40*16)
	.byt >(DISPLAY_ADRESS+40*17)
	.byt >(DISPLAY_ADRESS+40*18)
	.byt >(DISPLAY_ADRESS+40*19)
	.byt >(DISPLAY_ADRESS+40*20)
	.byt >(DISPLAY_ADRESS+40*21)
	.byt >(DISPLAY_ADRESS+40*22)
	.byt >(DISPLAY_ADRESS+40*23)
	.byt >(DISPLAY_ADRESS+40*24)
	.byt >(DISPLAY_ADRESS+40*25)
	.byt >(DISPLAY_ADRESS+40*26)
	.byt >(DISPLAY_ADRESS+40*27)



; positions x et y a entrer. s est l'adresse de la chaine qui doit se terminer par 0
; la longueur l de la chaine est retournée dans advp_l
; les registres sont rendus intacts à l appelant

_advp_x
.dsb 1
_advp_y
.dsb 1
_advp_s
.dsb 2
_advp_l
.dsb 1
_advp_attr
.dsb 1

_AdvancedPrint
.(
	pha
	txa
	pha
	; Initialise display adress
	; this uses self-modifying code
	; (the $0123 is replaced by display adress)
	
	; The idea is to get the Y position from the stack,
	; and use it as an index in the two adress tables.
	; We also need to add the value of the X position,
	; also taken from the stack to the resulting value.
	
	
	ldx _advp_y				; Access Y coordinate
	lda _ScreenAdressLow,x	; Get the LOW part of the screen adress
	clc						; Clear the carry (because we will do an addition after)
	adc _advp_x				; Add X coordinate
	sta write+1
	lda _ScreenAdressHigh,x	; Get the HIGH part of the screen adress
	adc #0					; Eventually add the carry to complete the 16 bits addition
	sta write+2				



	; Initialise message adress using the stack parameter
	; this uses self-modifying code
	; (the $0123 is replaced by message adress)
	lda _advp_s
	sta read+1
	lda _advp_s+1
	sta read+2


	; Start at the first character
	ldx #0
loop_char

	; Read the character, exit if it s a 0
read
	lda $0123,x
	beq end_loop_char
	adc _advp_attr
	; Write the character on screen
write
	sta $0123,x

	; Next character, and loop
	inx
	jmp loop_char  

	; Finished !
end_loop_char
	stx _advp_l
	pla
	tax
	pla
	rts
.)

