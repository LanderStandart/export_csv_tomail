uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path='\Standart-N\partner\';


var q,q1: TIBQuery;
    sl,sl1: TStringList;
    SQL,t,t1,f,f1,org_name,org_inn,codeClient: String;
    date_start,date_end:date;
    today:Tdatetime;




function filename:String;
var
t,y,m,d:String;
begin
 d:=Copy(DatetoStr(date),0,2);                                   
 m:=Copy(DatetoStr(date),4,2);
 y:=Copy(Datetostr(date),7,4);
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
shellExecuteA(0,'open','C:\Program Files (x86)\7-Zip\7z.exe',fz,'',5);

end;

//Посылаем по ФТП
Procedure FTP (f:string);
const
login='partner12222';
pass='TRLKJ-vesoy-iqhqy-%5yzj';
url='partner.melzdrav.ru';
files=extractfiledrive(application.ExeName)+path;

begin
  t:='-F -DD -u '+login+' -p '+pass+' '+url+' \ '+files+f;
  frmSpacePro.logit(t);
     ShellExecuteA(0, 'open','C:\Standart-N\partner\ncftpput.exe', t, '', 5);


end;



//проверяем наличие файла в директории
Function CheckFiles (codeClient,FileName1:String):String;
var
fn:string
begin
     fn:=Filename;
     sl:= TStringList.Create;
     sl1:= TStringList.Create;
     result:=extractfiledrive(application.ExeName)+path+codeClient+'$'+fn+FileName1;
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
 q2:=dm.TempQuery(nil);
 q2.Active:=false;
 q2.SQL.Text:=SQL;
 q2.Active:=true;
    except
      frmSpacePro.logit('неверный запрос');
      q2.Transaction.Rollback;
    end;
 result:=q2;
end;

Procedure ExtractBase(i:integer); //Выгрузка остатков
 Begin
    SQL:='select
               left(w.docnum,iif(position('' '',w.docnum)=0,char_length(w.docnum), position('' '',w.docnum)))as docnum,
               cast(w.docdate as date)as docdate,w.docagent,
    (select a.inn from  agents a inner join docs d on d.agent_id=a.id and d.g$profile_id=w.g$profile_id and d.id=w.doc_id
            and a.g$profile_id = w.g$profile_id)as INN,
            w.part_id,w.izg_id,w.sizg,w.scountry,w.sname,w.bcode_izg,w.quant,w.price_o,w.price,
                w.sprofile,cast(godendo as dm_date) as godendo_date,w.seria,w.barcode,g.partner_id
          from vw_warebase w
           inner join g$profiles g on g.id =w.g$profile_id
           where quant > 0.01 and w.g$profile_id ='+InttoStr(i)+'
               group by w.sname, w.part_id, w.quant, w.price_o,w.price,w.bcode_izg,
                        w.izg_id, w.sizg, w.scountry, w.g$profile_id,INN,w.doc_id,w.sprofile,
                        docnum,docdate,w.docagent,godendo_date,w.seria,w.barcode,g.partner_id';
 //    frmSpacePro.logit(SQL);
    q:=GetSQLResult(SQL);

   f:=CheckFiles(q.fieldbyname('partner_id').AsString,'.ost');
    frmSpacePro.logit(f);
    frmSpacePro.logit('Выгружаем остатки');

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
         '0;'+
         q.fieldbyname('Docnum').AsString+';'
         +StringReplace(q.fieldbyname('docdate').AsString,'.','',1) +';'
         +q.fieldbyname('docagent').AsString+';'
         +q.fieldbyname('INN').AsString+';'
         +';'
         +';'
         +';'
         +';'
          +';' +';'
         +';'
         +';'
         +q.fieldbyname('PART_ID').AsString+';'
         +q.fieldbyname('SNAME').AsString+';'
         +q.fieldbyname('IZG_ID').AsString+';'
         +q.fieldbyname('SIZG').AsString+';'
         +q.fieldbyname('scountry').AsString+';'
         +q.fieldbyname('bcode_izg').AsString+';'
         +FloatToStr(FormatFloat('0.##',q.fieldbyname('price_o').AsFloat))+';'
         +FloatToStr(FormatFloat('0.##',q.fieldbyname('price').AsFloat))+';'
         +q.fieldbyname('quant').AsString+';'
         +q.fieldbyname('seria').AsString+';'
         +q.fieldbyname('godendo_date').AsString+';'
         +q.fieldbyname('barcode').AsString+';';
         sl.Add(t);
       // frmSpacePro.logit(t);
         q.next;
      end;

      try
      sl.SaveToFile(f);
      sl.Free;
       sleep(1000);
      zip(f);



      except
     frmSpacePro.logit('неверный путь');
    end;

    frmSpacePro.logit('Остатки выгружены');
