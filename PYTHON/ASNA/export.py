import dbf
import fdb
import configparser
import query
from engine import Engine,CSV_File,FTP_work
import datetime
#import create_query

Eng = Engine()
config = configparser.ConfigParser()
config.read('./config.ini')
inn = config.get('BASE','INN')
path = config.get('BASE', 'PATH_TMP')

org_code = config.get('BASE', 'ORG_CODE')
asna_code = config.get('BASE', 'ASNA_CODE')
def_region = config.get('BASE', 'DEF_REGION')
INN = config.get('BASE', 'INN')


#создание ДБФ
def create_dbf(filename,columns,sql,values1=None):

    table = dbf.Table(filename,columns,codepage='cp866')
    table.open(mode=dbf.READ_WRITE)
    if values1 is None:
        values = Eng.get_sql(sql)
    else:
        values = Eng.get_sql(sql)
        values.extend(values1)
    i = 0
    while i < len(values):
        # print(values[i])
        datum = tuple(values[i])
        table.append(datum)
        i += 1
    table.close()




start =int(datetime.datetime.today().strftime("%H%M"))
print('Start:'+str(start))
# #Справочник товаров
SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
# Eng.get_sql(SQL,None,1)
print('Create GOODS')
create_dbf(path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',query.SQL_WARES)
print('complete - '+datetime.datetime.today().strftime("%H:%M"))
#
# #  #Базовые контрагенты
print('Create VENDOR')
datum1 = []
datum1.append(list(['1','Мелкооптовый покупатель',inn]))
datum1.append(list(['2','Розничный покупатель (ККМ)',inn]))
datum1.append(list(['3','Ввод остатков',inn]))
# # Собираем контрагентов
create_dbf(path+'vendor.dbf','id C(250); name C(250); inn C(250)',query.SQL_AGENTS,datum1)

# with open('query.txt','w') as file:
#     file.write(query.SQL_MOVE)
print('complete - '+datetime.datetime.today().strftime("%H:%M"))
filename1 = path+ org_code+'_'+asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
print('Create MOVE')
CSV_File(filename1, Eng.get_sql(query.SQL_MOVE)).create_csv()
print('complete - '+datetime.datetime.today().strftime("%H:%M"))
filename2 =path+org_code+'_'+asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")+'_RST'

#ОСТАТКИ
print('Create WAREBASE')
Eng.get_sql(query.SQL_DEL_WAREBASE,None,1)
Eng.get_sql(query.SQL_INSERT_WAREBASE,None,1)

CSV_File(filename2, Eng.get_sql(query.SQL_WAREBASE)).create_csv()
print('complete - '+datetime.datetime.today().strftime("%H:%M"))
end =int(datetime.datetime.today().strftime("%H%M"))
print(str(end))

print(str(end-start)+'мин')

FTP_work('FTP_CONF').upload_FTP(filename1 + '.txt')
FTP_work('FTP_CONF').upload_FTP(filename2 + '.txt')
FTP_work('FTP_CONF').upload_FTP(path+'goods.dbf')
FTP_work('FTP_CONF').upload_FTP(path+'vendor.dbf')







