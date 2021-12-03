#  Autor by Lander (c) 2021. Created for Standart-N LLT


from engine import FTP_work,Archiv,Db,existPath,read_ini,get_File,list_file_in_path,my_log,create_dbf,CSV_File
import datetime


logger = my_log.get_logger(__name__)
class Asna(Db):
    def __init__(self, profile_id=None):
        self.conf = 'ASNA'
        self.DB = Db()
        self.path_ini=__name__
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.org_code = read_ini(self.conf, 'ORG_CODE',self.path_ini)
        self.asna_code =read_ini(self.conf, 'ASNA_CODE',self.path_ini)
        self.inn = read_ini(self.conf, 'INN',self.path_ini)
        self.DB.cheak_db(read_ini(self.conf, 'TABLE',self.path_ini),'TABLE')
        self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE',self.path_ini),'PROCEDURE')
        self.DB.cheak_db(read_ini(self.conf, 'TRIGGER',self.path_ini),'TRIGGER')

        # if self.profile_id is None:
        #     logger.info('Алгоритм работает только для сетей !!!')
        #    exit()
    # def get_from_base(self,sql_file,commit=None):
    #     SQL = get_File(path='./modules/asna/sql/', file=sql_file)
    #     SQL=self.prepare_sql(SQL)
    #     data=self.DB.get_sql(SQL,None,commit)
    #     return data

    # def prepare_sql(self,sql):
    #     if not self.profile_id:
    #         res = sql.format(org_code=str(self.org_code),asna_code=str(self.asna_code),
    #                    date_beg=str(read_ini(self.conf, 'DATE_START',self.path_ini)),
    #                    date_end=str(read_ini(self.conf, 'DATE_END',self.path_ini)),
    #                        inn=str(read_ini(self.conf, 'INN',self.path_ini)),
    #                    aprofile_id='')
    #
    #     return res

    def get_Data(self):
#Справочник товаров

        SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
        #self.DB.get_sql(SQL,None,1)
        logger.info('Create GOODS')
        Db.get_from_base(self,module='asna',sql_file='wares')
        exit('dddsa')
        #data = DB.get_from_base(sql_file='wares')
        #create_dbf(self.path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',data)

#Базовые контрагенты
        logger.info('Create VENDOR')
        datum1 = []
        datum1.append(list(['1','Мелкооптовый покупатель',self.inn]))
        datum1.append(list(['2','Розничный покупатель (ККМ)',self.inn]))
        datum1.append(list(['3','Ввод остатков',self.inn]))

#Собираем контрагентов
        #data = self.get_from_base(sql_file='agents')
        # for row in data:
        #     datum1.append(row)
       # create_dbf(self.path+'vendor.dbf','id C(250); name C(250); inn C(250)',datum1)

#Собираем Движение
        filename1 = self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
        logger.info('Create MOVE')
        quota=[0,1,2,3,5,7,9,10,11,12,13,14,16,25,26]

        data =self.get_from_base(sql_file='move_g') if self.profile_id  else self.get_from_base(sql_file='move')
        CSV_File(data=data,filename=filename1,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete MOVE')

#ОСТАТКИ
        filename2 =self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'\
                   +datetime.datetime.today().strftime("%H%M")+'_RST'
        logger.info('Create WAREBASE')
        quota=[0,1,2,6,7,13]
        #очищаем таблицу
       # self.get_from_base(sql_file='del_warebase',commit=1)
        #заполняем таблицу
       # self.get_from_base(sql_file='insert_warebase',commit=1)
        data = self.get_from_base(sql_file='warebase')
        CSV_File(data=data,filename=filename2,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete WAREBASE')


        fl=list_file_in_path(self.path,'*')
        for fname in fl:
            FTP_work(self.conf).upload_FTP(fname, extpath=str(read_ini(self.conf, 'FTP_PATH',self.path_ini)), isbynary=True,rename=False)

# FTP_work('FTP_CONF').upload_FTP(filename1 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(filename2 + '.txt')
# FTP_work('FTP_CONF').upload_FTP(path+'goods.dbf')
# FTP_work('FTP_CONF').upload_FTP(path+'vendor.dbf')






