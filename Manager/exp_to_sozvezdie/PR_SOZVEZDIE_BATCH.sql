SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_BATCH (
    DATE_BEG DM_DATE,
    DATE_END DM_DATE,
    IFFIRST DM_ID)
returns (
    PART_ID DM_ID,
    QUANT DM_DOUBLE)
as
declare variable P_ID DM_ID;
begin
delete from exp_parts_sozvezdie where exp_parts_sozvezdie.date_parts=:date_beg;

if (:iffirst=1) then
    begin
        for select
            dd.part_id,
            abs(sum(dd.quant))
        from
            docs d
        left join doc_detail dd on dd.doc_id=d.id
        where
            d.docdate <=:date_beg||':00:00:00'--between '01.11.2018'||':00:00:00' and '01.11.2018'||':23:59:59'
            and dd.part_id is not null
          --  and d.doc_type in (1,11,10,17,2,3,4,5,6,9,20)
        group by
            dd.part_id
        having abs(sum(dd.quant))>0.001
        into :part_id,:quant
         do
      suspend;
    end

else
    begin
          for select
            dd.part_id
        from
            docs d
        left join doc_detail dd on dd.doc_id=d.id
        where
            d.docdate between :date_beg||':00:00:00' and :date_end||':23:59:59'
            and dd.part_id is not null
            and d.doc_type in (1,11,10,17,2,3,4,5,6,9,20)
        group by
            dd.part_id
        into :part_id
         do
      suspend;
    end

end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,DELETE ON EXP_PARTS_SOZVEZDIE TO PROCEDURE PR_SOZVEZDIE_BATCH;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_BATCH;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_SOZVEZDIE_BATCH;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO SYSDBA;