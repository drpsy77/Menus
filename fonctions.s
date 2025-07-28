
;;; L adresse de chaque fonction est mise dans un tableau de pointeur en relation avec 
;;; M1, M2, ... on doit retrouver exactement la meme position pour chaque fonction dans Mx et dans Px
#define DISPLAY_ADRESS $BB80

P1
.byt <fNouveau      ,>fNouveau
.byt <fEnregistrer  ,>fEnregistrer
.byt <fCharger      ,>fCharger
.byt <fImprimer     ,>fImprimer
.byt <fQuitter      ,>fQuitter

P2
.byt <fSelEcr       ,>fSelEcr
.byt <fEcranMem     ,>fEcranMem
.byt <fMemEcran     ,>fMemEcran
.byt <fMarquer   ,>fMarquer
.byt <fCopier    ,>fCopier
.byt <fColler    ,>fColler

P3
.byt <fPaper    ,>fPaper
.byt <fPaperLine,>fPaperLine
.byt <fInk      ,>fInk
.byt <fInkLine  ,>fInkLine
.byt <fCls      ,>fCls
.byt <fFullScr  ,>fFullScr
.byt <fReset    ,>fReset
.byt <fHdReset  ,>fHdReset


P4
.byt <fUltrafast, >fUltrafast
.byt <fFast     , >fFast
.byt <fMedium   , >fMedium
.byt <fNormal   , >fNormal


;;; De la meme maniere qu on a fait un tableau des Mx, on fait un tableau des Px

PROCADDRLOW
.byt <P1, <P2, <P3, <P4
PROCADDRHIGH
.byt >P1, >P2, >P3, >P4


;;; On selectionne d abord le menu pour pointer sur le bon Px
;;; Puis l article de menu pour pointer sur la bonne ligne dans le Px
;;; Destination contiendra l adresse de la fonction a appeler.
;;; Pour ajouter des fonctions, il suffit de les definir avec une etiquette 
;;; et d ajouter ces etiquettes dans les tableaux ci dessus
fenter
.(
	ldx CURMENU
	lda PROCADDRLOW,x
	sta PROCPTR
	lda PROCADDRHIGH,x
	sta PROCPTR+1
	ldx CURMENUART
	dex
	txa
	asl
	clc
	adc PROCPTR
	sta PROCPTR
	lda #0
	adc PROCPTR+1
	sta PROCPTR+1
	ldy #0
	lda (PROCPTR),y
	sta destination+1
	iny
	lda (PROCPTR),y
	sta destination+2
destination
	jmp $0123
	
.)


fNouveau
.(
	rts
.)


fEnregistrer
.(
	rts
.)

fCharger
.(
	rts
.)

;;; Sauve l ecran  dans la memoire courante 
;;; appel a la fonction definie dans base.s
fEcranMem
.(
	jsr _gCloseMenu
	ldx #1
	lda _ScreenAdressLow,x
	sta CpSrc
	lda _ScreenAdressHigh,x
	sta CpSrc+1
	sec
	lda SwitchNum
	sbc #48
	tax
	lda SAVSCRADRLOW,x
	sta CpDest
	lda SAVSCRADRHIGH,x
	sta CpDest+1
	jsr copieBoucle
	jmp gfin
.)

fMemEcran
.(
	jsr _gCloseMenu
	ldx #1
	lda _ScreenAdressLow,x
	sta CpDest
	lda _ScreenAdressHigh,x
	sta CpDest+1
	sec
	lda SwitchNum
	sbc #48
	tax
	lda SAVSCRADRLOW,x
	sta CpSrc
	lda SAVSCRADRHIGH,x
	sta CpSrc+1
	jsr copieBoucle
	jmp gfin
.)

;;; switche a l ecran suivant
fSelEcr
.(
	lda SwitchNum
	cmp SwitchNum+2
	beq suite
	inc SwitchNum
	jmp fin
suite
	lda #48
	sta SwitchNum
fin
	jsr ghaut
	jsr gbas
	rts
.)


fImprimer
.(
	rts
.)

fQuitter
.(
	jmp gfin
.)

COPIERX
.dsb 1
COPIERY 
.dsb 1

flagMark
.byt 0

fMarquer
.(
	ldx $268
	lda _ScreenAdressLow,x
	clc
	adc $269
	sta COPIERDEB
	lda _ScreenAdressHigh,x
	adc #0
	sta COPIERDEB+1
	inc CURMENUART
	lda CURMENUART
	sta flagMark
	jmp gfin
.)


