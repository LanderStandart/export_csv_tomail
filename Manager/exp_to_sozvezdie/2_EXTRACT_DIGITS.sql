SET TERM ^ ;

create or alter procedure EXTRACT_DIGITS (
    STRING varchar(32))
returns (
    DIGITS varchar(32))
as
declare variable CH char(1);
declare variable L integer;
declare variable I integer;
begin
   digits = '';
   L = CHAR_LENGTH(string);
   I = 1;
   while (I <= L) do begin
      CH = substring(STRING from I for 1);
      if (CH between '0' and '9') then
         DIGITS = DIGITS || CH;
      I = I + 1;
   end
  suspend;
end^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE EXTRACT_DIGITS TO SYSDBA;