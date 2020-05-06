select
 w.sname, abs(dd.quant) ,
dd.price, d1.docnum,d1.device_num,d1.docdate,d1.sum_dsc,(select caption from g$profiles where id=d1.g$profile_id)--,w.sizg
 from (
select
d.docnum,d.device_num,d.docdate,d.sum_dsc,d.id,d.g$profile_id
from docs d
where
d.docdate between '01.01.2020' and '31.03.2020' -->'01.04.2020'
and d.doc_type=3 --and d.g$profile_id in (10,3)
)d1
join doc_detail dd on dd.doc_id=d1.id and dd.g$profile_id=d1.g$profile_id
--join parts p on p.id=dd.part_id and p.g$profile_id=dd.g$profile_id
join wares w on w.id=dd.ware_id and  w.izg_id in (select id from vals v where upper(svalue)containing('МЕРЦ') and vtype in(3,6))