compteCopie
.dsb 2

fCopier
.(
	lda COPIERDEB+1
.(
	bne suite
	jmp fin
suite
.)
; calcul de l adresse du deuxième point
	ldx $268
	lda _ScreenAdressLow,x
	clc
	adc $269
	sta COPIERFIN
	lda _ScreenAdressHigh,x
	adc #0
	sta COPIERFIN+1
; fermeture du menu 
	jsr _gCloseMenu

; on regarde si le marqueur et la position courante sont dans l ordre
	sec
	lda COPIERFIN+1
	sbc COPIERDEB+1
	bpl suite        ; si positif ou nul: on garde. 
	lda COPIERFIN+1  ; sinon on echange- octet de poids fort
	pha
	lda COPIERDEB+1
	sta COPIERFIN+1
	pla
	sta COPIERDEB+1
	lda COPIERFIN  ; poids faible
	pha
	lda COPIERDEB
	sta COPIERFIN
	pla
	sta COPIERDEB
suite
	sec
	lda COPIERFIN
	sbc COPIERDEB
	sta comptCopie
	lda COPIERFIN+1
	sbc COPIERDEB+1
	bne fin ; le tampon de copie ne fait que 256 octets on sort si ca depasse
	lda COPIERDEB
	sta TMPPTR
	lda COPIERDEB+1
	sta TMPPTR+1
	ldy comptCopie
boucle
	lda (TMPPTR),y
	sta TAMPCOPIER,y
	dey
	bne boucle
	lda (TMPPTR),y
	sta TAMPCOPIER,y
fin
	inc CURMENUART
	lda CURMENUART
	sta flagMark
	jmp gfin
.)

fColler
.(
; calcul de l adresse du point de collage
	ldx $268
	lda _ScreenAdressLow,x
	clc
	adc $269
	sta TMPPTR
	lda _ScreenAdressHigh,x
	adc #0
	sta TMPPTR+1
; fermeture du menu 
	jsr _gCloseMenu

	ldy comptCopie
boucle
	lda TAMPCOPIER,y
	sta (TMPPTR),y
	dey
	bne boucle
	lda TAMPCOPIER,y
	sta (TMPPTR),y
fin
	lda CURMENUART
	sta flagMark
	jmp gfin
.)


fPaper
.(
	lda #0
	sta $02e2
	inc $26b
	lda #7
	and $26b
	sta $02e1
	adc #16
	sta $26b
	jsr $f204
	rts
.)

fPaperLine
	lda CURMENUART
	sta flagMark
	jsr _gCloseMenu
	ldx $268
	lda _ScreenAdressLow,x
	sta TMPPTR
	lda _ScreenAdressHigh,x
	sta TMPPTR+1
	ldy #0
	clc
	lda (TMPPTR),y
	adc #1
	and #23
fPaperInkLine
	sta (TMPPTR),y
	dec flagMark
.(
boucle
	jsr gbas
	dec flagMark
	bne boucle
.)
	jmp gbas


fInk
.(
	lda #0
	sta $02e2
	inc $26c
	lda #7
	and $26c
	sta $02e1
	sta $26c
	jsr $f210
	rts
.)

fInkLine
	lda CURMENUART
	sta flagMark
	jsr _gCloseMenu
	ldx $268
	lda _ScreenAdressLow,x
	sta TMPPTR
	lda _ScreenAdressHigh,x
	sta TMPPTR+1
	ldy #1
	clc
	lda (TMPPTR),y
	adc #1
	and #7
	jmp fPaperInkLine


fCls
.(
	jsr _gCloseMenu
	jmp $ccce
.)

;;; Exploiter toutes les colonnes - ne fonctionne pas
fFullScr
.(
	sec
	lda #2
	sbc $253
	sta $253
	jmp gfin
.)

fExplode
.(
	jmp $FACB
.)


fHdReset
.(
	jmp ($fffc)
.)

fReset
.(
	lda #0
	sta FLAGFIN
	sta CURMENU
	sta CURMENUART
	jmp $247
.)

fUltrafast
	lda #7
	ldx #1
	jmp fRepetition

fFast  
	lda #14
	ldx #2
	jmp fRepetition
	
fMedium
	lda #21
	ldx #3
	jmp fRepetition

fNormal
	lda #32
	ldx #4
fRepetition
	sta $24E
	stx $24F
	jmp gfin