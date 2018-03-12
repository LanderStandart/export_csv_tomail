uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;

var q,q1: TIBQuery;
    sl,sl1: TStringList;
    SQL,t,t1,f,f1,org_name,org_inn: String;
    date_start,date_end:date;

//проверяем наличие файла в директории
Function CheckFiles (FileName:String):String;
begin

     sl:= TStringList.Create;
     sl1:= TStringList.Create;
     result:=extractfiledrive(application.ExeName)+'\Standart-N\MFO\'+StringReplace(date_end,'.','',1)+FileName;
     if FileExists(result) then
     begin
       deletefile(result);
     end

end;

//получаем данные из запроса
Function GetSQLResult(SQL:String):TIBQuery;
begin
try
 q:=dm.TempQuery(nil);
 q.Active:=false;
 q.SQL.Text:=SQL;
 q.Active:=true;
    except
      frmSpacePro.logit('неверный запрос');
      q.Transaction.Rollback;
    end;
 result:=q;
end;

Procedure ExtractBase(i:integer); //Выгрузка остатков
 Begin
    SQL:='select first 10
    w.docnum,w.docdate,w.docagent,
    (select a.inn from  agents a inner join docs d on d.agent_id=a.id and d.g$profile_id=w.g$profile_id and d.id=w.doc_id
            and a.g$profile_id = w.g$profile_id)as INN,
            w.part_id,w.izg_id,w.sizg,w.scountry,w.sname,w.bcode_izg,w.quant,w.price_o,w.price,
                w.sprofile,cast(godendo as dm_date) as godendo_date,w.seria,w.barcode
          from vw_warebase w where quant > 0.01 and w.g$profile_id ='+InttoStr(i)+'
               group by w.sname, w.part_id, w.quant, w.price_o,w.price,w.bcode_izg,
                        w.izg_id, w.sizg, w.scountry, w.g$profile_id,INN,w.doc_id,w.sprofile,
                        w.docnum,w.docdate,w.docagent,godendo_date,w.seria,w.barcode';
    q:=GetSQLResult(SQL);
    f:=CheckFiles('Basemfo-Аптека '+Copy(q.fieldbyname('sprofile').AsString,1,3)+'.ost');
    frmSpacePro.logit(f);
    frmSpacePro.logit('Выгружаем остатки');

      t:='Тип Данных;Номер Документа;Дата Документа;Поставщик;ИНН Поставщика;Код Товара;Наименование Товара;Код производителя;'+
      'Наименование Производителя;Страна;Штрихкод;Закуп.цена;Розн.цена;Кол-во;Серия;Срок годности;Уникальный код;';
      sl.Add(t);
      while not q.eof do
      begin
         t:=
         '0;'+
         q.fieldbyname('Docnum').AsString+';'
         +q.fieldbyname('docdate').AsString+';'
         +q.fieldbyname('docagent').AsString+';'
         +q.fieldbyname('INN').AsString+';'
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
      except
     frmSpacePro.logit('неверный путь');
    end;

    frmSpacePro.logit('Остатки выгружены');
end;

begin
 //Базовые переменные - периуд отчета.
  date_start:=date-30;
  date_end:=date-25;
  frmSpacePro.logit(date_start);
  frmSpacePro.logit('Начали -'+TimetoStr( time));

 //Выгружаем остатки по точкам
  SQL:='select id from g$profiles';
  q1:=GetSQLResult(SQL);
  while not q1.eof do
      begin
       ExtractBase(q1.fieldbyname('id').AsInteger);
       q1.Next;
      end;

  exit;
 //выгрузка продаж


  frmSpacePro.logit('Выгружаем продажи');
  f:=CheckFiles('sales-mfo.csv');
  frmSpacePro.logit(f);
      SQL:='select  first 15
            (select first 1 p.param_value as inn from params p where p.param_id =''ORG_INN'')as inn,
            d.docnum,
            d.docdate,
            d.doc_type,
            a.caption as distrib,
            a.inn as distrib_inn,
            vname.svalue as sname,
            w.barcode,
            vorig_izg.svalue as izg,
            vcountry.svalue as country,
            dd.quant as quant,
            dd.price,
            (select g.caption from g$profiles g where g.id = dd.g$profile_id) as SPROFILE
            from doc_detail dd

  join docs d on d.id = dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type in (1,3,9)
  join agents a on a.id = d.agent_id and a.g$profile_id=dd.g$profile_id
  left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
  join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
  inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
  inner join out$mfo om on (om.barcode = w.barcode and coalesce(om.barcode,'''')<>'''') or (om.tovar = vname.svalue) or (om.tovar_mfo = vname.svalue)
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id
  inner join vals vcountry on w.country_id=vcountry.id  and w.g$profile_id=vcountry.g$profile_id
  where dd.g$profile_id not in (99,100)
    and dd.doc_commitdate between '''+datetostr(Date_start)+''' and '''+datetostr(Date_end)+''''+' order by d.docdate';

 GetSQLResult(SQL);
   frmSpacePro.logit(SQL);


      t:='Организация;ИНН;Склад;Номер документа;Дата документа;Наименование товара;Штрихкод;Производитель;Страна производства;
      Количество;Цена продажи;';
      sl.Add(t);


      while not q.eof do
      begin
       frmSpacePro.logit(q.FieldByName('doc_type').AsInteger);
         t:=
         'СТАНДАРТ-М;'
         +q.fieldbyname('inn').AsString+';'
         +q.fieldbyname('SPROFILE').AsString+';'
         +q.fieldbyname('docnum').AsString+';'
         +q.fieldbyname('docdate').AsString+';'
         +q.fieldbyname('SNAME').AsString+';'
         +q.fieldbyname('barcode').AsString+';'
         +q.fieldbyname('izg').AsString+';'
         +q.fieldbyname('country').AsString+';'
         +q.fieldbyname('QUANT').AsString+';'
         +q.fieldbyname('price').AsString+';'
         ;
         sl.Add(t);
         q.next;
      end;


     try
      sl.SaveToFile(f);
      sl.Free;
      except
     frmSpacePro.logit('неверный путь');
    end;


    frmSpacePro.logit('Готово -'+TimetoStr( time));
    q.Free;

end;