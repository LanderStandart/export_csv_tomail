SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_ACTION_MOVE (
    DEPARTMENTCODE DM_TEXT,
    DATE_START DM_DATETIME,
    DATE_END DM_DATETIME,
    DATE_STOP DM_DATETIME,
    IFFIRST DM_ID)
returns (
    MAP_PHARMACY_ID DM_TEXT,
    DISTRIBUTION_ID DM_TEXT,
    BATCH_ID DM_TEXT,
    DOC_DATE DM_TEXT,
    DOC_TYPE DM_TEXT,
    DOC_NUMBER DM_TEXT,
    POS_NUMBER DM_TEXT,
    CHECK_NUMBER DM_TEXT,
    CHECK_UNIQUE_NUMBER DM_TEXT,
    QUANTITY DM_TEXT,
    PURCHASE_SUM_NDS DM_TEXT,
    RETAIL_SUM_NDS DM_TEXT,
    DISCOUNT_SUM DM_TEXT,
    CASHIER_ID DM_TEXT,
    CASHIER_FULL_NAME DM_TEXT,
    CASHIER_TIN DM_TEXT,
    RESALE_SIGN DM_TEXT)
as
begin
if (:iffirst=0) then
    begin
    DELETE from sozvezdie_action_move where firsttime is null;
    INSERT INTO sozvezdie_action_move (map_pharmacy_id,
            distribution_id,
            batch_id,
            doc_date,
            doc_type,
            doc_number,
            pos_number,
            check_number,
            check_unique_number,
            quantity,
            purchase_sum_nds,
            retail_sum_nds,
            discount_sum,
            cashier_id,
            cashier_full_name,
            cashier_tin,
            resale_sign)
      select
      :departmentcode as map_pharmacy_id,
               d.id||dd.part_id as distribution_id,
               dd.part_id as batch_id,
               (select RESULT from pr_sozvezdie_format_datetime(d.commitdate,null)) as  doc_date,
               case d.doc_type
                when 1 then 3
                when 2 then 6
                when 3 then 2
                when 4 then 5
                when 5 then 8
                when 6 then 7
                when 17 then 8
                when 10 then 8
                when 9 then 4
                when 11 then 1
                when 20 then 9
                when 8 then iif (dd.quant>0,9,8)
                when 7 then iif (dd.quant>0,9,8)
				when 18 then iif (dd.quant>0,9,8)
				when 23 then iif (dd.quant>0,9,8)
				when 32 then 8
               end as doc_type,
    
              coalesce( iif(d.doc_type=3,(select d1.docnum from docs d1 where cast(d1.commitdate as date)=d.datez and d1.vshift=d.vshift and d1.doc_type=13),
                left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))), ' ')as doc_number,
              coalesce( iif(d.doc_type=3,d.device_num,''),' ')as pos_number,
               iif(d.doc_type=3,d.docnum,'')as check_number,
               iif(d.doc_type=3,d.docnum,'')as check_unique_number,
               cast(abs(dd.quant)as numeric(10,6)) as quantity,
             cast(abs(dd.summa_o)as numeric(10,2)) as purchase_sum_nds,
             cast(abs(dd.summa)+abs(dd.sum_dsc) as numeric(10,2)) as retail_sum_nds,
             cast(abs(dd.sum_dsc) as numeric(9,2)) as discount_sum,
             u.d$uuid as cashier_id,
             u.username as cashier_full_name,
             coalesce(u.inn,'') as cashier_tin,
             '0' as resale_sign
                from sozvezdie_action_batch p1

       join doc_detail dd on dd.part_id=p1.map_batch_id
    
      inner join docs d on d.id = dd.doc_id  and d.doc_type in (1,11,10,17,2,3,4,5,6,9,8,20,7,18,23,32) and d.commitdate between :date_start and :date_end
    
     -- left join parts p on dd.part_id=p1.part_id
      join users u on u.id=d.owner
      where  --d.commitdate between :date_start and :date_end
      --and
      p1.real_quant_beg is null
       order by d.commitdate ;

      suspend;
    end
else
   begin
      DELETE from sozvezdie_action_move where firsttime is not null;
    INSERT INTO sozvezdie_action_move (map_pharmacy_id,
            distribution_id,
            batch_id,
            doc_date,
            doc_type,
            doc_number,
            pos_number,
            check_number,
            check_unique_number,
            quantity,
            purchase_sum_nds,
            retail_sum_nds,
            discount_sum,
            cashier_id,
            cashier_full_name,
            cashier_tin,
            resale_sign,
            firsttime)
      select
              :departmentcode as map_pharmacy_id,
               p.map_batch_id as distribution_id,
               p.map_batch_id as batch_id,
               (select RESULT from pr_sozvezdie_format_datetime(:date_start,null)) as  doc_date,
               '9' as doc_type,
               'Первичная выгрузка'as doc_number,
               ''as pos_number,
               ''as check_number,
               ''as check_unique_number,
               cast(abs(p.real_quant_beg)as numeric(10,6)) as quantity,
             cast(abs(p1.price_o*p.real_quant_beg)as numeric(10,2)) as purchase_sum_nds,
             cast(abs(p1.price*p.real_quant_beg) as numeric(10,2)) as retail_sum_nds,
             cast(0 as numeric(9,2)) as discount_sum,
             '' as cashier_id,
             '' as cashier_full_name,
             '' as cashier_tin,
             '0' as resale_sign,
             '1' as firsttime
                from sozvezdie_action_batch p
    
     -- left join doc_detail dd on dd.part_id=p.part_id
     -- inner join docs d on d.id = dd.doc_id --and d.doc_type in (1,11,10,17,2,3,4,5,6,9,20)
      left join parts p1 on p1.id=p.map_batch_id
      --left join users u on u.id=d.owner
     -- where  d.docdate between :date_start and :date_stop order by d.docdate
     where p.real_quant_beg>0.001;

      suspend;
    end
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON SOZVEZDIE_ACTION_MOVE TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT SELECT ON DOCS TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT SELECT ON SOZVEZDIE_ACTION_BATCH TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT SELECT ON USERS TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT SELECT ON PARTS TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_ACTION_MOVE TO SYSDBA;