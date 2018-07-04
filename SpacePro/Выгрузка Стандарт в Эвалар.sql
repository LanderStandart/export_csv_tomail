uses
   Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, AdvOfficePager,
  ToolWin, ImgList, dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBGrid,AdvPanel, need,
  DB, IBQuery, IBDatabase, unDM, DBTables, cfdxUtils, Menus,cfUtils,
  unViewUtils, Buttons, ExtCtrls, StdCtrls, Windows, ShellApi,
  gb_table, Mask,  unFrameCustomDict, unMain,SysUtils, Windows;

const
    path='\Standart-N\Эвалар\';

var sheet,XLA : variant;
    qWork,q: TIBQuery;
    index: Integer;
    SQL,f,date_start,date_end:String;
     sl: TStringList;
                                                      


//проверяем наличие файла в директории
Function CheckFiles (FileName:String):String;
begin
     sl:= TStringList.Create;
     result:=extractfiledrive(application.ExeName)+path+StringReplace(date,'.','',1)+FileName;
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


procedure CreateDocExcel;
begin
  XLA:=CreateOleObject('Excel.Application');

  XLA.Visible := false;
  XLA.DisplayAlerts := False;

  //XLA.SheetsInNewWorkbook[1] := 0;
  XLA.WorkBooks.Add;
end;

procedure CloseDocExcel;
begin
  XLA.ActiveWorkbook.SaveAs(f);
  XLA.Quit;
  XLA := Unassigned;
end;

procedure GetHeader(c1,c2,c3,c4,c5,c6,c7,c8,c9:string);

 begin
 index:=1;
      sheet.cells[index,1]:=c1;
      sheet.cells[index,2]:=c2;
      sheet.cells[index,3]:=c3;
      sheet.cells[index,4]:=c4;
      sheet.cells[index,5]:=c5;
      sheet.cells[index,6]:=c6;
      sheet.cells[index,7]:=c7;
      sheet.cells[index,8]:=c8;
      sheet.cells[index,9]:=c9;
 end;

procedure GetCells(index,s1,s2,s3,s4,s5,s6,s7,s8,s9:string);
begin

      sheet.cells[index,1]:=qWork.FieldByName(s1).AsString;
      sheet.cells[index,2]:=qWork.FieldByName(s2).AsString;
      sheet.cells[index,3]:=qWork.FieldByName(s3).AsString;
      sheet.cells[index,4]:=qWork.FieldByName(s4).AsString;
      sheet.cells[index,5]:=qWork.FieldByName(s5).AsString;
      sheet.cells[index,6]:=qWork.FieldByName(s6).AsString;
      sheet.cells[index,7]:=qWork.FieldByName(s7).AsString;
      sheet.cells[index,8]:=qWork.FieldByName(s8).AsString;
      if Pos('code',s8)>0 then sheet.cells[index,8].NumberFormat:='0' else sheet.cells[index,9].NumberFormat:='0';
      if s9<>'' then sheet.cells[index,9]:=qWork.FieldByName(s9).AsString;
end;

procedure CreateSheet (sheet_caption,SQL,s1,s2,s3,s4,s5,s6,s7,s8,s9: String);{(i:Integer; d_id,sheet_caption: String);}
var index,index_col,max_col,f_index,i: Integer;
    old_sname,sname,col: String;
    sl: TstringList;
    formula1,uslovie1,uslovie2,uslovie3,uslovie4,uslovie5: String;
    name_range_sh,name_range_sum,name_range_nac,name_range_price,name_range_reit,name_range_dopgr,name_range_rxotcgr: String;
    FC,Shape: Variant;
begin

 qWork:=GetSQLResult(SQL);
 index:=2;

 while not qWork.Eof do
  begin
     GetCells(index,s1,s2,s3,s4,s5,s6,s7,s8,s9);
     qWork.Next;
     inc(index);
  end;
end;

procedure CreateSheets(Name,SQL,c1,c2,c3,c4,c5,c6,c7,c8,c9,s1,s2,s3,s4,s5,s6,s7,s8,s9:string);
var i: Integer;
    sheet_caption: Caption;
