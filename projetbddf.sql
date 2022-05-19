drop table if exists ue cascade;
drop table if exists module cascade;
drop table if exists enseignant cascade;
drop table if exists etudiant cascade;
drop table if exists controle cascade;
drop table if exists note cascade;



create table etudiant(
    id_etudiant name primary key,
    nom_etudiant varchar,
    prenom_etudiant varchar
);

create table enseignant(
    id_enseignant name primary key,
    nom_enseignant varchar,
    prenom_enseignant varchar
);


create table ue(
    id_ue serial primary key,
    nom_ue varchar
);

create table module(
    id_module serial primary key,
    nom_module varchar,    
    id_ue serial references ue,
    coefficient_module float
);


create table controle(
    id_controle serial primary key,
    id_module serial references module,
    id_enseignant name references enseignant,
    nom_controle varchar,
    date_controle date
);

create table note(
    id_controle serial references controle,
    id_etudiant name references etudiant,
    note float,
    coefficient_note float,
    check (note<=20 and note>=0),
    primary key(id_etudiant,id_controle)
);


/* ue */
insert into ue(nom_ue) values ('informatique');
insert into ue(nom_ue) values ('culture');
/* module */
insert into module(id_ue,nom_module,coefficient_module) values (1,'python',100);
insert into module(id_ue,nom_module,coefficient_module) values (1,'java',5);
insert into module(id_ue,nom_module,coefficient_module) values (1,'html',20);
insert into module(id_ue,nom_module,coefficient_module) values (2,'communication',0.0001);
insert into module(id_ue,nom_module,coefficient_module) values (2,'math',10);
insert into module(id_ue,nom_module,coefficient_module) values (2,'uml',0.1);
/* enseignant */
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values ('postgres','hocine','abir');
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values (2,'audibert','lautre');
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values (3,'lalaoui','enretard');
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values (4,'lepen','jeanmarie');
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values (5,'hebert','hebertt');
insert into enseignant(id_enseignant,nom_enseignant,prenom_enseignant) values (6,'toufik','fiktou');
/* controle */
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (1,'postgres','controlepython',current_timestamp);
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (2,2,'controlejava',current_timestamp);
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (3,3,'controlehtml',current_timestamp);
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (4,4,'controlecomm',current_timestamp);
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (5,5,'controlemath',current_timestamp);
insert into controle(id_module,id_enseignant,nom_controle,date_controle) values (6,6,'controleuml',current_timestamp);
/* etudiant */
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values ('postgres','semoule','sophiane');
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values (2,'moldave','rindo');
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values (3,'tora','eol');
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values (4,'lilali','rayane');
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values (5,'maroc','lhssene');
insert into etudiant(id_etudiant,nom_etudiant,prenom_etudiant) values (6,'algerie','lounes');
/* note */
insert into note(id_controle,id_etudiant,note,coefficient_note) values (1,'postgres',10,8);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (2,'postgres',11,7);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (3,'postgres',12,4);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (4,'postgres',14,5);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (5,'postgres',16,2);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (1,2,18,1);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (2,2,17,4);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (3,3,14,6);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (4,4,15,1);
insert into note(id_controle,id_etudiant,note,coefficient_note) values (5,5,16,1);

/* vue controle + enseignant */
create view vue_controle as select * from controle join enseignant using (id_enseignant);
/*  */
create view vue_note as select * from note join etudiant using (id_etudiant);

/* toute les note de tout les etudiant*/
create view notes as select * 
                        from ue 
                            join module using (id_ue)
                            join vue_controle using (id_module)
                            join vue_note using (id_controle);

/* toute les note de l'etudiant*/

create view mes_notes as select * 
                        from ue 
                            join module using (id_ue)
                            join vue_controle using (id_module)
                            join vue_note using (id_controle)
                            where id_etudiant=session_user;

/* vue rang total*/
create view classementue as ;





/* notes de l'etudiant avec son id_etudiant en parametre*/
CREATE or replace FUNCTION etudiant_notes
(in id name,out ue varchar,out module varchar,out enseignant int,out controle varchar,out date__controle date,out etudiant name,out la_note float,out le_coefficient float)
RETURNS SETOF RECORD AS
$$
begin
return query select nom_ue,nom_module,id_enseignant,nom_controle,date_controle,id_etudiant,note,coefficient from notes where id_etudiant=id;
end;
$$language plpgsql;















































/* partie étudiant */

/* moyenne module de l'étudiant parametre nom du module*/
CREATE or replace FUNCTION moyenneModule(in nom_modul varchar, out moyenne_module float)
returns float as
$$
  DECLARE
    coeffTot float;
    noteTot float;
    notes float;
    coeff float;
    curs CURSOR FOR
      SELECT note, coefficient_note FROM mes_notes WHERE nom_module = $1;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN curs;
    LOOP
      FETCH curs INTO notes, coeff;
      EXIT WHEN NOT FOUND;
      noteTot := noteTot + notes * coeff;
      coeffTot := coeffTot + coeff;
    END LOOP;
    if coeffTot>0 then
      moyenne_module := noteTot/coeffTot;
    end if;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;



