#  Autor by Lander (c) 2020. Created for Standart-N LLT
from engine import Db, CSV_File, FTP_work,existPath,read_ini


class Kz103(Db):
    def __init__(self, profile_id=None):
        self.profile_id = profile_id
        self.DB = Db()
        self.conf = 'KZ103'
        self.path_ini=__name__
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        existPath(self.path)
        self.head = [read_ini('CSV_CONF', 'HEAD',self.path_ini)]
        self.file_name = self.path + read_ini(self.conf, 'ID_CLIENT',self.path_ini)

    def get_Data(self):
        if self.profile_id:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase_g w where quant>0"
            self.profile_name = self.DB.get_sql("SELECT caption FROM G$PROFILES where id="+str(self.profile_id))[0][0]
            self.DB.get_sql("SELECT DESCRIPTION FROM G$PROFILES where id=" + str(self.profile_id))[0][0]
            self.where = " and w.g$profile_id=" + str(self.profile_id)
            self.file_name = self.file_name+'_'+str(self.profile_id)

        else:
            self.SQL = "SELECT  sname, cast(quant as numeric(9,2)), price FROM warebase w "
            self.profile_name = read_ini(self.conf, 'ID_CLIENT',self.path_ini)
            self.where = None


        CSV_File(self.file_name, self.DB.get_sql(self.SQL, self.where), self.head, self.profile_name).create_csv()

        FTP_work(self.conf).upload_FTP(self.file_name + '.csv')








