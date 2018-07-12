 uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path=extractfiledrive(application.ExeName)+'\Standart-N\partner\';
 devide='|';
var
 Sl,SaleMap,BuyMap,BaseMap,SuppMap,DepMap,GoodMap,StoreMap,DiscMap,SaleDiscMap,UserMap:TStringList;
 t,SQL,f:String;
 i:Intefer;
 q: TIBQuery;
 date_start,date_end:date;

procedure InitVar;
                                                   
Begin
date_start:=date-1;
date_end:=1;

//Поля выгрузки файла продаж  sales.csv
 SaleMap:=TStringList.Create;
 SaleMap.Add('IdLotMovement');
 SaleMap.Add('DepartmentCode');
 SaleMap.Add('IdDepartment');
 SaleMap.Add('IdDepartmentTo');
 SaleMap.Add('GoodsCode');
 SaleMap.Add('SupplierCode');
 SaleMap.Add('Quantity');
 SaleMap.Add('InvoiceNum');
 SaleMap.Add('InvoiceDate');
 SaleMap.Add('SaleStuNum');
 SaleMap.Add('SaleStuDate');
 SaleMap.Add('ChequeID');
 SaleMap.Add('ChequeNum');
 SaleMap.Add('ChequeDate');
 SaleMap.Add('ChequeDateModified');
 SaleMap.Add('ChequeType');
 SaleMap.Add('ChequePaymentType');
 SaleMap.Add('ChequeUserNum');
 SaleMap.Add('SaleDocType');
 SaleMap.Add('PriceWholebuy');
 SaleMap.Add('PVatWholeBuy');
 SaleMap.Add('VatWholeBuy');
 SaleMap.Add('PriceRetail');
 SaleMap.Add('PVatWholeRetail');
 SaleMap.Add('VatWholeRetail');
 SaleMap.Add('Discount');
 SaleMap.Add('BestBefore');
 SaleMap.Add('Series');
 SaleMap.Add('DocState');
 SaleMap.Add('IdStore');
 SaleMap.Add('IdStoreTo');

 //Поля выгрузки файла закупок Purchases.csv
 BuyMap:=TStringList.Create;
 BuyMap.Add('IdLotMovement');
 BuyMap.Add('DepartmentCode');
 BuyMap.Add('IdDepartment');
 BuyMap.Add('IdDepartmentFrom');
 BuyMap.Add('GoodsCode');
 BuyMap.Add('SupplierCode');
 BuyMap.Add('Quantity');
 BuyMap.Add('InvoiceNum');
 BuyMap.Add('InvoiceDate');
 BuyMap.Add('PurchaseStuInvoiceNum');
 BuyMap.Add('PurchaseStuInvoiceDate');
 BuyMap.Add('PurchaseDocType');
 BuyMap.Add('PriceWholebuy');
 BuyMap.Add('PVatWholeBuy');
 BuyMap.Add('VatWholeBuy');
 BuyMap.Add('PriceRetail');
 BuyMap.Add('PVatWholeRetail');
 BuyMap.Add('VatWholeRetail');
 BuyMap.Add('BestBefore');
 BuyMap.Add('Series');
 BuyMap.Add('DocState');
 BuyMap.Add('IdStore');
 BuyMap.Add('IdStoreFrom');

//Поля выгрузки файла остатков Balances.csv
 BaseMap:=TStringList.Create;
 BaseMap.Add('StockBalanceDate');
 BaseMap.Add('DepartmentCode');
 BaseMap.Add('IdDepartment');
 BaseMap.Add('InvoiceNum');
 BaseMap.Add('InvoiceDate');
 BaseMap.Add('GoodsCode');
 BaseMap.Add('Quantity');
 BaseMap.Add('PriceWholebuy');
 BaseMap.Add('PVatWholeBuy');
 BaseMap.Add('PriceWholebuyWithoutVat');
 BaseMap.Add('PriceRetail');
 BaseMap.Add('PVatWholeRetail');
 BaseMap.Add('PriceRetailWithoutVat');
 BaseMap.Add('IdStore');
 BaseMap.Add('QuantitySum');
 BaseMap.Add('SupplierCode');
 BaseMap.Add('BestBefore');
 BaseMap.Add('Series');
 BaseMap.Add('Barcode');

