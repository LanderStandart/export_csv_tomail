SET TERM ^ ;

create or alter procedure PR_XML_GOOD (
    S DM_TEXT)
returns (
    XML DM_TEXT)
as
begin
xml = replace(s,'&','&amp;');
xml = replace(xml, '<','&lt;');
xml = replace(xml, '>','&gt;');
xml = replace(xml, '''','&apos;');
xml = replace(xml, '"','&quot;');
  suspend;
end^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_XML_GOOD TO SYSDBA;