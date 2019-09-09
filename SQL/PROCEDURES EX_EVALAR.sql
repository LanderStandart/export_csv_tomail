SET TERM ^ ;

create or alter procedure EX_EVALAR_WAREBASE (
    DATE_END DM_DATE)
as
begin
Delete from EVALAR_WAREBASE where warebasedt=warebasedt;
INSERT INTO EVALAR_WAREBASE (warebasedt,sname,profile,city,address,quant,summa,bcode_izg,profile_id)
  select
        :date_end,
       w.sname,
        'Аптека '||(select left(g.caption,position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile ,
        'Ижевск' as City,
        (select substring(g.caption from position(' ' in g.caption) for position('тел' in g.caption)-position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id) as address,
        cast ( sum(dd.quant)as numeric(9,2)) as quant   ,
        sum(dd.summa)as summa,
        w.barcode as bcode_izg,
        dd.g$profile_id


    from doc_detail dd
    join  parts p on p.id = dd.part_id and p.g$profile_id=dd.g$profile_id   --and upper(p.orig_sizg) CONTAINING('ЭВАЛАР')
    JOIN wares w on w.id = p.ware_id
    join vals vizg on vizg.id=w.izg_id and upper (vizg.svalue)CONTAINING('ЭВАЛАР')
    where dd.doc_commitdate< :date_end   and dd.g$profile_id in (12,9,17,8)

    group by w.name_id,dd.g$profile_id,w.sname,w.barcode
    having sum(dd.quant)>0.001;
  suspend;
end^

SET TERM ; ^

create or alter procedure EX_EVALAR_SALES (
    DATE_START DM_DATE,
    DATE_END DM_DATE)
as
begin
DELETE FROM EVALAR_SALES where docdate=docdate;
INSERT INTO EVALAR_SALES (docdate,Kassir,sname,profile,city,address,quant,summa,barcode,profile_id)
 select
    d.docdate,
    (select u.username from users u where u.id=d.owner and u.g$profile_id=dd.g$profile_id) as Kassir,
    vname.svalue as SNAME,
    'Аптека'||(select left(g.caption,position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    'Ижевск' as City,
    (select substring(g.caption from position(' ' in g.caption) for position('тел' in g.caption)-position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id) as adress,
     -dd.quant as quant,
     cast(-dd.summa as numeric(9,2)) as summa,
     w.barcode,
     dd.g$profile_id
from doc_detail dd
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 3
 left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
 inner join WARES w on p.ware_id=w.id --and p.g$profile_id=w.g$profile_id
 inner join vals vname on w.name_id=vname.id
 inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and  upper(vorig_izg.svalue) containing 'ЭВАЛАР'

where d.docdate between :date_start and :date_end  and dd.g$profile_id in (12,9,17,8)
order by dd.doc_commitdate ;
  suspend;
end^


create or alter procedure EX_EVALAR_BUYS (
    DATE_START DM_DATE,
    DATE_END DM_DATE)
as
begin
DELETE FROM EVALAR_BUYS where docdate=docdate;
INSERT INTO EVALAR_BUYS (docdate,DISTRIBUTER,sname,profile,city,address,quant,summa,barcode,profile_id)
 select
    d.docdate,
   (select a.caption from agents a where a.id=d.agent_id and a.g$profile_id=dd.g$profile_id)  as Distributer,
    vname.svalue as SNAME,
    'Аптека'||(select left(g.caption,position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    'Ижевск' as City,
    (select substring(g.caption from position(' ' in g.caption) for position('тел' in g.caption)-position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id) as adress,
     dd.quant as quant,
     cast(dd.summa as numeric(9,2)) as summa,
     w.barcode,
     dd.g$profile_id
from doc_detail dd
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 1
 left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
 inner join WARES w on p.ware_id=w.id --and p.g$profile_id=w.g$profile_id
 inner join vals vname on w.name_id=vname.id
 inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and  upper(vorig_izg.svalue) containing 'ЭВАЛАР'

where d.docdate between :date_start and :date_end  and dd.g$profile_id in (12,9,17,8)
order by dd.doc_commitdate ;

  suspend;
end^

create or alter procedure EX_EVALAR_ALL_SALES (
    DATE_START DM_DATE,
    DATE_END DM_DATE)
as
begin
DELETE FROM evalar_all_sales where profile_id=profile_id;
INSERT INTO evalar_all_sales (profile,city,address,summa,profile_id,period)
    select
    'Аптека '||(select left(g.caption,position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    'Ижевск' as City,
    (select substring(g.caption from position(' ' in g.caption) for position('тел' in g.caption)-position(' ' in g.caption)) from g$profiles g where g.id=dd.g$profile_id) as address,
     cast (-sum(dd.summa)as numeric(9,2)) as summa,
     dd.g$profile_id,
     cast(:date_start as dm_text)||'-'||cast(:date_end as dm_text)
from doc_detail dd                                    
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 3
 where d.docdate between :date_start and :date_end and dd.g$profile_id in (12,9,17,8)
 group by dd.g$profile_id;
  suspend;
end^
