create index tache_indx on tache using btree (nom);

create index film_indx on film using btree (titre);

create index salle_indx on salle using hash (codePostal);
