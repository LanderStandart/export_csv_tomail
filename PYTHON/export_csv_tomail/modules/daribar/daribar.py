#  Autor by Lander (c) 2022. Created for Standart-N LLT
import re
import sys
from engine import FTP_work,Archiv,Db,create_dbf,os,existPath,read_ini,list_file_in_path,my_log,clear_export_path
import json
import time,datetime
logger = my_log.get_logger(__name__)
class Daribar(Db):
    def __init__(self,profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        existPath(self.path)
        clear_export_path(self.path)
        #список файлов фыгрузки
        self.expfile = read_ini(self.conf, 'FILE_LIST',self.path_ini).split(',')
        self.suffix =  '_g' if self.profile_id else ''

    def get_Data(self):
        for i in self.expfile:
            print(i)
