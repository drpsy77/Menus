
;;; L adresse de chaque fonction est mise dans un tableau de pointeur en relation avec 
;;; M1, M2, ... on doit retrouver exactement la meme position pour chaque fonction dans Mx et dans Px
P1
.byt <fNouveau      ,>fNouveau
.byt <fOuvrir       ,>fOuvrir
.byt <fFermer       ,>fFermer
.byt <fEnregistrer  ,>fEnregistrer
.byt <fImprimer     ,>fImprimer
.byt <fQuitter      ,>fQuitter

P2
.byt <fAnnuler   ,>fAnnuler
.byt <fMarquer   ,>fMarquer
.byt <fCopier    ,>fCopier
.byt <fColler    ,>fColler
.byt <fSupprimer ,>fSupprimer

P3
.byt <fPaper    ,>fPaper
.byt <fInk      ,>fInk
.byt <fCls      ,>fCls
.byt <fNew      ,>fNew
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
fOuvrir
.(
	rts
.)
fFermer
.(
	rts
.)
fEnregistrer
.(
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


fAnnuler
.(
	rts
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

fSelectionner
.(
	rts
.)

compteCopie
.dsb 2

fCopier
.(
	lda COPIERDEB
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
	bne fin ; le tampon de copie ne fait que 256 octets
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

fSupprimer
.(
	rts
.)

;;; ne fonctionne pas. Si queqlu un a une idee

fPaper
.(
	jsr _get
	txa
	sec
	sbc #48
	sta $02e1
	jsr $e204
	rts
.)

fInk
.(
	rts
.)

fCls
.(
	jsr _gCloseMenu
	jmp $ccce
.)

;;; ne fonctionne pas
fNew
.(
	jsr _gCloseMenu
;	jsr $c6ee
	rts
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

fTime
.(
	rts
.)

fClock
.(
	rts
.)

fUltrafast
	lda #7
	sta $24E
	lda #1
	sta $24F
	jmp gfin

fFast  
	lda #14
	sta $24E
	lda #2
	sta $24F
	jmp gfin
	
fMedium
	lda #21
	sta $24E
	lda #3
	sta $24F
	jmp gfin

fNormal
	lda #32
	sta $24E
	lda #4
	sta $24F
	jmp gfin