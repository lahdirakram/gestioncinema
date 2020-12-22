Create TABLE film (
    idFilm serial PRIMARY KEY,
    titre text NOT NULL,
    realisateur text,
    producteurs text,
    dateSortie date NOT NULL,
    nationalite text,
    genre text,
    devis text,
    unique(titre,realisateur,producteurs,dateSortie)    
);

create table client (
    idIndividu serial PRIMARY KEY,
    nom text NOT NULL,
    prenom text NOT NULL,
    pointFidelite integer check (pointFidelite >= 0)
);

create table employe (
    idIndividu serial PRIMARY KEY,
    nom text NOT NULL,
    prenom text NOT NULL,
    departement integer not null,
    salaire_horraire real  NOT NULL check(salaire_horraire >= 10.15), -- smic horraire en 2020 10,15 eur
    nbHeurPerSemaine integer NOT NULL check(nbHeurPerSemaine <= 48),
    gestionaire boolean NOT NULL DEFAULT FALSE 
);

create table tache (
    idTache serial PRIMARY KEY,
    nom text unique not null,
    descr text NOT NULL,
    nbEmploye integer NOT NULL check(nbEmploye > 0)
);
create table salle(
    idSalle serial PRIMARY KEY,
    nom text not null,
    adress text not null,
    codePostal text not null,
    commune text not null,
    fauteuils decimal not null check(fauteuils > 0),
    nblignes integer,
    stylecolones integer check( stylecolones > 0 and stylecolones < 5),
    estOuverte boolean not null DEFAULT TRUE
);
create table programmation (
    idProgrammation serial PRIMARY KEY,
    idEmploye integer NOT NULL REFERENCES employe(idIndividu) on delete cascade on update cascade,
    idFilm integer NOT NULL REFERENCES film(idFilm) on delete cascade on update cascade,
    idSalle integer NOT NULL REFERENCES salle(idSalle) on delete cascade on update cascade,
    dateDeffet date NOT NULL DEFAULT now(),
    dateDebut date NOT NULL DEFAULT now(),
    dateFin date NOT NULL DEFAULT (now()::date + 1) ,
    heurDebut time NOT NULL check( heurDebut >= '08:00:00'),
    heurFin time NOT NULL check(heurFin <= '24:00:00'),
    tarifBase integer not null check(tarifBase > 0) DEFAULT 5,
    check(dateDebut >= dateDeffet and dateFin >= dateDebut)\
);
create table reservation(
    idRes serial PRIMARY KEY,
    idProgrammation integer not null REFERENCES programmation(idProgrammation) on delete cascade on update cascade,
    idClient integer not null REFERENCES client(idIndividu) on delete cascade on update cascade,
    dateDeffet date not null check(dateDeffet >= now()::date) DEFAULT now(),
    dateseance date not null check(dateseance >= now()::date),
    ligne integer not null,
    col integer not null,
    colstyle integer not null check( colstyle > 0 and colstyle < 5),
    montantPaye decimal not null 
);
create table avis (
    idAvis serial PRIMARY KEY,
    idClient integer not null REFERENCES client(idIndividu) on delete cascade on update cascade,
    idRes integer not null REFERENCES reservation(idRes) on delete cascade on update cascade,
    nbEtoile integer NOT NULL check(nbEtoile > 0 and nbEtoile < 6),
    comentaire text 
);
create table attributionTache(
    idAttrib serial PRIMARY KEY,
    idEmploye integer not null REFERENCES employe(idIndividu) on delete cascade on update cascade,
    idTache integer not null REFERENCES tache(idTache) on delete cascade on update cascade,
    idSalle integer not null REFERENCES salle(idSalle) on delete cascade on update cascade,
    dateDeb date not null check( dateDeb >= now()::date) DEFAULT now(),
    dateFin date not null check( dateFin >= now()::date) DEFAULT now(),
    heur time not null check(heur >= '08:00:00'),
    nbHeur integer not null,
    estAbsent boolean not null DEFAULT FALSE,
    check(dateFin >= dateDeb and ((nbHeur * interval '1 hour')+heur) <='24:00:00')
);


