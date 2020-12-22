
-- point fidelite negatifs
update client set pointFidelite = -20 where idIndividu=8;

--salaire inferieur au smic
update employe set salaire_horraire = 5 where idIndividu=4;

--nombre d'heur de travail par semaine superieur a 48
update employe set nbHeurPerSemaine = 60 where idIndividu=4;




