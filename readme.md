# Système de gestion des salles de cinéma

## Contraintes:

1. Clé PRIMAIRE:
	1. (film: id_film)
	2. (salle: id_salle)
	3. (programmation:id_programmation)
	4. (individu: id)
	5. (tache: id)
	6. (avis: id)

2. NOT NULL:
	1. entité:
		1. film: id_film, titre, date_sortie, genre​.
		1. salle: id_salle, capacité, row_count, column_shape.
		1. programmation: tous les attributs.
		1. individu: id, nom, prenom.
		1. employe: salaire_horraire, nb_heur_par_sem.
		1. tache: id, description, nb_employe.
		1. avis: id, nb_etoile.
	1. association:
		1. affecte a: date, heur.
		1. reservation: date, row, col.
		1. a programe: date.

3. UNIQUE:
    1. tache: description.
4. CHECK:
	1. tache:
		1. description in (food, menage, technique, caisse,hotesse d’acceuil ,gestion )
	1. salle:
		1. capacite > 0
		2. row_count > 0
		3. column_shape in {2, 3, 4}
	1. programmation:
		1. heur in 10h et 22h.
	1. employe:
		1. salaire horaire entre 10 et 20.
		2. nb_heur entre 10 et 35.
5. TRIGGERS:
	1. parogrammation:
		1. date_fin > date_debut
		2. vérifier que cette programmation ne derange aucune autre programmation.
	1. reservation:
		1. vérifier que la combinaison (row,col) n’a pas été desprise.
	1. affecte a:
		1. vérifiez que la tâche correspondante n’est pas complète en term de nombre d'employés nécessaire.


## les règles de gestion:

1. un gérant organise une programmation qui est composée d’un film et se déroule dans une salle et qui a une date de début et date de fin avec heur précise et un tarif de base .(triggers)
2. un client peut réserver une ou plusieur places pour une programmation et le montant est calculé à partir du tarif de base plus le tarif des sièges et services supplémentaire (boisson , food ...).(triggers)
3. un client a le droit de laisser un avis en donnant le numéro de sa réservation, un nombre d'étoile entre 1 et 5 et un commentaire .(requete)
4. un gérant affecte un employé à une tâche pendant un nombre d’heur précise .(requête d’insertion)

## la description SQL du schéma de la base:

- film (​ **idFilm** ​, titre, realisateur, producteurs, dateSortie, nationalite, genre,
    devis)
- individu(​ **idIndividu** ​, nom, prenom)
- client (pointFidelite) ​ **hérite individu**
- employe (departement, salaire_horraire, nbHeurPerSemaine, gestionaire
    )​ **hérite individu**
- tache (​ **idTache,** ​ nom, descr, nbEmploye)
- salle(​ **idSalle,** ​ nom, adress, codePostal, commune, fauteuils, nblignes,
    stylecolones, estOuverte)
- programmation (​ **idProgrammation,** ​idEmploye*, idFilm*, idSalle*,
    dateDeffet, dateDebut, dateFin, heurDebut, heurFin, tarifBase)
- reservation(​ **idRes,** idProgrammation*,idClient*, dateDeffet, dateseance ,
    ligne, col, colstyle,montantPaye)
- avis (​ **idAvis** ​, idClient*,idRes*, nbEtoile,comentaire)
- attributionTache(​ **idAttrib** ​, idEmploye*, idTache*, idSalle*, dateDeb,
    dateFin, heur, nbHeur, estAbsent)


## liste des fonctions, triggers et règles de gestion:


- Fonctions :
	1. date_intersect : c’est une fonction qui prend deux intervals de date en entré et renvoie vrai s’il existe une intersection entre ces dates et
faux si non.
	1. count_lignes : c’est une fonction qui prend le nombre de fauteuils d’une salle en entré et renvoie le nombre de rang de cette salle.
	1. col_style : elle prend le nombre de fauteuils d’une salle et renvoie le nombre de groupe de fauteuil de cette salle. 
	1. calcul_montant : elle calcule le montant total de la réservation en allant du tarif de base de la séance pour qui on ajoute des suppléments qui dépends de la position de la place réservée.
- Triggers :
	1. AttributionTache trigger : il se déclenche après une insertion ou modification sur la table **attribution Tâche** et il a pour but de vérifier les contraintes suivantes:
		- le nombre d’heur de travail de l'employé concerné ne sera pas dépassé après l'ajout de cette tâche.
		- un employé ne peut pas être affecté à une salle qui se situe en dehors de son département.
		- un employé ne peut pas être affecté à deux tâche en parallèle.
		- l’attribution d’une tâche ne causera pas des dépassement en term de nombre d'employés nécessaire pour cette tâche.


	2. Programmation chevauchement : il se déclenche après une insertion ou modification sur la table **Programmation** et il a pour but de vérifier :
		- s’il y a pas d’autre programmations qui chevauchent avec cette nouvelle programmation.
		- que les employés de type gestionnaire peuvent ajouter une programmation.
	3. Réservation Valid : il se déclenche après une insertion ou modification sur la table **Réservation** et il a pour but de vérifier
		- si la date choisi est valide et que le siège choisi est disponible.
- Règles de gestion :
	1. ajoutProgrammation et annuleProgrammation : l’ajout d’une Programmation et son annulation.
	2. ajoutReservation et annuleReservation : l’ajout d’une Réservation et son annulation.
	3. attribuerTache et desattribuerTache : l’attribution d’une Tâche et son désattribution.
	4. ajoutAvis et supprimeAvis : l’ajout d’un avis et sa suppression.
	5. ajoutFilm et supprimeFilm : l’ajout d’un film et sa suppression.
	6. ajoutClient et supprimeClient : l’ajout d’un client et sa suppression.
	7. ajoutEmploye et supprimeEmploye : l’ajout d’un employe de sa suppression.
	8. ajoutTache et supprimeTache : l’ajout d’une tâche et sa suppression.
	9. ajoutSalle et supprimeSalle : l’ajout d’une salle et sa suppression.


- les indexes :
	1. tache_indx : index de type ‘barbre’ sur l’attribut nom de la table **tache** ce qui vas permettre un accès direct lors d’une recherche.
	1. film_indx : index de type ‘barbre’ sur l’attribut titre de la table **film** qui vas permettre un accès plus rapide.
	1. salle_indx : index de type ‘hash’ sur l’attribut code postal de la table **salle**.



