<b>Des menus déroulants pour ton ORIC</b>

Quand le MacIntosh Plus est arrivé à la maison, pour les besoins professionnels de mon père, j'ai été conquis par l'interface graphique de ce dernier, le caractère auto-documenté et natif des menus, la facilité à explorer les possibilités de la machine même sans avoir de manuel.

Alors j'ai voulu recréer quelque chose de semblable sur l'ORIC, déjà dans "la famille" depuis 2 ans. On est en 1986. Quasiment 40 ans plus tard... !


Ce qui est implemente:
- Affichage d'une barre de menus déroulants
- déplacement avec les flèches <- ->, haut et bas qui permettent de naviguer. Validation de la commande avec ENTER, sortie du menu avec ESC
- QUand on est dans l'interpréteur ORIC "normal", on appuie sur la touche FUNC our entrer dans le MENU
- Les commandes suivantes font quelque chose : Quitter, Marquer/Copier/Coller, Explode, Cls, Hd Reset et Reset.

L'interpréteur BASIC est totalement fonctionnel et on peut activer le menu à tout moment. 
Quand on "quitte le menu", on se retrouve où en était l'interpréteur de commandes du BASIC (qui est l'OS de base de l'ORIC ; non testé avec le SEDORIC).

 **Limite actuelle** : 
 Si une ligne est en cours de saisie dans l'interpréteur au moment de l'ouverture du menu, elle reste en mémoire (buffer/tampon du BASIC). 
 Ainsi, certaines actions comme `CLS` ou `Copier/Coller` n'ont d'effet que visuellement, sans interaction avec le buffer BASIC. 
 Aucune action faite quand le menu est actif n'est prise en compte dans le BASIC.
 Pour insérer dans le BASIC, il faut sortir du menu et utiliser `CTRL-A`.
 
**Fonction de Copier/Coller** (type EMACS)

1. Positionnez le curseur sur un point de l’écran.
2. Appuyez sur `FUNC` et sélectionnez `Edition > Marquer`.
3. Déplacez le curseur sur un second point.
4. Appuyez à nouveau sur `FUNC` et sélectionnez `Copier`.
5. Placez-vous où vous voulez coller.
6. Appuyez sur `FUNC` et choisissez `Edition > Coller`.
