SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_ACTION_REMHANT (
    DEPARTMENTCODE DM_TEXT,
    DATE_START DM_DATE,
    DATE_END DM_DATE,
    IFFIRST DM_ID)
returns (
    MAP_PHARMACY_ID DM_TEXT,
    BATCH_ID DM_TEXT,
    DATES DM_TEXT,
    OPENING_BALANCE DM_TEXT,
    CLOSING_BALANCE DM_TEXT,
    INPUT_RETAIL_PRICE_BALANCE DM_TEXT,
    INPUT_PURCHASING_PRICE_BALANCE DM_TEXT,
    OUTPUT_RETAIL_PRICE_BALANCE DM_TEXT,
    OUTPUT_PURCHASING_PRICE_BALANCE DM_TEXT,
    PRICE DM_TEXT,
    PRICE_O DM_TEXT)
as
begin
if (:iffirst=0) then
    begin
      for   select
                query.map_pharmacy_id,
                query.batch_id,
                query.dates,
                cast(query.opening_balance as numeric(9,2))as opening_balance,
                cast(query.closing_balance as numeric(9,2))as closing_balance,
                cast(query.opening_balance * query.price as numeric(9,2))as input_retail_price_balance,
                cast(query.opening_balance * query.price_o as numeric(9,2))as input_purchasing_price_balance,
                cast(query.closing_balance * query.price as numeric(9,2))as output_retail_price_balance,
                cast(query.closing_balance * query.price_o as numeric(9,2))as output_purchasing_price_balance,
                cast(query.price as numeric(9,2)),
                cast(query.price_o as numeric(9,2))
            from
                (select
                    :departmentcode as map_pharmacy_id,
                    dd.part_id as batch_id,
                    (select result from pr_sozvezdie_format_datetime(:date_start,0)) as dates,
    --(select cast(sum(dd1.quant) as numeric(9,4)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)
                    (select quant from pr_get_warebase_from_date(dateadd(day,-1,:date_start),dd.part_id))as opening_balance,
                    (select quant from pr_get_warebase_from_date(:date_start,dd.part_id)) as closing_balance,
                    cast(sum(abs(dd.summa_o))as numeric(9,2))as output_purchasing_price_balance,
                    cast(p.price as numeric(9,2))as price,
                    cast(p.price_o as numeric(9,2))as price_o
    
                  from pr_sozvezdie_batch (:date_start,:date_start,0)p1
    
                 left join doc_detail dd on dd.part_id=p1.part_id
                 left join parts p on p.id=p1.part_id
                 left join docs d on dd.doc_id=d.id
                 where
                   d.docdate between :date_start||':00:00:00' and :date_start||':23:59:59'
                 group by dates,batch_id,price,price_o
                 )  query
    
      into
       :map_pharmacy_id,
       :batch_id,
       :dates,
       :opening_balance,
       :closing_balance,
       :input_retail_price_balance,
       :input_purchasing_price_balance,
       :output_retail_price_balance,
       :output_purchasing_price_balance,
       :price,
       :price_o
      do
      suspend;
    end
else
    begin
      for   select
                query.map_pharmacy_id,
                query.batch_id,
                query.dates,
                cast(0 as numeric(9,2))as opening_balance,
                cast(query.closing_balance as numeric(9,2))as closing_balance,
                cast(0 as numeric(9,2))as input_retail_price_balance,
                cast(0  as numeric(9,2))as input_purchasing_price_balance,
                cast(query.closing_balance * query.price as numeric(9,2))as output_retail_price_balance,
                cast(query.closing_balance * query.price_o as numeric(9,2))as output_purchasing_price_balance,
                cast(query.price as numeric(9,2)),
                cast(query.price_o as numeric(9,2))
            from
                (select
                    :departmentcode as map_pharmacy_id,
                    p1.part_id as batch_id,
                    (select result from pr_sozvezdie_format_datetime(:date_start,0)) as dates,
    --(select cast(sum(dd1.quant) as numeric(9,4)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)
                    (select quant from pr_get_warebase_from_date(dateadd(day,-1,:date_start),p1.part_id))as opening_balance,
                   iif(p1.quant=(select quant from pr_get_warebase_from_date(:date_end,p1.part_id)),(select quant from pr_get_warebase_from_date(:date_end,p1.part_id)),p1.quant-(select quant from pr_get_warebase_from_date(:date_end,p1.part_id))) as closing_balance,
                    --cast(sum(abs(dd.summa_o))as numeric(9,2))as output_purchasing_price_balance,
                    cast(p.price as numeric(9,2))as price,
                    cast(p.price_o as numeric(9,2))as price_o

    
                  from pr_sozvezdie_batch (:date_start,:date_start,1)p1
    
                 left join doc_detail dd on dd.part_id=p1.part_id
                 left join parts p on p.id=p1.part_id
                 left join docs d on dd.doc_id=d.id
--                 where
--                      d.docdate >= :date_end||':23:59:59'
                group by dates,batch_id,price,price_o,p1.quant
                 )  query
    
      into
       :map_pharmacy_id,
       :batch_id,
       :dates,
       :opening_balance,
       :closing_balance,
       :input_retail_price_balance,
       :input_purchasing_price_balance,
       :output_retail_price_balance,
       :output_purchasing_price_balance,
       :price,
       :price_o
      do
      suspend;
    end
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_GET_WAREBASE_FROM_DATE TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON PARTS TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT TO SYSDBA;