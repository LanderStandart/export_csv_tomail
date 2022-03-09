#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import sys
from engine import Db, existPath, read_ini, my_log, put_file
import requests
import datetime
from requests.auth import HTTPBasicAuth
from calendar import monthrange
from tqdm import tqdm
logger = my_log.get_logger(__name__)
class Pharmit(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.url_file_id = read_ini(self.conf, 'URL_FILE_ID', self.conf)
        self.url_get_file_id = read_ini(self.conf, 'URL_GET_FILE_ID', self.conf)
        self.url_load = read_ini(self.conf, 'URL_LOAD', self.conf)
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.DB.cheak_db(read_ini(self.conf, 'TABLE', self.path_ini), 'TABLE')
        self.DB.cheak_db(read_ini(self.conf, 'PROCEDURE', self.path_ini), 'PROCEDURE')
        self.DB.cheak_db(read_ini(self.conf, 'TRIGGER', self.path_ini), 'TRIGGER')

        self.base = self.DB.get_from_base(self.path_ini,'getbase',{"profile_id":self.profile_id})[0][0] if self.profile_id else 1
        self.Logins = json.loads(read_ini(self.conf, 'LOGIN', self.conf).replace("'", '"'))[str(self.base)] if self.base  else read_ini(self.conf, 'LOGIN', self.conf)
        self.password = json.loads(read_ini(self.conf, 'PASS', self.conf).replace("'", '"'))[str(self.base)] if self.base  else read_ini(self.conf, 'PASS', self.conf)
        self.auth=HTTPBasicAuth(self.Logins,self.password)

    def get_Data(self,date_start=None):

        if not date_start and int(datetime.datetime.now().strftime('%H')) != 23 and int(datetime.datetime.now().strftime('%M')) < 50:
            self.get_Decada()
            self.check_date()

            return
        self.date_start = self.getDate() if not date_start else date_start



        print(self.date_start + '   '+datetime.datetime.now().strftime('%H'))
        self.fileID = self.getToken(datetime.datetime.strptime(self.date_start, '%d.%m.%Y').strftime('%Y%m%d'))
        logger.info(f'FileID-{self.fileID}')
        if self.fileID!=0:
            if self.profile_id:
                val = {'date_start': self.date_start, 'date_end': self.date_start, 'profile_id': self.profile_id}
                self.data = self.DB.get_from_base(__name__, 'move', val)
            else:
                val = {'date_start': self.date_start, 'date_end': self.date_start}
                self.data = self.DB.get_from_base(__name__, 'move_alone', val)

            self.put_packet(self.getPacket())
        # date_start = datetime.date.today()-datetime.timedelta(days=11)


        if not date_start:
            self.check_date()
        self.get_Decada()

    def send_request(self, type,data=None,header=None,auth=None,url=None):
        header = {'Content-type': 'application/json'} if type=='POST' else None
        res = requests.request(type,url=url,data=data,headers=header,auth=auth)
#        logger.info(f'{self.url_file_id}-{res.status_code}- {res.reason}-\n{res.text}')
        return res.text


    def getToken(self, date,type='DateSale'):
        headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        data = json.dumps({type: date})
        #logger.error(data)
        res=self.send_request(data=data,type='POST',header=headers,auth=self.auth,url=self.url_file_id)
        if "Данные за эту дату уже загружены!" in res or "Данные за эту декаду уже загружены!" in res or "Данные за этот месяц уже загружены!" in res:
            logger.error("Данные за эту дату уже загружены!")
            res=0
            
            #res=self.send_request(url=self.url_get_file_id+date,type='GET',auth=self.auth)
        logger.info(f'Baseagent-{self.base} -{self.Logins} - getToken {type}  Answer- {res}')
        return res

    def getPacket(self):
        packet = []
        i = 1
        j = 0
        pbar = tqdm(total=len(self.data))
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
            self.check_null(pack)
            packet.append(one_str)
            pbar.update(1)
            i += 1
            if i == 100:
                i = 0
                self.send_packet(packet,j)
                packet = []
            j += 1
        self.send_packet(packet,j)
#        pbar.write(j)
        return j


    def send_packet(self, packet,count,last=None):
        data = json.dumps(packet, ensure_ascii=False).encode('utf8')
        headers = {'Content-type': 'application/json'}
#       print(self.path+str(count)+'.json')
       # print(packet)
       # logger.info(self.path+str(self.fileID)+'_'+str(count)+'.json')
        put_file(self.path+str(self.fileID)+'_'+str(count)+'.json',data)

        self.send_request(data=data,type='POST',header=headers,auth=self.auth,url=self.url_load)

    def put_packet(self,count):
        self.send_request(type='PUT',auth=self.auth,url=self.url_file_id+f'/{self.fileID}_{count}')

    def getDate(self):
        if not read_ini(self.conf,'DATE_START',self.conf):
            self.date_start =datetime.datetime.now() if int(datetime.datetime.now().strftime('%H'))>5 else datetime.date.today()-datetime.timedelta(days=1)
            self.date_start = self.date_start.strftime('%d.%m.%Y')
        else:
            self.date_start=read_ini(self.conf,'DATE_START',self.conf)
        return self.date_start

    def check_null(self,packet):
       # TypeId, GoodName, Pharm, Quantity, FileId, ProviderSaleId
        if not packet[0]  or not packet[4]  or not packet[8]  or not packet[5]  or not packet[15] :
            logger.error(f'Пустые значения -TypeId {packet[0]} GoodName {packet[4]} Pharm {packet[8]} Quantity {packet[5]} ProviderSaleId {packet[15]}')

    def check_date(self):
        #return
        chk_date=datetime.datetime.strptime(read_ini(self.conf,'DATE_CHECK',self.conf), '%d.%m.%Y').strftime('%Y%m%d')
        url=f'{self.url_load}?startDate={chk_date}'
        res = self.send_request(url=url, type='GET', auth=self.auth)
        res = json.loads(res.replace("'",'"'))
        noDate=res['noDates']
        for date in noDate:
            c_date=datetime.datetime.strptime(str(date),'%Y%m%d').strftime('%d.%m.%Y')
            self.get_Data(date_start=c_date)
        return

    def getPacket_decada(self):
        
        packet = []
        i = 1
        j = 0
        for pack in self.data:

            one_str = {'typeid': pack[0],
                       'Tender': pack[1],
                       'GoodName': pack[2],
                       'producerName': pack[3],
                       'Pharm': pack[4],
                       'Pharmaddress': pack[5],
                       'barcode': str(pack[6]),
                       'quantity': pack[7],
                       'FileId': self.fileID,
         }
            #self.check_null(pack)
            packet.append(one_str)
            i += 1
            if i == 100:
                i = 0
                self.send_packet(packet,j)
                packet = []
            j += 1
        self.send_packet(packet,j)
        print(j)
        return j

    def get_Decada(self):
        today =datetime.date.today().strftime('%d')
        date_go = None
        month = read_ini(self.conf, 'MONTH', self.conf) if read_ini(self.conf, 'MONTH', self.conf)  else str(int(datetime.date.today().strftime('%m')) - 1) if int(datetime.date.today().strftime('%m')) != 1 else '12' 
        year = read_ini(self.conf, 'YEAR', self.conf) if read_ini(self.conf, 'YEAR', self.conf)  else str(int(datetime.date.today().strftime('%Y'))) if int(month) != 1 else str(int(datetime.date.today().strftime('%Y'))-1)
        last_day=str(monthrange(int(year), int(month))[1])
        
        date_start = f'01.{month}.{year}'
        if today==5 or read_ini(self.conf,'DECADA',self.conf)=='5':
            #month
            date_go=year+month
            type='MonthSale'
            date_end = f'{last_day}.{month}.{year}'

        if today==15 or read_ini(self.conf,'DECADA',self.conf)=='15':
            #decade 1
            date_go=year+month+'1'
            type = 'DecadeSale'
            date_end = f'10.{month}.{year}'

        if today==25 or read_ini(self.conf,'DECADA',self.conf)=='25':
            #decade 2
            date_go=year+month+'2'
            type = 'DecadeSale'
            date_end = f'20.{month}.{year}'
        if not date_go:
            return
        logger.info(f'{date_go}--{type}')
        self.fileID = self.getToken(date=date_go,type=type)

        if self.fileID != 0:
            val = {'date_start': date_start, 'date_end': date_end, 'profile_id': self.profile_id}
            self.data = self.DB.get_from_base(__name__, 'decada', val)
            self.put_packet(self.getPacket_decada())





