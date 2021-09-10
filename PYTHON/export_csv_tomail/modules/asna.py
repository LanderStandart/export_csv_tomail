#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,os,LogIt,existPath,read_ini,get_File,put_file,my_log,create_dbf
import datetime
#import create_query

logger = my_log.get_logger(__name__)
class Asna(Db):
    def __init__(self, profile_id=None):
        self.conf = 'ASNA'
        self.DB = Db()
        self.path = read_ini(self.conf, 'PATH_EXPORT')
        existPath(self.path)
        self.profile_id = profile_id
        self.org_code = read_ini(self.conf, 'ORG_CODE')
        self.asna_code =read_ini(self.conf, 'ASNA_CODE')
        self.def_region =read_ini(self.conf, 'DEF_REGION')
        self.inn = read_ini(self.conf, 'INN')
        # if self.profile_id is None:
        #     logger.info('Алгоритм работает только для сетей !!!')
        #    exit()
    def get_from_base(self,sql_file):
        SQL = get_File(path='./modules/asna/sql/', file=sql_file)
        data=self.DB.get_sql(SQL,None)
        return data

    def get_Data(self):
        start =int(datetime.datetime.today().strftime("%H%M"))
        logger.info('Start:'+str(start))
#Справочник товаров
        SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
        #self.DB.get_sql(SQL,None,1)
        logger.info('Create GOODS')
        #data = get_from_base(sql_file='wares')
        #create_dbf(self.path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',data)

 #Базовые контрагенты
        logger.info('Create VENDOR')
        datum1 = []
        datum1.append(list(['1','Мелкооптовый покупатель',self.inn]))
        datum1.append(list(['2','Розничный покупатель (ККМ)',self.inn]))
        datum1.append(list(['3','Ввод остатков',self.inn]))

# Собираем контрагентов
        data = get_from_base(sql_file='agents')
        for row in data:
            datum1.append(row)
        create_dbf(self.path+'vendor.dbf','id C(250); name C(250); inn C(250)',datum1
                   )
#
# # with open('query.txt','w') as file:
# #     file.write(query.SQL_MOVE)
# print('complete - '+datetime.datetime.today().strftime("%H:%M"))
#Собираем Движение
        filename1 = path+ org_code+'_'+asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
        logger.info('Create MOVE')
        quota=[0,1,2,3,5,7,9,10,11,12,13,14,16,25,26]
#
# ASNA_File(filename1, Eng.get_sql(query.SQL_MOVE)).create_csv(quota)
# print('complete - '+datetime.datetime.today().strftime("%H:%M"))
# filename2 =path+org_code+'_'+asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")+'_RST'
#
# #ОСТАТКИ
# print('Create WAREBASE')
#
# Eng.get_sql(query.SQL_DEL_WAREBASE,None,1)
# Eng.get_sql(query.SQL_INSERT_WAREBASE,None,1)
# quota=[0,1,2,6,7]
# ASNA_File(filename2, Eng.get_sql(query.SQL_WAREBASE)).create_csv(quota)
# print('complete - '+datetime.datetime.today().strftime("%H:%M"))
# end =int(datetime.datetime.today().strftime("%H%M"))
# print(str(end))
#
# print(str(end-start)+'мин')

# FTP_work('FTP_CONF').upload_FTP(filename1 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(filename2 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(path+'goods.dbf')
# FTP_work('FTP_CONF').upload_FTP(path+'vendor.dbf')