/* moyenne UE de l'étudiant parametre nom du UE*/
CREATE or replace FUNCTION moyenneUE(in nom_uee varchar, out moyenne_ue float)
returns float as
$$
  DECLARE
    coeffTot float;
    noteTot float;
    module varchar;
    coeff float;
    moymodule float;
    curse CURSOR FOR
      SELECT nom_module,coefficient_module FROM mes_notes WHERE nom_ue = $1;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN curse;
    LOOP
      FETCH curse INTO module, coeff;
      EXIT WHEN NOT FOUND;
      moymodule:=moyenneModule(module);
      noteTot := noteTot + moymodule * coeff;
      coeffTot := coeffTot + coeff;
    END LOOP;
    if coeffTot>0 then
      moyenne_ue := noteTot/coeffTot;
    end if;
    CLOSE curse;
    return;
  END;
$$ language plpgsql security definer;


/* moyenne totale de l'étudiant*/
CREATE or replace FUNCTION moyennetotal(out moyenne_total float)
returns float as
$$
  DECLARE
    noteTot float;
    uee varchar;
    coeff float;
    coeffTot float;
    moyue float;
    cursee CURSOR FOR
      SELECT nom_ue FROM mes_notes;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN cursee;
    LOOP
      FETCH cursee INTO uee;
      EXIT WHEN NOT FOUND;
      moyue:=moyenneUE(uee);
      noteTot := noteTot + moyue ;
      coeffTot := coeffTot + 1;
    END LOOP;
    if coeffTot>0 then
    moyenne_total := noteTot/coeffTot;
    end if;
    CLOSE cursee;
    return;
  END;
$$ language plpgsql security definer;


