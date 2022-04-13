#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob
from engine import Db, existPath, read_ini, my_log, os, time, XML,Archiv,FTP_work
from datetime import datetime


logger = my_log.get_logger(__name__)


class E003(Db):
    def __init__(self, profile_id=None):
        logger.info('Init...')
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.date_start = read_ini(self.conf, 'DATE_START', self.conf)
        self.Logins = json.loads(read_ini(self.conf, 'LOGIN', self.conf).replace("'", '"'))



    def getType(self):
        # type = 0 Выгрузка полного прайса
        # type = 1 Выгрузка изменений относительно пункта 1
        Log = self.Logins[self.profile_id]

        self.type = 0 #if (datetime.now().strftime('%w') == '1' or read_ini(self.conf, 'TYPE', self.conf)) and chkFile == 0 else 1
        print(f'LOGIN-{Log}--{self.type}')

    def get_Data(self):
        print(self.profile_id)

        if self.profile_id:
            val = {'profile_id': self.profile_id}
            sql_name = 'full_g'
            val = {'profile_id': self.profile_id}
            pharmname = self.DB.get_from_base(__name__, 'pharmname', val)
            pharm = pharmname[0][0]
            self.file_name = self.path + f'pharm_{self.profile_id}'
        else:
            sql_name = 'full'
            val=None
            pharm =read_ini(self.conf, 'PHARM', self.conf)
            self.file_name = self.path + f'pharm_1'


        self.data = self.DB.get_from_base(__name__, sql_name, val)

        attrib = {"date": datetime.now().strftime('%Y-%m-%d %H:%M'), "price_list_type": '0'}

        gl_root = XML.add_root(self, root='yml_catalog', attrib=attrib)
        root = XML.add_element(self, 'shop', gl_root)

        url =read_ini(self.conf, 'URL', self.conf)
        XML.add_element(self, 'name', gl_root,data=pharm)
        root1 = XML.add_element(self, 'offers', gl_root)
        for s in self.data:
            attrib= {"id":s[8]}
            offer = XML.add_element(self, 'offer', root1, attrib=attrib)
            XML.add_element(self, 'ItemName', offer, data=str(s[1]))
            XML.add_element(self, 'vendor', offer, data=str(s[2]))
            XML.add_element(self, 'country_of_origin', offer, data=str(s[3]))
            XML.add_element(self, 'count', offer, data=str(s[4]))
            XML.add_element(self, 'price', offer, data=str(s[5]))
            XML.add_element(self, 'expireDate', offer, data=str(s[6]))
            XML.add_element(self, 'EAN', offer, data=str(s[7]))
            XML.add_element(self, 'is_delivery', offer, data='0')
            XML.add_element(self, 'url', offer,data=f'{url}{s[8]}')


        XML().save_file(root=gl_root, filename=f'{self.file_name}.xml')
        Archiv(self.file_name, 'xml').zip_File()
        FTP_work(self.conf).upload_FTP('./' + f'{self.file_name}.zip',isbynary=True)



