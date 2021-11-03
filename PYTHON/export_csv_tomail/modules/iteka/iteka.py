#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob
from engine import Db, existPath, read_ini, my_log,os,time
from datetime import datetime

logger = my_log.get_logger(__name__)

class Iteka(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.date_start = '01.11.2021'
        self.Logins = json.loads(read_ini(self.conf, 'LOGIN', self.conf).replace("'", '"'))


    def getType(self):
        # type = 0 Выгрузка полного прайса
        # type = 1 Выгрузка изменений относительно пункта 1
        Log = self.Logins[self.profile_id]
        print(f'LOGIN-{Log}')
        chkFile = self.chk_file(Log)
        type=0 if datetime.now().strftime('%w') == '1' or read_ini(self.conf,'TYPE',self.conf) and chkFile==0 else 1

        return type

    def get_Data(self):

        if self.getType() == 0:
            val ={'profile_id': self.profile_id}
            sql_name = 'full'
        else:
            val ={'date_start': self.date_start, 'profile_id': self.profile_id}
            sql_name = 'new'
        self.data = self.DB.get_from_base(__name__, sql_name, val)

    def chk_file(self,Login):
        path = f'{self.path}{Login}_0_*'
        try:
            list_of_files = glob.glob(path)  # * means all if need specific format then *.csv
            latest_file = max(list_of_files, key=os.path.getctime)
            file_time = datetime.fromtimestamp(os.path.getmtime(latest_file)).strftime('%d.%m.%Y')
            res = 1 if file_time == datetime.now().strftime('%d.%m.%Y') else 0
            return res
        except:
            return 0







