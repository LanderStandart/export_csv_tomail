#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Создание DBF
import sys,dbf
import csv
sys.path.insert (0,".")
from system import System

class DBF_File(System):
    def __init__(self):

        self.logger =self.Logs(__name__)

    def create_dbf(self, filename, columns, values, values1=None):
        self.logger.info('Создаем DBF -' + filename)
        table = dbf.Table(filename, columns, codepage='cp1251', )
        table.open(mode=dbf.READ_WRITE)
        # values = values_in.extend(values1) if values1 else values_in

        i = 0
        j = []
        while i < len(values):
            for a in values[i]:
                #print(f'{type(a)}  - {a}')
                j.append(self.clear_string(a) if isinstance(a, str) else a)
            datum = tuple(j)

            table.append(datum)
            j = []
            i += 1
        table.close()
        self.logger.info('В файл ' + filename + ' добавлено ' + str(i) + ' строк')

        # Чистим строку от спец символов



