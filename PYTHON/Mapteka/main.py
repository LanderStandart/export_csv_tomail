from engine import Db,Assort_item
import dbf

DataB = Db()

def create_dbf(filename,columns,sql,values1=None):


    table = dbf.Table(filename,columns,codepage='cp1251')
    table.open(mode=dbf.READ_WRITE)
    if values1 is None:
        values = DataB.get_sql(sql)

    else:
        values = DataB.get_sql(sql)
        values.extend(values1)




    i = 0
    while i < len(values):
        datum = tuple(values[i])
        print(datum)
        table.append(datum)
        i += 1
    table.close()


SQL="select first 3 d.doc_type as doctype," \
    "(select  dt.caption from doc_types dt where dt.id=d.doc_type ) as docname," \
    "d.docnum as ndok," \
    "cast(d.docdate as dm_text) as datedok," \
    "iif (d.doc_type =1,d.docnum,' ')as ndoksup," \
    "iif (d.doc_type=1,cast(d.docdate as dm_text),' ')as datesup," \
    "' ' as numsf," \
    "'1' as aptcode," \
    "'DD' as aptname," \
    "iif(d.doc_type=1,d.agent_id,' ')as codesup," \
    "iif(d.doc_type=1,(select caption from agents a where a.id = d.agent_id),' ')as namesup," \
    "iif(d.doc_type=1,(select a.inn from agents a where a.id = d.agent_id),' ')as innsup," \
    "' ' as buyerc," \
    "' ' as buyern," \
    "' ' as buyerinn," \
    "coalesce(p.ware_id,'') as nomn," \
    "coalesce(w.sname,'')," \
    "'0' as flkom," \
    "abs(dd.quant) as quant," \
    "' ' as ndssup," \
    "p.nds," \
    "p.price_o as cenazak," \
    "abs(dd.summa_o) as sumzak," \
    "dd.price as cenarozn," \
    "abs(dd.summa) as sumrozn," \
    "dd.sum_dsc as sumdisc," \
    "iif (d.doc_type in (3,9)and abs(d.summ1)>0,abs(dd.summa),0)as sumNAL," \
    "iif (d.doc_type in (3,9)and abs(d.summ2)>0,abs(dd.summa),0)as sumbank," \
    "' ' as sumvanc " \
    "from " \
    "docs d " \
    "left join doc_detail dd on dd.doc_id=d.id " \
    "left join parts p on p.id = dd.part_id " \
    "left join wares w on w.id = p.ware_id" \
    " where p.ware_id is not null "


create_dbf('ven2.dbf',"doctype N(2,0); docname C(250); ndok C(250);datedok C(250);Ndoksup C(250);datesup C(40);numsf C(250);aptcode c(250);aptname C(250);codesup c(250);namesup C(250);innsup C(20); buyerc C(40);buyern C(40); buyerinn C(40); nomn C(40); drugs C(250);flkom C(40);quant N(15,2);ndssup C(250); nds C(250); cenazak N(15,2); sumzak N(15,2); cenarozn N(15,2);sumrozn N(15,2); sumdisc N(15,2); sumnal N(15,2); sumbank N(15,2); sumvanc C(250)",SQL)
s=DataB.get_sql(SQL)
print(s)