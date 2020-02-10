SET TERM ^ ;

create or alter procedure PR_WAREBASE_PROAPTEKA
returns (
    STOCKBALANCEDATE DM_TEXT,
    DEPARTMENTCODE DM_TEXT,
    SUPPLIERCODE DM_TEXT,
    INVOICENUM DM_TEXT,
    INVOICEDATE DM_DATE,
    BARCODE DM_TEXT,
    PRICEWHOLEBUY DM_TEXT,
    PRICERETAIL DM_TEXT,
    BESTBEFORE DM_TEXT,
    GOODSCODE DM_TEXT,
    QUANTITY DM_DOUBLE,
    PRICEWHOLEBUYWITHOUTVAT DM_TEXT,
    PVATWHOLEBUY DM_DOUBLE,
    PRICERETAILWITHOUTVAT DM_TEXT,
    PVATWHOLERETAIL DM_DOUBLE,
    QUANTITYSUM DM_DOUBLE,
    SERIES DM_TEXT,
    IDSTORE DM_TEXT,
    IDDEPARTMENT DM_TEXT)
as
declare variable REP_DATE DM_DATETIME;
declare variable DATEEND DM_DATETIME;
declare variable Q_DATE DM_DATETIME;
declare variable MAXDATE DM_DATETIME;
declare variable PART_ID DM_ID;
declare variable QUANT DM_DOUBLE;
begin
--определяем дату за которую формируем отчет
if (current_time>'23:00:00') then rep_date=current_timestamp; else rep_date=dateadd(day,-1,current_timestamp);--если отчет формируется раньше 23-00 то выгружаем данные за вчера
rep_date=cast(cast(rep_date as date)||' 00:00:01' as dm_datetime);--начало периода

dateend=cast(cast(rep_date as date)||' 23:59:59' as dm_datetime);--конец периода

--maxdate=(select max(plm.doc_commitdate)from partner_load plm );--Дата последней выгрузки
--mindate=(select min(plm.doc_commitdate)from partner_load plm );--Дата самых старых данных в выгрузке
--если данных нет в таблице то выгружаем c начала квартала
     if (extract(month from rep_date) in (1,2,3)) then q_date='01.01.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (4,5,6)) then q_date='01.04.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (7,8,9)) then q_date='01.07.'||extract(year from rep_date)||' 00:00:01';
     if (extract(month from rep_date) in (10,11,12)) then q_date='01.10.'||extract(year from rep_date)||' 00:00:01';


--if (maxdate is null) then rep_date=q_date;
--
--if (rep_date<>maxdate) then
maxdate=rep_date; -- Если дата выгрузки больше или меньше даты последней выгрузки, выгружаем с даты последних данных



--if (mindate<:dateend-93) then delete from partner_load where doc_commitdate<:dateend-93;-- Удаляет даные относящиеся к предыдущему периоду выгрузки (прошлый квартал)
--
--if ((select first 1 part_id from partner_load_begin where partner_load_begin.q_date=:q_date )is not null) then delete from partner_load_begin where partner_load_begin.q_date=:q_date;
--insert into partner_load_begin(part_id,quant, q_date)
--for  select dd.part_id,cast(abs(sum(dd.quant)) as dm_double),:q_date from doc_detail dd where dd.doc_commitdate<:q_date group by dd.part_id having abs(sum(dd.quant))>0.001;


     while (rep_date<dateadd(day,1,dateend))  do
      begin
         for
          select
                q.part_id,
                sum(q.quant)
          from
             (  select
                 dd.part_id,
                 sum(dd.quant) as quant
                 from doc_detail dd
                 where dd.doc_commitdate between :q_date and :rep_date
                 group by dd.part_id ) q
                group by part_id
                having sum(q.quant)>0.001
            into  :part_id, :quant  do
         begin
             for select
                (select s from utpr_datetostr(:rep_date)) as StockBalanceDate,
                '' as DepartmentCode,
                (select iif(pr.agent_id>0,pr.agent_id,'999999')  from pr_getmotherpart(p.id) pr)as SupplierCode,
                (select (select docs.docnum from docs where docs.id=pr.doc_id)  from pr_getmotherpart(p.id) pr) as InvoiceNum,
                (select (select docs.docdate from docs where docs.id=pr.doc_id)  from pr_getmotherpart(p.id) pr) as InvoiceDate,

                w.barcode as Barcode ,
                cast (abs(p.price_o) as numeric(9,2)) as PriceWholeBuy,
                cast (abs(p.price) as numeric(9,2)) as PriceRetail,
                (select s from utpr_datetostr(iif (p.godendo is not null, cast(p.godendo as date),cast('01.01.1900' as date)))) as BestBefore,
                :part_id as GoodsCode,
                :quant as Quantity,
                cast(p.price_o - (cast(p.price_o - abs(p.price_o/(1+(p.nds/100)))as numeric(9,2)))as numeric(9,2)) as PriceWholebuyWithoutVat,
                cast(p.price_o - abs(p.price_o/(1+(p.nds/100)))as numeric(9,2)) as PvatWholeBuy,
                cast(p.price - (coalesce(cast(p.price-abs(p.price/(1+((select deps.ndsr from deps where deps.id = p.dep)/100)))as numeric(9,2)),0))as numeric(9,2))  as PriceRetailWithoutVat,
             --   cast(p.price - abs(p.price/(1+((cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)))/100)))as numeric(9,2)) as PVatWholeRetail,
                coalesce(cast(p.price-abs(p.price/(1+((select deps.ndsr from deps where deps.id = p.dep)/100)))as numeric(9,2)),0) as PVatWholeRetail,
                :quant as QuantitySum,
                p.seria as Series,
                '10000' as IDstore,
                '10000' as IDDepartment
            from parts p
                left join docs d on d.id=p.doc_id
                left join wares w on w.id=p.ware_id
                left join vals v_izg on v_izg.id=w.izg_id
                left join vals v_strana on v_strana.id=w.country_id
                left join vals v_sname on v_sname.id=w.name_id
        
                where p.id = :part_id
                 into  :StockBalanceDate,:DepartmentCode, :SupplierCode, :InvoiceNum,:InvoiceDate,  :Barcode, :PriceWholeBuy, :PriceRetail,:BestBefore,:GoodsCode, :Quantity,
                 :PriceWholebuyWithoutVat, :PvatWholeBuy,:PriceRetailWithoutVat,:PVatWholeRetail,:QuantitySum,:Series,:IDStore,:IDDepartment
                 do
                 suspend;

         end
     rep_date=dateadd(day,1,rep_date);
     end
    -- UPDATE params set PARAM_VALUE=(select s from utpr_datetostr((select max(insertdt)from partner_load))) WHERE params.param_id='PARTNER_LAST' ;
     suspend;
   --

end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT EXECUTE ON PROCEDURE UTPR_DATETOSTR TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT EXECUTE ON PROCEDURE PR_GETMOTHERPART TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT SELECT ON DOCS TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT SELECT ON DEPS TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT SELECT ON PARTS TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT SELECT ON WARES TO PROCEDURE PR_WAREBASE_PROAPTEKA;
GRANT SELECT ON VALS TO PROCEDURE PR_WAREBASE_PROAPTEKA;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_WAREBASE_PROAPTEKA TO SYSDBA;