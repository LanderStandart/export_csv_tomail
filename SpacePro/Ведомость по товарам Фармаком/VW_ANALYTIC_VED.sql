/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Views                                  ***/
/******************************************************************************/


/* View: VW_ANALYTIC_VED */
CREATE OR ALTER VIEW VW_ANALYTIC_VED(
    ID,
    QUANT,
    SUMMA,
    PART_ID,
    PRICE_M,
    SNAME,
    G$PROFILE_ID,
    PROFILE_NAME,
    SGROUP,
    ANALITIC_UUID,
    SAGENT,
    SIZG,
    SUMMA_O,
    QUANT_PRIHOD,
    SUMMA_PRIHOD,
    SUMMA_O_PRIHOD,
    QUANT_PP,
    QUANT_RP,
    QUANT_OTHER,
    QUANT_BEG,
    QUANT_END,
    PRICE,
    PRICE_O,
    WARES_SET_D$UUID,
    PRICE_KON,
    PRICE_O_KON,
    BARCODE)
AS
select
    a.id,
    cast(a.quant as numeric(15,2)),
    a.summa,
    a.part_id,
   -- (select ww. from wares_set_detail ww where ww.ware_id=a.w),
    price_m,
    a.sname,
    a.g$profile_id,
    (select g.caption from g$profiles g where g.id=a.g$profile_id),
    '',
    a.analitic_uuid,
    agents.caption,
    a.sizg,
    cast(a.quant*p.price_o as numeric(15,2)),
    cast(quant_prihod as numeric(15,2)),
    cast(quant_prihod*p.price as numeric(15,2)),
    cast(quant_prihod*p.price_o as numeric(15,2)),
    cast(QUANT_PP as numeric(15,2)),
    cast(quant_rp as numeric(15,2)),
    cast(quant_other as numeric(15,2)),
    cast(quant_beg as numeric(15,2)),
    cast(quant_end as numeric(15,2)),
    p.price,
    p.price_o,
    WARES_SET_D$UUID,
    cast((quant_end*price) as numeric(15,2)),
    cast((quant_end*price_o) as numeric(15,2)),
    w.barcode
from analytic_VED a
--left join agents on agents.global_id=a.agent_id-- and agents.g$profile_id=a.g$profile_id
left join agents on agents.id=a.agent_id  --заявка №930798 Поломова М.М.
left join parts p on p.id=a.part_id and p.g$profile_id=a.g$profile_id
left join wares w on w.id=p.ware_id
;




/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
