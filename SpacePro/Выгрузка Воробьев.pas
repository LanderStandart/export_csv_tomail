uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;

var q: TIBQuery;
    sl: TStringList;
    SQL,t,f,org_name,org_inn: String;

  //проверяем наличие файла в директории
Function CheckFiles (FileName:String):String;
begin

     result:=extractfiledrive(application.ExeName)+'\Standart-N\MFO\'+StringReplace(datetoStr(date),'.','',1)+FileName;
     if FileExists(result) then
     begin
       deletefile(result);
     end

end;

//получаем данные из запроса
Procedure GetSQLResult(SQL:String);
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

end;


begin
   sl:= TStringList.Create;
   f:=CheckFiles('toSite.csv');
   frmSpacePro.logit(f);
   SQL:='select list(g.caption)as group_tovar,  w.sprofile,w.sname,w.bcode_izg,w.quant,w.price,
               w.G$PROFILE_ID,cast(godendo as dm_date) as godendo_date,
               w.PART_ID,w.SCOUNTRY, w.BARCODE
                  from vw_warebase w
              left  join group_detail gd on gd.grouptable_id = w.name_id  and gd.grouptable = ''PARTS.NAME_ID'' and gd.g$profile_id=w.g$profile_id
              left  join groups g on g.id = gd.group_id  and g.g$profile_id=w.g$profile_id

                  where quant > 0.01
            group by  w.G$PROFILE_ID,w.sprofile,w.sname,w.mmbsh,w.bcode_izg,w.quant,w.price,
                godendo_date,
               w.PART_ID,w.SCOUNTRY, w.BARCODE  ';

   GetSQLResult(SQL);

   t:='Код партии;Группа Товара;Товар;Страна;Штрихкод;Аптека;Код Аптеки;Кол-во;Цена;Срок Годности;';
   sl.Add(t);
      while not q.eof do
      begin
         t:=q.fieldbyname('PART_ID').AsString+';'
		 +q.fieldbyname('group_tovar').AsString+';'
         +q.fieldbyname('SNAME').AsString+';'
         +q.fieldbyname('SCOUNTRY').AsString+';'
         +q.fieldbyname('BARCODE').AsString+';'
         +q.fieldbyname('SPROFILE').AsString+';'
         +q.fieldbyname('G$PROFILE_ID').AsString+';'
         +q.fieldbyname('QUANT').AsString+';'
         +q.fieldbyname('PRICE').AsString+';'
         +q.fieldbyname('godendo_date').AsString+';';
         sl.Add(t);
         frmSpacePro.logit(t);
         q.next;
      end;

      try
      sl.SaveToFile(f);
      sl.Free;
      except
     frmSpacePro.logit('неверный путь');
     end;
  //    t:='fullssl autotls host=smtp.mail.ru port=465 User=sharapat1@mail.ru Pass=2293236 FROMEMAIL=sharapat1@mail.ru TOEMAIL=kerlaz@live.ru,databox@dobraya-apteka.kz SUBJ="Прайс АйдакеФарм" BODY="Автоматическая рассылка" file0="'+f+'"';
  //    ShellExecute(0, 'open','D:\Standart-N\VGMCSend\VGMCSend.exe', t, '', 5);

 frmSpacePro.logit('Готово -'+TimetoStr( time));
    q.Free;

end;