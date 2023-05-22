#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob
from engine import Db, existPath, read_ini, my_log, sys, time, XML,Archiv,FTP_work,get_File
from datetime import datetime
from calendar import monthrange
sys.path.insert(0, "./engine")
from CSV import CSV_File


logger = my_log.get_logger(__name__)


class Standartpro(Db):
    def __init__(self, profile_id=None):
        logger.info(f'Init...{__name__}')
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = f'./export/{__name__}/'
        existPath(self.path)
        self.profile_id = profile_id
        self.client = read_ini(self.conf, 'CLIENT', self.conf)
        logger.info(f'Finish Init...{__name__}')

    def get_Data(self):
        self.get_Date()
        suffix = '_g' if self.profile_id else '' #exit('Работаем только с сетями')
        task = f'move{suffix}'

        head = get_File(f'./modules/{__name__}/head/', task).split('\n')

        val = {'profile_id': self.profile_id, 'date_start': self.date_start.strftime("%d.%m.%Y"),
               'date_end': self.date_end.strftime("%d.%m.%Y")}
        data = self.DB.get_from_base(__name__, task, val, profile=suffix)
        filename =f'{self.path}{self.client}_{self.profile_id}_{self.date_end.strftime("%d%m%Y")}_move' if self.profile_id else f'{self.path}{self.client}_{self.date_end.strftime("%d%m%Y")}_move'
        CSV_File(filename, data, head).create_csv()
        FTP_work(self.conf).upload_FTP(filename + '.csv', isbynary=False)


    def get_Date(self):
        # Получаем дату предыдущий месяц или первая половина текущего
        month = read_ini(self.conf, 'MONTH', self.conf) if read_ini(self.conf, 'MONTH', self.conf) else datetime.today().month-1
        year = read_ini(self.conf, 'YEAR', self.conf) if read_ini(self.conf, 'YEAR',self.conf) else datetime.today().year
        last_day = str(monthrange(int(year), int(month))[1])
        self.date_start = datetime.strptime(f'01.{month}.{year}', '%d.%m.%Y')
        self.date_end = datetime.strptime(f'{last_day}.{month}.{year}', '%d.%m.%Y')


