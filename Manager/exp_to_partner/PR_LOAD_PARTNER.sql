SET TERM ^ ;

create or alter procedure PR_LOAD_PARTNER
returns (
    SNAME DM_TEXT,
    PART_ID integer,
    DOCNUM DM_TEXT,
    DOCDATE DM_DATETIME,
    DOCAGENT DM_TEXT,
    IZG_ID DM_UUID_NULL,
    SIZG DM_TEXT,
    SCOUNTRY DM_TEXT,
    BARCODE DM_TEXT,
    PRICE_O DM_DOUBLE,
    PRICE DM_DOUBLE,
    GODENDO_DATE DM_DATE,
    SERIA DM_TEXT,
    QUANT DM_DOUBLE,
    INN DM_TEXT,
    BCODE_IZG DM_TEXT)
as
declare variable MINDATE DM_DATETIME;
declare variable MAXDATE DM_DATETIME;
declare variable REP_DATE DM_DATETIME;
declare variable DATEEND DM_DATETIME;
declare variable Q_DATE DM_DATETIME;
begin
--определяем дату за которую формируем отчет
if (current_time>'23:00:00') then rep_date=current_timestamp; else rep_date=dateadd(day,-1,current_timestamp);--если отчет формируется раньше 23-00 то выгружаем данные за вчера
rep_date=cast(cast(rep_date as date)||' 00:00:01' as dm_datetime);--начало периода

dateend=cast(cast(rep_date as date)||' 23:59:59' as dm_datetime);--конец периода

maxdate=(select max(plm.doc_commitdate)from partner_load plm );--Дата последней выгрузки
mindate=(select min(plm.doc_commitdate)from partner_load plm );--Дата самых старых данных в выгрузке
--если данных нет в таблице то выгружаем c начала квартала
     if (extract(month from rep_date) in (1,2,3)) then q_date='01.01.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (4,5,6)) then q_date='01.04.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (7,8,9)) then q_date='01.07.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (10,11,12)) then q_date='01.10.'||extract(year from rep_date)||' 00:00:01';


if (maxdate is null) then rep_date=q_date;

if (rep_date<>maxdate) then rep_date=maxdate; -- Если дата выгрузки больше или меньше даты последней выгрузки, выгружаем с даты последних данных



if (mindate<:dateend-93) then delete from partner_load where doc_commitdate<:dateend-93;-- Удаляет даные относящиеся к предыдущему периоду выгрузки (прошлый квартал)

if ((select first 1 part_id from partner_load_begin where partner_load_begin.q_date=:q_date )is not null) then delete from partner_load_begin where partner_load_begin.q_date=:q_date;
insert into partner_load_begin(part_id,quant, q_date)
  select dd.part_id,cast(abs(sum(dd.quant)) as dm_double),:q_date from doc_detail dd where dd.doc_commitdate<:q_date group by dd.part_id having abs(sum(dd.quant))>0.001;


     while (rep_date<dateadd(day,1,dateend))  do
      begin
         for
          select
                q.part_id,
                sum(q.quant)
          from
             (  select
                    plb.part_id,
                    plb.quant
                  from partner_load_begin plb
                  where plb.q_date=:q_date
                 union
                 select
                 dd.part_id,
                 sum(dd.quant) as quant
                 from doc_detail dd
                 where dd.doc_commitdate between :q_date and :rep_date
                 group by dd.part_id ) q
                group by part_id
                having sum(q.quant)>0.001
 into  :part_id, :quant  do
         begin
           insert into partner_load (docdate,docagent,docnum, inn,izg_id,sizg,scountry,sname,bcode_izg,price_o,price,godendo_date,seria,barcode,doc_commitdate,part_id,quant,q_date)
            select
                (select s from utpr_datetostr(:rep_date)) as docdate,
                (select (select a.caption from agents a where a.id=pr.agent_id  ) from pr_getmotherpart(p.id) pr)as docagent,
                left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))as docnum,
                (select a.inn from  agents a where d.agent_id=a.id ) as INN,
                w.izg_id,
                v_izg.svalue as sizg,
                v_strana.svalue as scountry,
                v_sname.svalue as sname,
                w.barcode as bcode_izg,
                cast (abs(p.price_o) as numeric(9,2)) as price_o,
                cast (abs(p.price) as numeric(9,2)) as price,
                (select s from utpr_datetostr(iif (p.godendo is not null, cast(p.godendo as date),cast('01.01.1900' as date)))) as godendo_date,
                p.seria,
                p.barcode,
                :rep_date,
                :part_id,
                :quant,
                :q_date
            from parts p
                left join docs d on d.id=p.doc_id
                left join wares w on w.id=p.ware_id
                left join vals v_izg on v_izg.id=w.izg_id
                left join vals v_strana on v_strana.id=w.country_id
                left join vals v_sname on v_sname.id=w.name_id
        
                where p.id = :part_id ;
        --            into  :docdate, :docagent, :docnum, :INN, :izg_id, :sizg, :scountry, :sname, :bcode_izg, :price_o, :price,:godendo_date, :seria, :barcode;

         end
     rep_date=dateadd(day,1,rep_date);
     end
     UPDATE params set PARAM_VALUE=(select s from utpr_datetostr((select max(insertdt)from partner_load))) WHERE params.param_id='PARTNER_LAST' ;
     suspend;


end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON PARTNER_LOAD TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT,INSERT,DELETE ON PARTNER_LOAD_BEGIN TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_LOAD_PARTNER;
GRANT EXECUTE ON PROCEDURE UTPR_DATETOSTR TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON AGENTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT EXECUTE ON PROCEDURE PR_GETMOTHERPART TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON PARTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON DOCS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON WARES TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON VALS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT,UPDATE ON PARAMS TO PROCEDURE PR_LOAD_PARTNER;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_LOAD_PARTNER TO SYSDBA;