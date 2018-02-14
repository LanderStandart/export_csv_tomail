SET TERM ^ ;

create or alter procedure PR_GET_BARCODE_FOR_TSD (
    SEPARATOR varchar(1))
returns (
    BARCODE varchar(250),
    SNAME varchar(1024),
    PRICE double precision,
    PART_ID bigint)
as
declare variable STRING DM_TEXT;
begin
  Separator = coalesce(Separator, ',');
  if (Separator = '') then Separator = ',';
  BARCODE = '';
--  for select bcode_izg, sname, price, part_id from warebase into :String, :sname, :price, :part_id do
 for select barcode, sname, 0, 0 from wares into :String, :sname, :price, :part_id do
  begin
    while (String != '') do
    begin
      if (substring(String from 1 for 1) != Separator) then
        BARCODE = BARCODE || substring(String from 1 for 1);
      else
      begin
        if (BARCODE != '') then suspend;
        BARCODE = '';
      end
      String = substring(String from 2);
    end
    if (BARCODE != '') then
    begin
     suspend;
     BARCODE = '';
    end
  end
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT ON WARES TO PROCEDURE PR_GET_BARCODE_FOR_TSD;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_GET_BARCODE_FOR_TSD TO SYSDBA;