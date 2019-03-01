SET TERM ^ ;

create or alter procedure PR_LOAD_PARTNER (
    DATEEND DM_DATE,
    G$PROFILE_ID integer)
returns (
    PARTNER_ID integer,
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
    G$PROFILE_ID_OUT integer,
    QUANT DM_DOUBLE,
    INN DM_TEXT,
    BCODE_IZG DM_TEXT)
as
begin
 for select  dd.part_id,cast(abs(sum(dd.quant)) as dm_double) as quant, g$profile_id
         from doc_detail dd
     where dd.doc_commitdate<=:DATEEND and dd.g$profile_id = :g$profile_id
 group by dd.part_id, g$profile_id
 having abs(sum(dd.quant))>0.001 into  :part_id, :quant, :G$PROFILE_ID_OUT  do
 begin
    select  g.partner_id,
         :DATEEND as docdate,
        (select (select a.caption from agents a where a.id=pr.agent_id and a.g$profile_id=p.g$profile_id ) from pr_getmotherpart(p.id, :G$PROFILE_ID) pr)as docagent,
        left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))as docnum,
        (select a.inn from  agents a where d.agent_id=a.id and a.g$profile_id=p.g$profile_id) as INN,
        w.izg_id,
        v_izg.svalue as sizg,
        v_strana.svalue as scountry,
        v_sname.svalue as sname,
        w.barcode as bcode_izg,
        cast (abs(p.price_o) as numeric(9,2)) as price_o,
        cast (abs(p.price) as numeric(9,2)) as price,
        iif (p.godendo is not null, cast(p.godendo as date),'01.01.1900') as godendo_date,
        p.seria,
        p.barcode
    from parts p
        left join docs d on d.id=p.doc_id and d.g$profile_id=p.g$profile_id
        left join wares w on w.id=p.ware_id
        left join vals v_izg on v_izg.id=w.izg_id
        left join vals v_strana on v_strana.id=w.country_id
        left join vals v_sname on v_sname.id=w.name_id
        left join g$profiles g on g.id = p.g$profile_id
        where p.id = :part_id and p.g$profile_id = :G$PROFILE_ID_OUT
            into :partner_id, :docdate, :docagent, :docnum, :INN, :izg_id, :sizg, :scountry, :sname, :bcode_izg, :price_o, :price,:godendo_date, :seria, :barcode;
     suspend;
 end

end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON AGENTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT EXECUTE ON PROCEDURE PR_GETMOTHERPART TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON PARTS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON DOCS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON WARES TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON VALS TO PROCEDURE PR_LOAD_PARTNER;
GRANT SELECT ON G$PROFILES TO PROCEDURE PR_LOAD_PARTNER;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_LOAD_PARTNER TO SYSDBA;