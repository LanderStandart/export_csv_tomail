#  Autor by Lander (c) 2021. Created for Standart-N LLT
import time
import datetime
import os, sys,re
import configparser
import pathlib
import logging
import smtplib,ssl
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart

class Log():

    def get_file_handler(self):
        date = datetime.datetime.now().strftime('%Y%m%d%H%M')
        filename = f"{self.directory}{date}loggi.log"
        file_handler = logging.FileHandler(filename)
        file_handler.setLevel(logging.INFO)
        file_handler.setFormatter(logging.Formatter(self._log_format, datefmt=self.datefmt))
        return file_handler

    def get_stream_handler(self):
        stream_handler = logging.StreamHandler()
        stream_handler.setLevel(logging.INFO)
        stream_handler.setFormatter(logging.Formatter(self._log_format, datefmt=self.datefmt))
        return stream_handler

    def get_logger(self,name,module=''):
        self._log_format = f"%(asctime)s - [%(levelname)s] (%(filename)s).%(funcName)s(%(lineno)d) - %(message)s"
        self.datefmt = '%m-%d %H:%M'

        self.directory = f'./log/'if module =='' else f'./log/{name}/'
        if os.path.exists(self.directory):
            path_info = f'Каталог -{self.directory} найден'
        else:
            path_info = f'Каталог -{self.directory}  ненайден, создаем...'
            os.mkdir(self.directory)
        logger = logging.getLogger(name)
        logger.setLevel(logging.INFO)
        logger.addHandler(self.get_file_handler())
        logger.addHandler(self.get_stream_handler())
        return logger


class System(Log):
    def __init__(self):
        self.logger = self.Logs(__name__)

    def Logs(self,name,module=''):

        return self.get_logger(name,module)


    def read_ini(self,sections, params, modules=None, save=None, values=None):
        config = configparser.ConfigParser()
        self.modules = modules.lower() if modules else modules
        root_path = f'{os.getcwd()}'
        path = root_path if not self.modules else os.path.join(root_path,'modules',self.modules)
        path_ini = os.path.join(path,'config.ini')
        try:
            config.read(path_ini)
            if not save:
                return config.get(sections, params)
            else:
                # config[sections][params]=str(values)
                config.set(sections, params, str(values))
                with open(path_ini, 'w') as configfile:
                    config.write(configfile)

        except:
            self.logger.error(f'Нет параметра - {params} в настройках - {sections} модуля {self.modules} - {path}\config.ini')

    def list_file_in_path(self,path, ext):
        curDir = pathlib.Path(path)
        curPatt = "*." + ext
        fList = []
        for curFile in curDir.glob(curPatt):
            fList.append(str(curFile))
        return fList

    # def get_File(self,path, file):
    #     try:
    #         with open(path + file,buffering=1024000) as file:
    #             self.p = file.read()
    #             # p = p.split('\n')
    #     except FileNotFoundError:
    #         self.logger.error('Файл:' + path + file + '- недоступен для загрузки')
    #         sys.exit()
#
 #       return self.p
    def get_File(self,path,file):
        try:
            filename = f'{path}{file}'
            file = open(filename,mode='r')
            self.p = file.read()
            file.close()
        except FileNotFoundError:
         self.logger.error('Файл:' + path + file + '- недоступен для загрузки')
         sys.exit()
        return self.p

    def clear_export_path(self,path,sec=86000):
        # Чистим логи чтобы выгрузка была только свежая
        self.logger.info(f'Удаляем старые выгрузки в - {path}')
        now = datetime.datetime.now()
        i = 0
        if not path: return self.logger.error('Не указан путь для удаления выгрузок')
        try:
            with os.scandir(path) as files:
                for file in files:
                    time_file = time.ctime(os.path.getctime(path + file.name))
                    time_file = datetime.datetime.strptime(time_file, '%c')
                    if now - time_file > datetime.timedelta(seconds=sec):
                        print('Удален - ' + file.name)
                        i += 1

                        os.remove(path + file.name)

            self.logger.info('Удаленно ' + str(i) + ' файлов')
        except FileNotFoundError:
            self.logger.info('Удалять нечего')

    def existPath(self,path):
        if not path: return self.logger.error('Не указан путь для  выгрузок')
        if os.path.exists(path):
            path_info=f'Каталог -{path} найден'
        else:
            path_info=f'Каталог -{path}  ненайден, создаем...'
            os.mkdir(path)
        self.logger.info(path_info)

    def put_file(self,filen, data):
        type_f = 'ab' if type(data) == bytes else 'a'
        with open(filen, type_f) as file:
            file.write(data)



    def planner(self,module):
        now = datetime.datetime.today()
        last_start = self.read_ini(module.upper(), 'LAST_START',module.lower())
        period = self.read_ini(module.upper(), 'PERIOD',module.lower())
        period_hour =self.read_ini(module.upper(), 'PERIOD_HOUR',module.lower())
        if not period:
            self.logger.info('не знаю периуд запускаемся')
            res=1
            return res
        last_start_diff = now-datetime.datetime.strptime(last_start,'%d.%m.%Y %H:%M:%S')
        self.logger.info(f'Последний раз запускали {last_start} периуд запуска {period} прошло {last_start_diff}')
        if (period == 'MONTH' and last_start_diff.days < 31) or (period == 'DAY' and last_start_diff.days < 1) \
                or (period == 'HOUR' and last_start_diff.total_seconds()/(60*60) < int(period_hour)):
            self.logger.info('Следующий запуск еще не подошел')
            res = 0

            return res
        else:
            res = 1
            format_time = '%d.%m.%Y %H:%M:%S' if period not in 'MONTH' else '%d.%m.%Y 00:00:00'
            self.read_ini(module.upper(), 'LAST_START',module.lower(), save=1, values=now.strftime(format_time))

            return res

    def clear_string(self, text, code='cp866'):
        if isinstance(text, str):
            text = re.sub("^\s+|\n|\r|\s+$", '', text)

            regex = r"[a-zA-Z]+|[а-яА-Я]+|\d+|№|\s"
            text1 = re.findall(regex, text)
            text = ''.join(text1)

            text = text.encode(code, 'ignore')
        else:
            text = ''

        return text.decode(code, 'ignore')

    def MailTo(self,filename,from_addr,to_addr,subj,smtp,login,password):
        #  Archiv(filename, 'xls').zip_File()
        basename = os.path.basename(filename)
        from_addr = from_addr
        file_to_attach = filename
        to_emails = to_addr.split(',')
        msg = MIMEMultipart()
        msg["From"] = from_addr
        msg["Subject"] = subj
        msg["To"] = ", ".join(to_emails)
        # msg.attach(MIMEText('text'))

        try:
            with open(file_to_attach, "rb") as fil:
                part = MIMEApplication(
                    fil.read(),
                    Name=basename
                )
            # After the file is closed
            part['Content-Disposition'] = 'attachment; filename="%s"' % basename
            msg.attach(part)
        except IOError:
            print(f"Ошибка при открытии файла вложения {file_to_attach}")


        with smtplib.SMTP_SSL(smtp)as server:

        #   smtp.starttls()
            server.ehlo()
            server.login(login, password)
            server.sendmail(from_addr, to_emails, msg.as_string())
    # except smtplib.SMTPException as err:
        #     print('Что - то пошло не так...')
        #     raise err


