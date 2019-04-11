//-------------------------------------------------------
// TMS выгрузки для партнера Созвездие
//(с) 15.09.2018 Дмитрий Дрыняев Стандарт-Н

//-------------------------------------------------------

 uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,system,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path=extractfiledrive(application.ExeName)+'\Standart-N\sozvezdie\'; //путь для выгрузки файлов
 devide='|'; // Разделитель данных
 dev='';//first 100 можно вписать такое значение и будет уменьшина выборка
 DepartmentCode='2'; // Код профиля Аптеки
 ClientID='987';//Код клиента созвездия
var
 MP,sl,GoodMap,MoveMap,BaseMap,ListMap,FileMap,SQLMap:TStringList;
 t,SQL,f,Filename,tg,nomenclature_codes,s,s1,dateS:String;
 i,j:Intefer;
 q,qwork: TIBQuery;
 date_start,date_end,date_stop:date;
 outFile:TextFile;




         



//--------------------------------------------------------------------------------------------------------------------
//Инициация переменных
procedure InitVar;
Begin

date_start:=StrToDate('01.08.2016');//date-1; //Дата начала выборки
date_end:=StrToDate('02.08.2016');//date;
date_stop:=date+1;//StrToDate('01.12.2018');   //Дата окончания выборки


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
 MoveMap.Add('cashier_id');
 MoveMap.Add('cashier_full_name');
 MoveMap.Add('cashier_tin');
 MoveMap.Add('resale_sign');

  //Поля выгрузки файла остатков
 BaseMap:=TStringList.Create;
 BaseMap.Add('map_pharmacy_id');
 BaseMap.Add('batch_id');
 BaseMap.Add('dates');
 BaseMap.Add('opening_balance');
 BaseMap.Add('closing_balance');
 BaseMap.Add('input_purchasing_price_balance');
 BaseMap.Add('output_purchasing_price_balance');
 BaseMap.Add('input_retail_price_balance');
 BaseMap.Add('output_retail_price_balance');

end;

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

function filename(date_end:String):String;
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

//проверяем наличие файла в директории
Function CheckFiles (FileName1,path,date_end:String):String; // подготовка файла для импорта
var
fn:string;

begin
     fn:=filename(date_end);
     frmManagerXP2.LogIt(fn);


     result:=path+fn+FileName1+'.xml';
     frmManagerXP2.LogIt(result);
     if FileExists(result) then
     begin
       deletefile(result);
     end

 assignFile(outfile,result);
 rewrite(outfile);
end;




