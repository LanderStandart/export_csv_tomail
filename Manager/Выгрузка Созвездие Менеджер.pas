//-------------------------------------------------------
// TMS выгрузки для партнера Созвездие
//(с) 15.09.2018 Дмитрий Дрыняев Стандарт-Н
// для клиента РепроФарм
//-------------------------------------------------------

 uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,system,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path=extractfiledrive(application.ExeName)+'\Standart-N\partner\'; //путь для выгрузки файлов
 devide='|'; // Разделитель данных
var
 MP,Sl,GoodMap,MoveMap,BaseMap,ListMap,FileMap,SQLMap:TStringList;
 t,SQL,f,DepartmentCode,Filename,headerFile,footerFile,headerPart,FooterPart,nomenclature_codes,
 headerMove,FooterMove,headerBase,FooterBase,dev:String;
 i,j:Intefer;
 q: TIBQuery;
 date_start,date_end:date;


//---------------------------------------------
//Формируем SQL запросы для требуемых выгрузок
//---------------------------------------------

//--------------------------------------------------------------------------------------------------------------------
Function Val(Str1:String);    //проверка на число если значение число возвращает =0 если строка то =1
var t1:Extended;
begin
try
t1:=StrtoFloat(Str1);
result:=0;
except
result:=1;
end;
end;


