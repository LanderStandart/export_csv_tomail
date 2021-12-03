#  Autor by Lander (c) 2020. Created for Standart-N LLT
from ftplib import FTP
import fdb

import importlib
import os.path
import importlib.util
import sys
import functools
import os
import time
import datetime
import dbf
import inspect
sys.path.insert(0, "./engine")
from CSV import CSV_File
from ftp import FTP_work
from XMLcreate import XML
from Archiv import Archiv
from system import read_ini, list_file_in_path, get_File,clear_export_path,existPath,put_file

import my_log

logger = my_log.get_logger(__name__)
def Log(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        args_repr = [f"{a!r}" for a in args]
        kwargs_repr = [f"{k}={v!r}" for k, v in kwargs.items()]
        if args_repr[0]:
            args_repr[0]=func.__name__
        signature =", ".join(args_repr+kwargs_repr)
        logger.info(f"Выполняю: {signature}")
        value = func(*args, **kwargs)

        # return value
        # print("После вызова функции.")
    return wrapper



#Подключение к БД
class Db:
    def __init__(self):
        section = 'BASE_CONF'
        self.host = read_ini(section, 'HOST')
        self.database = read_ini(section, 'PATH')
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()

    def create_sql(self,string,module):
         s=get_File('./modules/'+module+'/scripts/',string)
         sq=s.split('^')
         for se in sq:
             self.get_sql(sql=se,commit=1)
             #print('se')

         logger.info('CREATE ->'+string[5])

         return

    def cheak_db(self,name1,type):
        frm = inspect.stack()[1]
        mod = inspect.getmodule(frm[0])
        if not name1:return logger.error(f'Нет параметров для проверки - {type}')
        names = name1.split(',')
        for name in names:
            if type == 'TABLE':
                sql = f"select r.rdb$FIELD_id from RDB$RELATIONS r where r.rdb$relation_name='{name}'"
            elif type=='PROCEDURE':
                sql =f"select r.rdb$procedure_id from RDB$PROCEDURES r where r.rdb$procedure_name='{name}'"
            elif type=='TRIGGER':
                sql = f"select r.rdb$trigger_name from RDB$TRIGGERS r where r.rdb$trigger_name='{name}'"
            print(name)
            result=self.get_sql(sql)
            if result:
                print(result)
            else:
                print('Создаем'+name)
                self.create_sql(name,mod.__name__)



#Запрос к базе с условием
    def get_sql(self,sql,where=None,commit=None):
        self.sql=sql
        self.commit = commit
        self.where = where
        if self.where:
            self.sql = self.sql + ' '+self.where
        # query = self.curs.execute(self.sql)
        #logger.info('Запрос-'+self.sql)
     # проверка корректности запроса
        try:
            query = self.curs.execute(self.sql)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')
            logger.error(''.join(str(Err)))

            if Errs:
                if self.search(Errs, 'Table unknown\n'):
                    msg='Таблица не найдена\n'
                    sql_err='errTable'
                elif self.search(Errs, 'Procedure unknown\n'):
                    msg='Процедура не найдена\n'
                    sql_err='errProcedure'
                else:
                    logger.error('Ошибка в запросе')
                    logger.error('Вероятная ошибка - ' + Errs[2]+self.sql)
                    sql_err='errSql'
                #logger.error(msg)
                if 'errTable' in sql_err or 'errProcedure' in sql_err:
                    self.create_sql(Errs)
                    return self.get_sql(sql,where,commit)
                else:
                    sys.exit(sql_err)

        # Вывод результатов или проведение
        result = []
        if self.commit:
            self.conn.commit()
            return
        else:
            for i in query:
                result.append(list(i))

            #LogIt(self.sql + 'Содержит ' + str(len(result)))
            self.conn.commit()
            return result


    def search(self, list, n):
        for i in range(len(list)):

            if list[i] == n:
                return i
        return False

    def get_from_base(self, module,sql_file:str,val=None):
        path=f'./modules/{module}/sql/'
        SQL = get_File(path=path, file=sql_file)
        SQL=self.prepare_sql(SQL,values=val)
        #logger.info(SQL)
        data=self.get_sql(SQL,None,None)
        return data

    def prepare_sql(self,sql,values=None):
        try:
            res = sql.format(**values) if values else sql

        except KeyError as Key:
            sys.exit(logger.error(f'Не задан параметр - {Key} \n в запросе \n {sql}'))

        return res










class ExportData(Db):
    def __init__(self,firm):
        self.firm = firm
        self.DB = Db()
        self.module_path=f"./modules/{self.firm.lower()}/"

    @Log
    def create(self,filename,queue=None):
        self.filename = '.\\export\\'+filename
        logger.info(self.filename)
 #Импортируем соответсвующую библиотеку для выбранной выгрузки
        try:
            spec = importlib.util.spec_from_file_location(self.firm.lower(), self.module_path+self.firm.lower()+'.py')
            module = importlib.util.module_from_spec(spec)
            sys.modules[spec.name] = module
            spec.loader.exec_module(module)
            firmname = getattr(module,self.firm)

        except FileNotFoundError:
            logger.error('Алгоритм выгрузки:'+self.firm+'- недоступен для загрузки')
            exit()
        else:
            logger.info('Загружаю алгоритм выгрузки:'+self.firm)


        if int(read_ini('PARAMS', self.firm.lower())):
            try:
                entity=read_ini(self.firm.upper(), 'ENTITY', self.firm.lower())
                if int(read_ini('BASE_CONF', 'ALONE')):
                    firmname().get_Data()
                elif not entity and not int(read_ini('BASE_CONF', 'ALONE')):

                    SQL_profile = f"SELECT id,caption FROM G$PROFILES where id {get_profile()}"
                    profiles = self.DB.get_sql(SQL_profile)
                    prof=[]
                    if not queue:
                        for i in profiles:
                            firmname(profile_id=str(i[0])).get_Data()
                    else:
                        for i in profiles:
                            prof.append(str(i[0]))
                        prof=','.join(prof)
                        firmname(profile_id=str(prof)).get_Data()
                else:
                    entity = entity.split(',')


                    for i in entity:
                        val={'baseagent':str(i)}
                        profiles = self.DB.get_from_base( sql_file='baseagent', module=self.firm.lower(), val=val)
                        prof = []
                        if not queue:
                            for i in profiles:
                                firmname(profile_id=str(i[0])).get_Data()
                        else:
                            for i in profiles:
                                prof.append(str(i[0]))
                            prof = ','.join(prof)
                            firmname(profile_id=str(prof)).get_Data()




            except AttributeError:
                logger.error(f'Нет алгоритма для выгрузки get_DATA(){firmname}')



def tranlit(input_str):
    slovar = {'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e',
              'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n',
              'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h',
              'ц': 'c', 'ч': 'cz', 'ш': 'sh', 'щ': 'scz', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e',
              'ю': 'u', 'я': 'ja', 'А': 'A', 'Б': 'B', 'В': 'V', 'Г': 'G', 'Д': 'D', 'Е': 'E', 'Ё': 'E',
              'Ж': 'ZH', 'З': 'Z', 'И': 'I', 'Й': 'I', 'К': 'K', 'Л': 'L', 'М': 'M', 'Н': 'N',
              'О': 'O', 'П': 'P', 'Р': 'R', 'С': 'S', 'Т': 'T', 'У': 'U', 'Ф': 'F', 'Х': 'H',
              'Ц': 'C', 'Ч': 'CZ', 'Ш': 'SH', 'Щ': 'SCH', 'Ъ': '', 'Ы': 'y', 'Ь': '', 'Э': 'E',
              'Ю': 'U', 'Я': 'YA', ',': '', '?': '', ' ': '_', '~': '', '!': '', '@': '', '#': '',
              '$': '', '%': '', '^': '', '&': '', '*': '', '(': '', ')': '', '-': '', '=': '', '+': '',
              ':': '', ';': '', '<': '', '>': '', '\'': '', '"': '', '\\': '', '/': '', '№': '',
              '[': '', ']': '', '{': '', '}': '', 'ґ': '', 'ї': '', 'є': '', 'Ґ': 'g', 'Ї': 'i',
              'Є': 'e', '—': ''}

    # Циклически заменяем все буквы в строке
    for key in slovar:
        input_str = input_str.replace(key, slovar[key])
    return input_str





def get_profile():
    section = 'BASE_CONF'
    profiles_on = read_ini(section, 'PROFILES_ON')
    profiles_off = read_ini(section, 'PROFILES_OFF')
    if profiles_on:
        result = f"in ({profiles_on})"
    else:
        result = f"not in ({profiles_off})"
    return result





#создание ДБФ
def create_dbf(filename,columns,values,values1=None):
    logger.info('Создаем DBF -' +filename)
    table = dbf.Table(filename,columns,codepage='cp866',)
    table.open(mode=dbf.READ_WRITE)
    #values = values_in.extend(values1) if values1 else values_in

    i = 0
    j=[]
    while i < len(values):
        for a in values[i]:
            j.append(clear_string(a)) #if isinstance(a,str) else a  )
        datum = tuple(j)
        table.append(datum)
        j=[]
        i += 1
    table.close()
    logger.info('В файл '+filename+' добавлено '+str(i)+' строк')

#Чистим строку от спец символов
def clear_string(text):
        text=text.encode('cp866','ignore')
        return text.decode('cp866','ignore')