end;

Procedure ExtractMove(i:integer);//Выгрузка движения
Begin
 SQL:='select

           iif (d.doc_type=1,10,iif(d.doc_type=3,20,d.doc_type))as d_type,
           left(d.docnum,iif(position('' '',d.docnum)=0,char_length(d.docnum), position('' '',d.docnum)))as docnum,
           cast(d.docdate as date)as docdate,
           a.caption as Supplier,
           a.inn as Supplier_INN,
           d.device_num,
           iif(d.doc_type=3,d.docnum, '''')as N_Chek,
          (select first 1 u.username from users u where u.id=d.owner)as FIO_Chek,
           iif ((abs (dd.discount)>0),1,0) as disk_T,
          cast( dd.sum_dsc as numeric(9,2)) as Disk_Sum,
          dd.summa_o as Sum_Zak,
          dd.summa as Sum_Rozn,
          0 as pp_teg,
          dd.part_id as Drug_code,
          vname.svalue as Drug_name,
          w.izg_id,
          vorig_izg.svalue as Drug_Producer_Name,
          w.barcode,
          vcountry.svalue as Drug_Producer_country,
          p.price_o as Cena_Zak,
          dd.price as Cena_Rozn,
          dd.quant,
          p.seria,
          p.godendo,
          p.barcode,
          g.partner_id

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type in (3,9)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
   inner join g$profiles g on g.id =dd.g$profile_id
  where dd.g$profile_id ='+InttoStr(i)+'
     and dd.doc_commitdate between '''+date_start+''' and '''+date_end+''' order by d.docdate';
//frmSpacePro.logit(SQL);
q:=GetSQLResult(SQL);
f:=CheckFiles(q.fieldbyname('partner_id').AsString,'.mov');
   frmSpacePro.logit(f);
   frmSpacePro.logit('Выгружаем Движение');

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
         +StringReplace(q.fieldbyname('docdate').AsString,'.','',1) +';'
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
         +q.fieldbyname('Drug_Producer_Name').AsString+';'
         +q.fieldbyname('Drug_Producer_country').AsString+';'
         +q.fieldbyname('Cena_Zak').AsString+';'
         +q.fieldbyname('Cena_Rozn').AsString+';'
         +q.fieldbyname('quant').AsString+';'
         +q.fieldbyname('seria').AsString+';'
         +q.fieldbyname('godendo').AsString+';'
         +q.fieldbyname('barcode').AsString+';'
         ;
         sl.Add(t);
         q.next;
      end;


     try
      sl.SaveToFile(f);
      sleep(1000);
      Zip(f);


      except
     frmSpacePro.logit('неверный путь');
    end;


End;

begin
 //Базовые переменные - периуд отчета.
  date_start:='01.01.2018';//DateToStr(date-1);
  date_end:='27.01.2018';//DatetoStr(date);
  frmSpacePro.logit(date_start);
  frmSpacePro.logit('Начали -'+TimetoStr( time));


 //Выгружаем остатки по точкам
  SQL:='select id from g$profiles where partner_id is not null';
  q1:=GetSQLResult(SQL);
  while not q1.eof do
      begin
       ExtractBase(q1.fieldbyname('id').AsInteger);
       q1.Next;
      end;


 //выгрузка движение

   SQL:='select id from g$profiles where partner_id is not null';
  q1:=GetSQLResult(SQL);
  while not q1.eof do
      begin
       frmSpacePro.logit(q1.fieldbyname('id').AsString);
       ExtractMove(q1.fieldbyname('id').AsInteger);
       q1.Next;
      end;


    ftp('*.zip');



    frmSpacePro.logit('Готово -'+TimetoStr( time));
    q.Free;

end;