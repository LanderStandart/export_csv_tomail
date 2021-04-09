#  Autor by Lander (c) 2020. Created for Standart-N LLT
from  engine import ExportData,Db,LogIt,read_ini
import os
try:
    os.remove('./log.txt')
except:
    print('Файла с логом не нашлось')

system = Db()
# system.config.read('./config.ini')


params = system.config.items('PARAMS')
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        LogIt('Формируем:'+ firm)
        ExportData(firm).create('file')






