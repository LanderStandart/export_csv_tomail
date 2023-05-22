pass#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Выгрузка на ФТП
import ftplib
from ftplib import FTP
from system import System
import os.path,pathlib
from tqdm import tqdm

class FTP_work(System):
    def __init__(self,sections,user=None,passw=None):
        self.sections = sections
        self.host = self.read_ini(self.sections, 'FTP_HOST',sections)
        self.port = int(self.read_ini(self.sections, 'FTP_PORT',sections))
        self.ftp_user = user if user else self.read_ini(self.sections, 'FTP_USER',sections)
        self.ftp_password = passw if passw else self.read_ini(self.sections, 'FTP_PASSWORD',sections)
        self.status = self.read_ini(self.sections, 'STATUS',sections)
        self.logger = self.Logs(__name__)

    def upload_FTP(self, file_name, isbynary=None, extpath=None, rename=None):
        self.file_name =  file_name
        self.logger.info(pathlib.Path(self.file_name).name)
        if self.status == '1':

            self.isbynary = isbynary
            try:

                #            print(self.host, self.ftp_user, self.ftp_password, self.file_name, self.port+self.isbynary)
                self.logger.info(f'Connect to FTP - {self.host}:{self.port} for Upload {self.file_name}')
                f_obj = open(self.file_name, 'rb')

                filesize = os.path.getsize(self.file_name)

                ext_filename = pathlib.Path(self.file_name).name

                try:
                    ftp = FTP()
                    ftp.encoding = 'utf-8'
                    self.logger.info(f'Connect to FTP- {self.host}:{self.port}')
                    ftp.connect(self.host, self.port,timeout=10)
                    ftp.login(self.ftp_user, self.ftp_password)
                except :
                    self.logger.error(f'Нет Связи с ФТП файл {self.file_name} не выгружен  ')
                    return

                if extpath:
                    ftp.cwd(extpath)
                self.logger.info('Upload:' + ext_filename)
                ftp.set_pasv(True)

                if self.isbynary:
                    with tqdm(unit='blocks', unit_scale=True, leave=False, miniters=1, desc='Uploading......',
                              total=filesize) as tqdm_instance:
                        ftp.storbinary('STOR ' + ext_filename, f_obj, 2048,
                                       callback=lambda sent: tqdm_instance.update(len(sent)))

                    # with f_obj as fobj:
                    #     ftp.storbinary('STOR ' + ext_filename, fobj)
                else:
                    with tqdm(unit='blocks', unit_scale=True, leave=False, miniters=1, desc='Uploading......',
                              total=filesize) as tqdm_instance:
                        ftp.storlines('STOR ' + ext_filename, f_obj,
                                       callback=lambda sent: tqdm_instance.update(len(sent)))
                    # ftp.storlines("STOR " + ext_filename, f_obj)
                #            toname = os.path.splitext(ext_filename)[0]+'.zip'

                if rename:
                    #  print(ext_filename,toname,'RENAME')
                    ftp.rename(fromname=ext_filename, toname=os.path.splitext(ext_filename)[0] + '.zip')
                    # FTP.rename(ext_filename, os.path.splitext(ext_filename)[0]+'.zip')
                ftp.quit()
            except Exception as Error:
                Err = Error.args
                Errs = Err[0].split('- ')
                self.logger.error(''.join(str(Err)))
                ftp.quit()
                return 0
            else:
                return 1
        else:
            self.logger.info(str(self.host) +':'+ str(self.port))
            ext_filename = os.path.basename(r'' + self.file_name)
            self.logger.info(ext_filename)
            self.logger.warning('FTP:Тестовый режим выгрузка отключена')
            return 1

    def sinhro(self,REMOTE_FOLDER,LOCAL_FOLDER):
        if self.status == '1':
            try:

                server = FTP(self.host)
                server.login(self.ftp_user,self.ftp_password)
                server.set_pasv(True)

                server.cwd(REMOTE_FOLDER)
                os.chdir(LOCAL_FOLDER)

                remote_files = set(server.nlst())
                l = set(os.listdir(os.curdir))

                local_files = set(filter(lambda x:'NAME' in x,l))
                trasfer = local_files - remote_files
                print(len(trasfer))
                # exit()
                for local_file in trasfer:

                   self.logger.info(local_file)

                   server.storbinary('STOR ' + local_file, open(local_file, 'rb'))
                server.close()
            except ftplib.all_errors as Error:
                Err = Error.args
                Errs = Err[0].split('- ')
                self.logger.error(''.join(str(Err)))
                ftp.quit()
            else:
                self.logger.info(f'{local_file}-Загружен OK!')

        else:
            self.logger.info(str(self.host) +':'+ str(self.port))
            self.logger.warning('FTP:Тестовый режим выгрузка отключена')



