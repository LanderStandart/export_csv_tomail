/******************************************************************************/
/***                Generated by IBExpert 09.04.2019 8:46:37                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/


CREATE GENERATOR GEN_SOZVEZDIE_ACTION_BATCH1_ID;

CREATE TABLE SOZVEZDIE_ACTION_BATCH1 (
    ID                         DM_ID /* DM_ID = BIGINT */,
    MAP_BATCH_ID               DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PHARMACY_NAME          DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    NOMENCLATURE_ID            DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_NOMENCLATURE_NAME      DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCT_CODE           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCT_NAME           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    PRODUCER_ID                DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCER_CODE          DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCER_NAME          DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    PRODUCER_COUNTRY_ID        DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCER_COUNTRY_CODE  DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PRODUCER_COUNTRY_NAME  DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_SUPPLIER_CODE          DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_SUPPLIER_TIN           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    SUPPLIER_NAME              DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    BATCH_DOC_DATE             DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    BATCH_DOC_NUMBER           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    PURCHASE_PRICE_NDS         DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    PURCHASE_NDS               DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    RETAIL_PRICE_NDS           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    BARCODE                    DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    SIGN_COMISSION             DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    NOMENCLATURE_CODES         DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    REAL_QUANT_BEG             DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    MAP_PHARMACY_ID            DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    RETAIL_NDS                 DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    XML                        DM_TEXT_BIG /* DM_TEXT_BIG = VARCHAR(10000) */
);




/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX SOZVEZDIE_ACTION_BATCH1_ID ON SOZVEZDIE_ACTION_BATCH1 (MAP_BATCH_ID);
CREATE UNIQUE INDEX SOZVEZDIE_ACTION_BATCH1_IDX1 ON SOZVEZDIE_ACTION_BATCH1 (ID, MAP_BATCH_ID);


/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: SOZVEZDIE_ACTION_BATCH1_BI */
CREATE OR ALTER TRIGGER SOZVEZDIE_ACTION_BATCH1_BI FOR SOZVEZDIE_ACTION_BATCH1
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.id is null) then
    new.id = gen_id(gen_SOZVEZDIE_ACTION_BATCH1_id,1);
end
^


/* Trigger: SOZVEZDIE_ACTION_BATCH1_BI0 */
CREATE OR ALTER TRIGGER SOZVEZDIE_ACTION_BATCH1_BI0 FOR SOZVEZDIE_ACTION_BATCH1
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_pharmacy_name is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';
  if (new.map_batch_id is null) then new.map_batch_id='';

end
^


