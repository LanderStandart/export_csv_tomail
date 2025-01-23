#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Создание CSV
import sys
import csv
sys.path.insert (0,".")
from system import System

class CSV_File(System):
    def __init__(self):

        self.logger =self.Logs(__name__)

    def create_csv(self,filename, data, header=None, profile_code=None,delimeter=';',encoding='cp1251',quotechar="'",ext='.csv',dialect='excel',quota=None):
        self.filename = filename
        self.data = data
        self.header = header
        self.profile_code = profile_code
        self.delimeter = delimeter
        self.quotechar = quotechar
        self.encoding = encoding
        self.ext = ext
        self.dialect = dialect

        res_row=[]
        self.quota = quota
        self.logger.info('Create File:'+self.filename + self.ext)
        try:

            with open(self.filename + self.ext, 'w', newline='',encoding=self.encoding) as f:

                # writer = csv.writer(f,delimiter=self.delimeter,dialect='excel', escapechar='~',quotechar=self.quotechar, quoting=csv.QUOTE_NONE)
                writer = csv.writer(f,dialect=self.dialect, delimiter=self.delimeter, escapechar='~',quotechar=self.quotechar)

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
        except:
            return 0
        else:
            return 1

