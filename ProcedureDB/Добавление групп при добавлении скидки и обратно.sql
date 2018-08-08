--Автоматическое добавление групп при добавленнии скидок и обратно
SET SQL DIALECT 3;


SET TERM ^ ;



CREATE OR ALTER TRIGGER DISCOUNTS_AI0 FOR DISCOUNTS
ACTIVE AFTER INSERT POSITION 0
AS
declare variable group_id dm_id;
begin
  update or insert into dsc_groups (dsc_id, group_id, restrict_mode) values (new.id, null, 1) matching (dsc_id, group_id);
  for select id from groups where grouptable containing 'PARTS' into :group_id do
    update or insert into dsc_groups (dsc_id, group_id, restrict_mode) values (new.id, :group_id, 1) matching (dsc_id, group_id);
end


CREATE OR ALTER TRIGGER GROUPS_BI_DSC_RULES FOR GROUPS
ACTIVE BEFORE INSERT POSITION 0
AS
declare variable d_id dm_id_null;
begin
  for select id from discounts where status=0 into :d_id do
  begin
    update or insert into DSC_GROUPS(DSC_ID,GROUP_ID,RESTRICT_MODE) values (:d_id,new.id,1) matching (DSC_ID,GROUP_ID);
  end
end
^


SET TERM ; ^
