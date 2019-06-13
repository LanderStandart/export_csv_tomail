SET TERM ^ ;

create or alter procedure PR_JSON_GOOD (
    S DM_TEXT)
returns (
    JSON DM_TEXT)
as
begin
  json=replace(s,'"','\"');
  suspend;
end^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_JSON_GOOD TO SYSDBA;