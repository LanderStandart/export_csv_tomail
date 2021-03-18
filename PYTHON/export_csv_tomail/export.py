#  Autor by Lander (c) 2020. Created for Standart-N LLT
import time
import configparser
from typing import Any, Union

import MyUtils
from  MyUtils import Db,Archiv,CSV_File,ExportData

DataB = Db()
config = configparser.ConfigParser()
config.read('./config.ini')

#исходя из настроек подгружаем выгрузки
# if int(config.get('PARAMS', 'DAMUMED')):
#     from damumed import Damumed
# if int(config.get('PARAMS', '103KZ')):
#     from kz103 import Kz103
# if int(config.get('PARAMS', 'Kz2GIS')):
#     from kz2gis import Kz2GIS
# if int(config.get('PARAMS', 'FARMIT')):
#     from  pharmit import Pharmit

head = [config.get('CSV_CONF', 'HEAD')]
# SQL_profile= "SELECT first 2 id,caption,email FROM G$PROFILES where email is not null"
SQL_profile= "SELECT id,caption,email FROM G$PROFILES where id in(140,141)"

# if int(config.get('PARAMS', '103KZ')):
#     if int(config.get('BASE_CONF', 'ALONE')):
#         # Выгружаем на FTP  apteka.103.kz
#         Kz103().get_data()
#     else:
#         profiles = DataB.get_sql(SQL_profile)
#         for i in profiles:
#             Kz103 (i[0]).get_data()
#
# # if int(config.get('PARAMS', 'Kz2GIS')):
# #     if int(config.get('BASE_CONF', 'ALONE')):
# #         # Выгружаем на FTP  2Gis
# #         Kz2GIS().get_data()
# #     else:
# #         profiles = DataB.get_sql(SQL_profile)
# #         for i in profiles:
# #             Kz2GIS(i[0]).get_data()
#
#

#
#
# #формирует выгрузку остатков для фармИТ
# if  int(config.get('PARAMS', 'FARMIT')):
#     print('Формируем: PharmIT')
#     PharmIt().get_Data()
#
# print(config.items('PARAMS'))
params = config.items('PARAMS')
#
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        print('Формируем:'+ firm)
        ExportData(firm).create('file')




