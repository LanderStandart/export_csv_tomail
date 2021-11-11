#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob
from engine import Db, existPath, read_ini, my_log, os, time, XML,FTP_work
from datetime import datetime

logger = my_log.get_logger(__name__)


class Iteka(Db):
    def __init__(self, profile_id=None):
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

        chkFile = self.chk_file(f'{Log}_0')
        self.type = 0 if datetime.now().strftime('%w') == '1' or read_ini(self.conf, 'TYPE',
                                                                          self.conf) and chkFile == 0 else 1
        print(f'LOGIN-{Log}--{self.type}')

    def get_Data(self):
        print(self.profile_id)
        if list(self.Logins.keys()).count(self.profile_id)>0:
            self.file_name = self.path + self.Logins[self.profile_id]
            print(self.file_name)

            self.getType()
            print(self.type)
            if not self.date_start:
                self.date_start = datetime.now().strftime('%d.%m.%Y')


            if self.type == 0:
                val = {'profile_id': self.profile_id}
                sql_name = 'full'
            else:
                val = {'date_start': self.date_start, 'profile_id': self.profile_id}
                sql_name = 'new'
            self.data = self.DB.get_from_base(__name__, sql_name, val)

            gl_root = XML.add_root(self, root='offers')

            for s in self.data:
                attrib = {"name": s[0], "price": str(s[1]), "country_of_origin": str(s[2]), "vendor": str(s[3]),
                          "count": str(s[4]), "offer_id": s[5]}

                XML.add_element(self, 'offer', gl_root, attrib=attrib)
            count = read_ini(self.conf, 'COUNT', self.conf)
            upd_count = int(count)+1
            XML().save_file(root=gl_root, filename=f'{self.file_name}_{self.type}_{str(upd_count)}.xml')
            read_ini(self.conf, 'COUNT', self.conf, save=1, values=upd_count)
            FTP_work(self.conf).upload_FTP('./' + f'{self.file_name}_{self.type}_{str(upd_count)}.xml',
                                           extpath=str(read_ini(self.conf, 'FTP_PATH', self.path_ini)), isbynary=True,
                                           )
        else:
            return

    def chk_file(self, Login):
        path = f'{self.path}{Login}_0_*'
        try:
            list_of_files = glob.glob(path)  # * means all if need specific format then *.csv
            latest_file = max(list_of_files, key=os.path.getctime)
            file_time = datetime.fromtimestamp(os.path.getmtime(latest_file)).strftime('%d.%m.%Y')
            res = 1 if file_time == datetime.now().strftime('%d.%m.%Y') else 0
            return res
        except:
            return 0
