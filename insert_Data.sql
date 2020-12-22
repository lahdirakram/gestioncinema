create table temp_film (
    VISA integer,
    TITRE text,
    REALISATEUR text,
    PRODUCTEURS text,
    DEVIS text,
    GENRE text,
    EOF text,
    RANG text,
    ASR text,
    PAYANTE text,
    CLAIR  text,
    NATIONALITE text,
    dateSortie integer,
    DECOMPOSITION text,
    AIDES text
);
COPY temp_film
FROM '/home/netbook/Bureau/BDA/projet/cnc-production-cinematographique-liste-des-films-agreespublic.csv' DELIMITER ';' CSV HEADER;

delete from temp_film where titre = null or dateSortie = null;

insert into film(titre,realisateur,producteurs,dateSortie,nationalite,genre,devis) 
select TITRE,REALISATEUR,PRODUCTEURS,(dateSortie||'-01-01')::date,NATIONALITE,GENRE,DEVIS from temp_film where TITRE is not null and dateSortie is not null;

drop table temp_film;

create table temp_salle (
    ndeg_auto  text,
    nom text,
    region_administrative text,
    adresse text,
    code_insee text,
    commune text,
    population_de_la_commune decimal,
    dep text,
    ndeguu text,
    unite_urbaine text,
    population_unite_urbaine decimal,
    situation_geographique text,
    ecrans decimal,
    fauteuils decimal,
    semaines_d_activite decimal,
    seances decimal,
    entrees_2018 decimal,
    entrees_2017 decimal,
    evolution_entrees text,
    tranche_d_entrees text,
    proprietaire text,
    col1 text,
    col2 text,
    col3 text,
    col4 text,
    col5 text,
    col6 text,
    col7 text,
    col8 text,
    col9 text,
    col10 text,
    col11 text,
    col12 text,
    col13 text,
    col14 text,
    col15 text,
    col16 text,
    col17 text,
    col18 text,
    col19 text
);
COPY temp_salle
FROM '/home/netbook/Bureau/BDA/projet/etablissements-cinematographiquesculture.csv' DELIMITER ';' CSV HEADER;

insert into salle(nom,adress,codePostal,commune,fauteuils,nblignes,stylecolones) 
select nom,adresse,code_insee,commune,fauteuils,count_lignes(fauteuils),col_style(fauteuils)
from temp_salle
where 
    nom is not null 
and adresse is not null 
and code_insee is not null
and commune is not null
and fauteuils is not null
and proprietaire = 'UGC' ;

drop table temp_salle;


insert into client (nom,prenom,pointFidelite) values 
('lahdir','mohamed',default),
('client1','client1',default),
('client2','client2',default),
('client3','client3',default),
('client4','client4',default);


insert into employe (nom,prenom,departement,salaire_horraire,nbHeurPerSemaine,gestionaire) values 
('emp1','emp1',75,10.16,35,default),
('emp2','emp2',69,11.0,40,default),
('emp3','emp3',91,10.16,35,default),
('emp4','emp4',75,10.16,35,default),
('emp5','emp5',69,10.16,35,default);

insert into tache (nom,descr,nbEmploye) values
('food','Lorem ipsum dolor sit amet.',4),
('menage','Lorem ipsum dolor sit amet.',4),
('technique','Lorem ipsum dolor sit amet.',2),
('caisse','Lorem ipsum dolor sit amet.',2),
('acceuil','Lorem ipsum dolor sit amet.',1),
('gestion','Lorem ipsum dolor sit amet.',1);



