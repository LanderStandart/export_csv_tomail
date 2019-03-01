select
           d.id as IdLotMovement,
           '1' as DepartmentCode,
           d.agent_id as IDDepartment,
           '1' as IDDepartmentTo,
           dd.part_id as GoodsCode,
           (select docs.agent_id from docs where docs.id=p.doc_id) as SupplierCode,
           cast(trunc(abs(dd.quant),0) as numeric (4,0)) as Quantity,
           (select docs.docnum from docs where docs.id=p.doc_id) as InvoiceNum,
           cast((select docs.docdate from docs where docs.id=p.doc_id)as date) as InvoiceDate,
           d.docnum as SaleStuNum,
           d.docdate as SaleStuDate,
           iif(d.doc_type in (3,9), d.id,'') as ChequeID,
           iif(d.doc_type in (3,9),d.docnum,'') as ChequeNum,
           iif(d.doc_type in (3,9),d.commitdate,'') as ChequeDateModified,
           iif((d.doc_type in (3,9) and d.summ1<>0 and d.summ2=0),'CASH',iif((d.doc_type in (3,9) and d.summ1=0 and d.summ2<>0),'P_CARD',iif(d.doc_type in (3,9),'MIXED','')))as ChequeType,
           iif (d.doc_type=3,'SUB',iif(d.doc_type=9,'RETURN','')) as ChequePaymentType,
           iif(d.doc_type in (3,9),d.creater,'') as ChequeUserNum,
           iif(d.doc_type in (3,9),'Cheque',iif(d.doc_type=11,'Invoice_Out',iif(d.doc_type=4,'ActReturnToContractor',iif(d.doc_type=6,'MoveSub',''))))as SaleDocType,
           cast(p.price_o as numeric (9,2)) as PriceWholeBuy,
          cast(p.nds as numeric (3,0)) as VatWholeBuy,
          cast(p.sum_ndso as numeric(9,2))as PvatWholeBuy,
          cast(dd.price as numeric(9,2)) as PriceRetail,
          cast((select deps.ndsr from deps where deps.id = p.dep)as numeric (3,0)) as VatWholeRetail,
          cast(abs(dd.sum_ndsr)as numeric(9,2)) as PVatWholeRetail,
          iif(d.doc_type in (3,9),dd.discount,'') as Discount,
          cast(p.godendo as date)as BestBefore,
          p.seria as Series,
          'PROC' as DocState,
          '1' as Idstore,
          iif(d.doc_type=6,d.agent_id,'') as IDStoreTO

            from doc_detail dd

  inner join docs d on d.id = dd.doc_id  and d.doc_type in (3,9,11,4,6)
  inner join agents a on a.id = d.agent_id

  left join parts p on dd.part_id=p.id
  join WARES w on p.ware_id=w.id
  inner join vals vname on w.name_id=vname.id
  inner join vals vorig_izg on w.orig_izg_id=vorig_izg.id
  inner join vals vcountry on w.country_id=vcountry.id
  where  dd.doc_commitdate between '01.05.2018' and '11.07.2018' order by d.docdate