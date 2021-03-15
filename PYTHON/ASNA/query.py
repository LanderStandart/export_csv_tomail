import configparser
import datetime
config = configparser.ConfigParser()
config.read('./config.ini')
org_code = config.get('BASE', 'ORG_CODE')
asna_code = config.get('BASE', 'ASNA_CODE')
def_region = config.get('BASE', 'DEF_REGION')
INN = config.get('BASE', 'INN')
date_beg = config.get('BASE', 'DATE_BEG')
date_end = config.get('BASE', 'DATE_END')

if date_end =='':
    date_end ="'"+datetime.datetime.today().strftime("%d.%m.%Y")+"'"
if date_beg =='':
    date_beg = "'"+datetime.datetime.today().replace(day=1).strftime("%d.%m.%Y")+"'"




#Запрос списка контрагентов
SQL_AGENTS="select cast(a.id as varchar(255)) as ID, caption as name, coalesce(INN,'') as INN from agents a " \
           "--inner join ASNA_G$PROFILES ga on ga.id = a.g$profile_id " \
           "where  a.id > 0 --and ga.id is not null  "

#Запрос товаров
SQL_WARES="select id,replace(MGN_NAME,'—','') as name,replace(PRODUCER,'—','') as PRODUCER, COUNTRY, EAN from ASNA_GOODS where ACTUAL = 1 order by MGN_NAME"
#SQL_WARES="select w.id,w.mgn_name,w.izg_id,w.country_id,w.barcode from wares w where sname is not null and sname <>'' order by MGN_NAME "

#Запрос Движения
SQL_MOVE ="select cast(dd.id as varchar(255)) as ID," \
                "cast(d.id as varchar(255)) as DOC_ID, " \
                "'"+org_code+"' as ur_l," \
                "'"+asna_code+"'," \
                "case d.doc_type" \
                " when 11 then 1 --мелкооптовый отпуск\n" \
                " when 3  then 2 --продажа через ККМ\n" \
                " when 1  then 3 --приход товара\n" \
                " when 9  then 4 --возврат от покупателя\n" \
                " when 37 then 4 --возврат от покупателя\n" \
                " when 4  then 5 --возврат поставщику\n" \
                " when 2  then iif((char_length(a.email) between 1 and 3), 6, 8) --межскладская передача\n" \
                " when 17 then 7 --Списание\n" \
                " when 10 then 7 --Списание\n" \
                " when 5  then 7 --Списание\n" \
                " when 20 then 8  --Ввод остатков\n" \
                " end as doc_type,\n" \
                " case d.doc_type" \
                "   when 11 then '"+INN+"' --мелкооптовый отпуск\n" \
                "   when 3  then '"+INN+"' --продажа через ККМ\n" \
                "   when 1  then coalesce(a.inn,'') --приход товара\n" \
                "   when 2  then '"+asna_code+"' --межскладская передача\n" \
                "   when 17 then '"+asna_code+"'  --Списание \n" \
                "   when 10 then '"+asna_code+"'  --Списание \n" \
                "   when 5 then '"+asna_code+"'  --Списание \n" \
                "   when 20 then '"+asna_code+"' --Ввод остатков\n" \
                "  else ''" \
                "  end as sagent,\n" \
    "       left(cast(d.commitdate as varchar(255)),19) as doc_date," \
    "       case d.doc_type \n" \
    "        when 3 then d.docnum||'Ч'||(select max(docnum) from docs d2 where d2.status = 1 and d2.doc_type=13 and d2.vshift = d.vshift and d2.device_num = d.device_num) \n" \
    "    else d.docnum" \
    "       end as docnum, \n" \
    "       dcard," \
    "       dcard," \
    "       dcard," \
    "       (select GOODS_ID from PR_ASNA_GET_GOODS(p.ware_id)) as GOODS_ID,\n" \
    "       abs(dd.quant) as quant," \
    "       a.inn as inn," \
    "       coalesce(0," + def_region + ") as region," \
    "       abs(Round((dd.quant*p.price_o*100/(100+dp.nds)),2)) as sum_b_nds," \
    "       abs(dd.summa_o) as summa_o," \
    "       abs(Round((dd.summa_o-dd.quant*p.price_o*100/(100+dp.nds)),2)) as sum_nds," \
    "       abs(dd.summa+dd.sum_dsc) as summa_b_dsc," \
    "       abs(dd.summa) as summa," \
    "       abs(dd.sum_dsc) as sum_dsc," \
    "       d.status, '| | |0'" \
    " from doc_detail dd\n" \
    "inner join docs d on dd.doc_id = d.id " \
    "inner join agents a on a.id=d.agent_id " \
    "inner join parts p on  dd.part_id = p.id " \
    "inner join deps dp on p.dep = dp.id \n" \
    "where d.status = 1 and d.doc_type in (11,2,3,1,37,9,4,17,10,5,20) and dd.doc_commitdate between "+date_beg+" and "+date_end+" \n" \
    "and (select GOODS_ID from PR_ASNA_GET_GOODS(p.ware_id)) is not null \n" \
    " and dd.quant <> 0 " \
    "order by 1"

SQL_DEL_WAREBASE = "delete from ASNA_WAREBASE"
SQL_INSERT_WAREBASE = "insert into ASNA_WAREBASE(part_id, G$PROFILE_ID,ddate) select id, '1', "+date_end+" from parts p"
SQL_WAREBASE = "select '"+org_code+"' as ur_l," \
               "'"+asna_code+"'," \
               " a.inn as inn," \
               " coalesce(0,"+def_region+") as region," \
                " left(cast(cast(dateadd(0 day to w.ddate) as dm_datetime) as varchar(255)),19) as beg_date," \
               " left(cast(d.commitdate as varchar(255)),19) as post_date," \
               " (select GOODS_ID from PR_ASNA_GET_GOODS(w.ware_id)) as GOODS_ID," \
               " w.quant," \
               " coalesce(abs(Round((w.quant*w.price_o*100/(100+w.nds)),2)),0) as sum_b_nds," \
               " coalesce(abs(Round(w.quant*w.price_o,2)),0) as summa_o," \
               " coalesce(abs(Round((w.quant*w.price_o-w.quant*w.price_o*100/(100+w.nds)),2)),0) as sum_nds," \
                " coalesce(abs(round(w.quant*w.price,2)),0) as summa " \
                                         "from ASNA_WAREBASE w " \
        " inner join docs d on w.doc_id = d.id "\
        "inner join agents a on a.id=w.agent_id "\
        "where (select GOODS_ID from PR_ASNA_GET_GOODS(w.ware_id)) is not null " \
        "order by 1"