//Поля выгрузки файла справочник подразделений  departments.csv
 DepMap:=TStringList.Create;
 DepMap.Add('DepartmentName');
 DepMap.Add('DepartmentCode');
 DepMap.Add('DepartmentAdress');
 DepMap.Add('InstallPointCode');
 DepMap.Add('InventoryControl');
 DepMap.Add('PriceCompare');
 DepMap.Add('CompanyName');
 DepMap.Add('AdressJur');
 DepMap.Add('Tin');
 DepMap.Add('Trrc');
 DepMap.Add('Phone');
 DepMap.Add('ManagerName');
 DepMap.Add('IdDepartment');

 //Поля выгрузки файла справочник товаров  goods.csv
 GoodMap:=TStringList.Create;
 GoodMap.Add('Code');
 GoodMap.Add('Name');
 GoodMap.Add('Producer');
 GoodMap.Add('Country');
 GoodMap.Add('Barcode1');
 GoodMap.Add('Barcode2');
 GoodMap.Add('Barcode3');
 GoodMap.Add('GuidEs');
 GoodMap.Add('CodeSup1');
 GoodMap.Add('CodeSup2');
 GoodMap.Add('CodeGoodsSup1');
 GoodMap.Add('CodeGoodsSup2');

  //Поля выгрузки файла справочник складов  Store.csv
 StoreMap:=TStringList.Create;
 StoreMap.Add('IdStore');
 StoreMap.Add('StoreName');
 StoreMap.Add('IdDepartment');
 StoreMap.Add('StoreTypeName');

   //Поля выгрузки файла справочник дисконтов  Discount.csv
 DiscMap:=TStringList.Create;
 DiscMap.Add('IdDiscountProgram');
 DiscMap.Add('DiscountProgramName');
 DiscMap.Add('DiscountProgramPercent');
 DiscMap.Add('DiscountType');
 DiscMap.Add('DiscountCardBarcode');

    //Поля выгрузки файла справочник продаж с дисконтом  discount_sale.csv
 SaleDiscMap:=TStringList.Create;
 SaleDiscMap.Add('IdDocumentItem');
 SaleDiscMap.Add('IdDiscount');
 SaleDiscMap.Add('AmountDiscount');
 SaleDiscMap.Add('BonusPercent');

 //Поля выгрузки файла справочник продаж с дисконтом  user.csv
 UserMap:=TStringList.Create;
 UserMap.Add('UserNum');
 UserMap.Add('Name');
 UserMap.Add('FullName');
 UserMap.Add('DateDeleted');
end;
 //----------------------------------------------------------------------------------------------------------------------------
function filename:String;
var
t,y,m,d:String;
begin
 d:=Copy(date,0,2);
 m:=Copy(date,4,2);
 y:=Copy(date,7,4);

 t:=StringReplace(time,':','',1);
 if Length(t)<6 then t:='0'+t;
 result:=y+m+d+t;
end;

//----------------------------------------------------------------------------------------------------------------------------
//проверяем наличие файла в директории
Function CheckFiles (FileName1:String):String;
var
fn:string
begin
     fn:=Filename;
     sl:= TStringList.Create;
     result:=path+fn+FileName1+'.csv';
     if FileExists(result) then
     begin
       deletefile(result);
     end

end;
//----------------------------------------------------------------------------------------------------------------------------


//Архивируем файл
Procedure ZIP (f:string);
var
fz:string;
begin
fz:=' a -tzip -sdel -r0 -i!*.csv '+path+filename+'.zip '+f;
frmManagerXP2.logit(fz);
shellExecuteA(0,'open','C:\Program Files\7-Zip\7z.exe',fz,'',5);

end;
//----------------------------------------------------------------------------------------------------------------------------

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
      frmManagerXP2.logit('неверный запрос');
      q2.Transaction.Rollback;
    end;
 result:=q2;
end;
//----------------------------------------------------------------------------------------------------------------------------

Procedure GetStringCSV(Map:TStringList;S,FileN:String);
begin
  f:=CheckFiles(FileN);
 t:='';                                                

 q:=GetSQLResult(S);
 for i := 0 to Map.Count-1 do
 t:=t+Map.Strings[i]+devide;

 sl.Add(t);
 t:='';
while not q.eof do
 begin
     for i := 0 to Map.Count-1 do
         begin
             t:=t+q.fieldbyname(Map.Strings[i]).AsString+devide;
         end;
 sl.Add(t); 
 t:='';
 q.Next;
 end;

try
  sl.SaveToFile(f);
  sl.Free;
  except                                                  
     frmManagerXP2.logit('неверный путь');
  end;
 frmManagerXP2.logit(FileN+'.csv - выгружен');
