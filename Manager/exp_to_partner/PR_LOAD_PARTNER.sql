SET TERM ^ ;

create or alter procedure PR_LOAD_PARTNER (
    DATESTART DM_DATETIME,
    DATEEND DM_DATETIME)
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
begin
maxdate=(select max(plm.doc_commitdate)from partner_load plm );--Дата последней выгрузки
mindate=(select min(plm.doc_commitdate)from partner_load plm );--Дата самых старых данных в выгрузке
if (maxdate is null) then datestart=:DAtestart; --если данных нет в таблице то выгружаем с указанной даты
if (:datestart<>maxdate) then datestart=maxdate; -- Если дата выгрузки больше или меньше даты последней выгрузки, выгружаем с даты последних данных

if (mindate<:dateend-93) then delete from partner_load where doc_commitdate<:dateend-93;-- Удаляет даные относящиеся к предыдущему периоду выгрузки (прошлый квартал)

     while (datestart<>dateend+1)  do
      begin
         for
        
          select  dd.part_id,cast(abs(sum(dd.quant)) as dm_double) as quant
                 from doc_detail dd
             where dd.doc_commitdate<=:datestart
         group by dd.part_id
         having abs(sum(dd.quant))>0.001 into  :part_id, :quant  do
         begin
           insert into partner_load (docdate,docagent,docnum, inn,izg_id,sizg,scountry,sname,bcode_izg,price_o,price,godendo_date,seria,barcode,doc_commitdate,part_id,quant)
            select
                cast (:datestart as date) as docdate,
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
                iif (p.godendo is not null, cast(p.godendo as date),'01.01.1900') as godendo_date,
                p.seria,
                p.barcode,
                :datestart,
                :part_id,
                :quant
            from parts p
                left join docs d on d.id=p.doc_id
                left join wares w on w.id=p.ware_id
                left join vals v_izg on v_izg.id=w.izg_id
                left join vals v_strana on v_strana.id=w.country_id
                left join vals v_sname on v_sname.id=w.name_id
        
                where p.id = :part_id ;
        --            into  :docdate, :docagent, :docnum, :INN, :izg_id, :sizg, :scountry, :sname, :bcode_izg, :price_o, :price,:godendo_date, :seria, :barcode;

         end
     datestart=datestart+1;
     end
     suspend;


end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON PARTNER_LOAD TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON AGENTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT EXECUTE ON PROCEDURE PR_GETMOTHERPART TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON PARTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON DOCS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON WARES TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON VALS TO PROCEDURE PR_LOAD_PARTNER;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_LOAD_PARTNER TO SYSDBA;