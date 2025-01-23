#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob,sys
sys.path.insert(0, "./engine")
from system import System
from firebirdsql import Db
from ftp import FTP_work
from Archiv import Archiv
from XMLcreate import XML
from datetime import datetime,timedelta




class Iteka(Db,System):
    def __init__(self):
        self.DB = Db()
        self.logger = self.Logs(__name__)
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = self.read_ini(self.conf, 'PATH_EXPORT', self.conf)
        self.existPath(self.path)

        self.date_start = self.read_ini(self.conf, 'DATE_START', self.conf)
        self.Logins = json.loads(self.read_ini(self.conf, 'LOGIN', self.conf).replace("'", '"'))
        self.Pass = json.loads(self.read_ini(self.conf, 'PASSWORD', self.conf).replace("'", '"'))
        self.file_name = ''



    def getType(self):
        # type = 0 Выгрузка полного прайса
        # type = 1 Выгрузка изменений относительно пункта 1
        Log = self.Logins[self.profile_id] if self.profile_id else self.Logins[1]
        # Log = self.Logins[self.profile_id]

        chkFile = self.chk_file(f'{Log}_0')
        self.type = 0 if (datetime.now().strftime('%w') == '1' or self.read_ini(self.conf, 'TYPE', self.conf)) and chkFile == 0 else 1
        print(f'LOGIN-{Log}--{self.type}')

    def getUserFTP(self):
        val = {'profile_id': self.profile_id}
        sql_name = 'bin'
        self.data = self.DB.get_from_base(__name__, sql_name, val)
        self.LoginsFtp = json.loads(self.read_ini(self.conf, 'LOGINFTP', self.conf).replace("'", '"'))
        self.PassFtp = json.loads(self.read_ini(self.conf, 'PASSWORDFTP', self.conf).replace("'", '"'))
        self.l_ftp = self.LoginsFtp[self.data[0][0]]
        self.p_ftp = self.PassFtp[self.data[0][0]]
        self.logger.info(f'{self.l_ftp} --- {self.p_ftp}')



    def get_Data(self, profile_id=None):
        self.profile_id = profile_id
        suffix = '_g' if self.profile_id else ''
        self.profile_id = self.profile_id if self.profile_id else '1'

        print(self.profile_id)
        if list(self.Logins.keys()).count(self.profile_id)>0:
            self.file_name = self.path + self.Logins[self.profile_id]
        print(self.file_name)
        self.date_start = datetime.now()-timedelta(hours=1)
        self.date_start = self.date_start.strftime('%d.%m.%Y  %H:%M')
        self.getType()
        print(self.type)
        if not self.date_start:
            self.date_start = datetime.now().strftime('%d.%m.%Y')


        if self.type == 0:
            val = {'profile_id': self.profile_id}
            sql_name = 'full'+suffix
        else:
            val = {'date_start': self.date_start, 'profile_id': self.profile_id}
            sql_name = 'new'+suffix
        self.data = self.DB.get_from_base(__name__, sql_name, val)

        attrib = {"date": datetime.now().strftime('%Y-%m-%d %H:%M'), "price_list_type": str(self.type)}
        gl_root = XML.add_root(self, root='yml_catalog', attrib=attrib)
        root = XML.add_element(self, 'shop', gl_root)

        val = {'profile_id': self.profile_id}
        pharmname = self.DB.get_from_base(__name__, 'pharmname', val)
        pharm = pharmname[0][0] if self.profile_id else self.read_ini(self.conf, 'COMPANY', self.conf)

        XML.add_element(self, 'company', root,data=pharm)

        lvl1 = XML.add_element(self, 'currencies', root)

        attrib = {"id":"KZ","rate":"1"}
        lvl2 = XML.add_element(self, 'currency ', lvl1,attrib=attrib)

        root1 = XML.add_element(self, 'offers', gl_root)
        for s in self.data:
            attrib= {"id":s[5],"type":"medicine"}
            offer = XML.add_element(self, 'offer', root1, attrib=attrib)
            XML.add_element(self, 'name', offer, data=s[0])
            XML.add_element(self, 'price', offer, data=str(s[1]))
            XML.add_element(self, 'country_of_origin', offer, data=str(s[2]))
            XML.add_element(self, 'vendor', offer, data=str(s[3]))
            XML.add_element(self, 'count', offer, data=str(s[4]))
            XML.add_element(self, 'offer_id', offer, data=str(s[5]))
        count = self.read_ini(self.conf, 'COUNT', self.conf)
        upd_count = int(count)+1
        XML().save_file(root=gl_root, filename=f'{self.file_name}_{self.type}_{str(upd_count)}.xml')
        self.read_ini(self.conf, 'COUNT', self.conf, save=1, values=upd_count)


        FTP_work(self.conf,self.Logins[self.profile_id],self.Pass[self.profile_id]).upload_FTP('./' + f'{self.file_name}_{self.type}_{str(upd_count)}.xml',isbynary=True)


    def chk_file(self, Login):
        self.logger.info(f'{self.path}{Login}_*')
        path = f'{self.path}{Login}_*'
        try:
            list_of_files = glob.glob(path)  # * means all if need specific format then *.csv
            latest_file = max(list_of_files, key=os.path.getctime)
            file_time = datetime.fromtimestamp(os.path.getmtime(latest_file)).strftime('%d.%m.%Y')
            res = 1 if file_time == datetime.now().strftime('%d.%m.%Y') else 0
            return res
        except:
            return 0
