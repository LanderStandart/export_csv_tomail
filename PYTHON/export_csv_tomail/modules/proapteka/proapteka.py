
#  Autor by Lander (c) 2021. Created for Standart-N LLT
import sys,os
sys.path.insert(0, "./engine")
from firebirdsql import Db
from system import System
from CSV import CSV_File
from Archiv import Archiv
from ftp import FTP_work
import json,re
import time,datetime

class Proapteka(System):
    def __init__(self):
        self.logger = self.Logs(__name__)

        self.CSV_File =CSV_File()
        self.DB = Db()
        self.conf = 'PROAPTEKA'
        self.path_ini=__name__
        self.code = str(self.read_ini(self.conf, 'ID_CLIENT',self.path_ini))

        #список файлов фыгрузки
        self.expfile = self.read_ini(self.conf, 'FILE_LIST',self.path_ini).split(',')


    def getFilename(self, filename):#формируем имя файла
        self.filename= filename
        return self.path +self.filename

    def get_File(self,path,file):
        try:
            with open(path+file)as file:
                p = file.read()
                # p = p.split('\n')
        except FileNotFoundError:
            self.logger.error('Файл:' + i + '- недоступен для загрузки')
            exit()
        return p

    def get_Data(self,profile_id=None):

        #Если сеть запросы другие
        self.profile_id = profile_id
        #self.depcode = f'RegUg_{self.profile_id}'  # self.dep_code = json.loads(self.read_ini(self.conf, 'KOD_PROFILE', self.conf).replace("'", '"'))
        # self.path = self.read_ini(self.conf, 'PATH_EXPORT',
        #                           self.path_ini)\
        #             + f'{self.profile_id}/' if self.profile_id else self.read_ini(
        #     self.conf, 'PATH_EXPORT', self.path_ini)
        self.path = self.read_ini(self.conf, 'PATH_EXPORT', self.path_ini)

        self.existPath(self.path)
        self.clear_export_path(self.path, sec=3000)

        if self.profile_id:
            suffix = '_g'
            self.depcode =f'{self.code}_{self.profile_id}' # self.dep_code[self.profile_id]
        else:
            suffix = ''
            self.depcode = self.dep_code["1"]


        self.logger.info(self.profile_id)
        #полная выгрузка производится в 10-00 и 22-00
        if int(datetime.datetime.today().strftime('%H')) in (12,10,22):
            for i in self.expfile:
                self.logger.info(i)
                date_s = datetime.date.today()-datetime.timedelta(days=45)
                date_start = datetime.datetime.today().strftime('%d.%m.%Y')
                head = self.get_File('./modules/proapteka/head/',i.lower()).split('\n')

                val={'FROM_DATE':date_start,
                     'date_start':date_s.strftime('%d.%m.%Y'),
                     'date_end':datetime.date.today().strftime('%d.%m.%Y')} if not self.profile_id \
                    else {'FROM_DATE':date_start,
                          'date_start':date_s.strftime('%d.%m.%Y'),
                          'profile_id':self.profile_id,
                          'DepartmentCode': self.depcode,
                          'date_end':datetime.date.today().strftime('%d.%m.%Y')}
                data=self.DB.get_from_base(__name__,i.lower(),val,profile=suffix)
                if i.lower() =='goods':
                    for stroka in data:
                        stroka[1] = re.sub("[\n]|[\r]",'',stroka[1])
                        stroka[1] =''.join(re.findall("([A-Za-z]+|[А-Яа-я]+|\d+|\s|\№)", stroka[1]))

                self.CSV_File.create_csv(self.getFilename(i),data, head,delimeter='|',encoding='utf-8')
        else:
            i='Stock'
            head = self.get_File('./modules/proapteka/head/', i.lower()).split('\n')
            date_start = datetime.datetime.today().strftime('%d.%m.%Y')
            val={'FROM_DATE':date_start,
                 'date_end':datetime.date.today().strftime('%d.%m.%Y')}if not self.profile_id \
                    else {'FROM_DATE':date_start,
                          'profile_id':self.profile_id,
                          'DepartmentCode':self.depcode,
                          'date_end':datetime.date.today().strftime('%d.%m.%Y')}
            data=self.DB.get_from_base(__name__,i.lower(),val,profile=suffix)
            self.logger.info(self.getFilename(i))
            # os.remove(self.getFilename(i))
            self.CSV_File.create_csv(self.getFilename(i), data, head, delimeter='|', encoding='utf-8')
        fl=self.list_file_in_path(self.path,'*')
        data_file = datetime.datetime.fromtimestamp(os.path.getmtime(f'{self.getFilename(i)}.csv')).strftime('%Y%m%d%H%M%S')
        self.logger.info(data_file)
        lst_file = self.list_file_in_path(self.path, 'zip')
        for file in lst_file:

            os.remove(file)

         #datetime.datetime.now().strftime('%Y%m%d%H%M00')
        arc_name = f'{self.path}{self.depcode}.zip'
        self.logger.info(f'Create archive - {arc_name}')
        Archiv().zip_Files(fl,arc_name)
        #os.rename(arc_name,f'{arc_name}_{data_file}.zip')
        lst_file = self.list_file_in_path(self.path, 'csv')
        for file in lst_file:
            os.remove(file)

        self.logger.info(f'Create archive - {arc_name}')
        FTP_work(self.conf).upload_FTP(f'{arc_name}', extpath=str(self.read_ini(self.conf, 'FTP_PATH', self.path_ini)), isbynary=True,rename=False)
        # for fname in fl:
        #     FTP_work(self.conf).upload_FTP(fname, extpath=extpath, isbynary=True,rename=False)