Function GoodSQL:string; //SQL выборка товаров
begin
Result:='select '+dev+'p.id as map_batch_id,
'''+DepartmentCode+''' as map_pharmacy_id,
(select p.param_value  from params p where p.param_id=''ORG_NAME_SHORT'')as map_pharmacy_name,
'''' as nomenclature_id,
vname.svalue as map_nomenclature_name,
'''' as map_product_code,
'''' as map_product_name,
'''' as producer_id,
w.orig_izg_id as map_producer_code,
vorig_izg.svalue as map_producer_name,
'''' as producer_country_id,
w.country_id as map_producer_country_code,
vcountry.svalue as map_producer_country_name,
d.agent_id as map_supplier_code,
a.inn as map_supplier_tin,
a.caption as supplier_name,
extract(year from d.docdate)||''-''||iif(extract(month from d.docdate)>10,extract(month from d.docdate),''0''||extract(month from d.docdate))||''-''
||iif(extract(day from d.docdate)>10,extract(day from d.docdate),''0''||extract(day from d.docdate))||''T00:00:00'' as batch_doc_date,
d.docnum as batch_doc_number,
cast (p.price_o as numeric(10,2)) as purchase_price_nds,
cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)) as purchase_nds,
cast (p.price as numeric(10,2)) as retail_price_nds,
cast (p.nds as numeric(9,0)) as retail_nds,
w.barcode as barcode,
''0'' as sign_comission,
w.name_id as nomenclature_codes

from parts p
 join WARES w on p.ware_id=w.id
  inner join doc_detail dd on dd.part_id = p.id
  inner join docs d on d.id = dd.doc_id
  inner join agents a on a.id=d.agent_id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id';
end;

Function MoveSQL:string; //SQL выборка Движения
begin
result:='select  '+dev+'
           '''+DepartmentCode+''' as map_pharmacy_id,
           d.id as distribution_id,
           p.id as batch_id,
           extract(year from d.docdate)||''-''||iif(extract(month from d.docdate)>10,extract(month from d.docdate),''0''||extract(month from d.docdate))||''-''
           ||iif(extract(day from d.docdate)>10,extract(day from d.docdate),''0''||extract(day from d.docdate))||''T00:00:00'' as  doc_date,
           case d.doc_type
            when 1 then 3
            when 2 then 6
            when 3 then 2
            when 4 then 5
            when 5 then 8
            when 6 then 7
            when 17 then 8
            when 10 then 8
            when 9 then 4
            when 11 then 1
            when 20 then 9
           end as doc_type,

           iif(d.doc_type=3,(select d1.docnum from docs d1 where cast(d1.docdate as date)=d.datez and d1.vshift=d.vshift and d1.doc_type=13),
            left(d.docnum,iif(position('' '',d.docnum)=0,char_length(d.docnum), position('' '',d.docnum))))as doc_number,
           iif(d.doc_type=3,d.device_num,'''')as pos_number,
           iif(d.doc_type=3,d.docnum,'''')as check_number,
           iif(d.doc_type=3,d.docnum,'''')as check_unique_number,
           abs(dd.quant) as quantity,
         cast(abs(dd.summa_o)as numeric(10,2)) as purchase_sum_nds,
         cast(abs(dd.summa)+abs(dd.sum_dsc) as numeric(10,2)) as retail_sum_nds,
         cast(abs(dd.sum_dsc) as numeric(9,2)) as discount_sum
            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (1,11,10,17,2,3,4,5,6,9,20)

  left join parts p on dd.part_id=p.id

  where  dd.doc_commitdate between '''+DateToStr(date_start)+''' and '''+DateToSTR(date_end)+''' order by d.docdate';
end;

Function BaseSQL:string; //SQL выборка остатков
begin
result:='select '+dev+'
'''+DepartmentCode+''' as map_pharmacy_id,
dd.part_id as batch_id,
extract(year from current_date)||''-''||iif(extract(month from current_date)>10,extract(month from current_date),''0''||extract(month from current_date))||''-''
||iif(extract(day from current_date)>10,extract(day from current_date),''0''||extract(day from current_date))||''T00:00:00'' as "date",
(select cast(sum(dd1.quant) as numeric(9,4)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)as opening_balance,
cast(sum(dd.quant)as numeric(9,4)) as closing_balance,
cast(sum(abs(dd.summa_o))as numeric(9,2))as output_purchasing_price_balance,
(select cast(sum(dd1.summa_o) as numeric(9,2)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)as input_purchasing_price_balance,
cast(sum(abs(dd.summa))as numeric(9,2))as output_retail_price_balance,
(select cast(sum(dd1.summa) as numeric(9,2)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)as input_retail_price_balance


 from doc_detail dd
join parts p on p.id=dd.part_id


where dd.doc_commitdate<='''+DateToStr(date_end)+'''
group by batch_id,"date"
having abs(sum(dd.quant))>0.001
';
end;


function filename:String;
var
t,y,m,d,dateF:String;
begin
 dateF:=DatetoStr(date_end);
 frmManagerXP2.LogIt(dateF);
 d:=Copy(dateF,0,2);
 m:=Copy(dateF,4,2);
 y:=Copy(dateF,7,4);

 t:=StringReplace(time,':','',1);
 if Length(t)<6 then t:='0'+t;
 result:=y+m+d+t;
end;


//--------------------------------------------------------------------------------------------------------------------
//Инициация переменных
procedure InitVar;
Begin
date_start:=StrToDate('01.01.2018');//date-1; //Дата начала выборки
date_end:=StrToDate('10.06.2018');//date;     //Дата окончания выборки
DepartmentCode:='1'; // Код профиля Аптеки

 //Перечень SQL  выгрузки
 SQLMap:=TStringList.Create;
 SQLMap.Add(GoodSQL);
 SQLMap.Add(MoveSQL);
 SQLMap.Add(BaseSQL);

 //Поля выгрузки файла справочник товаров  goods.csv
 GoodMap:=TStringList.Create;
 GoodMap.Add('map_batch_id');
 GoodMap.Add('map_pharmacy_id');
 GoodMap.Add('map_pharmacy_name');
 GoodMap.Add('nomenclature_id');
 GoodMap.Add('map_nomenclature_name');
 GoodMap.Add('map_product_code');
 GoodMap.Add('map_product_name');
 GoodMap.Add('producer_id');
 GoodMap.Add('map_producer_code');
 GoodMap.Add('map_producer_name');
 GoodMap.Add('producer_country_id');
 GoodMap.Add('map_producer_country_code');
 GoodMap.Add('map_producer_country_name');
 GoodMap.Add('map_supplier_code');
 GoodMap.Add('map_supplier_tin');
 GoodMap.Add('supplier_name');
 GoodMap.Add('batch_doc_date');
 GoodMap.Add('batch_doc_number');
 GoodMap.Add('purchase_price_nds');
 GoodMap.Add('purchase_nds');
 GoodMap.Add('retail_price_nds');
 GoodMap.Add('retail_nds');
 GoodMap.Add('barcode');
 GoodMap.Add('sign_comission');
 GoodMap.Add('nomenclature_codes');

 //Поля выгрузки файла справочник товаров  goods.csv
 MoveMap:=TStringList.Create;
 MoveMap.Add('map_pharmacy_id');
 MoveMap.Add('distribution_id');
 MoveMap.Add('batch_id');
 MoveMap.Add('doc_date');
 MoveMap.Add('doc_type');
 MoveMap.Add('doc_number');
 MoveMap.Add('pos_number');
 MoveMap.Add('check_number');
 MoveMap.Add('check_unique_number');
 MoveMap.Add('quantity');
 MoveMap.Add('purchase_sum_nds');
 MoveMap.Add('retail_sum_nds');
 MoveMap.Add('discount_sum');

  //Поля выгрузки файла остатков
 BaseMap:=TStringList.Create;
 BaseMap.Add('map_pharmacy_id');
 BaseMap.Add('batch_id');
 BaseMap.Add('date');
 BaseMap.Add('opening_balance');
 BaseMap.Add('closing_balance');
 BaseMap.Add('input_purchasing_price_balance');
 BaseMap.Add('output_purchasing_price_balance');
  BaseMap.Add('input_retail_price_balance');
 BaseMap.Add('output_retail_price_balance');


end;
 //----------------------------------------------------------------------------------------------------------------------------
function FormatDateXML (Datexml:String):String; // Формируем название файла =текущее дата время
var
t,y,m,d:String;
begin
 d:=Copy(datexml,0,2);
 m:=Copy(datexml,4,2);
 y:=Copy(datexml,7,4);
 if Length(m)=1 then m:='0'+m;
 result:=y+'-'+m+'-'+d;
end;



//----------------------------------------------------------------------------------------------------------------------------
//проверяем наличие файла в директории
Function CheckFiles (FileName1:String):String; // подготовка файла для импорта
var
fn:string
begin
     fn:=filename();
     frmManagerXP2.LogIt(fn);
     sl:= TStringList.Create;

     result:=path+fn+FileName1+'.xml';
     frmManagerXP2.LogIt(result);
     if FileExists(result) then
     begin
       deletefile(result);
     end

end;



//----------------------------------------------------------------------------------------------------------------------------
//Архивируем файл
Procedure ZIP (f:string); //процедура архивирование файла
var
fz:string;
begin
fz:=' a -tzip -sdel -r0 -i!*.csv '+path+filename+'.zip '+f;
frmManagerXP2.logit(fz);
shellExecuteA(0,'open','C:\Program Files\7-Zip\7z.exe',fz,'',5);

end;
//----------------------------------------------------------------------------------------------------------------------------

//получаем данные из запроса
Function GetSQLResult(SQL:String):TIBQuery; //процедура возвращает результат переданного запроса
var
q2:TIBQuery;
begin
try
 q2:=dm.TempQuery(nil);
 q2.Active:=false;
 q2.SQL.Text:=SQL;
 //frmManagerXP2.logit(SQL);
 q2.Active:=true;
    except
      frmManagerXP2.logit('неверный запрос');
      q2.Transaction.Rollback;
    end;
 result:=q2;
end;
//----------------------------------------------------------------------------------------------------------------------------

Function XMLre(xmltext):String;
begin
 xmltext:=StringReplace(xmltext,'<','&lt;',1);
 xmltext:=StringReplace(xmltext,'>','&gt;',1);
 xmltext:=StringReplace(xmltext,'&','&amp;',1);
 xmltext:=StringReplace(xmltext,'''','&apos;',1);
 xmltext:=StringReplace(xmltext,'"','&quot;',1);
 result:=xmltext;
end;



Procedure XMLTemplate;
begin
headerFile:='<?xml version="1.0" encoding="WINDOWS-1251"?>
<map-actions client_id="987">
<data_version>4</data_version> ';

footerFile:='</map-actions>';

//headerPart:='<action type="batches" datestart="'+FormatDateXML(DateToStr(date_start))+'T00:00:00" dateend="'+FormatDateXML(DateToStr(date_start))+
//'T00:00:00" map_pharmacy_ids="'+DepartmentCode+'">
//<batches>';

headerPart:='<action type="batches" map_pharmacy_ids="'+DepartmentCode+'">
<batches>';

FooterPart:='</batches>
</action>';

//headerMove:='<action type="distributions" datestart="'+FormatDateXML(DateToStr(date_start))+
//'T00:00:00" dateend="'+FormatDateXML(DateToStr(date_start))+'T00:00:00" map_pharmacy_ids="'+DepartmentCode+'">
//<distributions>';
//FooterMove:='</distributions>
//</action>';

headerMove:='<action type="distributions"  map_pharmacy_ids="'+DepartmentCode+'">
<distributions>';
FooterMove:='</distributions>
</action>';

//headerBase:='<action type="remnants" datestart="'+FormatDateXML(DateToStr(date_start))+
//'T00:00:00" dateend="'+FormatDateXML(DateToStr(date_start))+'T00:00:00" map_pharmacy_ids="'+DepartmentCode+'">
//<remnants>
//';
headerBase:='<action type="remnants" map_pharmacy_ids="'+DepartmentCode+'">
<remnants>
';

FooterBase:='
</remnants>
</action>';




end;

//----------------------------------------------------------------------------------------------------------------------------
Procedure GetStringXML(Map:TstringlistUTF8;S,FileN,footer,tag:String); // выгрузка в XML пока на примере Созвездия
var outstring,header,str,subfooter,subheader:string;
i,j,r,c:integer;
ru:extended;
begin
 subheader:='';
 subfooter:='';
 q:=GetSQLResult(S);

//заполняем файл данными
while not q.eof do
 begin
  t:=t+'<'+tag+'>';
     for i := 0 to Map.Count-1 do
         begin
             subheader:='';
             subfooter:='';
            str:=q.fieldbyname(Map.Strings[i]).AsString;
            if Map.Strings[i]='nomenclature_codes' then begin subheader := '<code owner="map">';subfooter:='</code>';end;
            if val(str)=0 then str:=StringReplace(str,',','.',1);//если значение дробное число меняем "." на ","
            t:=t+'<'+Map.Strings[i]+'>'+subheader+XMLre(str)+subfooter+'</'+Map.Strings[i]+'>'+#13#10;

            // frmManagerXP2.LogIt(Map.Strings[i]);

         end;
 t:=t+'</'+tag+'>';
 sl.Add(t);
 frmManagerXP2.LogIt(t);
 t:='';
 q.Next;
 end;
t:=footerFile;
sl.Add(t);


end;

begin
 dev:='first 1000 ';
InitVar;
XMLTemplate;
 f:=CheckFiles('_client_id_bat');
 t:='';
 t:=headerFile;
 t:=t+headerPart;
 GetStringXML(GoodMap,SQLMap.Strings[0],'_client_id_bat',footerpart,'batch');
 t:='';
 t:=headerMove;
 GetStringXML(MoveMap,SQLMap.Strings[1],'_client_id_bat',footermove,'distribution');
 t:='';
 t:=headerBase;
 GetStringXML(BaseMap,SQLMap.Strings[2],'_client_id_bat',footerBase,'remnant');

 try
 //сохраняем файл
  sl.SaveToFile(f);
  //sl.Free;
  except
     frmManagerXP2.logit('неверный путь');
  end;
 frmManagerXP2.logit('.xml - выгружен');

//Zip(path);
end;