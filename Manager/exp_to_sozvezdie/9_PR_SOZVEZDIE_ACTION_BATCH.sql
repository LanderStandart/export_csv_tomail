SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_ACTION_BATCH (
    DEPARTMENT_CODE DM_ID,
    DATE_START DM_DATETIME,
    DATE_END DM_DATETIME,
    IFFIRST DM_ID)
returns (
    MAP_BATCH_ID DM_TEXT,
    MAP_PHARMACY_ID DM_TEXT,
    MAP_PHARMACY_NAME DM_TEXT,
    NOMENCLATURE_ID DM_TEXT,
    MAP_NOMENCLATURE_NAME DM_TEXT,
    MAP_PRODUCT_CODE DM_TEXT,
    MAP_PRODUCT_NAME DM_TEXT,
    PRODUCER_ID DM_TEXT,
    MAP_PRODUCER_CODE DM_TEXT,
    MAP_PRODUCER_NAME DM_TEXT,
    PRODUCER_COUNTRY_ID DM_TEXT,
    MAP_PRODUCER_COUNTRY_CODE DM_TEXT,
    MAP_PRODUCER_COUNTRY_NAME DM_TEXT,
    MAP_SUPPLIER_CODE DM_TEXT,
    MAP_SUPPLIER_TIN DM_TEXT,
    SUPPLIER_NAME DM_TEXT,
    BATCH_DOC_DATE DM_TEXT,
    BATCH_DOC_NUMBER DM_TEXT,
    PURCHASE_PRICE_NDS DM_TEXT,
    PURCHASE_NDS DM_TEXT,
    RETAIL_PRICE_NDS DM_TEXT,
    RETAIL_NDS DM_TEXT,
    BARCODE DM_TEXT,
    SIGN_COMISSION DM_TEXT,
    NOMENCLATURE_CODES DM_TEXT)
