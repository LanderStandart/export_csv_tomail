#  Autor by Lander (c) 2021. Created for Standart-N LLT


#from engine import FTP_work,Archiv,Db,existPath,read_ini,get_File,list_file_in_path,my_log,create_dbf,CSV_File
import datetime,sys,os,glob
sys.path.insert(0, "./engine")
from system import System
from firebirdsql import Db
from ftp import FTP_work
from Archiv import Archiv
from CSV import CSV_File
from dbf_F import DBF_File



#logger = my_log.get_logger(__name__)
class Asna(Db,System):
    def __init__(self):
        self.logger = self.Logs(__name__)
        self.conf = 'ASNA'
        self.DB = Db()
        self.DBF = DBF_File()
        self.CSV = CSV_File()
        self.FTP = FTP_work(self.conf)
        self.path_ini=__name__
        self.path = self.read_ini(self.conf, 'PATH_EXPORT',self.conf)
        self.existPath(self.path)

        self.def_region = '0'
        self.org_code = self.read_ini(self.conf, 'ORG_CODE',self.path_ini)
        self.asna_code =self.read_ini(self.conf, 'ASNA_CODE',self.path_ini)
        self.inn = self.read_ini(self.conf, 'INN',self.path_ini)

    def get_Data(self, profile_id=None):
        self.profile_id = profile_id
#Справочник товаров
        goods=self.chk_file('goods.dbf')
        self.logger.info(goods)
        self.logger.info(self.profile_id)
        self.get_Date()
        SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
        self.DB.get_sql(SQL,None,1)
        self.logger.info('Create GOODS')
        goods = self.chk_file('goods.dbf')
        if goods:
            data = self.DB.get_from_base(module='asna',sql_file='wares')
            self.DBF.create_dbf(self.path+'goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',data)
            self.FTP.upload_FTP(self.path+'goods.dbf', extpath=str(self.read_ini(self.conf, 'FTP_PATH', self.path_ini)), isbynary=True,
                                rename=False)
        else:
            self.logger.info(f'File goods.dfb fresh')

#Базовые контрагенты
        self.logger.info('Create VENDOR')
        datum1 = []
        datum1.append(list(['1','Мелкооптовый покупатель',self.inn]))
        datum1.append(list(['2','Розничный покупатель (ККМ)',self.inn]))
        datum1.append(list(['3','Ввод остатков',self.inn]))
        vendor = self.chk_file('vendor.dbf')
        if vendor:
#Собираем контрагентов
            data = self.DB.get_from_base(module='asna',sql_file='agents')
            for row in data:
                datum1.append(row)
            self.DBF.create_dbf(self.path+'vendor.dbf','id C(250); name C(250); inn C(250)',datum1)
            self.FTP.upload_FTP(self.path + 'vendor.dbf', extpath=str(self.read_ini(self.conf, 'FTP_PATH', self.path_ini)),isbynary=True, rename=False)
        else:
            self.logger.info(f'File vendor.dbf fresh')

#Собираем Движение
        #filename1 = self.path+ self.org_code+'_'+self.asna_code+'_'+datetime.datetime.today().strftime("%Y%m%d")+'T'+datetime.datetime.today().strftime("%H%M")
        filename1 = f'{self.path}{self.org_code}_{self.asna_code}_{datetime.datetime.today().strftime("%Y%m%d")}T{datetime.datetime.today().strftime("%H%M")}_{self.profile_id}'
        self.logger.info('Create MOVE')
        quota=[0,1,2,3,5,7,9,10,11,12,13,14,16,25,26]
        val = {'org_code': f'{self.org_code}_{self.profile_id}','asna_code': f'{self.asna_code}_{self.profile_id}','def_region':self.def_region,'inn':self.inn,
                     'date_beg':self.date_start.strftime('%d.%m.%Y'),'date_end':self.date_end.strftime('%d.%m.%Y'),'profile_id':self.profile_id}
        
        data =self.DB.get_from_base(module='asna',sql_file='move_g',val=val) if self.profile_id  else self.DB.get_from_base('asna','move',val)
        self.CSV.create_csv(data=data,filename=filename1,delimeter='|',ext='.txt',quota=quota)
        self.FTP.upload_FTP(f'{filename1}.txt', extpath=str(self.read_ini(self.conf, 'FTP_PATH', self.path_ini)),
                            isbynary=True, rename=False)
        self.logger.info('Complete MOVE')

#ОСТАТКИ
        filename2 =f'{self.path}{self.org_code}_{self.asna_code}_{datetime.datetime.today().strftime("%Y%m%d")}T{datetime.datetime.today().strftime("%H%M")}_RST_{self.profile_id}'
        self.logger.info('Create WAREBASE')
        quota=[0,1,2,6,7,13]
        val =  {'org_code': f'{self.org_code}_{self.profile_id}','asna_code': f'{self.asna_code}_{self.profile_id}','date_end':self.date_end.strftime('%d.%m.%Y')}
        data = self.DB.get_from_base('asna','warebase',val)
        self.CSV.create_csv(data=data, filename=filename2,delimeter='|',ext='.txt',quota=quota)
        self.FTP.upload_FTP(f'{filename2}.txt', extpath=str(self.read_ini(self.conf, 'FTP_PATH', self.path_ini)),
                            isbynary=True, rename=False)
        self.logger.info('Complete WAREBASE')


        # fl=self.list_file_in_path(self.path,'*')
        # for fname in fl:



    def get_Date(self):
        date_start =self.read_ini(self.conf, 'DATE_START',self.path_ini)
        if date_start:
            self.logger.info('Выбранна дата из настроек')
            self.date_start = datetime.datetime.strptime(date_start, "%d.%m.%Y")
            self.date_end = datetime.datetime.today() - datetime.timedelta(days=1)
        # datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")#
        else:
            self.logger.info('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today() - datetime.timedelta(days=1)
            self.date_end = datetime.datetime.today()

    def chk_file(self, Login):
        path=Login

        try:
            list_of_files = glob.glob(path)  # * means all if need specific format then *.csv
            latest_file = max(list_of_files, key=os.path.getctime)
            file_time = datetime.date.fromtimestamp(os.path.getmtime(latest_file)).strftime('%d.%m.%Y')
            self.logger.info(file_time)
            res = 0 if file_time == datetime.datetime.now().strftime('%d.%m.%Y') else 1
            return res
        except:
            self.logger.info('file_time')
            return 1






