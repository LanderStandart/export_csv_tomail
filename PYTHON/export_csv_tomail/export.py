import declare
import fdb
import csv
import configparser

config = configparser.ConfigParser()
config.read('./config.ini')
section = 'BASE_CONF'
host = config.get(section, 'HOST')
database = config.get(section, 'PATH')



conn = fdb.connect(host=host, database=database, user='sysdba', password='masterkey')

curs = conn.cursor()
head = [config.get('CSV_CONF', 'HEAD')]
SQL_profile= "SELECT id,caption,email FROM G$PROFILES"
SQL_warebase = "SELECT sname, cast(quant as numeric(9,2)), price FROM warebase_g  w "

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

def upload_FTP(host,ftp_user,ftp_password,file_name):
    ftp = FTP()
    ftp.connect(host)
    ftp.login(ftp_user, ftp_password)
    ftp.set_pasv(False)
    ftp.storlines("STOR " + file_name, open(file_name, 'rb'))
    ftp.quit()



def create_csv(filename,data,header,profile_code):
    with open(filename+'.csv', 'w', newline='') as f:
        writer = csv.writer(f, delimiter=';',escapechar=' ', quoting=csv.QUOTE_NONE)
        writer.writerow(header)
        print(header)

        for row in data:
            row=[profile_code]+row
            writer.writerow(row)
            #print(row)


profiles = get_sql(SQL_profile)

for i in profiles:
    where = "where w.g$profile_id="+str(i[0])
    create_csv(i[1],get_sql(SQL_warebase,where),head,i[2])
    upload_FTP(config.get('FTP_CONF', 'HOST'),config.get('FTP_CONF', 'FTP_USER'),config.get('FTP_CONF', 'FTP_PASSWORD')],i[1].'.csv')
    upload_FTP(config.get('FTP_CONF1', 'HOST'), config.get('FTP_CONF1', 'FTP_USER'),
               config.get('FTP_CONF1', 'FTP_PASSWORD')], i[1].
    '.csv')


