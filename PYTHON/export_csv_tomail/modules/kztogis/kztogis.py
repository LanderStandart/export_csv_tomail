#  Autor by Lander (c) 2020. Created for Standart-N LLT
from system import System
from CSV import CSV_File
from ftp import FTP_work
from firebirdsql import Db

class Kztogis(System):
    def __init__(self,profile_id=None):

        self.logger = self.Logs(__name__)
        self.profile_id = profile_id
        self.DB = Db()
        # self.SYS = System()
        self.path_ini = __name__
        self.profile_id = profile_id
        self.conf = self.path_ini.upper()
        self.path = self.read_ini(self.conf, 'PATH_EXPORT', self.path_ini.lower())
        self.existPath(self.path)
        self.head = self.read_ini(self.conf, 'HEAD',self.path_ini).split(';')
        self.file_name = f"{self.read_ini(self.conf, 'PATH_EXPORT',self.path_ini)}{self.read_ini(self.conf, 'ID_CLIENT',self.path_ini)}"
        if self.profile_id:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase_g w "
            self.profile_name = self.DB.get_sql("SELECT caption FROM G$PROFILES where id="+str(self.profile_id))[0][0]
            self.where = " where w.g$profile_id="+str(self.profile_id)
            self.file_name = self.file_name+'_'+str(self.profile_id)
        else:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase w "
            self.profile_name = self.read_ini('BASE_CONF', 'CLIENT')
            self.where =None

    def get_Data(self):
        self.logger.info('Формируем: '+self.file_name)
        try:
            result = CSV_File(self.file_name, self.DB.get_sql(self.SQL, self.where), self.head,self.profile_name).create_csv()

            result = FTP_work(self.conf).upload_FTP(self.file_name + '.csv')
            self.logger.info(f'result - {result}')
            if 0 in result:
                raise ValueError("What's is goes wrong")

        except:
            return 0
        else:
            return 1