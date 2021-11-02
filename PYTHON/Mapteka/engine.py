import json
import os
from ftplib import FTP
import fdb
import configparser
import dbf

#Подключение к БД
class Db:
    def __init__(self):
        self.config = configparser.ConfigParser()
        self.config.read('./config.ini')
        section = 'BASE_CONF'
        self.host = self.config.get(section, 'HOST')
        self.database = self.config.get(section, 'PATH')
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()

#Запрос к базе с условием
    def get_sql(self,sql,where=None):
        self.sql=sql
        self.where = where
        if self.where:
            self.sql = self.sql + self.where
        # print(sql)
        query = self.curs.execute(sql)
        result = []
        for i in query:
            result.append(list(i))
        return result
    def newFile(self):
        os.unlink('data_file.json')

#Выгрузка на ФТП
class FTP_work(Db):
    def __init__(self,sections):
        self.DB = Db()
        self.sections = sections
        self.host = self.DB.config.get(self.sections, 'FTP_HOST')
        self.port = int(self.DB.config.get(self.sections, 'FTP_PORT'))
        self.ftp_user = self.DB.config.get(self.sections, 'FTP_USER')
        self.ftp_password = self.DB.config.get(self.sections, 'FTP_PASSWORD')

    def upload_FTP(self, file_name, isbynary=None):
        self.file_name = file_name
        self.isbynary = isbynary
        print(self.host, self.ftp_user, self.ftp_password, self.file_name, self.port,self.isbynary)
        f_obj = open(self.file_name, 'rb')

        ftp = FTP()
        # ftp.encoding = 'utf-8'
        ftp.connect(self.host, self.port)

        ftp.login(self.ftp_user, self.ftp_password)
        print('Upload')
        ftp.set_pasv(True)
        if self.isbynary:
            with f_obj as fobj:
                ftp.storbinary('STOR '+self.file_name,fobj)
        else:
            ftp.storlines("STOR " + self.file_name, f_obj)
        ftp.quit()

class Assort_item(Db):
    def __init__(self,org_chenum,qtty,item_id,item_name,price,remark,drug_id=0,
                 delivery=0,reserv=0,preorder=0,payonline=0,limited=0,action=0,bycard=0):
        self.DB = Db()
        self.org_id = int(self.DB.config.get('BASE_CONF', 'ORG_ID')) # код аптеки aptekamos
        self.org_chenum = org_chenum # внутренний код аптеки если не заполнено будет org_id
        self.drug_id = drug_id #код ЕГК
        self.price = price
        self.delivery = delivery #признак доставки
        self.reserv = reserv
        self.preorder = preorder
        self.payonline = payonline
        self.limited = limited
        self.action = action
        self.bycard = bycard
        self.qtty = qtty
        self.item_id = item_id #Внутренний код упаковки скорее карточки товара
        self.item_name = item_name #Наименование товара
        #self.item_name = u"{}".format(self.item_name)
        self.remark = remark
    def writeJson(self):
        self.json_str = {"org_id":self.org_id,"org_chenum":self.org_chenum,"drug_id":self.drug_id,
                         "price":self.price,"delivery":self.delivery,"reserv":self.reserv,
                         "preorder":self.preorder,"payonline":self.payonline,"limited":self.limited,
                         "action":self.action,"bycard":self.bycard,"qtty":self.qtty,"item_id":self.item_id,
                         "item_name":self.item_name,"remark":self.remark}

        with open("data_file.json","a",encoding="utf-8") as write_file:
            json.dump(self.json_str,write_file,ensure_ascii=False,indent=4)







