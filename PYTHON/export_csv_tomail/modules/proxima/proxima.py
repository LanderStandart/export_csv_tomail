#  Autor by Lander (c) 2021. Created for Standart-N LLT
import re
import datetime
import itertools,json,sys
from pathlib import Path
import requests
from requests.auth import HTTPBasicAuth
import gzip
import base64
from tqdm import tqdm
sys.path.insert(0, "./engine")
from system import System
from firebirdsql import Db
from ftp import FTP_work
from Archiv import Archiv
from XMLcreate import XML
from calendar import monthrange




class Proxima(Db,System):
    def __init__(self):
        self.logger = self.Logs(__name__,__name__)
        self.logger.info('Init')
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.alone = str(self.read_ini('BASE_CONF', 'ALONE'))
        self.path = self.read_ini(self.conf, 'PATH_EXPORT', self.path_ini)
        self.existPath(self.path)
        self.url_load = self.read_ini(self.conf, 'URL', self.path_ini)
        self.auth = HTTPBasicAuth('api', 'key-4c9d3a8d9521ff6a229f7de9bd961b7ee19d4eb7')

    def get_Data(self, profile_id=None):
        self.getDate()
        self.profile_id = profile_id
        task='sales_out'
        val = {'date_start': self.date_start, 'date_end': self.date_end, 'profile_id': self.profile_id}
        self.data = self.DB.get_from_base(__name__, task, val)
        self.logger.info(self.date_start)
        self.logger.info(self.date_end)
        self.logger.info(self.profile_id)
        self.getPacket()

    def getDate(self):
        month = self.read_ini(self.conf, 'MONTH', self.conf) if self.read_ini(self.conf, 'MONTH', self.conf) else str(
            int(datetime.date.today().strftime('%m')) - 1) if int(datetime.date.today().strftime('%m')) != 1 else '12'
        year = self.read_ini(self.conf, 'YEAR', self.conf) if self.read_ini(self.conf, 'YEAR', self.conf) else str(
            int(datetime.date.today().strftime('%Y'))) if int(month) != 1 else str(
            int(datetime.date.today().strftime('%Y')) - 1)
        lastday = str(monthrange(int(year), int(month))[1])
        month = month if len(month) > 1 else '0' + month
        self.date_start = f'01.{month}.{year}'
        self.date_end =f'{lastday}.{month}.{year}'

    def send_request(self, type, data=None, header=None, auth=None, url=None):
        # meta={"htag":"sale-out.monthly.kz",
        #       "span":[f"{self.date_start} 00:00:00",f"{self.date_end} 23:59:59"],
        #       "nick":"21-01"
        #       }
        # meta64=base64.b64encode(bytes(meta,'utf-8'))
        #
        #
        # header = {'Content-Encoding': 'gzip',
        #           'Content-type': 'application/json; charset=utf-8',
        #           'Content-Meta':meta64}

            #if type == 'POST' else None
        res = requests.request(type, url=url, data=data, headers=header, auth=auth)
        self.logger.info(f'{self.url_file_id}-{res.status_code}- {res.reason}-\n{res.text}')
        return res.text

    def getPacket(self):
        packet = []
        i = 1
        j = 0
        pbar = tqdm(total=len(self.data))
        for pack in self.data:
            one_str = {'id': pack[0],
                       'name': pack[1],
                       'quant_in': pack[2],
                       'price_in': pack[3],
                       'quant_out': pack[4],
                       'price_out': pack[5],
                       'stock': pack[6],
                       'reimbuse': pack[7],
                        }
            #self.check_null(pack)
            #self.logger.info(one_str)
            packet.append(one_str)
            pbar.update(1)
        #     i += 1
        #     if i == 100:
        #         i = 0
        #         self.send_packet(packet, j)
        #         packet = []
        #     j += 1
        # self.send_packet(packet, j)
        # #        pbar.write(j)
        self.send_packet(packet)
        return j

    def send_packet(self, packet, count=None, last=None):
        data = json.dumps(packet, ensure_ascii=False).encode('utf8')
        dataz=gzip.compress(data)
        meta = {"htag": "sale-out.monthly.kz",
                "span": [f"{self.date_start} 00:00:00", f"{self.date_end} 23:59:59"],
                "nick": "КЗ-4323158-А"
                }
        meta64 = base64.b64encode(bytes(str(meta), 'utf-8'))

        headers = {'Content-Encoding': 'gzip',
                  'Content-type': 'application/json; charset=utf-8',
                  'Content-Meta': meta64}
        #headers = {'Content-type': 'application/json'}
        self.logger.info(headers)
        #       print(self.path+str(count)+'.json')
        # print(packet)
        # logger.info(self.path+str(self.fileID)+'_'+str(count)+'.json')
       # put_file(self.path + str(self.fileID) + '_' + str(count) + '.json', data)

        self.send_request(data=data, type='POST', header=headers,auth=self.auth, url=self.url_load)