as
begin
if (:iffirst=0) then
     begin
    delete from sozvezdie_action_batch where sozvezdie_action_batch.firsttime=0;
     execute procedure pr_sozvezdie_batch (:date_start,:date_end,:iffirst);
     delete from sozvezdie_action_batch1 where sozvezdie_action_batch1.real_quant_beg is null;
     insert into sozvezdie_action_batch1 (map_batch_id,
               map_pharmacy_id,
               map_pharmacy_name,
               nomenclature_id,
               map_nomenclature_name,
               map_product_code,
               map_product_name,
               producer_id,
               map_producer_code,
               map_producer_name,
               producer_country_id,
               map_producer_country_code,
               map_producer_country_name,
               map_supplier_code,
               map_supplier_tin,
               supplier_name,
               batch_doc_date,
               batch_doc_number,
               purchase_price_nds,
               purchase_nds,
               retail_price_nds,
               retail_nds,
               barcode,
               sign_comission,
               nomenclature_codes)
           select distinct
            p.map_batch_id as map_batch_id,
            :department_code as map_pharmacy_id,
            (select p.param_value  from params p where p.param_id='ORG_NAME_SHORT')as map_pharmacy_name,
            '' as nomenclature_id,
            vname.svalue as map_nomenclature_name,
            '' as map_product_code,
            '' as map_product_name,
            '' as producer_id,
            w.orig_izg_id as map_producer_code,
            vorig_izg.svalue as map_producer_name,
            '' as producer_country_id,
            w.country_id as map_producer_country_code,
            vcountry.svalue as map_producer_country_name,
            d.agent_id as map_supplier_code,
            coalesce(a.inn, '') as map_supplier_tin,
            a.caption as supplier_name,
            (select RESULT from pr_sozvezdie_format_datetime(d.commitdate,0)) as batch_doc_date,
            d.docnum as batch_doc_number,
            cast (p1.price_o as numeric(10,2)) as purchase_price_nds,
            coalesce( cast((select round(deps.ndsr,0) from deps where deps.id = p1.dep)as dm_text),'') as purchase_nds,
            cast (p1.price as numeric(10,2)) as retail_price_nds,
            cast (p1.nds as numeric(9,0)) as retail_nds,
            iif(char_length (w.barcode)>14,'',w.barcode) as barcode,
            '0' as sign_comission,
            w.name_id as nomenclature_codes
         from  SOZVEZDIE_ACTION_BATCH  p
         left join parts p1 on p1.id=p.map_batch_id
        -- left join doc_detail dd on dd.part_id=p.part_id
         left  join docs d on d.id = p1.doc_id --and d.doc_type in (1,2,20)
         left join agents a on a.id=d.agent_id
         left join WARES w on p1.ware_id=w.id
         left join vals vname on w.name_id=vname.id
         left join vals vorig_izg on w.orig_izg_id=vorig_izg.id
         left join vals vcountry on w.country_id=vcountry.id;
        --where
        --  exists(select docs.docdate from docs left join doc_detail dd on dd.part_id=p.map_batch_id where docs.docdate  between :date_start and :date_en


      suspend;
     end
else
begin
   delete from sozvezdie_action_batch where sozvezdie_action_batch.firsttime=1;
    execute procedure pr_sozvezdie_batch (:date_start,:date_end,:iffirst);
     delete from sozvezdie_action_batch1 where sozvezdie_action_batch1.real_quant_beg is not null;
     insert into sozvezdie_action_batch1 (map_batch_id,
               map_pharmacy_id,
               map_pharmacy_name,
               nomenclature_id,
               map_nomenclature_name,
               map_product_code,
               map_product_name,
               producer_id,
               map_producer_code,
               map_producer_name,
               producer_country_id,
               map_producer_country_code,
               map_producer_country_name,
               map_supplier_code,
               map_supplier_tin,
               supplier_name,
               batch_doc_date,
               batch_doc_number,
               purchase_price_nds,
               purchase_nds,
               retail_price_nds,
               retail_nds,
               barcode,
               sign_comission,
               nomenclature_codes)
      select
            p.map_batch_id as map_batch_id,
            :department_code as map_pharmacy_id,
            (select p.param_value  from params p where p.param_id='ORG_NAME_SHORT')as map_pharmacy_name,
            '' as nomenclature_id,
            vname.svalue as map_nomenclature_name,
            '' as map_product_code,
            '' as map_product_name,
            '' as producer_id,
            w.orig_izg_id as map_producer_code,
            vorig_izg.svalue as map_producer_name,
            '' as producer_country_id,
            w.country_id as map_producer_country_code,
            vcountry.svalue as map_producer_country_name,
            d.agent_id as map_supplier_code,
            a.inn as map_supplier_tin,
            a.caption as supplier_name,
            (select RESULT from pr_sozvezdie_format_datetime(d.commitdate,0)) as batch_doc_date,
            d.docnum as batch_doc_number,
            cast (p1.price_o as numeric(10,2)) as purchase_price_nds,
            cast((select deps.ndsr from deps where deps.id = p1.dep)as numeric (3,0)) as purchase_nds,
            cast (p1.price as numeric(10,2)) as retail_price_nds,
            cast (p1.nds as numeric(9,0)) as retail_nds,
             iif(char_length (w.barcode)>14,'',w.barcode) as barcode,
            '0' as sign_comission,
            w.name_id as nomenclature_codes
         from SOZVEZDIE_ACTION_BATCH  p

         left join parts p1 on p1.id=p.map_batch_id
         left join docs d on d.id = p1.doc_id --and d.doc_type in (1,2,20)
         left join agents a on a.id=d.agent_id
         left join WARES w on p1.ware_id=w.id
         left join vals vname on w.name_id=vname.id
         left join vals vorig_izg on w.orig_izg_id=vorig_izg.id
         left join vals vcountry on w.country_id=vcountry.id;



      suspend;
     end
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,DELETE ON SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT,INSERT,DELETE ON SOZVEZDIE_ACTION_BATCH1 TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON PARAMS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON DEPS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON PARTS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON AGENTS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON WARES TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT SELECT ON VALS TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_BATCH TO SYSDBA;