/* Trigger: SOZVEZDIE_ACTION_BATCH1_BI1 */
CREATE OR ALTER TRIGGER SOZVEZDIE_ACTION_BATCH1_BI1 FOR SOZVEZDIE_ACTION_BATCH1
ACTIVE BEFORE INSERT POSITION 0
AS
begin
 new.map_pharmacy_name=replace(new.map_pharmacy_name,'&','&amp;');
 new.map_pharmacy_name=replace(new.map_pharmacy_name,'<','&lt;');
 new.map_pharmacy_name=replace(new.map_pharmacy_name,'>','&gt;');
 new.map_pharmacy_name=replace(new.map_pharmacy_name,'''','&apos;');
 new.map_pharmacy_name=replace(new.map_pharmacy_name,'"','&quot;');

 new.map_nomenclature_name=replace(new.map_nomenclature_name,'&','&amp;');
 new.map_nomenclature_name=replace(new.map_nomenclature_name,'<','&lt;');
 new.map_nomenclature_name=replace(new.map_nomenclature_name,'>','&gt;');
 new.map_nomenclature_name=replace(new.map_nomenclature_name,'''','&apos;');
 new.map_nomenclature_name=replace(new.map_nomenclature_name,'"','&quot;');

  new.map_product_name=replace(new.map_product_name,'&','&amp;');
 new.map_product_name=replace(new.map_product_name,'<','&lt;');
 new.map_product_name=replace(new.map_product_name,'>','&gt;');
 new.map_product_name=replace(new.map_product_name,'''','&apos;');
 new.map_product_name=replace(new.map_product_name,'"','&quot;');

 new.map_producer_name=replace(new.map_producer_name,'&','&amp;');
 new.map_producer_name=replace(new.map_producer_name,'<','&lt;');
 new.map_producer_name=replace(new.map_producer_name,'>','&gt;');
 new.map_producer_name=replace(new.map_producer_name,'''','&apos;');
 new.map_producer_name=replace(new.map_producer_name,'"','&quot;');

 new.map_producer_country_name=replace(new.map_producer_country_name,'&','&amp;');
 new.map_producer_country_name=replace(new.map_producer_country_name,'<','&lt;');
 new.map_producer_country_name=replace(new.map_producer_country_name,'>','&gt;');
 new.map_producer_country_name=replace(new.map_producer_country_name,'''','&apos;');
 new.map_producer_country_name=replace(new.map_producer_country_name,'"','&quot;');

 new.supplier_name=replace(new.supplier_name,'&','&amp;');
 new.supplier_name=replace(new.supplier_name,'<','&lt;');
 new.supplier_name=replace(new.supplier_name,'>','&gt;');
 new.supplier_name=replace(new.supplier_name,'''','&apos;');
 new.supplier_name=replace(new.supplier_name,'"','&quot;');
 
 new.batch_doc_number=replace(new.batch_doc_number,'&','&amp;');
 new.batch_doc_number=replace(new.batch_doc_number,'<','&lt;');
 new.batch_doc_number=replace(new.batch_doc_number,'>','&gt;');
 new.batch_doc_number=replace(new.batch_doc_number,'''','&apos;');
 new.batch_doc_number=replace(new.batch_doc_number,'"','&quot;');

 select digits from extract_digits(new.barcode) into new.barcode;
end
^


/* Trigger: SOZVEZDIE_ACTION_BATCH1_BIU0 */
CREATE OR ALTER TRIGGER SOZVEZDIE_ACTION_BATCH1_BIU0 FOR SOZVEZDIE_ACTION_BATCH1
ACTIVE BEFORE INSERT OR UPDATE POSITION 1
AS
begin
  new.xml='<batch>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_batch_id>'||new.map_batch_id||'</map_batch_id>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_pharmacy_id>'||new.map_pharmacy_id||'</map_pharmacy_id>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_pharmacy_name>'||new.MAP_PHARMACY_NAME||'</map_pharmacy_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<nomenclature_id>'||new.nomenclature_id||'</nomenclature_id>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_nomenclature_name>'||new.map_nomenclature_name||'</map_nomenclature_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_product_code>'||new.map_product_code||'</map_product_code>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_product_name>'||new.map_product_name||'</map_product_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<producer_id>'||new.producer_id||'</producer_id>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_producer_code>'||new.map_producer_code||'</map_producer_code>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_producer_name>'||new.map_producer_name||'</map_producer_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<producer_country_id>'||new.producer_country_id||'</producer_country_id>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_producer_country_code>'||new.map_producer_country_code||'</map_producer_country_code>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
   new.xml=new.xml||'<map_producer_country_name>'||new.map_producer_country_name||'</map_producer_country_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_supplier_code>'||new.map_supplier_code||'</map_supplier_code>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<map_supplier_tin>'||coalesce(new.map_supplier_tin, '')||'</map_supplier_tin>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<supplier_name>'||new.supplier_name||'</supplier_name>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<batch_doc_date>'||new.batch_doc_date||'</batch_doc_date>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
    new.xml=new.xml||'<batch_doc_number>'||new.batch_doc_number||'</batch_doc_number>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<purchase_price_nds>'||new.purchase_price_nds||'</purchase_price_nds>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
   new.xml=new.xml||'<purchase_nds>'||new.purchase_nds||'</purchase_nds>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<retail_price_nds>'||new.retail_price_nds||'</retail_price_nds>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<retail_nds>'||new.retail_nds||'</retail_nds>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<barcode>'||trim(new.barcode)||'</barcode>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'<sign_comission>'||new.sign_comission||'</sign_comission>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
   new.xml=new.xml||'<nomenclature_codes>'||'<code owner="map">'||new.nomenclature_codes||'</code>'||'</nomenclature_codes>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;
  new.xml=new.xml||'</batch>'||ASCII_CHAR(13)||ASCII_CHAR(10) ;

end
^


/* Trigger: SOZVEZDIE_ACTION_BATCH1_BIU10 */
CREATE OR ALTER TRIGGER SOZVEZDIE_ACTION_BATCH1_BIU10 FOR SOZVEZDIE_ACTION_BATCH1
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
begin
  if (new.purchase_nds is null) then new.purchase_nds='';
    if (new.map_supplier_tin is null) then new.map_supplier_tin='';
end
^


SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
