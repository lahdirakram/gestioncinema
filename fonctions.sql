create or replace function date_intersect (s1 date,e1 date,s2 date,e2 date) returns integer as $$
declare
        deb  date;
        fin    date;
        toreturn integer;
begin
        if s1 < s2 then
                deb := s2;
        else
                deb := s1;
        end if;
        if e1 < e2 then
                fin := e1;
        else
                fin := e2;
        end if;
        if deb <= fin then
                toreturn := fin - deb + 1;
        else
                toreturn := 0;
        end if;
        return toreturn;
end
$$ language plpgsql;

create or replace function count_lignes (s1 decimal) returns integer as $$
declare
        toreturn integer;
begin
        if s1 < 1000 then
                return CEIL(s1/50);
        else    if s1 < 2000 then
                        return CEIL(s1/100);
                else    if s1 <3000 then
                                return CEIL(s1/150);
                        else    if s1 < 4000 then
                                        return CEIL(s1/200);
                                else 
                                        return CEIL(s1/250);
                                end if;
                        end if;
                end if;
        end if;
end
$$ language plpgsql;

create or replace function col_style (s1 decimal) returns integer as $$
declare    
        toreturn integer;
begin
        if s1 < 1000 then
                return 1;
        else    if s1 < 2000 then
                        return 2;
                else    if s1 <3000 then
                                return 3;
                        else    
                                return 4;
                        end if;
                end if;
        end if;
end
$$ language plpgsql;


create or replace procedure initialisation() as $$
declare
        emp_gestionaire integer;
begin
-- mise a jour de l'attribut gestionaire de la table employe
        select idEmploye 
        into emp_gestionaire
        from attributionTache 
        where 
            dateDeb <= now() 
        and dateFin >= now()
        and idTache = (select idTache from tache where nom = 'gestion');

        update employe set gestionaire = False;
        update employe set gestionaire = True where idEmploye=emp_gestionaire;


end
$$ language plpgsql;

create or replace function calcul_montant(prog integer,ligne integer,colstyle integer) returns decimal as $$
declare
        program programmation%ROWTYPE;
        sal salle%ROWTYPE;
        suppLigne decimal;
        suppCol decimal;
begin
        select p.* into program from programmation p where p.idProgrammation = prog;
        select s.* into sal from salle s where s.idSalle=program.idSalle;

        if sal.stylecolones = 1 then
                suppCol=0.05;
        else if sal.stylecolones = 2 then
                suppCol=0.04;
             else if sal.stylecolones = 3 then
                       if(colstyle = 1 or colstyle = 3)then
                                suppCol=0.02;
                       else
                                suppCol=0.03;
                       end if; 
                  else if sal.stylecolones = 4 then
                       if(colstyle = 1 or colstyle = 4)then
                                suppCol=0.01;
                       else
                                suppCol=0.02;
                       end if; 
                       end if;
                  end if;
             end if;
        end if;

        suppLigne = 0.2*(1-(ligne::decimal / sal.nblignes));

        return program.tarifBase*(1+suppLigne+suppCol);
end
$$ language plpgsql;

--l’ajout d’une Programmation et son annulation
create or replace function ajoutProgrammation(emp integer,film integer,salle integer,deb date,
                fin date,hdeb time,hfin time,tarifbase integer) returns boolean as $$
begin
        insert into programmation(idEmploye,idFilm,idSalle,dateDeffet,dateDebut,dateFin,heurDebut,heurFin,tarifBase)
        values(emp,film,salle,now(),deb,fin,hdeb,hfin,tarifbase);
        return true;
end
$$ language plpgsql;
create or replace function annuleProgrammation(idP integer) returns boolean as $$
begin
        delete from programmation p where p.idProgrammation=idP;
        return true;
end
$$ language plpgsql;

--l’ajout d’une Réservation et son annulation
create or replace function ajoutReservation(prog integer,client integer ,dateseance date,
        ligne integer,col integer,colstyle integer) returns boolean as $$
begin
        insert into reservation(idProgrammation,idClient,dateDeffet,dateseance,ligne,col,colstyle,montantPaye)
        values (prog,client,now(),dateseance,ligne,col,colstyle,calcul_montant(prog,ligne,colstyle));

        return true;
end
$$ language plpgsql;

create or replace function annuleReservation(idR integer) returns boolean as $$
begin
        delete from reservation r where r.idRes=idR;
        return true;
end
$$ language plpgsql;

