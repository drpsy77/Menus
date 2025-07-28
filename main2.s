
;;; ROM ATMOS V1.1 exigee

#define DISPLAY_ADRESS $BB80

#define MENUCOLORBG 16
#define MENUCOLORFG 3
#define ARTMENUCOLORFG 4
#define MENUHILITE 6
#define BLANK 7

;;;--------------------------
	.zero

	*= $00

CURMENUPTR	.dsb 2
TAMPPTR		.dsb 2
SCPTR		.dsb 2
PROCPTR		.dsb 2
TMPPTR		.dsb 2

;;; STOP : 12 octets dispo en début de page 0


;;;--------------------------------
;;  on met le bout de code de detournement du clavier
;;  dans la page 2 pour eviter tout plantage lié à un HIMEM
;;  ou autre. 23 octets dispo dans la ROM ATMOS a cet endroit
;;;---------------------------------

	.bss

	*= $221
verifDetourn
	lda $a7
	cmp #$90
.(
	bne suite
	jmp gGestFunc
suite
.)
	rts


	.text

_main
.(
	lda #$00
	ldy #$90
	jsr $ebd8 ;; HIMEM
	lda $23C
	cmp #<verifDetourn
	beq suite
	sta gGestFuncfin+2
	lda $23D
	sta gGestFuncfin+3
	lda #<verifDetourn
	sta $23C
	lda #>verifDetourn
	sta $23D
suite
	lda #$0
	sta FLAGFIN
	sta flagMark
	jmp main
.)

TAMPON
.dsb 100

TAMPCOPIER
.dsb 256
COPIERDEB
.byt 0,0
COPIERFIN
.byt 0,0 
comptCopie
.byt 0

grexit
	lda $2e0
grexit2
	tax
	lda #0
	rts 

_get
	jsr gGestFuncfin+1
	bpl _get
	jmp grexit2


FLAGFIN
.dsb 1

COORDX
.byt 1, 0, 0, 0, 0

M1
.byt 6,13
.asc "Fichier",0
.asc "Nouveau",0
.asc "Ouvrir",0
.asc "Fermer",0
.asc "Enregistrer",0
.asc "Imprimer",0
.asc "Quitter",0

M2
.byt 5,11
.asc "Edition",0
.asc "Annuler",0
.asc "Marquer",0
.asc "Copier",0
.asc "Coller",0
.asc "Supprimer",0

M3
.byt 5,9
.asc "Commandes",0
.asc "Paper",0
.asc "Ink",0
.asc "Cls",0
.asc "New",0
.asc "Explode",0

M4
.byt 4,10
.asc "Systeme",0
.asc "Hd Reset",0
.asc "Reset",0
.asc "Time",0
.asc "Clock",0


MENUS
.byt 4
MENUADDRLOW
.byt <M1, <M2, <M3, <M4
MENUADDRHIGH
.byt >M1, >M2, >M3, >M4


CURMENU
.byt 0

CURMENUART
.byt 0

TAMPADDR
.byt <TAMPON
.byt >TAMPON

main
.(
	jsr hideCursor
	jsr affMenuBar
	jsr affMajMenu
	lda flagMark
.(
	beq suite
	jsr calcPosMenu
	jsr sauveEcran
	ldx flagMark
	inx
	stx CURMENUART
	ldy #(128+7-MENUHILITE)
	jsr majMenuItem
suite
.)
boucle
	lda FLAGFIN
	beq sortboucle
	jsr inKeys
	jmp boucle
sortboucle
	jsr gSortie
	jsr showCursor
	rts
.)

hideCursor
.(
	lda #10
	sta $26A
	lda #4
	sta $24E
	lda #1
	sta $24F
	rts
.)

showCursor
.(
	lda #3
	sta $26A
	lda #32
	sta $24E
	lda #4
	sta $24F
	rts
.)


initRandom
.(
        lda $0276
        sta $FC
        sta $FE
        lda $0277
        sta $FB
        sta $FD
        lda #$80
        sta $FA
        rts
.)



