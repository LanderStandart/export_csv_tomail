
#  Autor by Lander (c) 2021. Created for Standart-N LLT
import sys
from engine import FTP_work,Archiv,Db,CSV_File,os,existPath,read_ini,list_file_in_path,my_log

import time,datetime
logger = my_log.get_logger(__name__)
class Proapteka(Db):
    def __init__(self,profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.conf = 'PROAPTEKA'
        self.path_ini=__name__
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        existPath(self.path)
        #список файлов фыгрузки
        self.expfile = read_ini(self.conf, 'FILE_LIST',self.path_ini).split(',')

    def getFilename(self, filename):#формируем имя файла
        self.filename= filename
        return self.path +self.filename

    def get_File(self,path,file):
        try:
            with open(path+file)as file:
                p = file.read()
                # p = p.split('\n')
        except FileNotFoundError:
            logger.error('Файл:' + i + '- недоступен для загрузки')
            exit()
        return p

    def get_Data(self):
        #полная выгрузка производится в 10-00 и 22-00
        if int(datetime.datetime.today().strftime('%H')) in (10,22):
            for i in self.expfile:
                logger.info(i)
                date_s = datetime.date.today()-datetime.timedelta(days=45)
                date_start = datetime.datetime.today().strftime('%d.%m.%Y')
                head = self.get_File('./modules/proapteka/head/',i.lower()).split('\n')
                val={'FROM_DATE':date_start,
                     'date_start':date_s.strftime('%d.%m.%Y'),
                     'date_end':datetime.date.today().strftime('%d.%m.%Y')}
                data=self.DB.get_from_base(__name__,i.lower(),val)
                CSV_File(self.getFilename(i),data, head,delimeter='|',encoding='utf-8').create_csv()
        else:
            i='Stock'
            head = self.get_File('./modules/proapteka/head/', i.lower()).split('\n')
            date_start = datetime.datetime.today().strftime('%d.%m.%Y')
            val={'FROM_DATE':date_start,
                 'date_end':datetime.date.today().strftime('%d.%m.%Y')}
            data=self.DB.get_from_base(__name__,i.lower(),val)
            logger.info(i)
            CSV_File(self.getFilename(i), data, head, delimeter='|', encoding='utf-8').create_csv()
        fl=list_file_in_path(self.path,'*')
#        print(fl)
        #FTP_work(self.conf).upload_FTP(file_name + '.csv', extpath=str(read_ini(self.conf, 'FTP_PATH')), isbynary=True,rename=False)
        for fname in fl:
            FTP_work(self.conf).upload_FTP(fname, extpath=str(read_ini(self.conf, 'FTP_PATH',self.path_ini)), isbynary=True,rename=False)












