select first 1000
    d.docdate, 
    (select u.username from users u where u.id=d.owner and u.g$profile_id=dd.g$profile_id) as Kassir,
    vname.svalue as SNAME,
    ''Аптека ''||(select left(g.caption,position('' '' in g.caption)) from g$profiles g where g.id=dd.g$profile_id)as Profile,
    ''Ижевск'' as City,
    (select substring(g.caption from position('' '' in g.caption) for position(''тел'' in g.caption)-position('' '' in g.caption)) from g$profiles g where g.id=w.g$profile_id) as adress,
     -dd.quant as quant,
     -dd.summa_o as summa,
     w.barcode
from doc_detail dd
 inner join docs d on d.id=dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type = 3
 left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
 inner join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
 inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
 inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id and upper(vorig_izg.svalue) containing ''ЭВАЛАР''

where dd.doc_commitdate between ''01.01.2018'' and ''01.02.2018''
order by dd.doc_commitdate