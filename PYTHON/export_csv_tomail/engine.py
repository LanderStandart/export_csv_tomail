#  Autor by Lander (c) 2020. Created for Standart-N LLT
import importlib
import importlib.util
import re
import dbf
import sys
sys.path.insert(0, "./engine")
# from CSV import CSV_File
# from ftp import FTP_work
# from XMLcreate import XML
# from Archiv import Archiv
from firebirdsql import Db
from system import System




class ExportData(Db,System):
    def __init__(self):
        self.DB = Db()
        self.logger = self.Logs(__name__)

    def create(self,filename,firm,queue=None):
        self.firm = firm
        self.module_path = f"./modules/{self.firm.lower()}/"
        self.filename = '.\\export\\'+filename
        self.logger.info(self.module_path)
 #Импортируем соответсвующую библиотеку для выбранной выгрузки
        try:
            spec = importlib.util.spec_from_file_location(self.firm.lower(), self.module_path+self.firm.lower()+'.py')
            module = importlib.util.module_from_spec(spec)
            self.logger.info(module)
            sys.modules[spec.name] = module
            spec.loader.exec_module(module)
            self.firmname = getattr(module,self.firm)
            self.Module = self.firmname()

        except FileNotFoundError as E:
            self.logger.error(E)
            self.logger.error('Алгоритм выгрузки:'+self.firm+'- недоступен для загрузки')
            exit()
        else:
            self.logger.info('Загружаю алгоритм выгрузки:'+self.firm)


        if int(self.read_ini('PARAMS', self.firm.lower())):
            try:
                entity=self.read_ini(self.firm.upper(), 'ENTITY', self.firm.lower())
                if int(self.read_ini('BASE_CONF', 'ALONE')):
                    self.Module.get_Data()
                elif not entity and not int(self.read_ini('BASE_CONF', 'ALONE')):

                    SQL_profile = f"SELECT id,caption FROM G$PROFILES where id {self.get_profile(self.firm.upper())} and status=0 " \
                                  f"and dbsecurekey is not null and char_length(description)>2 and dbsecurekey not containing('!') "

                    profiles = self.DB.get_sql(SQL_profile)

                    prof=[]
                    if not queue:
                        self.logger.info('NOT QUEUE')
                        for i in profiles:
                            self.Module.get_Data(profile_id=str(i[0]))
                    else:
                        self.logger.info('QUEUE')
                        for i in profiles:
                            print(i)
                            prof.append(str(i[0]))
                        prof=','.join(prof)
                        self.Module.get_Data(profile_id=str(prof))
                else:
                    entity = entity.split(',')


                    for i in entity:
                        val={'baseagent':str(i)}

                        profiles = self.DB.get_from_base( sql_file='baseagent', module=self.firm.lower(), val=val)

                        prof = []
                        if not queue:
                            for i in profiles:
                                self.Module.get_Data(profile_id=str(i[0]))
                        else:
                            for i in profiles:
                                prof.append(str(i[0]))
                            prof = ','.join(prof)

                            self.Module.get_Data(profile_id=str(prof))




            except AttributeError as E:
                self.logger.error(E)
                self.logger.error(f'Нет алгоритма для выгрузки get_DATA(){self.firmname}')







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





    def get_profile(self,firm):
        section = 'BASE_CONF'
        profiles_on = self.read_ini(firm, 'PROFILES_ON', firm) if self.read_ini(firm, 'PROFILES_ON', firm) else self.read_ini(section, 'PROFILES_ON')
        profiles_off = self.read_ini(firm, 'PROFILES_OFF', firm) if self.read_ini(firm, 'PROFILES_OFF', firm) else self.read_ini(section, 'PROFILES_OFF')
        if profiles_on:
            result = f"in ({profiles_on})"
        else:
            result = f"not in ({profiles_off})"
        return result





    #создание ДБФ
    def create_dbf(self,filename,columns,values,values1=None):
        self.logger.info('Создаем DBF -' +filename)
        table = dbf.Table(filename,columns,codepage='cp1251',)
        table.open(mode=dbf.READ_WRITE)
        #values = values_in.extend(values1) if values1 else values_in

        i = 0
        j=[]
        while i < len(values):
            for a in values[i]:
                print(f'{type(a)}  - {a}')
                j.append(clear_string(a) if isinstance(a,str) else a  )
            datum = tuple(j)

            table.append(datum)
            j=[]
            i += 1
        table.close()
        self.logger.info('В файл '+filename+' добавлено '+str(i)+' строк')

    #Чистим строку от спец символов
    def clear_string(self,text,code='cp866'):
            if isinstance(text,str):
                text = re.sub("^\s+|\n|\r|\s+$", '', text)
               # re.sub(regex, subst, test_str, 0, re.MULTILINE)
                regex = r"[a-zA-Z]+|[а-яА-Я]+|\d+|№|\s"
                text1 = re.findall(regex,text)
                text =''.join(text1)


                text=text.encode(code,'ignore')
            else:
                text = ''

            return text.decode(code,'ignore')













