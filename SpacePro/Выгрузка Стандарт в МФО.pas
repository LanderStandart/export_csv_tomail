uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;

var q: TIBQuery;
    sl: TStringList;
    dateF,t,f,org_name,org_inn: String;
    date_start,date_end:date;

begin
  date_start:=date-30;
  date_end:=date;
  frmSpacePro.logit(date_start);
  frmSpacePro.logit(date_end);
frmSpacePro.logit('Начали -'+TimetoStr( time));

 //выгрузка остатков
 // try
     sl:= TStringList.Create;
     f:=extractfiledrive(application.ExeName)+'\Standart-N\MFO\'+StringReplace(date_end,'.','',1)+'Basemfo.csv';
     frmSpacePro.logit(f);
     if FileExists(f) then
     begin
       deletefile(f);
     end

    q:=dm.TempQuery(nil);
   // try
      q.Active:=false;
      q.SQL.text:='select
                    w.sprofile,w.sname,w.bcode_izg,w.quant,
                    (select first 1 p.param_value as inn from params p where p.param_id =''ORG_INN'')as inn,
                    cast(godendo as dm_date) as godendo_date
                  from vw_warebase w where quant > 0.01 and w.g$profile_id not in (99,100)
                  and (exists (select barcode from out$mfo om where om.barcode = w.bcode_izg)
                     or exists(select tovar from out$mfo om where om.tovar = w.sname)
                     or exists(select tovar_mfo from out$mfo om where om.tovar_mfo = w.sname))
                  group by w.sprofile,w.sname,w.bcode_izg,w.quant,inn,godendo_date';
      frmSpacePro.logit('Выгружаем остатки');

      q.Active:=true;
      t:='Организация;ИНН;Склад;Дата остатков;Наименование товара;Штрихкод;Остаток;';
      sl.Add(t);
      while not q.eof do
      begin
         t:=q.fieldbyname('SPROFILE').AsString+';'+q.fieldbyname('inn').AsString+';'+
         ' ;'+DatetoStr(Date)+';'+q.fieldbyname('SNAME').AsString+';'+
         q.fieldbyname('BCODE_IZG').AsString+';'+
         q.fieldbyname('QUANT').AsString+';';
         sl.Add(t);
       //  frmSpacePro.logit(t);
         q.next;
      end;
      q.transaction.commit;
      sl.SaveToFile(f);
      sl.Free;

 //выгрузка продаж
  //try
  frmSpacePro.logit('Выгружаем продажи');
     sl:= TStringList.Create;
     f:=extractfiledrive(application.ExeName)+'\Standart-N\MFO\'+StringReplace(date_end,'.','',1)+'sales-mfo.csv';
     frmSpacePro.logit(f);
     if FileExists(f) then
     begin
       deletefile(f);
     end

    q:=dm.TempQuery(nil);
   // try
      q.Active:=false;
      q.SQL.text:='select
            (select first 1 p.param_value as inn from params p where p.param_id =''ORG_INN'')as inn,
            d.docnum,
            d.docdate,
            d.doc_type,
            vname.svalue as sname,
            w.barcode,
            vorig_izg.svalue as izg,
            vcountry.svalue as country,
            dd.human_quant as quant,
            dd.price,
            (select g.caption from g$profiles g where g.id = dd.g$profile_id) as SPROFILE
            from doc_detail dd

  join docs d on d.id = dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type in (3,9)
  left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
  join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
  inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
  inner join out$mfo om on (om.barcode = w.barcode and coalesce(om.barcode,'''')<>'''') or (om.tovar = vname.svalue) or (om.tovar_mfo = vname.svalue)
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id
  inner join vals vcountry on w.country_id=vcountry.id  and w.g$profile_id=vcountry.g$profile_id
  where dd.g$profile_id not in (99,100)
    and dd.doc_commitdate between '''+datetostr(Date_start)+''' and '''+datetostr(Date_end)+''''+' order by d.docdate';

     // frmSpacePro.logit(q.SQL.text);
     frmSpacePro.logit('выгружаем продажи');
      q.Active:=true;
      t:='Организация;ИНН;Номер документа;Дата документа;Наименование товара;Штрихкод;Производитель;Страна производства;
      Количество;Цена закупа;Цена продажи;';
      sl.Add(t);
      while not q.eof do
      begin
         t:=q.fieldbyname('SPROFILE').AsString+';'
         +q.fieldbyname('inn').AsString+';'
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
       //  frmSpacePro.logit(t);
         q.next;
      end;
      q.transaction.commit;
      sl.SaveToFile(f);
      frmSpacePro.logit(time);
      sl.Free;                                       


 //   except
    //  q.Transaction.Rollback;
 //   end
 // finally
    frmSpacePro.logit('Готово -'+TimetoStr( time));
    q.Free;
//  end;           
end;