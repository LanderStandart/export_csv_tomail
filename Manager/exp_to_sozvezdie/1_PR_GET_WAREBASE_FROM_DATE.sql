SET TERM ^ ;

create or alter procedure PR_GET_WAREBASE_FROM_DATE (
    DATE_W DM_DATETIME,
    PARTID DM_ID)
returns (
    QUANT DM_DOUBLE)
as
begin
  --for
  Select
     -- dd.part_id,
     cast(coalesce(sum(dd.quant),0)as numeric (9,2))
  from
   doc_detail dd
  left join docs d on d.id=dd.doc_id
  where 
    d.commitdate <= :DATE_W and
    dd.part_id =:partid
--  group by dd.part_id
 -- having abs(sum(dd.quant))>0.001
  into :quant;
--  do
  suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_GET_WAREBASE_FROM_DATE;
GRANT SELECT ON DOCS TO PROCEDURE PR_GET_WAREBASE_FROM_DATE;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_GET_WAREBASE_FROM_DATE TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_GET_WAREBASE_FROM_DATE TO SYSDBA;