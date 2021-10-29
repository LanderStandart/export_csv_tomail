#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import sys

from engine import Db, existPath, read_ini, my_log
import requests
import datetime
from requests.auth import HTTPBasicAuth

logger = my_log.get_logger(__name__)


class Pharmit(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.url_file_id = read_ini(self.conf, 'URL_FILE_ID', self.conf)
        self.url_load = read_ini(self.conf, 'URL_LOAD', self.conf)
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.DB.cheak_db(read_ini(self.conf, 'TABLE', self.path_ini), 'TABLE')
        self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE', self.path_ini), 'PROCEDURE')
        self.DB.cheak_db(read_ini(self.conf, 'TRIGGER', self.path_ini), 'TRIGGER')
        self.auth=HTTPBasicAuth(read_ini(self.conf, 'LOGIN', self.conf),read_ini(self.conf, 'PASS', self.conf))

    def get_Data(self):
        self.getDate()

        val = {'date_start': self.date_start, 'date_end': self.date_start, 'profile_id': self.profile_id}
        self.data = self.DB.get_from_base(__name__, 'move', val)
        #date_start = datetime.date.today()-datetime.timedelta(days=11)
        self.fileID = self.getToken(datetime.datetime.strptime(self.date_start,'%d.%m.%Y').strftime('%Y%m%d'))

        c=self.getPacket()
        self.put_packet(c)

    def send_request(self, type,data=None,header=None,auth=None,url=None):
        header = {'Content-type': 'application/json'} if type=='POST' else None
        res = requests.request(type,url=url,data=data,headers=header,auth=auth)
        logger.info(f'{self.url_file_id}-{res.status_code}- {res.reason}-\n{res.text}')
        return res.text


    def getToken(self, date):
        headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        data = json.dumps({'DateSale': date})
        res=self.send_request(data=data,type='POST',header=headers,auth=self.auth,url=self.url_file_id)
        return res

    def getPacket(self):
        packet = []
        i = 1
        j = 0
        for pack in self.data:

            one_str = {'typeid': pack[0],
                       'DateId': pack[1],
                       'TimeId':str(pack[18]).replace(':',''),
                       'ExternalGoodId': pack[2],
                       'ProducerName': pack[3],
                       'GoodName': pack[4],
                       'Quantity': str(pack[5]),
                       'WholesalePriceKzt': str(pack[6]),
                       'PriceKzt': str(pack[7]),
                       'Pharm': pack[8],
                       'PharmBin': pack[9],
                       'Pharmaddress': pack[10],
                       'Index': pack[11],
                       'LocalityName': '',
                       'PharmX': '',
                       'PharmY': '',
                       'DistribName': pack[12],
                       'DistribBin': pack[13],
                       'DistribAdress': pack[14],
                       'ProviderSaleId': pack[15],
                       'FileId': self.fileID,
                       'QuantityBalance': str(pack[17]), }
            packet.append(one_str)
            i += 1
            if i == 100:
                i = 0
                self.send_packet(packet)
                packet = []
            j += 1
        self.send_packet(packet)
        print(j)
        return j


    def send_packet(self, packet,last=None):
        data = json.dumps(packet, ensure_ascii=False).encode('utf8')
        headers = {'Content-type': 'application/json'}
        print(data)
        self.send_request(data=data,type='POST',header=headers,auth=self.auth,url=self.url_load)

    def put_packet(self,count):
        self.send_request(type='PUT',auth=self.auth,url=self.url_file_id+f'/{self.fileID}_{count}')

    def getDate(self):
        if not read_ini(self.conf,'DATE_START',self.conf):
            self.date_start =datetime.date.today().strftime('%d.%m.%Y')
        else:
            self.date_start=read_ini(self.conf,'DATE_START',self.conf)
        return self.date_start





