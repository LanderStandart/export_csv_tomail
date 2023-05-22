#  Autor by Lander (c) 2020. Created for Standart-N LLT
from firebirdsql import Db
from system import System
from CSV import CSV_File
from ftp import FTP_work


class Kz103(System):
    def __init__(self, profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.logger = self.Logs(__name__)
        self.conf = 'KZ103'
        self.path_ini=__name__
        self.path = self.read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        self.existPath(self.path)
        self.head = [self.read_ini(self.conf, 'HEAD',self.path_ini)]
        self.file_name = self.path + self.read_ini(self.conf, 'ID_CLIENT',self.path_ini)

    def get_Data(self):
        if self.profile_id:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase_g w where quant>0"
            self.profile_name = self.DB.get_sql("SELECT caption FROM G$PROFILES where id="+str(self.profile_id))[0][0]
            self.DB.get_sql("SELECT DESCRIPTION FROM G$PROFILES where id=" + str(self.profile_id))[0][0]
            self.where = " and w.g$profile_id=" + str(self.profile_id)
            self.file_name = self.file_name+'_'+str(self.profile_id)

        else:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase w "
            self.profile_name = self.read_ini(self.conf, 'ID_CLIENT',self.path_ini)
            self.where = None


        CSV_File(self.file_name, self.DB.get_sql(self.SQL, self.where), self.head, self.profile_name).create_csv()

        FTP_work(self.conf).upload_FTP(self.file_name + '.csv')














