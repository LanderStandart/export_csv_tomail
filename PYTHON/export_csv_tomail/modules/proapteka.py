#  Autor by Lander (c) 2021. Created for Standart-N LLT
import sys
from engine import FTP_work,Archiv,Db,CSV_File,os,existPath,read_ini,LogIt,list_file_in_path

import time,datetime

class Proapteka(Db):
    def __init__(self,profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.conf = 'PROAPTEKA'
        self.path = read_ini(self.conf, 'PATH_EXPORT')
        existPath(self.path)
        #список файлов фыгрузки
        self.expfile = self.DB.config.get(self.conf, 'FILE_LIST').split(',')

    def getFilename(self, filename):#формируем имя файла
        self.filename= filename
        return self.path +self.filename

    def get_File(self,path,file):
        try:
            with open(path+file)as file:
                p = file.read()
                # p = p.split('\n')
        except FileNotFoundError:
            system.LogIt('Файл:' + i + '- недоступен для загрузки')
            exit()
        return p

    def get_Data(self):
        #полная выгрузка производится в 10-00 и 22-00
        if int(datetime.datetime.today().strftime('%H')) in (10,22):
            for i in self.expfile:
                print(i)
                head = self.get_File('./modules/proapteka/head/',i.lower()).split('\n')
                sql = self.get_File('./modules/proapteka/sql/',i.lower())
                sql = sql.replace('DEP_CODE',self.DB.config.get(self.conf, 'DEPARTMENTCODE'))
                sql = sql.replace('+DepartmentCode+', self.DB.config.get(self.conf, 'DEPARTMENTCODE'))
                date_s = datetime.date.today()-datetime.timedelta(days=45)
                date_start = datetime.datetime.today().strftime('%d.%m.%Y')
                sql = sql.replace(':FROM_DATE', "'" + date_start + "'")
                sql = sql.replace('+DateToStr(date_start)+',date_s.strftime('%d.%m.%Y'))
                sql = sql.replace('+DateToStr(date_end)+', datetime.date.today().strftime('%d.%m.%Y'))
                CSV_File(self.getFilename(i),self.DB.get_sql(sql), head,delimeter='|',encoding='utf-8').create_csv()
        else:
            i='Stock'
            head = self.get_File('./modules/proapteka/head/', i.lower()).split('\n')
            sql = self.get_File('./modules/proapteka/sql/', i.lower())
            date_start = datetime.datetime.today().strftime('%d.%m.%Y')
            sql = sql.replace(':FROM_DATE', "'"+date_start+"'")
            print(i)
            CSV_File(self.getFilename(i), self.DB.get_sql(sql), head, delimeter='|', encoding='utf-8').create_csv()
        fl=list_file_in_path(self.path,'*')
#        print(fl)
        #FTP_work(self.conf).upload_FTP(file_name + '.csv', extpath=str(read_ini(self.conf, 'FTP_PATH')), isbynary=True,rename=False)
        for fname in fl:
            FTP_work(self.conf).upload_FTP(fname, extpath=str(read_ini(self.conf, 'FTP_PATH')), isbynary=True,rename=False)












