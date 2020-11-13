#  Autor by Lander (c) 2020. Created for Standart-N LLT
from MyUtils import Db,CSV_File,FTP_work
class Kz2GIS(Db):
    def __init__(self,profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.FTPconf='FTP_CONF1'
        self.head = [self.DB.config.get('CSV_CONF', 'HEAD')]
        if self.profile_id:
            self.SQL = "SELECT first 10 sname, cast(quant as numeric(9,2)), price FROM warebase_g w "
            self.profile_name = self.DB.get_sql("SELECT caption FROM G$PROFILES where id="+str(self.profile_id))[0][0]
            self.where = " where w.g$profile_id="+str(self.profile_id)
        else:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase w "
            self.profile_name = self.DB.config.get('BASE_CONF', 'CLIENT')
            self.where =None

    def get_data(self):
        print(self.profile_name,'Формируем: ')
        CSV_File(self.profile_name, self.DB.get_sql(self.SQL, self.where), self.head,self.profile_name).create_csv()
        FTP_work(self.FTPconf).upload_FTP(self.profile_name + '.csv')