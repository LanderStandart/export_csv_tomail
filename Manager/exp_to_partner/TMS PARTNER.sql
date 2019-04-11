uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,unDM,sysUtils;
const
 //Пути выгрузки по профилям
 path='\Standart-N\partner\';
 partner_id='15375';

 //Доступ профилей на ФТП
 login='partner15375';
 pass='vz4p-YQSQA-5FSV-gev8r-z5qc';
 url='partner.melzdrav.ru';



var q,q1,q3,qWork: TIBQuery;
    sl,sl1: TStringList;
    SQL,t,t1,f,f1,org_name,org_inn,codeClient,path1: String;
    date_start,date_end:date;
    today,maxdate,mindate:Tdatetime;
    fsLog:  TFileStream;

 procedure ExecPR (se:string);
begin
    qwork:=dm.TempQuery(nil);
    qwork.Active:=false;
    qwork.SQL.Text:=Se;
 //frmManagerXP2.logit(SQL);
    qwork.Active:=true;
    qwork.Transaction.Commit;
end;



function filename:String;
var
t,y,m,d:String;
begin
 d:=Copy(DatetoStr(maxdate),0,2);
 m:=Copy(DatetoStr(maxdate),4,2);
 y:=Copy(Datetostr(maxdate),7,4);
 t:=StringReplace(time,':','',1);
 if Length(t)<6 then t:='0'+t;
 result:=y+m+d+t;
end;

//Архивируем файл
Procedure ZIP (f:string);
var
fz:string;
begin
fz:=' a -tzip -sdel '+f+'.zip '+ f ;
//LogIt(fz);
shellExecuteA(0,'open','C:\Program Files\7-Zip\7z.exe',fz,'',5);

end;

//Посылаем по ФТП
Procedure FTP (f,login,pass,path:string);
const
files=extractfiledrive(application.ExeName)+path;

begin
  t:='-F -DD -u '+login+' -p '+pass+' '+url+' \ '+files+f;
  //frmSpacePro.logit(t);
     ShellExecuteA(0, 'open',files+'ncftpput.exe', t, '', 5);


end;



//проверяем наличие файла в директории
Function CheckFiles (codeClient,FileName1,pathz:String):String;
var
fn:string
begin
     fn:=Filename;
     sl:= TStringList.Create;
     sl1:= TStringList.Create;
     result:=extractfiledrive(application.ExeName)+pathz+codeClient+'$'+fn+FileName1;
     if FileExists(result) then
     begin
       deletefile(result);
     end

end;

//получаем данные из запроса
Function GetSQLResult(SQL:String):TIBQuery;
var
q2:TIBQuery;
begin
try
 //LogIt(SQL);
 q2:=dm.TempQuery(nil);
 q2.Active:=false;
 q2.SQL.Text:=SQL;
 q2.Active:=true;
    except
      frmManagerXP2.logit('неверный запрос');
      q2.Transaction.Rollback;
    end;
 result:=q2;
end;

