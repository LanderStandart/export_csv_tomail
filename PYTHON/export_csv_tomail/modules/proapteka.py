#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,CSV_File,os,LogIt,existPath
import time

class Proapteka(Db):
    def __init__(self,profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.conf = 'PROAPTEKA'
        self.path = self.DB.config.get(self.conf, 'PATH_EXPORT')
        existPath(self.path)
        #список файлов фыгрузки
        self.expfile = self.DB.config.get(self.conf, 'FILE_LIST').split(',')

    def getFilename(self, filename):#формируем имя файла
        self.filename=time.strftime('%Y')+time.strftime('%m')+time.strftime('%d')+time.strftime('%H')+time.strftime('%M')+time.strftime('%S')+ filename
        return self.path +self.filename

    def get_File(self,path,file):
        try:
            with open(path+file)as file:
                p = file.read()
                # p = p.split('\n')
        except FileNotFoundError:
            LogIt('Файл:' + i + '- недоступен для загрузки')
            exit()
        return p

    def get_Data(self):
        for i in self.expfile:
            head = self.get_File('./modules/proapteka/head/',i.lower()).split('\n')
            sql = self.get_File('./modules/proapteka/sql/',i.lower())
            sql = sql.replace('+DepartmentCode+',self.DB.config.get(self.conf, 'DEPARTMENTCODE'))
            sql = sql.replace('+DateToStr(date_start)+','01.10.2020')
            sql = sql.replace('+DateToStr(date_end)+', '01.11.2020')
            CSV_File(self.getFilename(i),self.DB.get_sql(sql), head,delimeter='|',encoding='utf-8').create_csv()
    def get_Warebase(self):
        #определяем дату за которую формируем отчет










