--update doc_detail dd set dd.doc_commitdate=(select cast(d.commitdate as dm_date) from docs d where d.id=dd.doc_id)
--where dd.doc_commitdate<>(select cast(d.commitdate as dm_date) from docs d where d.id=dd.doc_id)

update doc_detail dd
set price = (select price from parts p where p.id = dd.part_id)
where abs(price -(select price from parts p where p.id = dd.part_id))>0.01 or (price is null) ;

update doc_detail
set summa = (price*quant+sum_dsc)
where abs(summa-(price*quant+sum_dsc))>0.01 or (summa is null) ;

update docs d set d.summa = (select sum(dd.quant*p.price+dd.sum_dsc) from doc_detail dd left join parts p on dd.part_id = p.id where dd.doc_id = d.id)
where abs(d.summa - (select sum(dd.quant*p.price+dd.sum_dsc) from doc_detail dd left join parts p on dd.part_id = p.id where dd.doc_id = d.id)) > 0.01 or (d.summa is null) ;

update doc_detail dd1
set dd1.summa_o = (select p.price_o*dd.quant from doc_detail dd left join parts p on dd.part_id = p.id where dd.id = dd1.id)
where abs(dd1.summa_o - (select p.price_o*dd.quant from doc_detail dd left join parts p on dd.part_id = p.id where dd.id = dd1.id)) > 0.01 or (dd1.summa_o is null) ;

update docs d
set d.summa_o = (select sum(dd.quant*p.price_o) from doc_detail dd left join parts p on dd.part_id = p.id where dd.doc_id = d.id)
where abs(summa_o - (select sum(dd.quant*p.price_o) from doc_detail dd left join parts p on dd.part_id = p.id where dd.doc_id = d.id)) > 0.01 or (d.summa_o is null) and (d.status = 1);


update doc_detail dd set
 sum_ndsr = (QUANT * PRICE) *
(select D.NDSR from DEPS D where D.ID = (select dep from parts p where p.id = dd.part_id)) /
  (100 + (select D.NDSR from DEPS D where D.ID = (select dep from parts p where p.id = dd.part_id)))
  where dd.doc_commitdate>'01.01.2019' and
  coalesce(sum_ndsr,0)-coalesce(
  (QUANT * PRICE) *
(select D.NDSR from DEPS D where D.ID = (select dep from parts p where p.id = dd.part_id)) /
  (100 + (select D.NDSR from DEPS D where D.ID = (select dep from parts p where p.id = dd.part_id)))
  ,0) > 0.01