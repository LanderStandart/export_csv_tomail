#  Autor by Lander (c) 2021. Created for Standart-N LLT
#Выгрузка на ФТП
from ftplib import FTP
from system import read_ini,my_log
import os.path
from tqdm import tqdm
logger = my_log.get_logger(__name__)
class FTP_work:
    def __init__(self,sections):
        self.sections = sections
        self.host = read_ini(self.sections, 'FTP_HOST',sections)
        self.port = int(read_ini(self.sections, 'FTP_PORT',sections))
        self.ftp_user = read_ini(self.sections, 'FTP_USER',sections)
        self.ftp_password = read_ini(self.sections, 'FTP_PASSWORD',sections)
        self.status = read_ini(self.sections, 'STATUS',sections)

    def upload_FTP(self, file_name, isbynary=None, extpath=None, rename=None):
        self.file_name = file_name
        if self.status == '1':
            self.isbynary = isbynary
            #            print(self.host, self.ftp_user, self.ftp_password, self.file_name, self.port+self.isbynary)
            f_obj = open(self.file_name, 'rb')
            filesize = os.path.getsize(self.file_name)
            ext_filename = os.path.basename(r'' + self.file_name)
            ftp = FTP()
            # ftp.encoding = 'utf-8'
            ftp.connect(self.host, self.port)

            ftp.login(self.ftp_user, self.ftp_password)
            if extpath:
                ftp.cwd(extpath)
            logger.info('Upload:' + ext_filename)
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
        else:
            logger.info(str(self.host) +':'+ str(self.port))
            ext_filename = os.path.basename(r'' + self.file_name)
            logger.info(ext_filename)
            logger.warning('FTP:Тестовый режим выгрузка отключена')

