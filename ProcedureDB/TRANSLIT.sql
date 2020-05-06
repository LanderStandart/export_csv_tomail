SET TERM ^ ;

create or alter procedure TRANSLIT (
    STR DM_TEXT)
returns (
    STR_LAT DM_TEXT)
as
declare variable LAT1 DM_TEXT;
declare variable RUS DM_TEXT;
declare variable LAT2 DM_TEXT;
declare variable LAT3 DM_TEXT;
declare variable I integer;
declare variable POS integer;
declare variable CH varchar(2);
begin
rus =  'абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';
lat1 = 'abvgdejzzijklmnoprstufkccss"y''ejjABVGDEJZZIJKLMNOPRSTUFKCCSS"Y''EJJ';
lat2 = '      oh  j           h hhh   hua      OH  J           H HHH   HUA';
lat3 = '                          h                                H      ';

i = 1;
str_lat = '';

while (i <= char_length(:str)) do
begin
    ch = substring(:str from i for 1);
    pos = position(ch in rus);

    if (pos > 0) then
    begin
        if (ASCII_CHAR(upper(ascii_val(ch))) = ASCII_CHAR(ascii_val(ch))) then
            str_lat = str_lat || upper(substring(lat1 from pos for 1)) || trim(substring(lat2 from pos for 1)) || trim(substring(lat3 from pos for 1));
        else
            str_lat = str_lat || substring(lat1 from pos for 1) || trim(substring(lat2 from pos for 1)) || trim(substring(lat3 from pos for 1));
    end
    else
        str_lat = str_lat || ch;
    i = i + 1;
end
  suspend;
end^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE TRANSLIT TO SYSDBA;