/*etudiant note contrôle par module de l'etudiant parametre nom du module */
CREATE or replace FUNCTION ControleDuModule(in nom_modul varchar,out nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    curs CURSOR FOR
      SELECT nom_ue,nom_module,coefficient_module, nom_controle, note,coefficient_note FROM mes_notes WHERE nom_module = $1;
  BEGIN
    OPEN curs;
    LOOP
      FETCH curs INTO nom_uee,module,coef_module,NomDuControl ,notes,coeff;
      EXIT WHEN NOT FOUND;
      return next;
    END LOOP;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;


/*etudiant note contrôle par ue parametre ue*/
CREATE or replace FUNCTION ControleDuUE(inout nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    modulee varchar;
    curse CURSOR FOR
      SELECT nom_module FROM mes_notes WHERE nom_ue = $1;
  BEGIN
    OPEN curse;
    LOOP
      FETCH curse INTO modulee;
      EXIT WHEN NOT FOUND;
      return query select * from ControleDuModule(modulee);
    END LOOP;
    CLOSE curse;
  END;
$$ language plpgsql security definer;



/*etudiant  note tout les  contrôles */
CREATE or replace FUNCTION ControleTotal(out nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    modulee varchar;
    curse CURSOR FOR
      SELECT nom_module FROM mes_notes;
  BEGIN
    OPEN curse;
    LOOP
      FETCH curse INTO modulee;
      EXIT WHEN NOT FOUND;
      return query select * from ControleDuModule(modulee);
    END LOOP;
    CLOSE curse;
  END;
$$ language plpgsql security definer;



/*etudiant  rang ue */
create or replace function rangUE(in ue varchar,out rang int,out uee varchar,out nom_etudiantt varchar)
returns setof record as
$$
DECLARE

curserang cursor for 
  select distinct moyenneue($1,id_etudiant),nom_ue,id_etudiant from classementue ;
  etudiant name;
  moy float;

begin
rang:=0;
open curserang;
while  etudiant!=session_user then
LOOP
rang:=rang+1;
fetch curserang into moy,uee,etudiant;
end loop;

return query select distinct dense_rank() over (order by moyenne desc),moyenne,nom_ue,id_etudiant from
                                                                                                   (select distinct moyenneue(nom_ue,id_etudiant) as moyenne,nom_ue,id_etudiant 
                                                                                                                            from notes 
                                                                                                                                where nom_ue = $1 
                                                                                                                                  order by moyenne desc) as classementue;
close curserang;
end;
$$language plpgsql security definer;




/*etudiant  rang total */































/* partie enseignant*/




/*enseignant moyenne module parametre nom etudiant*/
CREATE or replace FUNCTION moyenneModuleEtudiant(in etudiant_id name, out moyenne float)
returns float as
$$
  DECLARE
    coeffTot float;
    noteTot float;
    notes float;
    coeff float;
    curs CURSOR FOR
      SELECT note, coefficient_module FROM notes WHERE id_enseignant = session_user and id_etudiant = $1 ;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN curs;
    LOOP
      FETCH curs INTO notes, coeff;
      EXIT WHEN NOT FOUND;
      noteTot := noteTot + notes * coeff;
      coeffTot := coeffTot + coeff;
    END LOOP;
    moyenne := noteTot/coeffTot;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;



/*enseignant controle module parametre nom etudiant*/

CREATE or replace FUNCTION ControleEtudiant(in etudiant_id name,out nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    curs CURSOR FOR
      SELECT nom_ue,nom_module,coefficient_module, nom_controle, note,coefficient_note FROM mes_notes WHERE id_enseignant = session_user and id_etudiant = $1 ;
  BEGIN
    OPEN curs;
    LOOP
      FETCH curs INTO nom_uee,module,coef_module,NomDuControl ,notes,coeff;
      EXIT WHEN NOT FOUND;
      return next;
    END LOOP;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;























































/* partie administrateur*/


/* administrateur moyenne module parametre nom etudiant nom module  */
CREATE or replace FUNCTION moyenneModuleEtudiant(in etudiant_id name,in module varchar, out moyenne float)
returns float as
$$
  DECLARE
    coeffTot float;
    noteTot float;
    notes float;
    coeff float;
    curs CURSOR FOR
      SELECT note, coefficient_module FROM notes WHERE nom_module = $2 and id_etudiant = $1 ;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN curs;
    LOOP
      FETCH curs INTO notes, coeff;
      EXIT WHEN NOT FOUND;
      noteTot := noteTot + notes * coeff;
      coeffTot := coeffTot + coeff;
    END LOOP;
    moyenne := noteTot/coeffTot;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;


/* administrateur moyenne ue parametre nom etudiant nom module  */

CREATE or replace FUNCTION moyenneUE(in nom_uee varchar,in etudiant_id name, out moyenne_ue float)
returns float as
$$
  DECLARE
    coeffTot float;
    noteTot float;
    module varchar;
    coeff float;
    moymodule float;
    curse CURSOR FOR
      SELECT nom_module,coefficient_module FROM notes WHERE nom_ue = $1 and id_etudiant = $2;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN curse;
    LOOP
      FETCH curse INTO module, coeff;
      EXIT WHEN NOT FOUND;
      moymodule:=moyenneModule(module);
      noteTot := noteTot + moymodule * coeff;
      coeffTot := coeffTot + coeff;
    END LOOP;
    if coeffTot>0 then
      moyenne_ue := noteTot/coeffTot;
    end if;
    CLOSE curse;
    return;
  END;
$$ language plpgsql security definer;


/*administrateur moyenne totale parametre nom etudiant*/
CREATE or replace FUNCTION moyennetotal(in etudiant name,out moyenne_total float)
returns float as
$$
  DECLARE
    noteTot float;
    uee varchar;
    coeff float;
    coeffTot float;
    moyue float;
    cursee CURSOR FOR
      SELECT nom_ue FROM notes where id_etudiant = $1;
  BEGIN
    coeffTot := 0;
    noteTot := 0;
    OPEN cursee;
    LOOP
      FETCH cursee INTO uee;
      EXIT WHEN NOT FOUND;
      moyue:=moyenneUE(uee);
      noteTot := noteTot + moyue ;
      coeffTot := coeffTot + 1;
    END LOOP;
    if coeffTot>0 then
    moyenne_total := noteTot/coeffTot;
    end if;
    CLOSE cursee;
    return;
  END;
$$ language plpgsql security definer;









/*administrateur controle module parametre nom etudiant nom module*/

CREATE or replace FUNCTION ControleEtudiant(in etudiant_id name,in modulee varchar,out nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    curs CURSOR FOR
      SELECT nom_ue,nom_module,coefficient_module, nom_controle, note,coefficient_note FROM mes_notes WHERE nom_module = $2 and id_etudiant = $1 ;
  BEGIN
    OPEN curs;
    LOOP
      FETCH curs INTO nom_uee,module,coef_module,NomDuControl ,notes,coeff;
      EXIT WHEN NOT FOUND;
      return next;
    END LOOP;
    CLOSE curs;
    return;
  END;
$$ language plpgsql security definer;


/* administrateur controle ue parametre nom etudiant et nom ue */

CREATE or replace FUNCTION ControleDuUE(inout nom_uee varchar,in etudiant_idd name,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    modulee varchar;
    curse CURSOR FOR
      SELECT nom_module FROM notes WHERE nom_ue = $1 and id_etudiant = $2 ;
  BEGIN
    OPEN curse;
    LOOP
      FETCH curse INTO modulee;
      EXIT WHEN NOT FOUND;
      return query select * from ControleDuModule(modulee);
    END LOOP;
    CLOSE curse;
  END;
$$ language plpgsql security definer;



/*administrateur  note tout les  contrôles */
CREATE or replace FUNCTION ControleTotal(in etudiant name,out nom_uee varchar,out module varchar,out coef_module float,out NomDuControl varchar, out notes float,out coeff float)
returns setof record as
$$
  DECLARE
    modulee varchar;
    curse CURSOR FOR
      SELECT nom_module FROM notes where id_etudiant = $1;
  BEGIN
    OPEN curse;
    LOOP
      FETCH curse INTO modulee;
      EXIT WHEN NOT FOUND;
      return query select * from ControleDuModule(modulee);
    END LOOP;
    CLOSE curse;
  END;
$$ language plpgsql security definer;




select * from moyenneModule('python');
select * from moyenneue('informatique');
select * from moyennetotal();
select * from ControleDuModule('python');
select * from ControleDuUE('informatique');
select * from controletotal();