begin

  i:=0;
  inc(i);

  CreateDocExcel;

  sheet:=XLA.WorkBooks[1].sheets.Add;
  sheet.Name := Name;

  CreateSheet(Name,SQL,s1,s2,s3,s4,s5,s6,s7,s8,s9);
  GetHeader(c1,c2,c3,c4,c5,c6,c7,c8,c9);
  f:=CheckFiles(Name+'.xlsx');
  XLA.ActiveWorkbook.SaveAs(f);

  CloseDocExcel;
end;


begin
date_start:=Datetostr(date-30);
date_end:=DatetoStr(date);

//Остатки
  SQL:='select first 10
    current_date,
    w.sname,
    ''Аптека ''||(select left(g.caption,position('' '' in g.caption)) from g$profiles g where g.id=w.g$profile_id)as Profile ,
    ''Ижевск'' as City,
    (select substring(g.caption from position('' '' in g.caption) for position(''тел'' in g.caption)-position('' '' in g.caption)) from g$profiles g where g.id=w.g$profile_id) as adress,
    w.quant,
    cast(w.price*w.quant as numeric(9,2)) as Summa,
    w.bcode_izg

          from vw_warebase w where quant > 0.01 -- and w.g$profile_id =+InttoStr(i)+
          and UPPER(w.sizg) containing ''ЭВАЛАР''
               group by w.sname,w.g$profile_id,w.quant,w.price,w.bcode_izg';

  CreateSheets('Остатки',SQL,'Дата снятия остатков','Название товара','Название Аптеки','Город',
                'Адрес аптеки','Кол-во','Сумма','Штрихкод','','current_date','sname','Profile',
                'City','adress','quant','Summa','bcode_izg','');


//продажи
 SQL:='select first 10
    d.docdate,
    (select u.username from users u where u.id=d.owner and u.g$profile_id=dd.g$profile_id) as Kassir,
    vname.svalue as SNAME,
    ''Аптека ''||(select left(g.caption,position('' '' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    ''Ижевск'' as City,
    (select substring(g.caption from position('' '' in g.caption) for position(''тел'' in g.caption)-position('' '' in g.caption)) from g$profiles g where g.id=w.g$profile_id) as adress,
     -dd.quant as quant,
     cast(-dd.summa_o as numeric(9,2)) as summa,
     w.barcode
from doc_detail dd
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 3
 left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
 inner join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
 inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
 inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id and upper(vorig_izg.svalue) containing ''ЭВАЛАР''

where dd.doc_commitdate between '''+Date_start+''' and '''+date_end+'''
order by dd.doc_commitdate';
  CreateSheets('Продажи',SQL,'Дата продажи','Кассир','Название товара','Название Аптеки','Город',
                'Адрес аптеки','Кол-во','Сумма','Штрихкод','docdate','Kassir','sname','Profile',
                'City','adress','quant','Summa','barcode'  );

//Закупки
SQL:='select first 10
    d.docdate,
    (select a.caption from agents a where a.id=d.agent_id and a.g$profile_id=dd.g$profile_id) as Distibuter,
    vname.svalue as SNAME,
    ''Аптека ''||(select left(g.caption,position('' '' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    ''Ижевск'' as City,
    (select substring(g.caption from position('' '' in g.caption) for position(''тел'' in g.caption)-position('' '' in g.caption)) from g$profiles g where g.id=w.g$profile_id) as adress,
     dd.quant,
    cast(dd.summa_o as numeric(9,2)) as summa,
     w.barcode
from doc_detail dd
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 1
 left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
 inner join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
 inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
 inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id and upper(vorig_izg.svalue) containing ''ЭВАЛАР''

where dd.doc_commitdate between '''+Date_start+''' and '''+date_end+'''
order by dd.doc_commitdate'
  CreateSheets('Закупки',SQL,'Дата закупки','Дистрибутор','Название товара','Название Аптеки','Город',
                'Адрес аптеки','Кол-во','Сумма','Штрихкод','docdate','Distibuter','sname','Profile',
                'City','adress','quant','Summa','barcode'  );


end;