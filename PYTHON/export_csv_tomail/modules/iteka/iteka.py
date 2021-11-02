#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json

from engine import Db, existPath, read_ini, my_log
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


    def getType(self):
        # type = 0 Выгрузка полного прайса
        # type = 1 Выгрузка изменений относительно пункта 1
        type = 0 if datetime.now().strftime('%w') == '1' else 1
        return type

    def get_Data(self):
        Logins = json.loads(read_ini(self.conf,'LOGIN',self.conf).replace("'",'"'))
        if self.getType() == 0:
            val ={'profile_id': self.profile_id}
            self.data = self.DB.get_from_base(__name__, 'full', val)
        else:
            val ={'date_start': self.date_start, 'profile_id': self.profile_id}
            self.data = self.DB.get_from_base(__name__, 'new', val)




