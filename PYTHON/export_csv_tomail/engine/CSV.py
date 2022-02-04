#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Создание CSV
import sys
import csv
sys.path.insert (0,".")
from system import my_log
logger = my_log.get_logger(__name__)
class CSV_File:
    def __init__(self,filename, data, header=None, profile_code=None,delimeter=';',encoding='cp1251',ext='.csv'):
        self.filename = filename
        self.data = data
        self.header = header
        self.profile_code = profile_code
        self.delimeter = delimeter
        self.encoding=encoding
        self.ext = ext

    def create_csv(self,quota=None):
        res_row=[]
        self.quota = quota
        logger.info('Create File:'+self.filename + self.ext)
        with open(self.filename + self.ext, 'w', newline='',encoding=self.encoding) as f:
            writer = csv.writer(f,delimiter=self.delimeter, escapechar='~',quotechar='', quoting=csv.QUOTE_NONE)
            if self.header is not None:
                writer.writerow(self.header)
            for row in self.data:
                if self.profile_code is None:
                    row = row
                else:
                    row = [self.profile_code] + row

                if self.quota:
                    for y in self.quota:
                        if row[y] is None or row[y]==' ':
                            row[y]=''
                        row[y]=str(row[y]).replace("'",'')
                        row[y]='"'+str(row[y])+'"'

                for s_row in row:
                    if s_row is None:
                        s_row=''
                    res_row.append(str(s_row).strip())
                writer.writerow(res_row)
                res_row=[]

