
P1
.byt <fFichier      ,>fFichier
.byt <fNouveau      ,>fNouveau
.byt <fOuvrir       ,>fOuvrir
.byt <fFermer       ,>fFermer
.byt <fEnregistrer  ,>fEnregistrer
.byt <fImprimer     ,>fImprimer
.byt <fQuitter      ,>fQuitter

P2
.byt <fEdition   ,>fEdition
.byt <fAnnuler   ,>fAnnuler
.byt <fCopier    ,>fCopier
.byt <fColler    ,>fColler
.byt <fSelect    ,>fSelect
.byt <fSupprimer ,>fSupprimer

P3
.byt <fCommandes,>fCommandes
.byt <fPaper    ,>fPaper
.byt <fInk      ,>fInk
.byt <fCls      ,>fCls
.byt <fNew      ,>fNew
.byt <fExplode  ,>fExplode

P4
.byt <fSysteme, >fSysteme
.byt <fHdReset, >fHdReset
.byt <fReset  , >fReset
.byt <fTime   , >fTime
.byt <fClock  , >fClock


PROCADDRLOW
.byt <P1, <P2, <P3, <P4
PROCADDRHIGH
.byt >P1, >P2, >P3, >P4



fenter
.(
	ldx CURMENU
	lda PROCADDRLOW,x
	sta PROCPTR
	lda PROCADDRHIGH,x
	sta PROCPTR+1
	ldx CURMENUART
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

fFichier
.(
	rts
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
	rts
.)


fEdition
.(
	rts
.)

fAnnuler
.(
	rts
.)

fCopier
.(
	rts
.)

fColler
.(
	rts
.)

fSelect
.(
	rts
.)

fSupprimer
.(
	rts
.)


fCommandes
.(
	rts
.)

fPaper
.(
	rts
.)

fInk
.(
	rts
.)

fCls
.(
	rts
.)

fNew
.(
	rts
.)

fExplode
.(
	jsr $FACB
	rts
.)


fSysteme
.(
	rts
.)

fHdReset
.(
	rts
.)

fReset
.(
	rts
.)

fTime
.(
	rts
.)

fClock
.(
	rts
.)
