
;;; MENUS DEROULANTS POUR ORIC ATMOS
;;; Lang: pure ASS
;;; ROM ATMOS V1.1 
;;; Author: DRPSY aka Pierre Garnier


;;; On peut changer les preferences de couleur
;;; Les menus deroules seront en inverse video pour ressortir quelle que soit la couleur PAPER
;;; La colonne INK est ecrasee a l affichage du premier menu

#define DISPLAY_ADRESS $BB80

#define MENUCOLORBG 16
#define MENUCOLORFG 3
#define ARTMENUCOLORFG 4
#define MENUHILITE 6
#define BLANK 7

;;;--------------------------
	.zero

	*= $00

;;; Pointeurs pour adressage indirect

CURMENUPTR	.dsb 2
TAMPPTR		.dsb 2
SCPTR		.dsb 2
PROCPTR		.dsb 2
TMPPTR		.dsb 2

tmpzz		.dsb 2

;;; STOP : 12 octets dispo en début de page 0


	.text
;;;--------------------------------
;;; PROCEDURE D INITIALISATION
;;; On initie le detournement de la lecture clavier 
;;; et on relance le BASIC avec affichage du message d accueil
;;; la memoire disponible est mise a jour car on a prealablement fait un HIMEM

debutProg
.(
;; REDIRECTION DU TRAITEMENT DES ENTREES CLAVIER
	lda $23C
	cmp #<gGestFunc
	beq suite
	sta gFinAdr+1
	lda $23D
	sta gFinAdr+2
	lda #<gGestFunc
	sta $23C
	lda #>gGestFunc
	sta $23D
;; HIMEM
	ldy #$90
	lda #$00
	jsr $ebd8
;; affichage du menu
	jsr affMenuBar
;; BASIC
	jmp $eccc
suite
	rts
.)

;;;----------------------------------
;;;  VARIABLES

;;; Tampon pour sauvegarder la partie de l ecran qui sera recouverte par le menu deroulant

TAMPON
.dsb 100

;;; pointeur vers la zone Tampon
;;; pas utile dans cette version mais cela permettrait de gerer une pile de tampons dans la meme zone
TAMPADDR
.byt <TAMPON
.byt >TAMPON

;;; Tampon pour le COPIER/COLLER et les pointeurs DEB et FIN de selection (adresses de l ecran)
;;; comptCopie est le nombre de caractères à recopier qui rend inutile COPIERFIN une fois qu il est calcule.
;;; un pointeur en page 0 est aussi utilise pour l adressage indirect
TAMPCOPIER
.dsb 250
COPIERDEB
.byt 0,0
COPIERFIN
.byt 0,0 
comptCopie
.byt 0

;;; code extrait de la ROM EB78. On boucle tant qu un caractere n est pas tape

_get
	lda $2df
	bpl _get
	and #$7f
	ldx #00
	stx $2df
	tax
	lda #0
	rts

;;; indicateur pour dire que le MENU est actif ou pas. Permet de sortir de la fonction principale
FLAGFIN
.dsb 1

;;; Liste des coordonnees X des titres de menu.
;;; Si on change le nombre de menus, il faut ajouter ou retirer un octet. 
;;; Elles sonc calculees dans le code.
;;; Le premier designe la position a partir de laquelle on affiche le premier menu.
COORDX
.byt 1, 0, 0, 0, 0

;;; Chaque Menu est designe par une etiquette M1, M2, ...
;;; Ensuite:
;;;  Octet 1 : nombre d articles de menu hors titre
;;;  Octer 2 : largeur du menu = largeur de la chaine la plus large + 2
;;;  Liste des chaines de caracteres a afficher, terminees par 0 (comme en C)
;;;  Piste d optimisation: faire comme le BASIC. ajouter 128 au dernier caractere. 
M1
.byt 6,12
.asc "Fichier",0
.asc "Nouveau",0
.asc "Ouvrir",0
.asc "Fermer",0
.asc "Enregistrer",0
.asc "Imprimer",0
.asc "Quitter",0

M2
.byt 5,10
.asc "Edition",0
.asc "Annuler",0
.asc "Marquer",0
.asc "Copier",0
.asc "Coller",0
.asc "Supprimer",0

M3
.byt 6,9
.asc "Commandes",0
.asc "Paper",0
.asc "Ink",0
.asc "Cls",0
.asc "New",0
.asc "Reset",0
.asc "Hd Reset",0

M4
.byt 4,10
.asc "Touches",0
.asc "UltraFast",0
.asc "Fast",0
.asc "Medium",0
.asc "Normal",0

