<b>Des menus déroulants pour ton ORIC</b>

Quand le MacIntosh Plus est arrivé à la maison, pour les besoins professionnels de mon père, j'ai été conquis par l'interface graphique de ce dernier, le caractère auto-documenté et natif des menus, la facilité à explorer les possibilités de la machine même sans avoir de manuel.

Alors j'ai voulu recréer quelque chose de semblable sur l'ORIC, déjà dans "la famille" depuis 2 ans. On est en 1986.

J'ai initié ce projet il y a bien longtemps, en BASIC, avec des tableaux de chaînes de caractères pour implémenter des menus déroulants. Mais je m'étais assez vite arrêté. Car c'était du code en plus et inutile quand on connait déjà son ordi.

C'est resté à me trotter dans la tête pendant toutes ces années. Et puis, je me suis mis à utiliser l'OSDK et j'ai appris l'assembleur de l'ORIC (bien après mon passage en école d'info ou j'avais appris le 68000).

Je me remets à l'ORIC plutôt en été pour des raisons évidentes ! Et là, ça m'a pris : faire en assembleur le programme de menus déroulants.

Bon. Créer les chaînes de caractères, les organiser en tableaux, les pointer, lire le clavier, capter les flèches de direction, tout ça n'est pas bien compliqué. Ensuite, vient le lien avec des fonctions à exécuter quand on appuie sur ENTER sur un article de menu.

Une partie je trouve intéressante du code, c'est que la fonction qui gère ça est générique. c'est à dire que pour ajouter des menus, il suffit de créer les paramètres adéquats dans les zones réservées et ça marchera tout seul.

Ce qui est implemente:
- déplacement avec les flèches, validation avec ENTER, sortie avec ESC
- Pour entrer dans le MENU, appuyer sur la touche FUNC
- Les commandes suivantes font quelque chose : Quitter, Marquer/Copier/Coller, Explode, Cls, Hd Reset et Reset.

L'interpréteur BASIC est totalement fonctionnel et on peut activer le menu à tout moment. Quand on sort du menu, on se retrouve où on en était.
Il y a un inconvénient : si par exemple on est en train de taper une ligne dans l'interpréteur et qu'on active le menu et que l'on fait un CLS, tout ce qui a déjà été entré est toujours en cours. L'interpréteur reprendra où on l'a laissé.
Conséquence : quand on fait un COPIER/COLLER, ça ne marche qu'à l'écran, mais pas dans le BASIC. Il faudra le refaire avec CTRL-A dans l'interpréteur.

COPIER/COLLER
Ca fonctionne comme dans EMACS : on se positionne sur un emplacement de l'écran. On active le menu via FUNC, on sélectionne Edition/Marquer. On se positionne sur une autre position. on appuie sur FUNC et on fait Copier (le menu est préselectionné). on se met ensuite n'importe où. Appui sur FUNC et Edition/Coller.

