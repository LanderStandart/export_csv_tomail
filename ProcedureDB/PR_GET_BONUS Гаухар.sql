SET TERM ^ ;

create or alter procedure PR_GET_BONUS (
    DOC_ID DM_ID,
    PART_ID DM_ID)
returns (
    X DM_ID,
    BONUS DM_DOUBLE)
as
declare variable GROUPID DM_ID;
declare variable FIVE DM_ID;
declare variable FOUR DM_ID;
declare variable THREE DM_ID;
declare variable TWO DM_ID;
declare variable STATUS DM_STATUS;
declare variable KOEF DM_DOUBLE;
begin
   koef = 0;
   two = 10035;
   three =10034;
   four = 0;
   five = 10032;
   status =0;
 --2%
  select gd.group_id from doc_detail dd
  join parts p on p.id=dd.part_id
  join wares w on w.id=p.ware_id
  join group_detail gd on gd.group_id in (:two, :three,:five) and gd.grouptable_id=w.name_id  and gd.grouptable='PARTS.NAME_ID'
  where dd.doc_id= :DOC_ID and dd.part_id =:part_id into :groupid;


  if (:groupid=two) then  begin koef=0.02; x = :koef*100;status = 1; end
  if (:groupid=three) then  begin koef=0.03; x = :koef*100;status = 1; end
  if (:groupid=four) then  begin koef=0.04; x = :koef*100;status = 1; end
  if (:groupid=five) then  begin koef=0.05; x = :koef*100;status = 1; end


  if (:status>0) then
  begin
  select abs(dd.summa*:koef) as bonus from doc_detail dd
  join parts p on p.id=dd.part_id
  join wares w on w.id=p.ware_id
  join group_detail gd on gd.group_id=:groupID and gd.grouptable_id=w.name_id  and gd.grouptable='PARTS.NAME_ID'
  where dd.doc_id= :DOC_ID and dd.part_id =:PART_ID into :bonus;
  end

suspend;

end^

SET TERM ; ^

/* Following GRANT statements are generated automatically */

GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_GET_BONUS;
GRANT SELECT ON PARTS TO PROCEDURE PR_GET_BONUS;
GRANT SELECT ON WARES TO PROCEDURE PR_GET_BONUS;
GRANT SELECT ON GROUP_DETAIL TO PROCEDURE PR_GET_BONUS;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_GET_BONUS TO SYSDBA;