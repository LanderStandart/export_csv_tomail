SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_ACTION_REMHANT (
    DEPARTMENTCODE DM_TEXT,
    DATE_START DM_DATETIME,
    DATE_END DM_DATETIME,
    IFFIRST DM_ID)
returns (
    MAP_PHARMACY_ID DM_TEXT,
    BATCH_ID DM_TEXT,
    DATES DM_TEXT,
    OPENING_BALANCE numeric(15,6),
    CLOSING_BALANCE numeric(15,6),
    INPUT_RETAIL_PRICE_BALANCE numeric(15,2),
    INPUT_PURCHASING_PRICE_BALANCE numeric(15,2),
    OUTPUT_RETAIL_PRICE_BALANCE numeric(15,2),
    OUTPUT_PURCHASING_PRICE_BALANCE numeric(15,2),
    PRICE numeric(15,2),
    PRICE_O numeric(15,2))
as
declare variable DOC_ID DM_ID;
declare variable DATESQL DM_DATETIME;
begin
if (:iffirst=0) then
    begin
    delete from sozvezdie_action_remhant where sozvezdie_action_remhant.batch_id is not null;
     --date_start=date_start;
     while (date_start<>current_date+1) do
     begin
      for select id from docs where docs.commitdate between :date_start and :date_end into :doc_id
      do
      begin
      insert into sozvezdie_action_remhant (map_pharmacy_id,
       batch_id,
       dates,
       opening_balance,
       closing_balance,
       input_retail_price_balance,
       input_purchasing_price_balance,
       output_retail_price_balance,
       output_purchasing_price_balance,
       price,
       price_o)
        select
                query.map_pharmacy_id,
                query.batch_id,
                query.dates,
                cast(query.opening_balance as dm_double)as opening_balance,
                cast(query.closing_balance as dm_double)as closing_balance,
                cast(query.opening_balance * query.price as dm_double)as input_retail_price_balance,
                cast(query.opening_balance * query.price_o as dm_double)as input_purchasing_price_balance,
                cast(query.closing_balance * query.price as dm_double)as output_retail_price_balance,
                cast(query.closing_balance * query.price_o as dm_double)as output_purchasing_price_balance,
                cast(query.price as dm_double),
                cast(query.price_o as dm_double)
            from
                (select
                    :departmentcode as map_pharmacy_id,
                    sab.map_batch_id as batch_id,
                    (select result from pr_sozvezdie_format_datetime(:date_start,0)) as dates,
    --(select cast(sum(dd1.quant) as numeric(9,4)) from doc_detail dd1 where dd1.doc_commitdate<=current_date-93 and dd1.part_id=dd.part_id)
                    (select quant from pr_get_warebase_from_date(:date_start,sab.map_batch_id))as opening_balance,
                    (select quant from pr_get_warebase_from_date(:date_end,sab.map_batch_id)) as closing_balance,
                   -- cast(sum(abs(dd.summa_o))as dm_double)as output_purchasing_price_balance,
                    cast(p.price as dm_double)as price,
                    cast(p.price_o as dm_double)as price_o
    
                  from sozvezdie_action_batch sab
    
                  join doc_detail dd on dd.doc_id =:doc_id and dd.part_id=sab.map_batch_id

                  join parts p on p.id=sab.map_batch_id
                -- inner join docs d on dd.doc_id=d.id
                  where
                    sab.real_quant_beg is null --and d.commitdate between :date_start and :date_end

                 group by dates,batch_id,price,price_o
                 )  query   ;

    end
     date_start=date_start+1;
     date_end=date_end+1;
     end


    suspend;
  end
else
    begin
     delete from sozvezdie_action_remhant where sozvezdie_action_remhant.batch_id is null;
      for select id from docs where docs.commitdate between :date_start and :date_end into :doc_id
      do
      begin
      insert into sozvezdie_action_remhant (map_pharmacy_id,
       batch_id,
       dates,
       opening_balance,
       closing_balance,
       input_retail_price_balance,
       input_purchasing_price_balance,
       output_retail_price_balance,
       output_purchasing_price_balance,
       price,
       price_o)
    
         select
                query.map_pharmacy_id,
                query.batch_id,
                query.dates,
                cast(0 as numeric(9,6))as opening_balance,
                cast(query.closing_balance as numeric(9,6))as closing_balance,
                cast(0 as numeric(9,2))as input_retail_price_balance,
                cast(0  as numeric(9,2))as input_purchasing_price_balance,
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
                    (select quant from pr_get_warebase_from_date(:date_start,dd.part_id))as opening_balance,
                   iif(p1.real_quant_beg =(select quant from pr_get_warebase_from_date(:date_end,dd.part_id)),(select quant from pr_get_warebase_from_date(:date_end,dd.part_id)),p1.real_quant_beg-(select quant from pr_get_warebase_from_date(:date_end,dd.part_id))) as closing_balance,
                    --cast(sum(abs(dd.summa_o))as numeric(9,2))as output_purchasing_price_balance,
                    cast(p.price as numeric(9,2))as price,
                    cast(p.price_o as numeric(9,2))as price_o

    
                           from sozvezdie_action_batch p1
    
                  join doc_detail dd on dd.doc_id =:doc_id and dd.part_id=p1.map_batch_id

                  join parts p on p.id=p1.map_batch_id
                -- inner join docs d on dd.doc_id=d.id
                  where
                    p1.real_quant_beg is not null --and d.commitdate between :date_start and :date_end

                 group by dates,batch_id,price,price_o,p1.real_quant_beg
                 )  query   ;



        end
     suspend;
end
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON SOZVEZDIE_ACTION_REMHANT TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_GET_WAREBASE_FROM_DATE TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT SELECT ON PARTS TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT TO SYSDBA;