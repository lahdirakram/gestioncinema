-- verification de nbheur par rapport a la semaine  
CREATE or replace FUNCTION attributiontache_trigger_func() RETURNS trigger AS $$
    DECLARE
        weekDeb date;
        nbHPS integer;
        sum_week integer;
        emp_count integer;
        count_autre_tache integer;
        emp_dpt integer;
        salle_dpt integer;
    BEGIN

        SELECT current_date - cast(extract(dow from current_date) as int) + 1 into weekDeb;
        SELECT e.nbheurpersemaine into nbHPS FROM employe e WHERE e.idindividu = new.idEmploye;
        SELECT COALESCE(sum(atch.nbHeur * date_intersect(atch.dateDeb,atch.dateFin,weekDeb,weekDeb+6)),0)
        into sum_week
        FROM attributionTache atch 
        WHERE
            atch.idEmploye = new.idEmploye 
            and atch.dateDeb <= weekDeb + 6
            and atch.dateFin >= weekDeb
            and atch.idAttrib <> new.idAttrib;
        raise notice '%',sum_week;
        if sum_week + new.nbHeur * (new.dateFin - new.dateDeb + 1) > nbHPS then
                RAISE EXCEPTION 'le nombre d heur autorise par semaine est depassé % + % / % ',sum_week,(new.nbHeur * (new.dateFin - new.dateDeb + 1)),nbHPS;
        end if;

        select TO_NUMBER(substring(s.codePostal from 1 for 2),'99')
        into salle_dpt
        from salle s
        WHERE s.idSalle =  new.idSalle; 

        select departement 
        into emp_dpt 
        from employe e 
        WHERE e.idindividu = new.idEmploye;

        if salle_dpt <> emp_dpt then
            RAISE EXCEPTION 'un employe ne peut pas etre affecter a une salle qui se situe dn dehors de son departement.';
        end if;


        SELECT count(*)
        into emp_count
        FROM attributionTache a 
        WHERE
            a.dateDeb <= new.dateFin
        and a.dateFin >= new.dateDeb
        and a.heur <= new.heur + new.nbHeur * interval '1 hour'
        and a.heur + a.nbHeur * interval '1 hour' >= new.heur
        and a.idTache = new.idTache
        and a.idSalle = new.idSalle;

        if emp_count > 0 then
            RAISE EXCEPTION 'lattribution de cette a tache cause des depassement du nombre demploye necessaire.';
        end if;

        SELECT count(*)
        into count_autre_tache
        FROM attributionTache a
        WHERE 
            a.idEmploye=new.idEmploye
        and a.dateDeb <= new.dateFin
        and a.dateFin >= new.dateDeb
        and a.heur <= new.heur + new.nbHeur * interval '1 hour'
        and a.heur + a.nbHeur * interval '1 hour' >= new.heur; 

        if count_autre_tache > 0 then
            RAISE EXCEPTION 'impossible denregistrer cette attribution de tache car lemploye a deja une tache qui chevauche.';
        end if;

        return new;
    END;
$$ LANGUAGE plpgsql;

create trigger attributiontache_trigger
before insert or update on attributionTache 
for each row 
execute function attributiontache_trigger_func();

-- vérifier que cette programmation ne chevauche avec aucune autre programmation
CREATE or replace FUNCTION programmation_chevauchement_func() RETURNS trigger AS $$
    DECLARE
        cpt_chevauchement integer;
        est_gestionaire boolean;
    BEGIN
        select e.gestionaire
        into est_gestionaire
        from employe e
        where e.idindividu = new.idEmploye;

        if est_gestionaire = False then
            RAISE EXCEPTION 'que les employe de type gestionaire peuvent ajouter une programmation';

        end if;

        SELECT count(*)
        into cpt_chevauchement
        FROM programmation p 
        WHERE
            p.dateDebut <= new.dateFin
            and p.dateFin >= new.dateDebut
            and p.heurDebut <= new.heurDebut
            and p.heurFin >= new.heurFin 
            and p.idSalle = new.idSalle;

        if cpt_chevauchement != 0 then
                RAISE EXCEPTION 'impossible d enregistrer cette programmation car elle chevauche avec % autres.',cpt_chevauchement;
        end if;

        return new;
    END;
$$ LANGUAGE plpgsql;

create trigger programmation_chevauchement 
before insert or update of idSalle,dateDebut,dateFin,heurDebut,heurFin on programmation 
for each row 
execute function programmation_chevauchement_func();

-- vérifier que la combinaison (row,col) n’a pas été des prise et que la date est dispo
CREATE or replace FUNCTION reservation_valid_func() RETURNS trigger AS $$
    DECLARE
        cpt_siege integer;
        prog programmation%ROWTYPE;
    BEGIN
        SELECT * into prog FROM programmation p WHERE p.idProgrammation = new.idProgrammation; 
        if new.dateseance < prog.dateDebut or new.dateseance > prog.dateFin then
            RAISE EXCEPTION 'impossible d enregistrer cette reservation car la date de la seance nest pas disponible.';
        end if; 
       
        SELECT count(*)
        into cpt_siege
        FROM reservation r
        WHERE
            r.idProgrammation = new.idProgrammation
            and r.dateseance = new.dateseance
            and r.ligne = new.ligne
            and r.col = new.col
            and r.colstyle = new.colstyle;
        if cpt_siege != 0 then
                RAISE EXCEPTION 'impossible d enregistrer cette reservation car le siege est deja pris.';
        end if;

        return new;
    END;
$$ LANGUAGE plpgsql;

create trigger reservation_valid
before insert or update on reservation 
for each row 
execute function reservation_valid_func();
