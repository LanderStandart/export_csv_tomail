SET TERM ^ ;

create or alter procedure PR_PHARMIT_OUT_DECADE (
    DATE_START DM_DATE,
    DATE_END DM_DATE)
as
begin
 delete from pharmit_out_decade  ;
  insert INTO pharmit_out_decade (typeid,tender,goodname,producername,pharm,pharmaddress,barcode,quantity,profile_id)
   select
    iif (d.doc_type in(3),3,iif (d.doc_type in(1),1,iif(d.doc_type in(2,6),5,'')))as typeid,
    '' as tender,
    (select sname from wares w where w.id=d1.ware_id) as goodname,
    (select svalue from vals v where v.id=(select w1.izg_id from wares w1 where w1.id=d1.ware_id))as producerName,

    (select a.caption from agents a where a.email=cast(d.g$profile_id as dm_text))as pharm,
   '' as pharmaddress,
     (select barcode from wares w where w.id=d1.ware_id) as barcode,
     abs(sum(d1.quant))as quantity,
     d.g$profile_id


 from  doc_detail d1
 left join docs d on d1.doc_id=d.id and d1.g$profile_id=d.g$profile_id
 join g$profiles g on g.id=d.g$profile_id
 --left join wares w on w.id = d1.ware_id
 --join (select dd.doc_id,dd.ware_id,dd.g$profile_id,dd.quant from doc_detail dd)d1 on d1.doc_id=d.id and d1.g$profile_id=d.g$profile_id

 where d1.doc_commitdate between :date_start and :date_end
 and d.doc_type in (1,3,2,6)
--and d1.g$profile_id=147
  Group by d.doc_type,d.g$profile_id,d1.ware_id;
 
  suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON PHARMIT_OUT_DECADE TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON WARES TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON VALS TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON AGENTS TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON DOCS TO PROCEDURE PR_PHARMIT_OUT_DECADE;
GRANT SELECT ON G$PROFILES TO PROCEDURE PR_PHARMIT_OUT_DECADE;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_PHARMIT_OUT_DECADE TO SYSDBA;