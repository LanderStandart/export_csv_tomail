uses
  Graphics, Controls, Forms, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, ibquery, DB, ChequeList, FR,
  ScriptRes, Barcode,ZKassa, StrUtils, Windows, Classes,
  IBDataBase, SysUtils;
var s,sbar: string;
  i,j:integer;
begin
sbar:='';
//Проверяем длину ШК
if( StrLen(barcode.text)<12) then
  begin
  i:=StrLen(barcode.text);
//Меньше 12 вероятно это дисконтная карта добиваем до полного нулями
   for j:=0 to 11-i do
      sbar:=sbar+'0';
  sbar:=sbar+barcode.text;
//Добавляем 13 ноль и применяем катру
  if ((StrLen(sbar) = 12) and (copy(sbar,1,1)='0')) Then
  begin
   s:='0'+sbar;
   Barcode.ApplyDiscount(s, 0);

   ScriptRes.Code := 1;
  end;
  end;
end;
