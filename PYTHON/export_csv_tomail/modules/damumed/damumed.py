#  Autor by Lander (c) 2020. Created for Standart-N LLT
from engine import FTP_work,Db,Archiv,read_ini,existPath,my_log,XML,get_File

logger = my_log.get_logger(__name__)
class Damumed(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.conf = 'DAMUMED'
        self.path_ini=__name__
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        existPath(self.path)
        self.profile_id = profile_id
        self.file_name =self.path+ read_ini(self.conf, 'ID_CLIENT',self.path_ini)
        logger.info('Формируем - '+self.file_name)
        if self.profile_id is None:
            logger.info('Алгоритм работает только для сетей !!!')
            exit()


    def get_Data(self):
        gl_root=XML.add_root(self,root='drugs' )
        SQL_DAMUMED =get_File('./modules/damumed/sql/','SQL_DAMUMED')
        SQL = SQL_DAMUMED.format(profile_id=self.profile_id)
        result = self.DB.get_sql(SQL)
        for s in result:
            attrib={"storeName":s[0],"drugName":s[1],"manufacturer":s[2],"country":s[3],"dosage":s[4],"packaging":s[5],
                    "registrationNumber":s[6],"balance":str(s[7]),"price":str(s[8]) }
            XML.add_element(self,'drug',gl_root,attrib=attrib)
        XML().save_file(root=gl_root,filename=self.file_name + str(self.profile_id) +".xml")
        Archiv(self.file_name+self.profile_id, 'xml').zip_File()
        FTP_work(self.conf).upload_FTP(self.file_name+self.profile_id + '.zip',isbynary=True)




