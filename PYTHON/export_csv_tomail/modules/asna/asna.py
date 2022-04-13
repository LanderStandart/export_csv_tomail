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
        self.def_region = '0'
        self.org_code = read_ini(self.conf, 'ORG_CODE',self.path_ini)
        self.asna_code =read_ini(self.conf, 'ASNA_CODE',self.path_ini)
        self.inn = read_ini(self.conf, 'INN',self.path_ini)
        self.DB.cheak_db(read_ini(self.conf, 'TABLE',self.path_ini),'TABLE')
        self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE',self.path_ini),'PROCEDURE')
        self.DB.cheak_db(read_ini(self.conf, 'TRIGGER',self.path_ini),'TRIGGER')


    def get_Data(self):
#Справочник товаров
        self.get_Date()
        SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
        #self.DB.get_sql(SQL,None,1)
        logger.info('Create GOODS')
        data = self.DB.get_from_base(module='asna',sql_file='wares')
        create_dbf(self.path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',data)

#Базовые контрагенты
        logger.info('Create VENDOR')
        datum1 = []
        datum1.append(list(['1','Мелкооптовый покупатель',self.inn]))
        datum1.append(list(['2','Розничный покупатель (ККМ)',self.inn]))
        datum1.append(list(['3','Ввод остатков',self.inn]))

#Собираем контрагентов
        data = self.DB.get_from_base(module='asna',sql_file='agents')
        for row in data:
            datum1.append(row)
        create_dbf(self.path+'vendor.dbf','id C(250); name C(250); inn C(250)',datum1)

#Собираем Движение
        filename1 = self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
        logger.info('Create MOVE')
        quota=[0,1,2,3,5,7,9,10,11,12,13,14,16,25,26]
        val = val = {'org_code': self.org_code,'asna_code': self.asna_code,'def_region':self.def_region,'inn':self.inn,
                     'date_beg':self.date_start.strftime('%d.%m.%Y'),'date_end':self.date_end.strftime('%d.%m.%Y')}
        data =self.DB.get_from_base(module='asna',sql_file='move_g') if self.profile_id  else self.DB.get_from_base('asna','move',val)
        CSV_File(data=data,filename=filename1,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete MOVE')

#ОСТАТКИ
        filename2 =self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'\
                   +datetime.datetime.today().strftime("%H%M")+'_RST'
        logger.info('Create WAREBASE')
        quota=[0,1,2,6,7,13]
        val =  {'org_code': self.org_code,'asna_code': self.asna_code,'date_end':self.date_end.strftime('%d.%m.%Y')}
        data = self.DB.get_from_base('asna','warebase',val)
        CSV_File(data=data,filename=filename2,delimeter='|',ext='.txt').create_csv(quota=quota)
        logger.info('Complete WAREBASE')


        fl=list_file_in_path(self.path,'*')
        for fname in fl:
            FTP_work(self.conf).upload_FTP(fname, extpath=str(read_ini(self.conf, 'FTP_PATH',self.path_ini)), isbynary=True,rename=False)


    def get_Date(self):
        date_start =read_ini(self.conf, 'DATE_START',self.path_ini)
        if date_start:
            logger.info('Выбранна дата из настроек')
            self.date_start = datetime.datetime.strptime(date_start, "%d.%m.%Y")
            self.date_end = datetime.datetime.today() - datetime.timedelta(days=1)
        # datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")#
        else:
            logger.info('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today() - datetime.timedelta(days=1)
            self.date_end = datetime.datetime.today()






