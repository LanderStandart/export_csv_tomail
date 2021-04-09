import dbf
import fdb
import configparser
import csv
import functools
from time import time
from ftplib import FTP

class Timer:
    def __init__(self,func):
        functools.update_wrapper(self,func)
        self.func = func
        self.start = time()
        self.end = 0
    def __call__(self, *args, **kwargs):
        self.end = time()
        print(f'{self.func.__name__!r}')
        print('Elapsed time: {}'.format(self.end - self.start)+' сек')
        return self.func(*args,**kwargs)


class Engine:
    def __init__(self):
        self.config = configparser.ConfigParser()
        self.config.read('./config.ini')
        section = 'DB'
        self.host = self.config.get(section, 'HOST')
        self.database = self.config.get(section, 'PATH')
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()
#запрос к базе
    def get_sql(self,sql,where=None,commit=None):
        self.sql = sql
        self.where = where
        self.commit = commit
        if self.where:
            self.sql = self.sql + self.where

#проверка корректности запроса
        try:
            query = self.curs.execute(sql)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')
            print(Err)
            Flag = self.search(Errs, 'Table unknown\n')
            if Flag > 0:
                return False,'Таблица не найдена\n'+Errs[Flag + 1]
            else:
                Flag = self.search(Errs, 'Token unknown ')
                if Flag > 0:
                    print('Ошибка в запросе')
                    print('Вероятная ошибка - '+Errs[Flag + 2])
                    return False
            return
#Вывод результатов или проведение
        result = []
        if self.commit:
            self.conn.commit()
            return
        else:
            for i in query:
              result.append(list(i))
            return result
        print(query)

    def search(self,list, n):
        for i in range(len(list)):

            if list[i] == n:
                return i
        return False

    def clear_psql(self,sql):
        self.sql = sql
        del_id = []
        for str in range(len(self.sql)):
            res = self.sql[str].find('/**')
            res2 = self.sql[str].find('SET SQL')
            len_str = len(self.sql[str])

            if res != -1 or len_str < 2 or res2 != -1:
                del_id.append(str)

        del_id.sort(reverse=True)
        for i in del_id:
            del self.sql[i]
        return self.sql


#Выгрузка на ФТП
class FTP_work(Engine):
    def __init__(self,sections):
        self.DB = Engine()
        self.sections = sections
        self.host = self.DB.config.get(self.sections, 'FTP_HOST')
        self.port = int(self.DB.config.get(self.sections, 'FTP_PORT'))
        self.ftp_user = self.DB.config.get(self.sections, 'FTP_USER')
        self.ftp_password = self.DB.config.get(self.sections, 'FTP_PASSWORD')

    def upload_FTP(self, file_name, isbynary=None):
        self.file_name = file_name
        self.isbynary = isbynary
        print(self.host, self.ftp_user, self.ftp_password, self.file_name, self.port,self.isbynary)
        f_obj = open(self.file_name, 'rb')

        ftp = FTP()
        # ftp.encoding = 'utf-8'
        ftp.connect(self.host, self.port)

        ftp.login(self.ftp_user, self.ftp_password)
        print('Upload'+file_name)
        ftp.set_pasv(True)
        ftp.cwd('turnovers')

        if self.isbynary:
            with f_obj as fobj:
                ftp.storbinary('STOR '+self.file_name,fobj)
        else:
            ftp.storlines("STOR " + self.file_name, f_obj)
        ftp.quit()

#Создание CSV
class ASNA_File:

    def __init__(self,filename, data, header=None, profile_code=None):
        self.filename = filename + '.txt'
        self.data = data
        self.header = header
        self.profile_code = profile_code
    def create_csv(self,quota=None):
        # 2 = csv.QUOTE_NONNUMERIC
        self.quota = quota
        print(self.filename + '.txt')
        with open(self.filename, 'w')as fd:
            for row in self.data:

                for y in self.quota:
                    if row[y] is None or row[y]==' ':
                        row[y]=''
                    row[y]=str(row[y]).replace("'",'')
                    row[y]='"'+str(row[y])+'"'
                    # print(row[y])
                fd.write("|".join([str(elem) for elem in row])+'\n')







