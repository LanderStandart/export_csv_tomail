#  Autor by Lander (c) 2021. Created for Standart-N LLT
import time
import datetime
import os,sys,dbf,re
import configparser
import pathlib
from my_log import Log
import requests


class System(Log):
    def __init__(self):
        self.logger = Log.get_logger(__name__)
    def read_ini(sections,params,modules=None,save=None,values=None):
        config = configparser.ConfigParser()
        path ='.' if not modules else './modules/'+modules
        try:
            config.read(path+'/config.ini')
            if not save:
                return config.get(sections, params)
            else:
                #config[sections][params]=str(values)
                config.set(sections, params, str(values))
                with open(path+'/config.ini', 'w') as configfile:
                    config.write(configfile)

        except:
            logger.error(f'Нет параметра - {params} в настройках - {sections} модуля {modules} - {path}/config.ini')

    def list_file_in_path(path,ext):
        curDir=pathlib.Path(path)
        curPatt="*."+ext
        fList = []
        for curFile in curDir.glob(curPatt):
            fList.append(str(curFile))
        return fList

    def get_File(self,path,file):
        try:
            with open(path+file)as file:
                p = file.read()
                # p = p.split('\n')
        except FileNotFoundError:
            logger.error ('Файл:' + path+file + '- недоступен для загрузки')
            sys.exit()
        return p

    def clear_export_path(path):
        #Чистим логи чтобы выгрузка была только свежая
        logger.info(f'Удаляем старые выгрузки в - {path}')
        now=datetime.datetime.now()
        i=0
        if not path:return logger.error('Не указан путь для удаления выгрузок')
        try:
            with os.scandir(path) as files:
                for file in files:
                    time_file = time.ctime(os.path.getctime(path+file.name))
                    time_file= datetime.datetime.strptime(time_file,'%c')
                    if now-time_file>datetime.timedelta(days=1):
                        print('Удален - '+file.name)
                        i +=1

                        os.remove(path+file.name)

            logger.info('Удаленно ' + str(i) + ' файлов')
        except FileNotFoundError:
            logger.info('Удалять нечего')

    def existPath(path):
        if not path:return logger.error('Не указан путь для  выгрузок')
        if os.path.exists(path):
            logger.info('Каталог -'+path+' найден')

        else:
            logger.info('Каталог -' + path + ' ненайден, создаем...')

            os.mkdir(path)

    def put_file(filen,data):
        type_f = 'ab' if type(data)==bytes else 'a'
        with open(filen, type_f)as file:
            file.write(data)

    def s_request( type,data=None,header=None,auth=None,url=None):
        header = {'Content-type': 'application/json'} if type=='POST' else None
        res = requests.request(type,url=url,data=data,headers=header,auth=auth)
        logger.info(f'{res.status_code}- {res.reason}-\n{res.text}')
        return res.text

    # Чистим строку от спец символов
    def clear_string(self,text, code='cp1251'):
        self.text = str(text)
       #  self.text = re.sub("^\s+|\n|\r|\s+$", '', self.text) if len(self.text)>2 else self.text
        self.text = self.text.encode(code, 'ignore')

        return self.text.decode(code, 'ignore')
    # создание ДБФ
    def create_dbf(self,filename, columns, values, values1=None):
        self.logger.info('Создаем DBF -' + filename)
        table = dbf.Table(filename, columns, codepage='cp866', )
        table.open(mode=dbf.READ_WRITE)
        # values = values_in.extend(values1) if values1 else values_in

        i = 0
        j = []
        while i < len(values):
            for a in values[i]:
                #self.logger.info(a)
                #j.append(self.clear_string(self,a) if isinstance(a, str) else a)
                j.append(a)
            datum = tuple(j)
            #self.logger.info(datum)
            table.append(datum)
            j = []
            i += 1
        table.close()
        self.logger.info('В файл ' + filename + ' добавлено ' + str(i) + ' строк')






