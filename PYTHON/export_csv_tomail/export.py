#  Autor by Lander (c) 2020. Created for Standart-N LLT

import fdb
import csv
import configparser
from ftplib import FTP
import zipfile 

config = configparser.ConfigParser()
config.read('c:/STANDART-N/export_csv_tomail/config.ini')
section = 'BASE_CONF'
host = config.get(section, 'HOST')
database = config.get(section, 'PATH')



conn = fdb.connect(host=host, database=database, user='sysdba', password='masterkey')

curs = conn.cursor()
head = [config.get('CSV_CONF', 'HEAD')]
SQL_profile= "SELECT id,caption,email FROM G$PROFILES where email is not null"
SQL_warebase = "SELECT sname, cast(quant as numeric(9,2)), price FROM warebase_g w "
SQL_warebase_PharmIT = "select g.caption,w.sname,w.sizg,w.quant,w.price from warebase_g w inner join g$profiles g on g.id=w.g$profile_id and g.email is not null  where w.quant>0"
#запрос к базе
def get_sql(sql,where=None):
    if where is None:
        sql=sql
    else:
        sql=sql+where

    query =curs.execute(sql)

    result = []
    for i in query:
        result.append(list(i))
    return result

def upload_FTP(host,ftp_user,ftp_password,file_name,port=21):
    ftp = FTP()
    ftp.connect(host,port)

    ftp.login(ftp_user, ftp_password)
    
    ftp.set_pasv(True)
    ftp.storlines("STOR " + file_name, open(file_name, 'rb'))
    ftp.quit()



def create_csv(filename,data,header=None,profile_code=None):
    with open(filename+'.csv', 'w', newline='') as f:
        writer = csv.writer(f, delimiter=';',escapechar=' ', quoting=csv.QUOTE_NONE)
        if header is not None:
            writer.writerow(header)
            print(header)

        for row in data:
            if profile_code is None:
                row=row
            else:
                row=[profile_code]+row
            writer.writerow(row)

profiles = get_sql(SQL_profile)
for i in profiles:
    where = "where w.quant>0 and w.g$profile_id="+str(i[0])
    #Выгрузка остатков раздельно по профилям
    create_csv(i[2],get_sql(SQL_warebase,where),head,i[2])
    # Выгружаем на FTP  apteka.103.kz
    upload_FTP(config.get('FTP_CONF', 'FTP_HOST'),config.get('FTP_CONF', 'FTP_USER'),config.get('FTP_CONF', 'FTP_PASSWORD'),i[2]+'.csv')
    #Выгружаем на FTP  2Gis
    upload_FTP(config.get('FTP_CONF1', 'FTP_HOST'), config.get('FTP_CONF1', 'FTP_USER'),
               config.get('FTP_CONF1', 'FTP_PASSWORD'), i[2]+'.csv')

#формирует выгрузку остатков для фармИТ
filen=config.get('FTP_CONF2', 'ID_CLIENT')
create_csv(filen, get_sql(SQL_warebase_PharmIT))
PharmZIP=zipfile.ZipFile('./'+filen+'.zip','w')
PharmZIP.write('./'+filen+'.csv',compress_type=zipfile.ZIP_DEFLATED)
PharmZIP.close()
upload_FTP(config.get('FTP_CONF2', 'FTP_HOST'),config.get('FTP_CONF2', 'FTP_USER'),config.get('FTP_CONF2', 'FTP_PASSWORD'),filen+'.csv',int(config.get('FTP_CONF2', 'FTP_PORT')))

