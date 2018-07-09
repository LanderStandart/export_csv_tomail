 uses
  unDM, cfIBUtils, unFrameCustomDict, need, cfUtils,
  inifiles, unMain,  unFRFramePreview,
  Classes, Graphics, Controls, Forms, Dialogs, AdvPanel,
  AdvGlowButton, DB, IBDatabase, IBQuery, ExtCtrls, StdCtrls,
  dxExEdtr, dxCntner, dxTL, dxDBCtrl, dxDBTL, Buttons, ComCtrls,
  AdvOfficePager,dateUtils, ImgList, ShellApi,Windows,sysUtils;
const
 path='\Standart-N\partner\';

procedure InitVar;
var
 SaleMap,BuyMap,BaseMap,SuppMap,DepMap,GoodMap,StoreMap,DiscMap,SaleDiscMap,UserMap:TStringList;
Begin
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