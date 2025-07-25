;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

ARTICLE

Des menus déroulants pour ton ORIC

Quand le MacIntosh Plus est arrivé à la maison, pour les besoins professionnels de mon père, j'ai été conquis par l'interface graphique de ce dernier, le caractère auto-documenté et natif des menus, la facilité à explorer les possibilités de la machine même sans avoir de manuel.

Alors j'ai voulu recréer quelque chose de semblable sur l'ORIC, déjà dans "la famille" depuis 2 ans. On est en 1986.

J'ai initié ce projet il y a bien longtemps, en BASIC, avec des tableaux de chaînes de caractères pour implémenter des menus déroulants. Mais je m'étais assez vite arrêté. Car c'était du code en plus et inutile quand on connait déjà son ordi.

C'est resté à me trotter dans la tête pendant toutes ces années. Et puis, je me suis mis à utiliser l'OSDK et j'ai appris l'assembleur de l'ORIC (bien après mon passage en école d'info ou j'avais appris le 68000).

Je me remets à l'ORIC plutôt en été pour des raisons évidentes ! Et là, ça m'a pris : faire en assembleur le programme de menus déroulants.

Bon. Créer les chaînes de caractères, les organiser en tableaux, les pointer, lire le clavier, capter les flèches de direction, tout ça n'est pas bien compliqué. Ensuite, vient le lien avec des fonctions à exécuter quand on appuie sur ENTER sur un article de menu.

Une partie je trouve intéressante du code, c'est que la fonction qui gère ça est générique. c'est à dire que pour ajouter des menus, il suffit de créer les paramètres adéquats dans les zones réservées et ça marchera tout seul.

