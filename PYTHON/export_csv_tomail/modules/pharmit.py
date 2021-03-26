#  Autor by Lander (c) 2020. Created for Standart-N LLT
from engine import Db,CSV_File,Archiv,FTP_work
class Pharmit(Db):
    def __init__(self,profile_id=None):
        self.DB = Db()
        self.SQL = "select first 1 g.caption,w.sname,w.sizg,w.quant,w.price from warebase_g w inner join g$profiles g on g.id=w.g$profile_id and g.email is not null  where w.quant>0"
        self.filen = self.DB.config.get('FTP_CONF2', 'ID_CLIENT')

    def get_Data(self):
        CSV_File(self.filen, self.DB.get_sql(self.SQL)).create_csv()
        Archiv(self.filen, 'csv').zip_File()
        FTP_work('FTP_CONF2').upload_FTP(self.filen + '.zip' )

