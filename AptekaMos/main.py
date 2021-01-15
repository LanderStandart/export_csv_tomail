from engine import Db,FTP_work
import dbf

SQL_WAREBASE = "select 13874, trim(w.ware_id), w.sname||' '||w.sizg||' '||w.scountry, w.price, w.quant,coalesce((select first 1  drug_id from out$aptekaros_id where item_id=w.ware_id and drug_id<>0),0) as DRUG_ID from warebase w where w.quant>0 and w.nds=10 "
DataB = Db()

res=DataB.get_sql(SQL_WAREBASE)
# DataB.newFile()
# for row in res:
#     Assort_item(1,row[3],row[0],row[1],row[2],'').writeJson()

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
        table.append(datum)
        i += 1
    table.close()

create_dbf('assort.dbf','org_id N(6,0); item_code C(40); Item_name C(250); price N(12,2); qtty N(12,2);DRUG_ID N(8,0) ',SQL_WAREBASE)
FTP_work('FTP_CONF').upload_FTP('assort.dbf' )
# G = Assort_item(1,2,4,res[0][0],res[0][1],res[0][2],'').writeJson()
# G = Assort_item(1,2,4,'11234','Витамины',2300,'').writeJson()


