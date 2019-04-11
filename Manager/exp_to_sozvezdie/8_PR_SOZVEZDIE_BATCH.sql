SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_BATCH (
    DATE_BEG DM_DATETIME,
    DATE_END DM_DATETIME,
    IFFIRST DM_ID)
as
begin


if (:iffirst=1) then
    begin
    INSERT into sozvezdie_action_batch (map_batch_id,real_quant_beg)
         select
            dd.part_id,
            abs(sum(dd.quant))
        from
            docs d
       join doc_detail dd on dd.doc_id=d.id
        where
            d.commitdate <=:date_end
            and dd.part_id is not null

        group by
            dd.part_id
        having (abs(sum(dd.quant))>0.001) or
         ((select count(dd1.id) from doc_detail dd1 left join docs on docs.id=dd1.doc_id where dd1.part_id=dd.part_id and docs.commitdate between :date_beg and :date_end)>0);

     --suspend;
    end

else
    begin
         INSERT into sozvezdie_action_batch (map_batch_id)
        select
            dd.part_id
        from
            docs d
         join doc_detail dd on dd.doc_id=d.id
        where
            d.commitdate between :date_beg and :date_end
            and dd.part_id is not null
          --  and d.doc_type in (1,11,10,17,2,3,4,5,6,9,20)
        group by
            dd.part_id;
      --   having abs(sum(dd.quant))>0.001
--        into :part_id
--         do
    --  suspend;
    end
 suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT INSERT ON SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_BATCH;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_BATCH;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_SOZVEZDIE_BATCH;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH1;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO SYSDBA;