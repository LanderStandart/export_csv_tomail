#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import sys
from engine import Db, existPath, read_ini, my_log, put_file

import requests
import datetime
from requests.auth import HTTPBasicAuth
from calendar import monthrange
from tqdm import tqdm
sys.path.insert(0, "./engine")
from CSV import CSV_File

logger = my_log.get_logger(__name__)
class Grandcapital(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.client_id= read_ini(self.conf, 'CLIENT_ID', self.conf)
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.type = int(read_ini(self.conf, 'TYPE', self.path_ini))
        # self.DB.cheak_db(read_ini(self.conf, 'TABLE', self.path_ini), 'TABLE')
        # self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE', self.path_ini), 'PROCEDURE')
        # self.DB.cheak_db(read_ini(self.conf, 'TRIGGER', self.path_ini), 'TRIGGER')




    def get_Data(self,date_start=None):
        self.filename=self.getFileName()
        self.getDate()
        logger.info(f'Формируем остатки по профилю- {self.profile_id}')
        file_ost = self.path + self.filename
        sql_file = 'warebase' if not self.profile_id else 'warebase_g'
        date_ost = self.date_start if self.type == 0 else self.date_start+datetime.timedelta(days=1)
        val={'date_beg':self.date_start.strftime('%d.%m.%Y'),'date_ost':date_ost.strftime('%d.%m.%Y'),'profile':self.profile_id}
        self.data = self.DB.get_from_base(__name__,sql_file,val)
        CSV_File(file_ost,self.data,ext='.ost').create_csv()

        logger.info(f'Формируем движение по профилю- {self.profile_id}')
        file_ost = self.path + self.filename
        sql_file = 'move' if not self.profile_id else 'move_g'
        val = {'date_start': self.date_start.strftime('%d.%m.%Y 00:00:00'), 'date_end': self.date_end.strftime('%d.%m.%Y 23:59:59'),
               'profile': self.profile_id}
        self.data = self.DB.get_from_base(__name__, sql_file, val)
        CSV_File(file_ost, self.data, ext='.mov').create_csv()



    def getFileName(self):
        return f'{self.client_id}${datetime.datetime.now().strftime("%Y%m%d%H%M%S")}'

    def getDate(self):
        self.date_start = datetime.datetime.now() if self.type == 0 else datetime.datetime.strptime(datetime.datetime.now().strftime('01.%m.%Y'),'%d.%m.%Y')- datetime.timedelta(days=1)
        self.date_end = datetime.datetime.now()

