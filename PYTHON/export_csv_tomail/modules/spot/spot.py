#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work, Archiv, Db, os, existPath, read_ini, get_File, put_file, my_log, CSV_File
import json
import datetime
import requests
from requests.auth import HTTPBasicAuth
import re
from pathlib import Path
import os
from tqdm import tqdm

logger = my_log.get_logger(__name__)


class Spot(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.profile_id = profile_id
        self.conf = self.path_ini.upper()
        self.suffix = '_g' if self.profile_id else ''
        # Если есть в настройках Путь для экспорта берем его или в штатный путь выгружаем
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.path_ini) if read_ini(self.conf, 'PATH_EXPORT',self.path_ini) else f'./export/{__name__}/'
        self.expfile = read_ini(self.conf, 'FILE_LIST', self.path_ini).split(',')
        self.distr = json.loads(read_ini(self.conf, 'ID_DISTR', self.path_ini))
        existPath(self.path)

    def get_key(self,d, value):
        for k, v in d.items():
            if v == value:
                return k

    def get_iddistr(self,data):
        # Get ID_DISTR
        # task = 'iddistr'
        # txt = []
        # val = {'profile_id': self.profile_id}
        # data = self.DB.get_from_base(__name__, task, val, profile=self.suffix)
        # for ee in data:
        #     str1 = ' '.join([str(e) for e in ee])
        #     txt.append(str1)
        #     str1 = ''
        # self.iddistr = ''.join(txt).lower()
        # if not self.iddistr:
        #     return

        self.iddistr = self.get_key(self.distr, data.lower())

    def get_date(self,task):
        date_s =datetime.datetime.strptime(read_ini(self.conf, 'DATE_START', self.path_ini),'%d.%m.%Y') if read_ini(self.conf, 'DATE_START', self.path_ini) else datetime.date.today()
        date_e = datetime.datetime.strptime(read_ini(self.conf, 'DATE_END', self.path_ini),'%d.%m.%Y') if read_ini(self.conf, 'DATE_END', self.path_ini) else datetime.date.today()
        self.date_start = date_s - datetime.timedelta(days=45) if task == 'offtake' or task == 'delivery' else date_s - datetime.timedelta(days=7)
        self.date_end =  date_s - datetime.timedelta(days=1)

    def create_data_file(self,task):
        date_go = self.date_start
        logger.info(f'{date_go} -- {self.date_end}')
        data_all = []
        ttl = self.date_end - self.date_start
        pbar = tqdm(total=ttl.days)
        self.name_distr =''
        while date_go < self.date_end:
            val = {'datestart': date_go.strftime('%d.%m.%Y'),
                   'profile': read_ini(self.conf, 'PROFILE_DISTR', self.path_ini),
                   'profile_id':self.profile_id}

            data = self.DB.get_from_base(__name__, task, val, profile=self.suffix)
            data_all.extend(data)
            date_go = date_go + datetime.timedelta(days=1)
            pbar.update(1)
            if task in 'ttoptions' or task in 'sku':
                date_go =self.date_end

        all_data = []
        logger.info(task)
        if task not in 'sku' and task not in 'offtake_report' and task not in 'stocks_report' and task not in 'stocks_tt_report':
            logger.info('not in report')
            for dat in data_all:
                self.get_iddistr(dat[0])
                self.name_distr = dat[0]
                if task in 'ttoptions':
                    dat[6] = str(dat[6]).replace(dat[0],self.iddistr)
                if task in 'offtake':
                    dat[2] = str(dat[2]).replace(dat[0],self.iddistr)
                dat[0] = self.iddistr
        elif task != 'offtake_report' and task != 'stocks_report' and task != 'stocks_tt_report':
            id_key = list(self.distr.keys())
            data_all = []
            for i in id_key:
                self.data_1=[]
                self.data_1 = [e.copy() for e in data]

                for dat1 in self.data_1:
                    dat1[0] = str(i)
                    if task == 'sku':
                        reg=re.compile(r"^\s+|\n|\r|;|\s+$")
                        dat1[2] = reg.sub(' ', dat1[2])
                data_all.extend(self.data_1)


        head = get_File(f'./modules/{__name__}/head/', task).split('\n')
        if task == 'stocks_tt_report' or task == 'offtake_report':
            task=f'{task}_{self.profile_id}'
        CSV_File(f'{self.path}\{task}', data_all, head, delimeter=';', encoding='utf-8').create_csv()
        self.send_file(f'{self.path}\{task}.csv',task)



    def get_Data(self):

        for i in self.expfile:
            self.get_date(i.lower())
            self.create_data_file(i.lower())

    def send_file(self,filename,task):
        self.Logins ='farmakom'
        self.password ='STAbu805'

        url = "https://aask.spot2d.com/dinfo/auto-upload.phtml"

        payload = {'__login': self.Logins,
                   '__password': self.password}
        files = [
            ('ufile', (f'{task}.csv', open(filename, 'rb'),
            'text/plain'))
        ]

        response = requests.request("POST", url, data=payload, files=files)
        logger.info(response.text)


