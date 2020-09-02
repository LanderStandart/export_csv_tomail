//-------------------------------------------------------
// TMS выгрузки для партнера ПРОАПТЕКА (Протек)
//(с) 15.07.2018 Дмитрий Дрыняев Стандарт-Н
// для клиента Вита-Мед
//-------------------------------------------------------

 uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  system, 
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path=extractfiledrive(application.ExeName)+'\Standart-N\proapteka\'; //путь для выгрузки файлов
 devide='|'; // Разделитель данных
var
 MP,Sl,SaleMap,BuyMap,BaseMap,SuppMap,DepMap,GoodMap,StoreMap,DiscMap,SaleDiscMap,UserMap,ListMap,FileMap,SQLMap:TStringList;
 t,SQL,f,DepartmentCode:String;
 i,j:Intefer;
 q: TIBQuery;
 date_start,date_end:date;              


//---------------------------------------------
//Формируем SQL запросы для требуемых выгрузок            
//---------------------------------------------
Function UserSQL:string; //SQL выборка остатков
begin
Result:='select iif(u.id<0,abs(u.id*10000),u.id) as UserNum, u.username as Name,u.username as FullName,'''' as DateDeleted  from users u';
end;
//----------------------------------------------------------------------------------------------------------------------------
Function SaleSQL:string; //SQL выборка продаж
Begin
Result:='select  d.id as IdLotMovement,
           '''+DepartmentCode+''' as DepartmentCode,
           iif(d.agent_id<0,abs(d.agent_id*10000),d.agent_id) as IDDepartment,
           iif(d.doc_type=6,d.agent_id,'''') as IDDepartmentTo,
           dd.part_id as GoodsCode,                                 
           (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
           cast(trunc(abs(dd.quant),0) as numeric (4,0)) as Quantity,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           d.docnum as SaleStuNum,
           d.docdate as SaleStuDate,  
           d.docdate as ChequeDate,
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
          cast(abs(dd.price*p.nds/100*p.nds)as numeric(9,2)) as PVatWholeRetail,
          iif(d.doc_type =3,cast(dd.discount as numeric(9,2)),'''') as Discount,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          ''PROC'' as DocState,                      
          '''+DepartmentCode+''' as Idstore,
          iif(d.doc_type=6,d.agent_id,'''') as IDStoreTO

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (3,11,4,6)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id    
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
  where  dd.doc_commitdate between ''' +DateToStr(date_start)+''' and '''+DateToStr(date_end)+''' order by d.docdate';
  
end;
//----------------------------------------------------------------------------------------------------------------------------
Function BaseSQL:string; //SQL выборка остатков
begin                                           
Result:='select
           current_date as StockBalanceDate,
           '''+DepartmentCode+''' as DepartmentCode,
           '''+DepartmentCode+''' as IDDepartment,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           dd.part_id as GoodsCode,
           cast(trunc(sum(dd.quant),0) as numeric (4,0) )as Quantity,
          cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          '''' as PriceWholebuyWithoutVat,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,
          cast(dd.price as numeric(9,2)) as PriceRetail,
          '''' as PriceRetailWithoutVat,
          cast(abs(dd.price*p.nds/(100+p.nds))as numeric(9,2)) as PVatWholeRetail, 
          '''+DepartmentCode+''' as Idstore,
          cast(trunc(sum(dd.quant),0) as numeric (4,0)) as QuantitySum,
          (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          w.barcode as Barcode

            from doc_detail dd
                             
  inner join docs d on d.id = dd.doc_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id                 
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
  where  dd.doc_commitdate <= '''+DateToStr(date_end)+'''
  group by dd.doc_commitdate,DepartmentCode,IDDepartment,InvoiceNum,InvoiceDate,GoodsCode,PriceWholeBuy,PvatWholeBuy,
           PriceRetail, PVatWholeRetail,Idstore,SupplierCode,BestBefore,Series,Barcode,p.nds,p.godendo,dd.price,p.price_o,p.sum_ndso,p.doc_id';
end;
//----------------------------------------------------------------------------------------------------------------------------
Function BuySQL:string; //SQL выборка закупок
begin
Result:='select
           d.id as IdLotMovement,                        
           '''+DepartmentCode+''' as DepartmentCode,                                     
           d.agent_id as IDDepartment,
           iif(d.doc_type=2,d.agent_id,'''') as IDDepartmentFrom,
           dd.part_id as GoodsCode,
           (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
           cast(trunc(abs(dd.quant),0) as numeric (4,0)) as Quantity,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,                        
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           d.docnum as PurchaseStuinvoiceNum,
           d.docdate as PurchaseStuInvoiceDate,
           iif(d.doc_type= 1,''PurchaseInvoice'',iif(d.doc_type=20,''ImportRemains'',iif(d.doc_type=9,''ActReturnBuyer'',iif(d.doc_type=2,''MoveAdd'',''''))))as PurchaseDocType,
           cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          cast(p.nds as numeric (3,0)) as VatWholeBuy,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,          
          cast(dd.price as numeric(9,2)) as PriceRetail,
          cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)) as VatWholeRetail,
          cast(abs(dd.price*(select deps.ndsr from deps where deps.id = p.dep)/(100+(select deps.ndsr from deps where deps.id = p.dep)))as numeric(9,2)) as PVatWholeRetail,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          ''PROC'' as DocState,
          '''+DepartmentCode+''' as Idstore,
          iif(d.doc_type=2,d.agent_id,'''') as IDStoreFrom

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (9,11,4,6)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
 where  dd.doc_commitdate between ''' +DateToStr(date_start)+''' and '''+DateTOStr(date_end)+''' order by d.docdate';
end;
//----------------------------------------------------------------------------------------------------------------------------

Function SuppSQL:string; //SQL выборка поставщиков
begin
Result:='select
 docs.agent_id as Code,
 agents.caption as Name,
 agents.fullname as FullName,
 agents.inn as Tin,
 agents.kpp as Trrc,               
 agents.phonenumbers as Phone,
 (select * from pr_getaddress(agents.addr_id)) as adress
 from docs
inner join agents on agents.id = docs.agent_id
where docs.doc_type in (1,4) and docs.agent_id>0 

group by docs.agent_id,agents.caption, agents.fullname,tin,Trrc,Phone,agents.addr_id';
end;
//--------------------------------------------------------------------------------------------------------------------

Function GoodSQL:string; //SQL выборка товаров
begin
Result:='select
p.id as Code,
vname.svalue as Name,
vorig_izg.svalue as Producer,
vcountry.svalue as Country,
w.barcode as barcode1,
p.barcode as barcode2,
p.barcode1 as barcode3,
'''' as GuidEs,
(select docs.agent_id from docs where docs.id=p.doc_id) as CodeSup1,
'''' as CodeSup2,
'''' as CodeGoodsSup1,
'''' as CodeGoodsSup2
from parts p
 join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id';
end;
//----------------------------------------------------------------------------------------------------------------------------
Function DepSQL:string;
begin
Result:='select
(select p.param_value  from params p where p.param_id=''ORG_NAME_SHORT'')as DepartmentName,
  '''+DepartmentCode+''' as DepartmentCode,
(select p.param_value  from params p where p.param_id=''ORG_ADRESS'') as DepartmentAddress,
'''' as InstallPointCode,
''Стандарт-Н'' as InventoryControl,
''Стандарт-Н'' as PriceCompare,
(select p.param_value  from params p where p.param_id=''ORG_NAME_SHORT'')as CompanyName,
(select p.param_value  from params p where p.param_id=''ORG_PARENT_ADRES'')as AddressJur,
(select p.param_value  from params p where p.param_id=''ORG_INN'')as Tin,
(select p.param_value  from params p where p.param_id=''ORG_KPP'')as Trrc,
(select p.param_value  from params p where p.param_id=''ORG_PHONE'')as PHONE,
(select p.param_value  from params p where p.param_id=''ORG_DIRECTOR'')as ManagerName,
'''+DepartmentCode+''' as IDDepartment
from rdb$database';
end;
//----------------------------------------------------------------------------------------------------------------------------
Function StoreSQL:string; //SQL выборка складов
begin
Result:='Select
  '''+DepartmentCode+''' as IdStore,
  (select p.param_value  from params p where p.param_id=''ORG_NAME_SHORT'')as StoreName,
  '''+DepartmentCode+''' as IdDepartment,
  ''основной''as StoreTypeName
  from rdb$database';
End;
//--------------------------------------------------------------------------------------------------------------------
Function SaleDiscSQL:string; //SQL выборка продаж со скидкой
begin
Result:='select  d.id as IdDocumentItem,
        '''' as IDDiscount,
        abs(dd.discount) as BonusPercent,
        cast(dd.sum_dsc as numeric(9,2)) as AmountDiscount

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (3,11,4,6)

  where dd.discount<0 and
   dd.doc_commitdate between ''' +DateToStr(date_start)+''' and '''+DateTOStr(date_end)+''' order by d.docdate';
end;
//--------------------------------------------------------------------------------------------------------------------
Function DiscSQL:String; // SQL выборка дисконтных карт
begin
Result:='Select '''' as IdDiscountProgram,
 ''''as DiscountProgramName,
 ''''as DiscountProgramPercent,
 '''' as DiscountType,
 '''' as DiscountCardBarcode
 from rdb$database';
end;


//--------------------------------------------------------------------------------------------------------------------
//Инициация переменных
procedure InitVar;
Begin
date_start:=date-1; //Дата начала выборки
date_end:=date;     //Дата окончания выборки
DepartmentCode:='1'; // Код профиля Аптеки


 //Перечень файлов выгрузки список файлов которые будут выгружены
 FileMap:=TStringList.Create;
 FileMap.Add('Users');
 FileMap.Add('Sales');
 FileMap.Add('Purchases');
 FileMap.Add('Balances');
 FileMap.Add('Suppliers');
 FileMap.Add('Departments');
 FileMap.Add('Goods');
 FileMap.Add('Store');
 FileMap.Add('Discount');
 FileMap.Add('Discount_Sale');

 //Перечень SQL  выгрузки
 SQLMap:=TStringList.Create;         
 SQLMap.Add(UserSQL);
 SQLMap.Add(SaleSQL);
 SQLMap.Add(BuySQL);
 SQLMap.Add(BaseSQL);
 SQLMap.Add(SuppSQL);
 SQLMap.Add(DepSQL);
 SQLMap.Add(GoodSQL);
 SQLMap.Add(StoreSQL);
 SQLMap.Add(DiscSQL);
 SQLMap.Add(SaleDiscSQL);



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
 SaleMap.Add('PriceWholeBuy');
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
 BuyMap.Add('PriceWholeBuy');
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
 BaseMap.Add('PriceWholeBuy');
 BaseMap.Add('PVatWholeBuy');
 BaseMap.Add('PriceWholebuyWithoutVat');
 BaseMap.Add('PriceRetail');
 BaseMap.Add('PVatWholeRetail');
 BaseMap.Add('PriceRetailWithoutVat');
 BaseMap.Add('IdStore');
 BaseMap.Add('SupplierCode');
 BaseMap.Add('BestBefore');
 BaseMap.Add('Series');
 BaseMap.Add('Barcode');

//Поля выгрузки файла справочник подразделений  departments.csv
 DepMap:=TStringList.Create;
 DepMap.Add('DepartmentName');
 DepMap.Add('DepartmentCode');
 DepMap.Add('IdDepartment');
 DepMap.Add('DepartmentAddress');
 DepMap.Add('InstallPointCode');
 DepMap.Add('InventoryControl');
 DepMap.Add('PriceCompare');
 DepMap.Add('CompanyName');
 DepMap.Add('AddressJur');
 DepMap.Add('Tin');
 DepMap.Add('Trrc');
 DepMap.Add('Phone');
 DepMap.Add('ManagerName');
 

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

  //Поля выгрузки файла справочника поставщиков  supplier.csv
 SuppMap:=TStringList.Create;
 SuppMap.Add('Name');
 SuppMap.Add('FullName');
 SuppMap.Add('Code');
 SuppMap.Add('Adress');
 SuppMap.Add('Tin');
 SuppMap.Add('Trrc');
 SuppMap.Add('Phone');

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

//Перечень профилей  выгрузки
 ListMap:=TStringList.Create;
 ListMap.Add(UserMap);
 ListMap.Add(SaleMap);
 ListMap.Add(BuyMap);
 ListMap.Add(BaseMap);
 ListMap.Add(SuppMap);
 ListMap.Add(DepMap);
 ListMap.Add(GoodMap);
 ListMap.Add(StoreMap);
 ListMap.Add(DiscMap);
 ListMap.Add(SaleDiscMap);

end;
 //----------------------------------------------------------------------------------------------------------------------------
function filename:String; // Формируем название файла =текущее дата время
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
Function CheckFiles (FileName1:String):String; // подготовка файла для импорта
var
fn:string
begin
     fn:=Filename;
     sl:= TStringList.Create;
     result:=path+FileName1+'.csv';
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

Procedure GetStringCSV(Map:TstringlistUTF8;S,FileN:String); // процедура формирует файлы выгрузки 
var outstring:string;
begin

  f:=CheckFiles(FileN);
 t:='';

 q:=GetSQLResult(S);
 //Создаем шапку файла                                               
 for i := 0 to Map.Count-1 do
 t:=t+Map.Strings[i]+devide;
                                                              
 sl.Add(t);
 t:='';
//заполняем файл данными
while not q.eof do
 begin
     for i := 0 to Map.Count-1 do
         begin  
            outstring:=UTF8Encode(q.fieldbyname(Map.Strings[i]).AsString);         
            if Length(outstring)<=0 then t:=t+'-'+devide
            else   t:=t+(outstring)+devide;
         end;
 sl.Add(t);
 t:='';
 q.Next;
 end;

try
 //сохраняем файл
  sl.SaveToFile(f);
  sl.Free;
  except
     frmManagerXP2.logit('неверный путь');
  end;
 frmManagerXP2.logit(FileN+'.csv - выгружен');
end;


//----------------------------------------------------------------------------------------------------------------------------



begin
InitVar;

 for j := 0 to ListMap.Count-1 do
  Begin
        GetStringCSV(ListMap.Strings[j],SQLMap.Strings[j],FileMap.strings[j]);
   end;

//Zip(path);
end;