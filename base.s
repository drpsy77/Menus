
;;; On definit une zone de sauvegarde des ecrans texte dans la memoire non occupee en mode Texte par la haute resolution
;;; Soit 6 ecrans disponibles de 27 lignes de 40 caracteres

#define SAUVECRAN $9A00
#define TAILLECRAN 1080 
#define MAXNBSCR 7

;;; Notez que la taille d un écran est de 1024+32+16+8 octets

SAVSCRADRLOW
	.byt <(SAUVECRAN+TAILLECRAN*0)
	.byt <(SAUVECRAN+TAILLECRAN*1)
	.byt <(SAUVECRAN+TAILLECRAN*2)
	.byt <(SAUVECRAN+TAILLECRAN*3)
	.byt <(SAUVECRAN+TAILLECRAN*4)
	.byt <(SAUVECRAN+TAILLECRAN*5)
	.byt <(SAUVECRAN+TAILLECRAN*6)
SAVSCRADRHIGH
	.byt >(SAUVECRAN+TAILLECRAN*0)
	.byt >(SAUVECRAN+TAILLECRAN*1)
	.byt >(SAUVECRAN+TAILLECRAN*2)
	.byt >(SAUVECRAN+TAILLECRAN*3)
	.byt >(SAUVECRAN+TAILLECRAN*4)
	.byt >(SAUVECRAN+TAILLECRAN*5)
	.byt >(SAUVECRAN+TAILLECRAN*6)



;;; 1080 = 10*108
;;; utiliser l un des compteurs avec une valeur < 127 permet d avoir un test de fin avec bpl
;;; qui teste si a, y ou x est negatif, autrement dit, on va pouvoir utiliser le 0 et ne
;;; debrancher que lorsque l indice passe a 255
#define BOUCIND1 108
#define BOUCIND2 10

CpSrc
.dsb 2

CpDest
.dsb 2

copieBoucle
.(
	lda CpSrc
	sta ScrOrigine+1
	lda CpSrc+1
	sta ScrOrigine+2
	lda CpDest
	sta ScrDestination+1
	lda CpDest+1
	sta ScrDestination+2
	
	ldx #BOUCIND2
bouc1
	dex
	bpl suite
	jmp suite3
suite
	ldy #BOUCIND1
bouc2
	dey
	bmi suite2
ScrOrigine
	lda $0123,y
ScrDestination
	sta $0123,y
	jmp bouc2
suite2
	clc
	lda ScrOrigine+1
	adc #BOUCIND1
	sta ScrOrigine+1
	lda ScrOrigine+2
	adc #0
	sta ScrOrigine+2
	clc
	lda ScrDestination+1
	adc #BOUCIND1
	sta ScrDestination+1
	lda ScrDestination+2
	adc #0
	sta ScrDestination+2
	jmp bouc1
suite3
	rts
.)
