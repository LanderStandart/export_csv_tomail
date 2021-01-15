#  Autor by Lander (c) 2020. Created for Standart-N LLT
from ftplib import FTP
import csv
import configparser
import fdb
import zipfile

#Подключение к БД
class Db:
    def __init__(self):
        self.config = configparser.ConfigParser()
        self.config.read('./config.ini')
        section = 'BASE_CONF'
        self.host = self.config.get(section, 'HOST')
        self.database = self.config.get(section, 'PATH')
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()

#Запрос к базе с условием
    def get_sql(self,sql,where=None):
        result=None
        self.sql=sql
        self.where = where
        if self.where:
            self.sql = self.sql + self.where
        # print(sql)
        query = self.curs.execute(sql)
        result = []
        for i in query:
            result.append(list(i))
        return result

#Архивирование файла
class Archiv:
    def __init__(self,fn,ext):
        self.fn = fn
        self.ext = ext
    def zip_File(self):
        with zipfile.ZipFile('./' + self.fn + '.zip', 'w') as ZIPP:
            ZIPP.write('./' +self.fn + '.'+self.ext, compress_type=zipfile.ZIP_DEFLATED)
        ZIPP.close()

#Создание CSV
class CSV_File():
    def __init__(self,filename, data, header=None, profile_code=None):
        self.filename = filename
        self.data = data
        self.header = header
        self.profile_code = profile_code

    def create_csv(self):
        print(self.filename + '.csv')
        with open(self.filename + '.csv', 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';', escapechar=' ', quoting=csv.QUOTE_NONE)
            if self.header is not None:
                writer.writerow(self.header)
            for row in self.data:
                if self.profile_code is None:
                    row = row
                else:
                    row = [self.profile_code] + row
                writer.writerow(row)

#Выгрузка на ФТП
class FTP_work(Db):
    def __init__(self,sections):
        self.DB = Db()
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
        print('Upload')
        ftp.set_pasv(True)
        if self.isbynary:
            with f_obj as fobj:
                ftp.storbinary('STOR '+self.file_name,fobj)
        else:
            ftp.storlines("STOR " + self.file_name, f_obj)
        ftp.quit()

class ExportData(Db):
    def __init__(self,firm):
        self.firm = firm
        self.DB = Db()

    def create(self):
        if int(self.DB.config.get('PARAMS', self.firm)):
            if int(self.DB.config.get('BASE_CONF', 'ALONE')):
                # Выгружаем на FTP  2Gis
                firm = self.firm
                from firm.lower import self.firm
                func = eval(self.firm)
                func.get_data()
            else:
                profiles = DataB.get_sql(SQL_profile)
                for i in profiles:
                    self.firm(i[0]).get_data()

def valid_xml(stroka):
    stroka = str(stroka)
    stroka = stroka.replace('<','&lt;')
    stroka = stroka.replace('<','&gt;')
    stroka = stroka.replace('&','&amp;')
    stroka = stroka.replace('"','&quot;')
    stroka = stroka.replace("'", '&apos;')
    return stroka

def tranlit(input_str):
    slovar = {'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e',
              'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n',
              'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h',
              'ц': 'c', 'ч': 'cz', 'ш': 'sh', 'щ': 'scz', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e',
              'ю': 'u', 'я': 'ja', 'А': 'A', 'Б': 'B', 'В': 'V', 'Г': 'G', 'Д': 'D', 'Е': 'E', 'Ё': 'E',
              'Ж': 'ZH', 'З': 'Z', 'И': 'I', 'Й': 'I', 'К': 'K', 'Л': 'L', 'М': 'M', 'Н': 'N',
              'О': 'O', 'П': 'P', 'Р': 'R', 'С': 'S', 'Т': 'T', 'У': 'U', 'Ф': 'F', 'Х': 'H',
              'Ц': 'C', 'Ч': 'CZ', 'Ш': 'SH', 'Щ': 'SCH', 'Ъ': '', 'Ы': 'y', 'Ь': '', 'Э': 'E',
              'Ю': 'U', 'Я': 'YA', ',': '', '?': '', ' ': '_', '~': '', '!': '', '@': '', '#': '',
              '$': '', '%': '', '^': '', '&': '', '*': '', '(': '', ')': '', '-': '', '=': '', '+': '',
              ':': '', ';': '', '<': '', '>': '', '\'': '', '"': '', '\\': '', '/': '', '№': '',
              '[': '', ']': '', '{': '', '}': '', 'ґ': '', 'ї': '', 'є': '', 'Ґ': 'g', 'Ї': 'i',
              'Є': 'e', '—': ''}

    # Циклически заменяем все буквы в строке
    for key in slovar:
        input_str = input_str.replace(key, slovar[key])
    return input_str

