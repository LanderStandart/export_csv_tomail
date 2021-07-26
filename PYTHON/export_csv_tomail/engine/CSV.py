#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Создание CSV
import sys
import csv
sys.path.insert (0,".")
from system import LogIt
class CSV_File:
    def __init__(self,filename, data, header=None, profile_code=None,delimeter=';',encoding='cp1251'):
        self.filename = filename
        self.data = data
        self.header = header
        self.profile_code = profile_code
        self.delimeter = delimeter
        self.encoding=encoding


    def create_csv(self):
        res_row=[]
        print(self.filename)
        LogIt('Create File:'+self.filename + '.csv')
        with open(self.filename + '.csv', 'w', newline='',encoding=self.encoding) as f:
            writer = csv.writer(f,delimiter=self.delimeter, escapechar='\\', quoting=csv.QUOTE_NONE)
            if self.header is not None:
                writer.writerow(self.header)
            for row in self.data:
                if self.profile_code is None:
                    row = row
                else:
                    row = [self.profile_code] + row
                for s_row in row:
                    if s_row is None:
                        s_row=''
                    res_row.append(str(s_row).strip())
                writer.writerow(res_row)
                res_row=[]

