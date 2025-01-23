import datetime

from system import System
from CSV import CSV_File
from ftp import FTP_work
from firebirdsql import Db

class Glovo(System):
    def __init__(self):

        self.logger = self.Logs(__name__)

        self.DB = Db()
        # self.SYS = System()
        self.path_ini = __name__

        self.conf = self.path_ini.upper()
        self.path = self.read_ini(self.conf, 'PATH_EXPORT', self.path_ini.lower())
        self.existPath(self.path)



    def get_Data(self,profile_id=None):
        self.profile_id = profile_id
        file_date = datetime.datetime.now().strftime('%Y%m%d_%H%M')
        self.count = self.read_ini(self.conf, 'count', self.path_ini.lower())
        self.file_name = f"{self.read_ini(self.conf, 'PATH_EXPORT', self.path_ini)}{self.read_ini(self.conf, 'companyID', self.path_ini)}_stock_{self.count}"
        self.logger.info('Формируем: '+self.file_name)
        task = 'full_g'
        self.head = self.get_File(f'./modules/{self.path_ini}/head/', task).split('\n')
        val = {'profile_id': str(self.profile_id)}
        data = self.DB.get_from_base(__name__, task, val)
        try:
            result = CSV_File().create_csv(self.file_name, data, self.head)
            self.logger.info(f'CSV returns {result}')
            #result = FTP_work(self.conf).upload_FTP(self.file_name + '.csv')
            self.logger.info(f'result - {result}')
            if result<1:
                raise ValueError("What's is goes wrong")

        except ValueError:
            return 0
        else:

            self.read_ini(self.conf, 'count', self.path_ini.lower(),save=1, values=int(self.count)+1)
            return 1