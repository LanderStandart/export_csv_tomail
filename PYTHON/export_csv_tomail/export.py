#  Autor by Lander (c) 2020. Created for Standart-N LLT
import configparser
from  MyUtils import Db,ExportData

DataB = Db()
config = configparser.ConfigParser()
config.read('./config.ini')

head = [config.get('CSV_CONF', 'HEAD')]

params = config.items('PARAMS')
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        print('Формируем:'+ firm)
        ExportData(firm).create('file')




