SET TERM ^ ;

create or alter procedure PR_LOAD_MOVE_PARTNER
returns (
    DRUG_NAME DM_TEXT,
    DRUG_CODE integer,
    DOCNUM DM_TEXT,
    DOCDATE DM_DATETIME,
    IZG_ID DM_UUID_NULL,
    DRUG_PRODUCER_NAME DM_TEXT,
    DRUG_PRODUCER_COUNTRY DM_TEXT,
    BARCODE DM_TEXT,
    CENA_ZAK DM_DOUBLE,
    GODENDO_DATE DM_DATE,
    SERIA DM_TEXT,
    QUANT DM_DOUBLE,
    BCODEIZG DM_TEXT,
    DISK_T DM_DOUBLE,
    DISK_SUM DM_DOUBLE,
    SUM_ZAK DM_DOUBLE,
    SUM_ROZN DM_DOUBLE,
    CENA_ROZN DM_DOUBLE,
    D_TYPE integer,
    SUPPLIER DM_TEXT,
    SUPPLIER_INN DM_TEXT,
    DEVICE_NUM DM_TEXT,
    N_CHEK DM_TEXT,
    FIO_CHEK DM_TEXT,
    PP_TEG DM_TEXT)
as
declare variable DOC_ID integer;
declare variable MAXDATE DM_DATETIME;
declare variable MINDATE DM_DATETIME;
declare variable REP_DATE DM_DATETIME;
declare variable DATEEND DM_DATETIME;
begin

--определяем дату за которую формируем отчет
if (current_time>'23:00:00') then rep_date=current_timestamp; else rep_date=dateadd(day,-1,current_timestamp);--если отчет формируется раньше 23-00 то выгружаем данные за вчера
rep_date=cast(cast(rep_date as date)||' 00:00:01' as dm_datetime);--начало периода

dateend=cast(cast(rep_date as date)||' 23:59:59' as dm_datetime);--конец периода

maxdate=(select max(plm.doc_commitdate)from partner_load_move plm );--Дата последней выгрузки
mindate=(select min(plm.doc_commitdate)from partner_load_move plm );--Дата самых старых данных в выгрузке
--если данных нет в таблице то выгружаем c начала квартала
if (maxdate is null) then
    begin    --определяем текущий квартал
     if (extract(month from rep_date) in (1,2,3)) then rep_date='01.01.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (4,5,6)) then rep_date='01.04.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (7,8,9)) then rep_date='01.07.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (10,11,12)) then rep_date='01.10.'||extract(year from rep_date)||' 00:00:01';
    end

if (rep_date<>maxdate) then rep_date=maxdate; -- Если дата выгрузки больше или меньше даты последней выгрузки, выгружаем с даты последних данных

if (mindate<:dateend-93) then delete from partner_load_move where doc_commitdate<:dateend-93;-- Удаляет даные относящиеся к предыдущему периоду выгрузки (прошлый квартал)

 for select
         dd.part_id as Drug_code,
         dd.doc_id,
        cast(abs(sum(dd.quant)) as dm_double) as quant,
        iif ((abs (dd.discount)>0),1,0) as disk_T,
        cast(abs(dd.sum_dsc) as numeric(9,2)) as Disk_Sum,
         abs(dd.summa_o) as Sum_Zak,
         abs(dd.summa) as Sum_Rozn,
         abs(dd.price) as Cena_Rozn


        from doc_detail dd

     where dd.doc_id is not null and dd.doc_commitdate between :rep_date and :DATEEND
     group by dd.part_id, dd.doc_id,dd.discount,dd.sum_dsc,dd.summa_o,dd.summa,dd.price
     into :drug_code, :doc_id, :quant,  :disk_T, :disk_sum, :Sum_Zak, :Sum_Rozn, :Cena_Rozn do
 begin
 INSERT INTO partner_load_move (d_type,docnum,docdate,supplier,supplier_inn,device_num,n_chek,fio_chek,pp_teg,drug_name,izg_id,drug_producer_name,bcodeizg,drug_producer_country,
                                                cena_zak,seria,godendo_date,barcode,drug_code,quant,disk_t,disk_sum,sum_zak,sum_rozn,cena_rozn,doc_commitdate)
               
    select
         iif (d.doc_type=1,10,iif(d.doc_type=3,20,d.doc_type))as d_type,
         left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))as docnum,
         (select s from utpr_datetostr(d.docdate))as docdate,
         (select a.caption from agents a where  a.id = (select agent_id from pr_getmotherpart(:drug_code))) as Supplier,
        (select a.inn from agents a where  a.id = (select agent_id from pr_getmotherpart(:drug_code))) as Supplier_INN,
         d.device_num, 
         iif(d.doc_type=3,d.docnum, '')as N_Chek,
         (select first 1 u.username from users u where u.id=d.owner)as FIO_Chek,
         0 as pp_teg,
         vname.svalue as Drug_name,
          w.izg_id,
         vorig_izg.svalue as Drug_Producer_Name,
         w.barcode as bcodeizg,
         vcountry.svalue as Drug_Producer_country,
          p.price_o as Cena_Zak,
          p.seria,
          (select s from utpr_datetostr(iif (p.godendo is not null, cast(p.godendo as date),cast('01.01.1900' as date)))) as godendo_date,
          p.barcode,
          :drug_code,
                      :quant,  :disk_T, :disk_sum, :Sum_Zak, :Sum_Rozn, :Cena_Rozn ,d.docdate


    from docs d
        left join parts p on p.id = :drug_code

        left join agents a on a.id = d.agent_id
        left join wares w on w.id=p.ware_id
        left join vals vorig_izg on vorig_izg.id=w.izg_id
        left join vals vcountry on vcountry.id=w.country_id
        left join vals vname on vname.id=w.name_id
        where   d.doc_type in (1,2,3,6,9)
        and d.id=:doc_id  -- and d.docdate between :DATESTART and :DATEEND
        --and d.docdate is not null ;
          ;

--            into :d_type, :docnum, :docdate, :supplier, :supplier_inn, :device_num, :n_chek, :fio_chek, :pp_teg, :drug_name, :izg_id, :drug_producer_name,
--                 :bcodeizg, :drug_producer_country, :cena_zak, :seria, :godendo_date, :barcode;


 end
   suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON PARTNER_LOAD_MOVE TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT EXECUTE ON PROCEDURE UTPR_DATETOSTR TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON USERS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON DOCS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON PARTS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON AGENTS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON WARES TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON VALS TO PROCEDURE PR_LOAD_MOVE_PARTNER;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_LOAD_MOVE_PARTNER TO SYSDBA;