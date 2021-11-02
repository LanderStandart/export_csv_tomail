#  Autor by Lander (c) 2020. Created for Standart-N LLT
from  engine import ExportData,Db,read_ini,my_log,clear_export_path
import configparser

import os

logger = my_log.get_logger(__name__)

config = configparser.ConfigParser()
config.read('./config.ini')
params = config.items('PARAMS')
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        logger.info('Формируем:'+ firm)
        path = read_ini(firm.upper(),'PATH_EXPORT',firm)
        queue = read_ini(firm.upper(),'QUEUE',firm)
        clear_export_path(path)
        path = './log/'
        clear_export_path(path)
        ExportData(firm).create('file',queue)






