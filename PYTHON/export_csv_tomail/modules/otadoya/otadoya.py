#  Autor by Lander (c) 2020. Created for Standart-N LLT
from engine import Db,  FTP_work, existPath, read_ini, my_log, sys
sys.path.insert(0, "./engine")
from CSV import CSV_File

logger = my_log.get_logger(__name__)
class Otadoya(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.profile_id = profile_id
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        existPath(self.path)

        self.file_name = self.path + read_ini(self.conf, 'ID_CLIENT',self.path_ini)+str(self.profile_id)
        logger.info('Формируем - ' + self.file_name)


    def get_Data(self):
        val = {'profile': self.profile_id}
        self.data = self.DB.get_from_base(__name__, 'warebase', val)
        CSV_File(self.file_name, self.data,  delimeter='|', encoding='utf-8').create_csv()
        FTP_work(self.conf).upload_FTP(self.file_name + '.csv')








