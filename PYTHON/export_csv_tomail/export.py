#  Autor by Lander (c) 2020. Created for Standart-N LLT

import configparser
import MyUtils
from  MyUtils import Db,Archiv,CSV_File

DataB = Db()
config = configparser.ConfigParser()
config.read('./config.ini')

if int(config.get('PARAMS', 'DAMUMED')):
    from damumed import Damumed
if int(config.get('PARAMS', '103KZ')):
    from kz103 import Kz103
if int(config.get('PARAMS', '2GIS')):
    from kz2gis import Kz2GIS
if int(config.get('PARAMS', 'FARMIT')):
    from  pharmit import PharmIt

head = [config.get('CSV_CONF', 'HEAD')]
SQL_profile= "SELECT first 2 id,caption,email FROM G$PROFILES where email is not null"
SQL_warebase_ITEKA = "select w.sname,w.price, w.scountry, w.sizg, w.quant, w.ware_id from warebase w " \
                     "inner join doc_detail dd on dd.part_id=w.part_id " \
                     "inner join docs d on d.id=dd.doc_id and d.commitdate between '$datestart' and current_timestamp"


if int(config.get('PARAMS', '103KZ')):
    if int(config.get('PARAMS', 'ALONE')):
        # Выгружаем на FTP  apteka.103.kz
        Kz103().get_data()
    else:
        profiles = DataB.get_sql(SQL_profile)
        for i in profiles:
            Kz103 (i[0]).get_data()

if int(config.get('PARAMS', '2GIS')):
    if int(config.get('PARAMS', 'ALONE')):
        # Выгружаем на FTP  2Gis
        Kz2GIS().get_data()
    else:
        profiles = DataB.get_sql(SQL_profile)
        for i in profiles:
            Kz2GIS(i[0]).get_data()


# формируем выгрузку DAMUMED
if int(config.get('PARAMS', 'DAMUMED')):
    if int(config.get('PARAMS', 'ALONE')):
        print('Одиночная точка пока не реализована')
    else:
        profiles = DataB.get_sql(SQL_profile)
        for i in profiles:
            print('Формируем: DAMUMED профиль->' + str(i[0]))
            fn = Damumed(DataB,MyUtils.tranlit(i[2]),str(i[0])).get_Data()


#формирует выгрузку остатков для фармИТ
if  int(config.get('PARAMS', 'FARMIT')):
    print('Формируем: PharmIT')
    PharmIt().get_Data()