affMenuBar
.(

	ldx #35
	lda #MENUCOLORBG
.(
loop
	sta DISPLAY_ADRESS,x
	dex
	bne loop
.)
	lda #MENUCOLORFG
	sta DISPLAY_ADRESS
	lda #BLANK
	sta DISPLAY_ADRESS+35
	lda #0
	sta _advp_attr
	ldx #0

boucle
;;;  On entre les paramètres de la fonction d affichage
;;;  La chaine de caracteres
	clc
	lda MENUADDRLOW,x
	adc #2
	sta _advp_s
	lda MENUADDRHIGH,x
	adc #0
	sta _advp_s+1
;;;  les coordonnées x et y
	lda #0
	sta _advp_y
	lda COORDX,x
	sta _advp_x
;;;  on affiche
	jsr _AdvancedPrint

;;; on récupère la longueur de la chaine et on additionne à la position 
;;; pour déduire la position suivante
	lda COORDX,x
	adc _advp_l
	adc #1
	inx
	sta COORDX,x
	cpx MENUS
	bne boucle
	rts
.)



inKeys
.(
	jsr _get
	cpx #11
	bne suite 
	jmp ghaut
suite
.)
	cpx #8
.(
	bne suite 
	jmp ggauche
suite
.)
	cpx #10
.(
	bne suite 
	jmp gbas
suite
.)
	cpx #9
.(
	bne suite 
	jmp gdroite
suite
.)
	cpx #27
.(
	bne suite 
	jmp gfin
suite
.)
	cpx #69
.(
	bne suite 
	jmp gtoggle
suite
.)
	cpx #13
.(
	bne suite 
	jmp genter
suite
.)
	rts


ggauche
	lda CURMENU
.(
	bne suite
	rts
suite
.)
	sec
	sbc #1
	pha
	jmp ggauchedroite

gdroite
	ldx CURMENU
	inx
	cpx MENUS
.(
	bne suite
	rts
suite
.)
	txa
	pha

ggauchedroite

	jsr _gCloseMenu
	pla
	sta CURMENU
	jsr affMajMenu
	
	rts

ghaut
	ldx CURMENUART
.(
	bne suite
	rts
suite
.)	
.(
	dex
	bne suite
	jsr calcPosMenu
	jsr restaureEcran
	lda #0
	sta CURMENUART
	rts
suite
.)
	ldy #(128+ARTMENUCOLORFG)
	jsr majMenuItem
	dec CURMENUART
	ldy #(128+7-MENUHILITE)
	jmp majMenuItem

gbas
	lda CURMENUART
.(
	bne suite
	jsr calcPosMenu
	jsr sauveEcran
	lda #$01
	sta CURMENUART
	ldy #(128+7-MENUHILITE)
	jmp majMenuItem
suite
.)
	cmp WLENY
.(
	bne suite
	rts
suite
.)
	ldy #(128+ARTMENUCOLORFG)
	jsr majMenuItem
	inc CURMENUART
	ldy #(128+7-MENUHILITE)
	jmp majMenuItem

gtoggle
	rts

genter
.(
	lda CURMENUART
	bne suite
	jmp gbas
suite
	jmp fenter
	

.)

gfin
	lda #0
	sta FLAGFIN
_gCloseMenu
	lda CURMENUART
.(
	beq suite
	lda #1
	sta CURMENUART
	jmp ghaut
suite
	rts
.)

;;; EN sortie du programme, on va :

gSortie
.(
	rts
.)

;;; On utilise la vectorisation de la saisie clavier qui permet un saut vers notre routine
;;; au sein de la saisie clavier de l interpréteur

gGestFunc
	pha
	lda $209
	cmp #$A5
.(
	beq suite1
	cmp #$A6
	bne gGestFuncfin
	lda #0
	sta $209
suite1
	txa
	pha
	tya
	pha
	php
	lda #$FF
	sta FLAGFIN
	jsr main
	plp
	pla
	tay
	pla
	tax
.)
gGestFuncfin
	pla
	jmp $0123


affMajMenu
.(

	ldx CURMENU
.(
	beq suite
	dex
	lda COORDX,x
	tax
	lda #MENUCOLORFG
	sta DISPLAY_ADRESS-1,x

	ldx CURMENU
suite
.)
	lda COORDX,x
	tax
	lda #MENUHILITE
	sta DISPLAY_ADRESS-1,x

	ldx CURMENU
	inx
	lda COORDX,x
	tax
	lda #MENUCOLORFG
	sta DISPLAY_ADRESS-1,x

	lda CURMENUART
	beq fend
	nop
fend	
	rts
.)


;Récupérer le nombre de lignes du menu dans y
;lire les lignes et connaître la longueur max des chaines de caractères des articles de menu

calcPosMenu
.(
	ldx CURMENU
	lda MENUADDRLOW, x
	sta CURMENUPTR
	lda MENUADDRHIGH, x
	sta CURMENUPTR+1
	
	lda COORDX,x
	sta WPOSX
	lda #1
	sta WPOSY
	
	ldy #0
	lda (CURMENUPTR),y
	sta WLENY
	iny
	lda (CURMENUPTR),y
	sta WLENX
	rts
.)

