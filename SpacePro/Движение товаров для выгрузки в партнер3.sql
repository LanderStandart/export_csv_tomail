select  first 15

           iif (d.doc_type=1,10,iif(d.doc_type=3,20,d.doc_type))as d_type,
           d.docnum,
           d.docdate,
           a.caption as Supplier,
           a.inn as Supplier_INN,
           d.device_num,
           iif(d.doc_type=3,d.docnum, '')as N_Chek,
          (select first 1 u.username from users u where u.id=d.owner)as FIO_Chek,
           iif ((abs (dd.discount)>0),1,0) as disk_T,
          cast( dd.sum_dsc as numeric(9,2)) as Disk_Sum,
          dd.summa_o as Sum_Zak,
          dd.summa as Sum_Rozn,
          0 as pp_teg,
          dd.part_id as Drug_code,
          vname.svalue as Drug_name,
          w.izg_id,
          vorig_izg.svalue as Drug_Producer_Name,
          w.barcode,
          vcountry.svalue as Drug_Producer_country,
          p.price_o as Cena_Zak,
          dd.price as Cena_Rozn,
          dd.quant,
          p.seria,
          p.godendo,
          p.barcode

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id and d.g$profile_id=dd.g$profile_id and d.doc_type in (3,9)
  inner join agents a on a.id = d.agent_id and a.g$profile_id=dd.g$profile_id

  left join parts p on dd.part_id=p.id  and p.g$profile_id=dd.g$profile_id
  join WARES w on p.ware_id=w.id and p.g$profile_id=w.g$profile_id
  inner join vals vname on w.name_id=vname.id  and w.g$profile_id=vname.g$profile_id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id  and w.g$profile_id=vorig_izg.g$profile_id
  inner join vals vcountry on w.country_id=vcountry.id  and w.g$profile_id=vcountry.g$profile_id
  where dd.g$profile_id not in (99,100)
    and dd.doc_commitdate between '01.01.2018' and '01.02.2018' order by d.docdate