--l’attribution d’une Tâche et son désattribution
create or replace function attribuerTache(emp integer,tache integer,salle integer,deb date,fin date,
        heur time,nbh integer) returns boolean as $$
begin
        insert into attributionTache(idEmploye,idTache,idSalle,dateDeb,dateFin,heur,nbHeur,estAbsent)
        values (emp,tache,salle,deb,fin,heur,nbh,default);

        return true;
end
$$ language plpgsql;

create or replace function desattribuerTache(idatt integer) returns boolean as $$ 
begin
        delete from attributionTache a where a.idAttrib = idatt;
        return true;
end
$$ language plpgsql;

--l’ajout d’un avis et sa suppression
create or replace function ajoutAvis(client integer,res integer, nbetoi integer,com text default null) returns boolean as $$
begin
        insert into avis(idClient,idRes,nbEtoile,comentaire)
        values(client,res,nbetoi,com);
        return true;
end
$$ language plpgsql;

create or replace function supprimeAvis(id integer) returns boolean as $$
begin
        delete from avis a where a.idAvis = id;
        return true;
end
$$ language plpgsql;

--l’ajout d’un film et sa suppression
create or replace function ajoutFilm(titre text, realisateur text, producteurs text, dateSortie date, 
        nationalite text, genre text, devis text) returns boolean as $$
begin
        insert into film(titre,realisateur,producteurs,dateSortie,nationalite,genre,devis)
        values(titre,realisateur,producteurs,dateSortie,nationalite,genre,devis);
        return true;
end
$$ language plpgsql;

create or replace function supprimeFilm (id integer) returns boolean as $$
begin
        delete from film f where f.idFilm = id;
        return true;
end
$$ language plpgsql;

--l’ajout d’un client et sa suppression.
create or replace function ajoutClient(nom text,prenom text) returns boolean as $$
begin
        insert into client(nom,prenom,pointFidelite)
        values(nom,prenom,default);
        return true;
end
$$ language plpgsql;

create or replace function supprimeFilm (id integer) returns boolean as $$
begin
        delete from client c where c.idIndividu = id;
        return true;
end
$$ language plpgsql;

--l’ajout d’un employe de sa suppression
create or replace function ajoutEmploye(nom text,prenom text,dept integer,salH real,nbhps integer) returns boolean as $$
begin
        insert into employe(nom,prenom,departement,salaire_horraire,nbHeurPerSemaine,gestionaire)
        values(nom,prenom,dept,salH,nbhps,default);
        return true;
end
$$ language plpgsql;

create or replace function supprimeEmploye (id integer) returns boolean as $$
begin
        delete from Employe e where e.idIndividu = id;
        return true;
end
$$ language plpgsql;

-- l’ajout d’une  tâche et sa suppression.
create or replace function ajoutTache(nom text,descr text,nbe integer) returns boolean as $$
begin
        insert into tache(nom,descr,nbEmploye)
        values(nom,descr,nbe);
        return true;
end
$$ language plpgsql;

create or replace function supprimeTache (id integer) returns boolean as $$
begin
        delete from Tache t where t.idTache = id;
        return true;
end
$$ language plpgsql;

--l’ajout d’une salle et sa suppression.

create or replace function ajoutSalle(nom text,adress text,codePostal text,commune text,fauteuils decimal) returns boolean as $$
begin
        insert into salle(nom,adress,codePostal,commune,fauteuils,nblignes,stylecolones)
        values(nom,adress,codePostal,commune,fauteuils,count_lignes(fauteuils),col_style(fauteuils));
        return true;
end
$$ language plpgsql;

create or replace function supprimeSalle (id integer) returns boolean as $$
begin
        delete from Salle s where s.idSalle = id;
        return true;
end
$$ language plpgsql;




create or replace function empAbsent (id integer,dateAbsence date,heurAbsence time) returns boolean as $$
begin
        update attributionTache a 
        set a.estAbsent=True 
        where 
            a.idEmploye=id 
        and dateAbsence <= a.dateFin 
        and dateAbsence >= a.dateDeb 
        and a.heur = heurAbsence;
        
        return true;
end
$$ language plpgsql;

create or replace function fermerSalle (id integer) returns boolean as $$
begin
        update Salle s set s.estOuverte=False where s.idSalle=id; 
        return true;
end
$$ language plpgsql;

create or replace function ouvreSalle (id integer) returns boolean as $$
begin
        update Salle s set s.estOuverte=True where s.idSalle=id; 
        return true;
end
$$ language plpgsql;