sauveEcran
.( 
;;; préparation de la zone tampon
	lda TAMPADDR
	sta TAMPPTR
	lda TAMPADDR+1
	sta TAMPPTR+1

;;; préparation de la zone écran
	ldx WPOSY
	lda _ScreenAdressLow,x
	clc
	adc WPOSX
	sta SCPTR
	lda _ScreenAdressHigh,x
	adc #0
	sta SCPTR+1

;;; préparation de la zone MENU
	clc
	ldx CURMENU
	lda MENUADDRLOW,x
	adc #2
;;; on saute le titre de menu
	sta CURMENUPTR
	sta _strptra
	lda MENUADDRHIGH,x
	adc #0
	sta CURMENUPTR+1
	sta _strptra+1
	jsr _strlen
	inx
	stx long_comp+1

	ldx WLENY
loopy

;;; on saute vers l article de menu suivant.  A contient la longueur retournée par strlen+1
	txa
	pha
	clc
	lda long_comp+1
	adc CURMENUPTR
	sta CURMENUPTR
	sta _strptra
	lda #0
	adc CURMENUPTR+1
	sta CURMENUPTR+1
	sta _strptra+1
	jsr _strlen
	inx
	stx long_comp+1
	
	ldy #0
	lda (SCPTR),y
	sta (TAMPPTR),y
	
	lda #(128+ARTMENUCOLORFG)
	sta (SCPTR),y
	clc
	inc SCPTR
.(
	bne suite6
	inc SCPTR+1
suite6
.)
	inc TAMPPTR
	pla
	tax
	ldy #0
loopx
	lda (SCPTR),y
	sta (TAMPPTR),y
long_comp
	cpy #$01
	bcs	suite
	lda (CURMENUPTR),y
	adc #128
	sta (SCPTR),y
	jmp suite2
suite
	lda #(128+32)
	sta (SCPTR),y
suite2
	iny
	cpy WLENX
	bne loopx
	clc
	lda TAMPPTR
	adc WLENX
	sta TAMPPTR ; pas besoin de faire l addition sur le poids fort car on est <256 et calé sur une page
	clc
	lda SCPTR
	adc #39
	sta SCPTR
	lda #0
	adc SCPTR+1
	sta SCPTR+1
	dex
	beq suite3
	jmp loopy
suite3
	rts
.)

restaureEcran
.(
	lda TAMPADDR
	sta TAMPPTR
	lda TAMPADDR+1
	sta TAMPPTR+1
	
	ldx WPOSY
	lda _ScreenAdressLow,x
	clc
	adc WPOSX
	sta SCPTR
	lda _ScreenAdressHigh,x
	adc #0
	sta SCPTR+1
	
	ldx WLENX
	inx
	stx compare+1
	ldx WLENY
loopy
	ldy #0
loopx
	lda (TAMPPTR),y
	sta (SCPTR),y
	iny
compare
	cpy #$01
	bne loopx
	clc
	lda TAMPPTR
	adc WLENX
	adc #$01
	sta TAMPPTR ; pas besoin de faire l addition sur le poids fort car on est <256 et calé sur une page
	clc
	lda SCPTR
	adc #40
	sta SCPTR
	lda #0
	adc SCPTR+1
	sta SCPTR+1
	dex
	beq suite3
	jmp loopy
suite3
	rts
.)


WPOSX
.dsb 1
WPOSY
.dsb 1
WLENX
.dsb 1
WLENY
.dsb 1

defWindow
.(
	lda #1
	sta CURMENUART
	jmp majMenuItem
.)


;;; longueur d une chaine. retour dans x

_strptra
.dsb 2

_strlen
.(
	lda _strptra
	sta loop+1
	lda _strptra+1
	sta loop+2
	ldx #0
	txa
loop
	cmp $0123,x
	beq suite
	inx
	jmp loop
suite
	rts
.)

plieMenu
.(
	
	rts
.)

;;; en y, la couleur d hilite 
sumtmp
.dsb 2

majMenuItem
.(

	ldx CURMENU
	lda COORDX,x
	sta sumtmp
	ldx CURMENUART
	lda _ScreenAdressLow,x
	clc
	adc sumtmp
	sta SCPTR
	lda _ScreenAdressHigh,x
	adc #0
	sta SCPTR+1
	tya
	ldy #0
	sta (SCPTR),y
	rts
.)