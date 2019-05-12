select
dd.part_id,
cast(d.docdate as date)as docdate,
(select (select a.caption from agents a where a.id=pr.agent_id) from pr_getmotherpart(dd.part_id) pr)as docagent,
left(d.docnum,iif(position(' ',d.docnum)=0,char_length(d.docnum), position(' ',d.docnum)))as docnum,
 (select a.inn from  agents a where d.agent_id=a.id)as INN,
w.izg_id,v_izg.svalue as sizg,v_strana.svalue as scountry,
v_sname.svalue as sname,w.barcode,p.price_o,p.price,cast(p.godendo as date) as godendo_date,p.seria,p.barcode,
sum(dd.quant)as quant
 from doc_detail dd
join parts p on p.id=dd.part_id
join docs d on d.id=p.doc_id
join wares w on w.id=p.ware_id
join vals v_izg on v_izg.id=w.izg_id
join vals v_strana on v_strana.id=w.country_id
join vals v_sname on v_sname.id=w.name_id


where dd.doc_commitdate<='01.05.2018'
group by sname,dd.part_id,docnum,docdate,docagent,agent_id,w.izg_id,sizg,scountry,w.barcode,p.price_o,p.price,godendo_date,p.seria,p.barcode
having abs(sum(dd.quant))<0.001