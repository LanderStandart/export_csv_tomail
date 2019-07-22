SET TERM ^ ;

create or alter procedure PR_GET_DAMUMED
returns (
    XML DM_TEXT_BIG)
as
declare variable STORENAME DM_TEXT;
declare variable DRUGNAME DM_TEXT;
declare variable MANUFACTURER DM_TEXT;
declare variable COUNTRY DM_TEXT;
declare variable DOSAGE DM_TEXT;
declare variable PACKAGING DM_TEXT;
declare variable REGISTRATIONNUMBER DM_TEXT;
declare variable BALANCE numeric(15,2);
declare variable PRICE numeric(15,2);
begin
xml='<?xml version="1.0" encoding="utf-8" ?>
<drugs>';
suspend;
for select
(select xml from pr_xml_good((select params.param_value from params where params.param_id='ORG_NAME_SHORT')))as storename,
(select xml from pr_xml_good(w.sname)) as drugname,
w.sizg as manufacturer,
w.scountry as country,
'' as dosage,
'' as packaging,
'' as registrationNumber,
w.quant as balance,
w.price as price
from vw_warebase  w
where w.quant>0.001 into :storeName, :drugName, :manufacturer, :country, :dosage,:packaging,:registrationNumber,:balance,:price
do
    begin
    xml= '  <drug storeName="'||:storename||'" drugName="'||:drugname||' " manufacturer="'||:manufacturer||'" country="'||:country||
        '" dosage="'||:dosage||'" packaging="'||:packaging||'" registrationNumber="'||:registrationnumber||'" balance="'||:balance||'" price="'||:price||'"/>
';
 suspend;
    end

xml = '</drugs>';
suspend;


end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT EXECUTE ON PROCEDURE PR_XML_GOOD TO PROCEDURE PR_GET_DAMUMED;
GRANT SELECT ON PARAMS TO PROCEDURE PR_GET_DAMUMED;
GRANT SELECT ON VW_WAREBASE TO PROCEDURE PR_GET_DAMUMED;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_GET_DAMUMED TO SYSDBA;