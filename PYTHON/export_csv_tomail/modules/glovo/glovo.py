#  Autor by Lander (c) 2021. Created for Standart-N LLT
import json
import glob
from engine import Db, existPath, read_ini, my_log, os, time, XML,FTP_work,clear_string
from datetime import datetime

logger = my_log.get_logger(__name__)


class Glovo(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.path_ini = __name__
        self.conf = self.path_ini.upper()
        self.path = read_ini(self.conf, 'PATH_EXPORT', self.conf)
        existPath(self.path)
        self.profile_id = profile_id
        self.date_start = read_ini(self.conf, 'DATE_START', self.conf)






    def get_Data(self):
        suffix = '_g' if self.profile_id else ''
        #self.profile_id = self.profile_id if self.profile_id else '1'

        print(self.profile_id)

        self.file_name = self.path + read_ini(self.conf, 'COMPANYID', self.conf)
        print(self.file_name)


        if not self.date_start:
            self.date_start = datetime.now().strftime('%d.%m.%Y')



        val = {'profile_id': self.profile_id}
        sql_name = 'full'+suffix

        self.data = self.DB.get_from_base(__name__, sql_name, val)

        attrib = {"date": datetime.now().strftime('%Y-%m-%d %H:%M'), "xmlns": "kaspiShopping","xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance",
                  "xsi:schemaLocation":"kaspiShopping http://kaspi.kz/kaspishopping.xsd"}
        gl_root = XML.add_root(self, root='kaspi_catalog', attrib=attrib)
        root =  gl_root



        XML.add_element(self, 'company', root,data=read_ini(self.conf, 'COMPANY', self.conf))
        XML.add_element(self, 'merchantid', root, data=read_ini(self.conf, 'merchantid', self.conf))



        root1 = XML.add_element(self, 'offers', gl_root)
        for s in self.data:
            attrib= {"sku":s[5]}
            offer = XML.add_element(self, 'offer', root1, attrib=attrib)
            XML.add_element(self, 'model', offer, data=clear_string(str(s[0])))
            avail=XML.add_element(self, 'availabilities', offer)


            if self.profile_id:
#                logger.info(s[6])
                for shop in str(s[6]).split(','):
                    ShopID = json.loads(read_ini(self.conf, 'SHOPID', self.conf).replace("'", '"'))
                    attrib = {"available": "yes", "storeId": f'{ShopID[shop]}'}
                    XML.add_element(self, 'availability', avail, attrib=attrib)

                citiprice = XML.add_element(self, 'cityprices', offer)
                attrib = {"cityId": read_ini(self.conf, 'cityID', self.conf)}
                XML.add_element(self, 'cityprice', citiprice, data=str(s[1]),attrib=attrib)
            else:
                attrib = {"available": "yes", "storeId": read_ini(self.conf, 'shopID', self.conf)}
                XML.add_element(self, 'availability', avail, attrib=attrib)
                XML.add_element(self, 'price', offer,data=str(s[1]))

            # XML.add_element(self, 'country_of_origin', offer, data=str(s[2]))
            # XML.add_element(self, 'vendor', offer, data=str(s[3]))
            # XML.add_element(self, 'count', offer, data=str(s[4]))
            # XML.add_element(self, 'offer_id', offer, data=str(s[5]))

        XML().save_file(root=gl_root, filename=f'{self.file_name}.xml')
        FTP_work(self.conf).upload_FTP('./' + f'{self.file_name}.xml', extpath=str(read_ini(self.conf, 'FTP_PATH', self.path_ini)),isbynary=True)



    def chk_file(self, Login):
        logger.info(f'{self.path}{Login}_*')
        path = f'{self.path}{Login}_*'
        try:
            list_of_files = glob.glob(path)  # * means all if need specific format then *.csv
            latest_file = max(list_of_files, key=os.path.getctime)
            file_time = datetime.fromtimestamp(os.path.getmtime(latest_file)).strftime('%d.%m.%Y')
            res = 1 if file_time == datetime.now().strftime('%d.%m.%Y') else 0
            return res
        except:
            return 0