Function XMLre(xmltext):String;
begin
xmltext:=StringReplace(xmltext,'&','&amp;',1);
 xmltext:=StringReplace(xmltext,'<','&lt;',1);
 xmltext:=StringReplace(xmltext,'>','&gt;',1);

 xmltext:=StringReplace(xmltext,'''','&apos;',1);
 xmltext:=StringReplace(xmltext,'"','&quot;',1);

 result:=xmltext;
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
//Архивируем файл
Procedure ZIP (f,path,filename:string); //процедура архивирование файла
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
 frmManagerXP2.logit(SQL);
 q2.Active:=true;

    except
      frmManagerXP2.logit('неверный запрос - '+SQL);
      q2.Transaction.Rollback;
    end;
 result:=q2;
end;
//----------------------------------------------------------------------------------------------------------------------------
Function XMLTemplates(types,clientID,DepCode:string;openclose:integer):String;
var
OP_tags,CL_tags:string;
begin
if types='' then
    begin
    OP_tags:='<?xml version="1.0" encoding="WINDOWS-1251"?>'+#13#10+'<map-actions client_id="'+ClientID+'">'+#13#10+'<data_version>4</data_version> ';
    CL_tags:=#13#10+'</map-actions>';
    end;
else
        begin
        if types<>'batch' then types:=types+'s'; else types:=types+'es';
        OP_tags:='<action type="'+types+'" map_pharmacy_ids="'+DepartmentCode+'">'+#13#10+'<'+types+'>'+#13#10;
        CL_tags:='</'+types+'>'+#13#10+'</action>'+#13#10;
        end;
if openclose=0 then result:=OP_tags else result:=CL_tags;

end;

//----------------------------------------------------------------------------------------------------------------------------
Procedure GetStringXML(Map:TstringlistUTF8;S,FileN,tag:String); // выгрузка в XML пока на примере Созвездия
var outstring,header,str,subfooter,subheader,footer:string;
    i,j,r,c:integer;
    ru:extended;
begin
    subheader:='';
    subfooter:='';
    frmManagerXP2.LogIt(s);
    q:=GetSQLResult(S);


    //t:=XMLTemplates(tag,clientID,DepartmentCode,0);
//заполняем файл данными
    while not q.eof do
     begin
         t:='';
         t:=t+Trim(q.fieldbyname('XML').AsString);

         write(outfile,t);
         t:='';
         q.Next;
     end;

     q.Free;
end;

procedure ExecPR (se:string);
begin                        
    qwork:=dm.TempQuery(nil);
    qwork.Active:=false;
    qwork.SQL.Text:=Se;
 //frmManagerXP2.logit(SQL);
    qwork.Active:=true;
    qwork.Transaction.Commit;
end;


begin

sl:= TStringList.Create;
InitVar;

 f:=CheckFiles('_987_bat',path,date_end);
 t:='';

 t:=XMLTemplates('',clientID,DepartmentCode,0);
 write(outfile,t); //sl.Add(t);
     //date_end:=date_stop;
     s:='execute procedure PR_SOZVEZDIE_ACTION_BATCH('''+DepartmentCode+''','''+DatetoStr(date_start)+':00:00:00'','''+DatetoStr(date_start)+':23:59:59'',1)';
     frmManagerXP2.LogIt(s);
     ExecPR(s);

     date_start:=date_start+1;
    DATEs:=':00:00:00';
    s:='execute procedure PR_SOZVEZDIE_ACTION_BATCH('''+DepartmentCode+''','''+DatetoStr(date_start)+':00:00:00'','''+DatetoStr(date_stop-1)+':23:59:59'',0)';
     frmManagerXP2.LogIt(s);
     ExecPR(s);
   s:='select XML from SOZVEZDIE_ACTION_BATCH1';
     t:=XMLTemplates('batch',clientID,DepartmentCode,0);
     write(outfile,t);
     GetStringXML(GoodMap,S,'_987_bat','batch');
     t:=XMLTemplates('batch',clientID,DepartmentCode,1);
     write(outfile,t); //sl.Add(t);

     t:='';

   InitVar;
     //date_end:=date_stop;
     DATEs:=':00:00:00';
     s:='execute procedure PR_SOZVEZDIE_ACTION_MOVE('''+DepartmentCode+''','''+DatetoStr(date_start)+DateS+''','''+DatetoStr(date_start)+':00:01:59'','''+DatetoStr(date_stop)+':23:59:59'',1)';
     frmManagerXP2.LogIt(s);
     ExecPR(s);
     DATEs:=':00:01:00';
      s:='execute procedure PR_SOZVEZDIE_ACTION_MOVE('''+DepartmentCode+''','''+DatetoStr(date_start)+DateS+''','''+DatetoStr(date_stop-1)+':23:59:59'','''+DatetoStr(date_stop-1)+':23:59:59'',0)';
     frmManagerXP2.LogIt(s);
     ExecPR(s);
     t:='';

     s:='SELECT XML FROM SOZVEZDIE_ACTION_MOVE';
     t:=XMLTemplates('distribution',clientID,DepartmentCode,0);
     write(outfile,t);
     GetStringXML(MoveMap,S,'_987_bat','distribution');


     t:=XMLTemplates('distribution',clientID,DepartmentCode,1);
     write(outfile,t);
     //sl.Add(t);
     t:='';
    InitVar;
                                   
    s:='execute procedure PR_SOZVEZDIE_ACTION_remhant('''+DepartmentCode+''','''+DatetoStr(date_start)+':00:00:00'','''+DatetoStr(date_start)+':23:59:59'',1)';
    frmManagerXP2.LogIt(s);
    ExecPR(s);
    t:='' ;
    t:=XMLTemplates('remnant',clientID,DepartmentCode,0);
    write(outfile,t);
  //   s:='SELECT distinct XML FROM SOZVEZDIE_ACTION_REMHANT';
  //   GetStringXML(BaseMap,S,'_987_bat','remnant');
        date_start:=date_start+1;

    s:='execute procedure PR_SOZVEZDIE_ACTION_remhant('''+DepartmentCode+''','''+DatetoStr(date_start)+':00:00:00'','''+DatetoStr(date_start)+':23:59:59'',0)';
     frmManagerXP2.LogIt(s);
     ExecPR(s);
     s:='';
     frmManagerXP2.LogIt(dateTostr(date_start));
     s:='SELECT XML FROM SOZVEZDIE_ACTION_REMHANT';
     GetStringXML(BaseMap,S,'_987_bat','remnant');

   t:=XMLTemplates('remnant',clientID,DepartmentCode,1);
   t:=t+XMLTemplates('',clientID,DepartmentCode,1);
   write(outfile,t);
//   sl.Add(t);

 try
 //сохраняем файл
 // sl.SaveToFile(f);
  sl.Free;
  except
     frmManagerXP2.logit('неверный путь');
  end;
 frmManagerXP2.logit('.xml - выгружен');
 CloseFile(outfile);
//Zip(f,path,filename);
end;
