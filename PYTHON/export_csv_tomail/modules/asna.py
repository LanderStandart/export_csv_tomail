#  Autor by Lander (c) 2021. Created for Standart-N LLT
import sys

from engine import FTP_work,Archiv,Db,os,existPath,read_ini,get_File,list_file_in_path,my_log,create_dbf,CSV_File
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
        self.DB.cheak_db(read_ini(self.conf, 'TABLE'),'TABLE')
        self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE'),'PROCEDURE')
        self.DB.cheak_db(read_ini(self.conf, 'TRIGGER'),'TRIGGER')
        sys.exit()
        # if self.profile_id is None:
        #     logger.info('Алгоритм работает только для сетей !!!')
        #    exit()
    def get_from_base(self,sql_file,commit=None):
        SQL = get_File(path='./modules/asna/sql/', file=sql_file)
        SQL=self.prepare_sql(SQL)
        data=self.DB.get_sql(SQL,None,commit)
        return data

    def prepare_sql(self,sql):
        sql=sql.replace('+org_code+',  str(self.org_code))
        sql=sql.replace('+asna_code+',  str(self.asna_code))
        sql=sql.replace('+date_beg+',  str(read_ini(self.conf, 'DATE_START')))
        sql=sql.replace('+date_end+',  str(read_ini(self.conf, 'DATE_END')))
        #print(sql)
        return sql

    def get_Data(self):
#Справочник товаров

        SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
        self.DB.get_sql(SQL,None,1)
        logger.info('Create GOODS')
        #data = get_from_base(sql_file='wares')
        #create_dbf(self.path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',data)

#Базовые контрагенты
        logger.info('Create VENDOR')
        datum1 = []
        datum1.append(list(['1','Мелкооптовый покупатель',self.inn]))
        datum1.append(list(['2','Розничный покупатель (ККМ)',self.inn]))
        datum1.append(list(['3','Ввод остатков',self.inn]))

#Собираем контрагентов
        data = self.get_from_base(sql_file='agents')
        for row in data:
            datum1.append(row)
        #create_dbf(self.path+'vendor.dbf','id C(250); name C(250); inn C(250)',datum1)

#Собираем Движение
        filename1 = self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
        logger.info('Create MOVE')
        quota=[0,1,2,3,5,7,9,10,11,12,13,14,16,25,26]
        data = self.get_from_base(sql_file='move')
        CSV_File(data=data,filename=filename1,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete MOVE')

#ОСТАТКИ
        filename2 =self.path+ self.org_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")+'_RST'
        logger.info('Create WAREBASE')
        quota=[0,1,2,6,7]
        #очищаем таблицу
        self.get_from_base(sql_file='del_warebase',commit=1)
        #заполняем таблицу
        self.get_from_base(sql_file='insert_warebase',commit=1)
        data = self.get_from_base(sql_file='warebase')
        CSV_File(data=data,filename=filename2,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete WAREBASE')


        fl=list_file_in_path(self.path,'*')
        for fname in fl:
            FTP_work(self.conf).upload_FTP(fname, extpath=str(read_ini(self.conf, 'FTP_PATH')), isbynary=True,rename=False)

# FTP_work('FTP_CONF').upload_FTP(filename1 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(filename2 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(path+'goods.dbf')
# FTP_work('FTP_CONF').upload_FTP(path+'vendor.dbf')