end;
//----------------------------------------------------------------------------------------------------------------------------
Function UserSQL:string;  //SQL выборка первостольников
begin
Result:='select u.id as UserNum, u.username as Name,u.username as FullName,'''' as DateDeleted  from users u';
end;  
//----------------------------------------------------------------------------------------------------------------------------
Function SaleSQL:string; //SQL выборка продаж
begin
Result:='select
           d.id as IdLotMovement,
           ''1'' as DepartmentCode,
           d.agent_id as IDDepartment,
           iif(d.doc_type=6,d.agent_id,'''') as IDDepartmentTo,
           dd.part_id as GoodsCode,
           (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
           cast(trunc(abs(dd.quant),0) as numeric (4,0)) as Quantity,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           d.docnum as SaleStuNum,
           d.docdate as SaleStuDate,
           iif(d.doc_type =3, d.id,'''') as ChequeID,
           iif(d.doc_type =3,d.docnum,'''') as ChequeNum,
           iif(d.doc_type =3,d.commitdate,'''') as ChequeDateModified,
           iif((d.doc_type =3 and d.summ1<>0 and d.summ2=0),''CASH'',iif((d.doc_type =3 and d.summ1=0 and d.summ2<>0),''P_CARD'',iif(d.doc_type =3,''MIXED'','''')))as ChequeType,
           iif (d.doc_type=3,''SUB'',iif(d.doc_type=9,''RETURN'','''')) as ChequePaymentType,
           iif(d.doc_type =3,d.creater,'''') as ChequeUserNum,
           iif(d.doc_type =3,''Cheque'',iif(d.doc_type=11,''Invoice_Out'',iif(d.doc_type=4,''ActReturnToContractor'',iif(d.doc_type=6,''MoveSub'',''''))))as SaleDocType,
           cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          cast(p.nds as numeric (3,0)) as VatWholeBuy,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,
          cast(dd.price as numeric(9,2)) as PriceRetail,
          cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)) as VatWholeRetail,
          cast(abs(dd.sum_ndsr)as numeric(9,2)) as PVatWholeRetail,
          iif(d.doc_type =3,dd.discount,'''') as Discount,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          ''PROC'' as DocState,
          ''1'' as Idstore,
          iif(d.doc_type=6,d.agent_id,'''') as IDStoreTO

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (3,11,4,6)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
  where  dd.doc_commitdate between' +date_start+' and '+date_end+' order by d.docdate';
end;  
//----------------------------------------------------------------------------------------------------------------------------
Function BuySQL:string; //SQL выборка закупок
begin
Result:='select
           d.id as IdLotMovement,
           ''1'' as DepartmentCode,
           d.agent_id as IDDepartment,
           iif(d.doc_type=2,d.agent_id,'''') as IDDepartmentFrom,
           dd.part_id as GoodsCode,
           (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
           cast(trunc(abs(dd.quant),0) as numeric (4,0)) as Quantity,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           d.docnum as PurchaseStuinvoiceNum,
           d.docdate as PurchaseStuInvoiceDate,
           iif(d.doc_type= 1,''PurchaseInvoice'',iif(d.doc_type=20,''ImportRemains'',iif(d.doc_type=9,''ActReturnBuyer'',iif(d.doc_type=2,''MoveAdd'',''''))))as SaleDocType,
           cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          cast(p.nds as numeric (3,0)) as VatWholeBuy,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,
          cast(dd.price as numeric(9,2)) as PriceRetail,
          cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)) as VatWholeRetail,
          cast(abs(dd.sum_ndsr)as numeric(9,2)) as PVatWholeRetail,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          ''PROC'' as DocState,
          ''1'' as Idstore,
          iif(d.doc_type=2,d.agent_id,'''') as IDStoreFrom

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (9,11,4,6)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
 where  dd.doc_commitdate between' +date_start+' and '+date_end+' order by d.docdate';
end;  
//----------------------------------------------------------------------------------------------------------------------------
Function BaseSQL:string; //SQL выборка остатков
begin
Result:='select
           current_date as StockBalanceDate,
           ''1'' as DepartmentCode,
           ''1'' as IDDepartment,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           dd.part_id as GoodsCode,
           cast(trunc(sum(dd.quant),0) as numeric (4,0) )as Quantity,
          cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,
          cast(dd.price as numeric(9,2)) as PriceRetail,
          cast(abs(dd.sum_ndsr)as numeric(9,2)) as PVatWholeRetail,
          ''1'' as Idstore,
          cast(trunc(sum(dd.quant),0) as numeric (4,0)) as QuantitySum,
          (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          p.barcode as Barcode

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
  where  dd.doc_commitdate <= '+date_end+' 
  group by dd.doc_commitdate,DepartmentCode,IDDepartment,InvoiceNum,InvoiceDate,GoodsCode,PriceWholeBuy,PvatWholeBuy,
           PriceRetail, PVatWholeRetail,Idstore,SupplierCode,BestBefore,Series,Barcode,dd.sum_ndsr,p.godendo,dd.price,p.price_o,p.sum_ndso,p.doc_id';
end;		   
//----------------------------------------------------------------------------------------------------------------------------


begin
InitVar;

GetStringCSV(UserMap,UserSQL,'User');
 frmManagerXP2.logit(path);
//Zip(path);
end;                                                             