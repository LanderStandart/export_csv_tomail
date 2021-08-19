#  Autor by Lander (c) 2020. Created for Standart-N LLT
from  engine import ExportData,Db,read_ini,my_log
from system import LogIt


import os




logger = my_log.get_logger(__name__)
Db = Db()
# system.config.read('./config.ini')


params = Db.config.items('PARAMS')
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        #LogIt('Формируем:'+ firm)
        logger.info('Формируем:'+ firm)
        ExportData(firm).create('file')






