SET SQL DIALECT 3;



SET TERM ^ ;



CREATE OR ALTER TRIGGER WARES_BU0_MGN_NAME_ASNA FOR WARES
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
declare variable sname dm_text;
declare variable sizg dm_text;
declare variable scountry dm_text;
declare variable barcode dm_text;
begin

 select svalue from vals where id = new.name_id into :sname;
 select svalue from vals where id = new.izg_id into :sizg;
 select svalue from vals where id = new.country_id into :scountry;

 if (:sname is null) then exit;

 if (char_length(new.barcode) <> 13) then barcode = ''; else barcode = new.barcode;

 if ((select GOODS_ID from PR_ASNA_GET_GOODS(new.id)) is null) then
  --доп проверка на уникальность, т.к. при вставке процедура PR_ASNA_GET_GOODS не видит новые данные
  if (not exists(select id from ASNA_GOODS where MGN_NAME = Trim(:sname) and producer = Trim(:sizg) and country=Trim(:scountry) and ean = Trim(:barcode))) then
    insert into ASNA_GOODS(MGN_NAME, producer, country, ean) values (Trim(:sname), Trim(:sizg), Trim(:scountry), Trim(:barcode));




end
^

SET TERM ; ^
