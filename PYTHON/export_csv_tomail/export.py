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
SQL_warebase = "SELECT sname, cast(quant as numeric(9,2)), price FROM warebase_g w "
SQL_warebase_PharmIT = "select first 1 g.caption,w.sname,w.sizg,w.quant,w.price from warebase_g w inner join g$profiles g on g.id=w.g$profile_id and g.email is not null  where w.quant>0"
SQL_warebase_ITEKA = "select w.sname,w.price, w.scountry, w.sizg, w.quant, w.ware_id from warebase w " \
                     "inner join doc_detail dd on dd.part_id=w.part_id " \
                     "inner join docs d on d.id=dd.doc_id and d.commitdate between '$datestart' and current_timestamp"

def Create_upload(param,profile_id,profile_name):
    #Определяем получателя
    if param == '2GIS':
        FTPCONF='FTP_CONF1'
    #Если получатель включен высылаем файл
    if int(config.get('PARAMS', param)):
        print('Формируем: '+param+' профиль->' + profile_name)
        # Создаем файл с данными
        where = "where w.quant>0 and w.g$profile_id=" + str(profile_id)
        MyUtils.create_csv(profile_name, DataB.get_sql(SQL_warebase, where), head, profile_name)
        # Выгружаем на ФТП
        MyUtils.upload_FTP(config.get(FTPCONF, 'FTP_HOST'), config.get(FTPCONF, 'FTP_USER'),
                           config.get(FTPCONF, 'FTP_PASSWORD'), profile_name + '.csv')


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
    # #Выгрузка остатков раздельно по профилям
    #     MyUtils.create_csv(i[2],DataB.get_sql(SQL_warebase,where),head,i[2])
    # # Выгружаем на FTP  apteka.103.kz
    #     Create_upload('103KZ', i[0], i[2])
    # #Выгружаем на FTP  2Gis
    #     Create_upload('2GIS', i[0], i[2])

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





