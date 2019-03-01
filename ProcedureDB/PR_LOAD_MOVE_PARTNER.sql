SET TERM ^ ;

create or alter procedure PR_LOAD_MOVE_PARTNER (
    DATESTART DM_DATE,
    DATEEND DM_DATE,
    G$PROFILE_ID integer)
returns (
    PARTNER_ID integer,
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
    G$PROFILE_ID_OUT integer,
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
begin
 for select
         dd.part_id as Drug_code,
         dd.doc_id,
        cast(abs(sum(dd.quant)) as dm_double) as quant,
        iif ((abs (dd.discount)>0),1,0) as disk_T,
        cast(abs(dd.sum_dsc) as numeric(9,2)) as Disk_Sum,
         abs(dd.summa_o) as Sum_Zak,
         abs(dd.summa) as Sum_Rozn,
         abs(dd.price) as Cena_Rozn,
         dd.g$profile_id

        from doc_detail dd

     where dd.doc_commitdate between :DATESTART and :DATEEND and dd.g$profile_id = :g$profile_id
     group by dd.part_id, dd.doc_id,dd.discount,dd.sum_dsc,dd.summa_o,dd.summa,dd.price,dd.g$profile_id
     into :drug_code, :doc_id, :quant,  :disk_T, :disk_sum, :Sum_Zak, :Sum_Rozn, :Cena_Rozn , :g$profile_id_out   do
 begin
    select  g.partner_id,
         iif (d.doc_type=1,10,iif(d.doc_type=3,20,d.doc_type))as d_type,
         left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))as docnum,
         cast(d.docdate as date)as docdate,
         a.caption as Supplier,
         a.inn as Supplier_INN,
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
          iif (p.godendo is not null, cast(p.godendo as date),'01.01.1990') as godendo_date,
          p.barcode


    from docs d
        left join parts p on p.id = :drug_code and p.g$profile_id=d.g$profile_id

        left join agents a on a.id = d.agent_id and a.g$profile_id=p.g$profile_id
        left join wares w on w.id=p.ware_id
        left join vals vorig_izg on vorig_izg.id=w.izg_id
        left join vals vcountry on vcountry.id=w.country_id
        left join vals vname on vname.id=w.name_id
        left join g$profiles g on g.id = p.g$profile_id
        where  d.g$profile_id = :G$PROFILE_ID_OUT  and d.doc_type in (1,2,3,6,9) and d.id=:doc_id  and d.docdate between :DATESTART and :DATEEND


            into :partner_id, :d_type, :docnum, :docdate, :supplier, :supplier_inn, :device_num, :n_chek, :fio_chek, :pp_teg, :drug_name, :izg_id, :drug_producer_name,
                 :bcodeizg, :drug_producer_country, :cena_zak, :seria, :godendo_date, :barcode;

     suspend;
 end

end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON USERS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON DOCS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON PARTS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON AGENTS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON WARES TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON VALS TO PROCEDURE PR_LOAD_MOVE_PARTNER;
GRANT SELECT ON G$PROFILES TO PROCEDURE PR_LOAD_MOVE_PARTNER;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_LOAD_MOVE_PARTNER TO SYSDBA;