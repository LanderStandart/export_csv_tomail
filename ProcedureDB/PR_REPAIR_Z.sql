SET TERM ^ ;

create or alter procedure PR_REPAIR_Z
returns (
    VERB DM_TEXT1024)
as
declare variable SUMM2 numeric(15,2);
declare variable SUMM3 numeric(15,2);
declare variable SUMM4 numeric(15,2);
declare variable DEVICE_NUM DM_TEXT;
declare variable VSHIFT DM_ID;
declare variable ID DM_ID;
declare variable SUMM1_R numeric(15,2);
declare variable SUMM2_R numeric(15,2);
declare variable SUMM3_R numeric(15,2);
declare variable SUMM1 numeric(15,2);
declare variable SUMM4_R numeric(15,2);
declare variable AGENT_ID DM_ID_NULL;
declare variable AUDIT_ID DM_ID_NULL;
declare variable ZDATE DM_DATETIME;
declare variable SUMM1_SR numeric(15,2);
declare variable SUMM1_BR numeric(15,2);
declare variable SUMM2_SR numeric(15,2);
declare variable SUMM2_BR numeric(15,2);
declare variable SUMM4_OLD numeric(15,2);
-- период берется из параметра даты запрета редактирования AUTO_BANCORRECTDATE
begin
  for select
        d.summ1,
        d.summ2,
        d.summ3,
        d.summ4,
        d.device_num,
        d.vshift,
        d.id,
        d.agent_id,
        d.audit_id,
        d.commitdate
      from docs d
      where
        d.doc_type = 13
        and ((d.summ1=0) or (d.summ2=0)or (d.summ3=0)or(d.summ4=0))
        and d.commitdate>=(select first 1 p.param_value from params p where p.param_id='AUTO_BANCORRECTDATE')
        order by d.device_num,d.id
        into :summ1,:summ2,:summ3,:summ4,:device_num,:vshift,:id,:agent_id, :audit_id,:zdate
        do
            begin
            verb=' ';
            summ1_sr=(select COALESCE(sum(abs(summ1)),0)
                      from docs where doc_type =3 and DEVICE_NUM=:device_num and VSHIFT=:vshift);
            summ1_br=(select COALESCE(sum(abs(summ1)),0)
                 from docs where doc_type =9 and DEVICE_NUM=:device_num and VSHIFT=:vshift);

            summ2_sr = (select COALESCE(sum(abs(summ2)),0)
                      from docs where doc_type =3 and DEVICE_NUM=:device_num and VSHIFT=:vshift);
            summ2_br = (select COALESCE(sum(abs(summ2)),0)
                 from docs where doc_type =9 and DEVICE_NUM=:device_num and VSHIFT=:vshift);
            summ4_old =coalesce((select summ4 from docs where DEVICE_NUM=:DEVICE_NUM and VSHIFT=:vshift-1 and doc_type=13),0);

            summ1_r = :summ1_sr - :summ1_br;
            summ2_r = :summ1_sr + :summ2_sr;
            summ3_r = :summ2_r - (:summ1_br+:summ2_br);
            summ4_r = :summ4_old + :summ2_r;



        verb = ' SUMM1---->>'||coalesce(:summ1,0)||'-->'||coalesce(:summ1_r,0)||'   '||
        ' SUMM2---->>'||coalesce(:summ2,0)||'-->'||coalesce(:summ2_r,0)||'   '||
        ' SUMM3---->>'||coalesce(:summ3,0)||'-->'||coalesce(:summ3_r,0)||'   '||
        ' SUMM4---->>'||coalesce(:summ4,0)||'-->'||coalesce(:summ4_r,0)||'   ';

UPDATE OR insert into docs (ID,PARENT_ID,DOC_TYPE,STATUS,AGENT_ID,RGUID,AUDIT_ID,DOCNUM,DOCDATE,vshift,vnum,DEVICE_NUM,SUMM1,SUMM2,SUMM3,SUMM4,SUMM5,SUMM6,SUMM7,SUMM8,COMMENTS) values
                   (:ID,0,13,1,:AGENT_ID,replace(UUID_TO_CHAR( GEN_UUID()),'-',''),:AUDIT_ID,0,:ZDATE,:vshift,0,:DEVICE_NUM,:summ1_r,:summ2_r,:summ3_r,:summ4_r,null,null,null,null,
                   :verb);

UPDATE or INSERT INTO CASH_DOCS (PARENT_ID, DOC_TYPE, STATUS, AGENT_ID,CREATESESSION_ID, RGUID, OWNER, COMMITDATE, SUMMA, VSHIFT, DEVICE_NUM, DOC_ID,SBASE)
               VALUES (0, 1, 1, :AGENT_ID,:AUDIT_ID, replace(UUID_TO_CHAR( GEN_UUID()),'-',''), :AGENT_ID, :ZDATE, :summ1_r, :VSHIFT, :DEVICE_NUM, :id,'repair')
               matching (DOC_ID);



          suspend;
            end

end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,UPDATE ON DOCS TO PROCEDURE PR_REPAIR_Z;
GRANT SELECT ON PARAMS TO PROCEDURE PR_REPAIR_Z;
GRANT SELECT,INSERT,UPDATE ON CASH_DOCS TO PROCEDURE PR_REPAIR_Z;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_REPAIR_Z TO SYSDBA;