;;; Les etiquettes sont mises dans un tableau de pointeurs 
;;; qui permettra facilement de switcher d un menu a l autre

MENUS
.byt 4
MENUADDRLOW
.byt <M1, <M2, <M3, <M4
MENUADDRHIGH
.byt >M1, >M2, >M3, >M4

;;; MENU selectionne. Cette valeur est conservee lorsqu on quitte et qu on revient
CURMENU
.byt 0

;;; ARTICLE DE MENU. Cette valeur n est pas conservee car en sortant, on ferme les menus
CURMENUART
.byt 0

;;;---------------------------------
;;; CODE


;;; Programme PRINCIPAL
;;; On initie l affichage du menu a chaque fois, car on ne sait pas si la barre de statut 
;;; n a pas ete mise a jour par ailleurs (CLOAD par exemple)
;;;
;;; flagMark contient l article de menu suivant pour la gestion du copier coller
principal
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
	stx CURMENUART
	ldy #(128+7-MENUHILITE)
	jsr majMenuItem
	lda #0
	sta flagMark
suite
	lda #$FF
	sta FLAGFIN
.)
boucle
	lda FLAGFIN
	beq sortboucle
	jsr inKeys
	jmp boucle
sortboucle
	jmp showCursor
.)

;;; on inhibe le curseur et on change la repetition des touches
;;; peut être ajuste

hideCursor
.(
	lda #10
	sta $26A
	rts
.)

showCursor
.(
	lda #3
	sta $26A
w	rts
.)

;;; Affichage de la barre de menu dans la ligne  de statut 0
;;; alternative non exploree: changer le nombre de lignes scrollables et se mettre au dessus ou en dessous
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


;;; Test des touches. les noms des etiquettes de fonction sont parlantes
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
_escape
	jmp gfin
suite
.)
	cpx #13
.(
	bne suite 
	jmp genter
suite
.)
	rts

tmpDroiteGauche
.dsb 1
ggauche
	lda CURMENU
.(
	bne suite
	rts
suite
.)
	sec
	sbc #1
	sta tmpDroiteGauche
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
	sta tmpDroiteGauche

ggauchedroite

	jsr _gCloseMenu
	lda tmpDroiteGauche
	sta CURMENU
	jmp affMajMenu

;;; ghaut permet de fermer le menu. on appelle ghaut avant de quitter le menu
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

;;; gbas permet de derouler le menu

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

genter
.(
	lda CURMENUART
	bne suite
	jmp gbas
suite
	jmp fenter
	

.)

;;; Pour sortir, on met a 0 le FLAGFIN et on enroule le menu
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

;;; On utilise la vectorisation de la saisie clavier qui permet un saut vers notre routine
;;; au sein de la saisie clavier de l interpréteur
;;; Concretement, on interromp l interpreteur en plein travail de capture des saisies clavier
;;; et on lui rend la main exactement la ou il est reste
;;; mais on ne se substitue pas a lui
;;; donc au retour, le buffer du BASIC sera identique
;;; AMELIORATION A ENVISAGER: permettre le COLLER dans le BUFFER BASIC pour ne pas avoir a faire de CTRL-A
;;; ici, on teste les touches de fonction : $209
;;; on pourrait faire d autres choses comme des raccourcis clavier directs
;;; REFERENCE: CEO MAG 348 - la touche FUNC par Andre
;;; pas certain que la sauvegarde des registres et de la pile soient utiles mais j ai eu plein de pb 
;;; avec la pile, et je ne sais pas ce dont le BASIC a reellement besoin alors...

gGestFunc
	php
	pha
	lda FLAGFIN
	bne gGestFuncfin
	lda $209
	cmp #$A5
.(
	beq suite1
	cmp #$A6
	beq suite1
	jmp gGestFuncfin
suite1
	txa
	pha
	tya
	pha
	jsr  principal
	pla
	tay
	pla
	tax
.)
gGestFuncfin
	pla
	plp
gFinAdr
	jmp $0123

;;; Mise a jour du menu active
;;; consiste a mettre a jour la couleur d HILITE 

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
	rts
.)

;;;Calcul de la fenêtre d affichage du menu: Position WPOSX, WPOSY et dimensions WLENX, WLENY
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

;;; Sauvegarde de la partie d ecran qui sera ecrasee par la fenetre dans TAMPON
;;; Affichage du menu deroule
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
	stx tmpzz
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
	ldx tmpzz
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

;;; Quand on enroule le menu, on remet a l ecran la zone prealablement sauvegardee

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


;;; en y, la couleur d hilite 
sumtmp
.dsb 2

;;; Mise a jour de la couleur d hilite de l article de menu selectionne
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