Procedure ExtractBase(partner_id:integer;path:String;maxdate:Datetime); //Выгрузка остатков
 Begin
   SQL:='select * from partner_load where doc_commitdate ='''+DateToStr(maxdate)+'''';

    frmSpacePro.logit(SQL);
    q:=GetSQLResult(SQL);

   f:=CheckFiles(InttoStr(partner_id),'.ost',path);
   // logit(f);
    frmManagerXP2.logit('Выгружаем остатки');

    {  t:='Тип Данных по строке;Номер Документа из программы участника;Дата создания или изменения строки документа из программы участника'+
      ';Поставщик;ИНН Поставщика;Номер ККМ;Номер чека из программы участника;ФИО Кассира;Тип скидки по строке чека;'+
      'Cумма скидки по строке чека;Закупочная сумма по строке чека;Розничная сумма по строке чека;Признак использования модуля "Приоритетная рекомендация" по строке чека;'+
      'Код Товара по справочнику товаров;Наименование Товара по справочнику товаров;Код производителя по справочнику производителей;'+
      'Наименование Производителя по справочнику производителей;Название страны производителя;Штрих код завода изготовителя;'
      +'Цена за единицу закупочная в рублях, округление до целых копеек;Цена за единицу розничная в рублях,округление до целых копеек;Количество;Серия товара;Срок годности товара;'+
      'Уникальный код партии из системы учета товародвижения,в формате штрих кода EAN-13;';
      sl.Add(t);}
      while not q.eof do
      begin
         t:=
          '0;'+                                                            //1
         q.fieldbyname('Docnum').AsString+';'                             //2
         +StringReplace(DateToStr(maxdate),'.','',1) +';'  //3
         +q.fieldbyname('docagent').AsString+';'                          //4
         +q.fieldbyname('INN').AsString+';'                               //5
         +';'                                                             //6
         +';'                                                             //7
         +';'                                                             //8
         +';'                                                             //9
          +';' +';'                                                       //10-11
         +';'                                                             //12
         +';'                                                             //13
         +q.fieldbyname('PART_ID').AsString+';'                           //14
         +StringReplace(q.fieldbyname('SNAME').AsString,';',' ',1)+';'    //15
         +q.fieldbyname('IZG_ID').AsString+';'                            //16
         +StringReplace(q.fieldbyname('SIZG').AsString,'"','',1)+';'                              //17
         +q.fieldbyname('scountry').AsString+';'                          //18
          +q.fieldbyname('bcode_izg').AsString+';'
         +q.fieldbyname('price_o').AsString+';'
         +q.fieldbyname('price').AsString+';'
         +q.fieldbyname('quant').AsString+';'
         +q.fieldbyname('seria').AsString+';'
         +StringReplace(q.fieldbyname('godendo_date').AsString,'.','',1)+';'
         +q.fieldbyname('barcode').AsString+';';
         sl.Add(t);
       // frmSpacePro.logit(t);
         q.next;
      end;

      try
      sl.SaveToFile(f);
   //   Logit('SavetoFile-'+f);
      sl.Free;
       sleep(1000);
      zip(f);
      except
     frmManagerXP2.logit('неверный путь');
    end;

  //  frmSpacePro.logit('Остатки выгружены');
end;

Procedure ExtractMove(partner_id:integer;pathe:string;startdate:DateTime);//Выгрузка движения
Begin
 SQL:='select * from partner_load_move where doc_commitdate between '''+DateToStr(startdate)+''' and '''+DateToStr(incday(startdate,1))+'''';
 frmSpacePro.logit(SQL);
q:=GetSQLResult(SQL);
f:=CheckFiles(InttoStr(partner_id),'.mov',pathe);
  // logit(f);
   frmManagerXP2.logit('Выгружаем Движение');

     {t:='Тип Данных по строке;Номер Документа из программы участника;Дата создания или изменения строки документа из программы участника'+
      ';Поставщик;ИНН Поставщика;Номер ККМ;Номер чека из программы участника;ФИО Кассира;Тип скидки по строке чека;'+
      'Cумма скидки по строке чека;Закупочная сумма по строке чека;Розничная сумма по строке чека;Признак использования модуля "Приоритетная рекомендация" по строке чека;'+
      'Код Товара по справочнику товаров;Наименование Товара по справочнику товаров;Код производителя по справочнику производителей;'+
      'Наименование Производителя по справочнику производителей;Название страны производителя;Штрих код завода изготовителя;'
      +'Цена за единицу закупочная в рублях, округление до целых копеек;Цена за единицу розничная в рублях,округление до целых копеек;Количество;Серия товара;Срок годности товара;'+
      'Уникальный код партии из системы учета товародвижения,в формате штрих кода EAN-13;';
      sl.Add(t);
      }

      while not q.eof do
      begin

         t:=
      +q.fieldbyname('d_type').AsString+';'
         +q.fieldbyname('docnum').AsString+';'
         +StringReplace(DateToStr(maxdate),'.','',1) +';'  //3
         +q.fieldbyname('Supplier').AsString+';'
         +q.fieldbyname('Supplier_INN').AsString+';'
         +q.fieldbyname('device_num').AsString+';'
         +q.fieldbyname('N_Chek').AsString+';'
         +q.fieldbyname('FIO_Chek').AsString+';'
         +q.fieldbyname('disk_T').AsString+';'
         +q.fieldbyname('Disk_Sum').AsString+';'
         +q.fieldbyname('Sum_Zak').AsString+';'
         +q.fieldbyname('Sum_Rozn').AsString+';'
         +q.fieldbyname('pp_teg').AsString+';'
         +q.fieldbyname('Drug_code').AsString+';'
         +q.fieldbyname('Drug_name').AsString+';'
         +q.fieldbyname('izg_id').AsString+';'
          +StringReplace(q.fieldbyname('Drug_name').AsString,';',' ',1)+';'
        //
         +q.fieldbyname('Drug_Producer_country').AsString+';'
          +q.fieldbyname('bcodeizg').AsString+';'
         +q.fieldbyname('Cena_Zak').AsString+';'
         +q.fieldbyname('Cena_Rozn').AsString+';'
         +q.fieldbyname('quant').AsString+';'
         +q.fieldbyname('seria').AsString+';'
         +StringReplace(q.fieldbyname('godendo_date').AsString,'.','',1) +';'
         +q.fieldbyname('barcode').AsString+';'
         ;
         sl.Add(t);
         q.next;
      end;


     try
      sl.SaveToFile(f);
     //  Logit('SavetoFile-'+f);
      sleep(1000);
      Zip(f);


      except
     frmManagerXP2.logit('неверный путь');
    end;
                    

End;


begin


  date_start:=StrToDate('09.09.2018');//DateToStr(date-1);  //
  date_end:=strtoDate('11.09.2018');//DatetoStr(date);//
  SQL:='select cast( coalesce(max(plm.doc_commitdate),''30.12.1999'')as dm_datetime) as maxdate from partner_load plm';
  q:=GetSQLResult(SQL);
  maxdate:=q.fieldbyname('maxdate').AsDateTime;
  if (maxdate='30.12.1999') then maxdate:=date_start;
  frmManagerXP2.LogIt(maxdate);
  q.Transaction.Commit;

SQL:='execute procedure pr_load_partner('''+DateToStr(maxdate)+''','''+DateToStr(date_end)+''') ';
frmManagerXP2.LogIt(SQL);
ExecPR(SQL);
SQL:='execute procedure pr_load_move_partner('''+DateToStr(date_start)+''','''+DateToStr(date_end)+''')';
ExecPR(SQL);
frmManagerXP2.LogIt(SQL);


  try
  //if not fileexists(extractfilepath(application.ExeName)+'Partner.log') then
  //TFileStream.Create(extractfilepath(application.ExeName)+'Partner.log',fmCreate).Free;
  // fsLog:=TFileStream.Create(extractfilepath(application.ExeName)+'partner.txt',fmOpenReadWrite);
 //  logit(DatetoStr(date_start));
 // logit('Начали -'+TimetoStr( time));

 frmManagerXp2.LogIt(maxdate);
 //Выгружаем остатки по точкам
 while (maxdate<>date_end) do
 begin
  ExtractBase(partner_id,path,maxdate);
  ExtractMove(partner_id,path,maxdate);
  frmManagerXp2.LogIt(maxdate);
  maxdate:=IncDay(maxdate,1);
 end;
 //выгрузка движение



  //    InitVar;
  //     while date_end<>date do
    //      begin

  //
    //           date_end:=date_end+1;
    //           date_start:=date_start+1;
     //     end;


 //ftp('*.zip',login,pass,path);




  //  logit('Готово -'+TimetoStr( time));
    q.Free;

   finally
    // fsLog.Free;
   end;
end;