#  Autor by Lander (c) 2020. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,valid_xml,LogIt,existPath,my_log
logger = my_log.get_logger(__name__)
class Damumed(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.conf = 'DAMUMED'
        self.path = self.DB.config.get(self.conf, 'PATH_EXPORT')
        existPath(self.path)
        self.profile_id = profile_id
        self.file_name =self.path+ self.DB.config.get(self.conf, 'ID_CLIENT')
        logger.info('Формируем - '+self.file_name)
        if self.profile_id is None:
            logger.info('Алгоритм работает только для сетей !!!')
            exit()


    def get_Data(self):

        with open(self.file_name + str(self.profile_id) +".xml", "wb")as file_damumed:
            xml = '<?xml version="1.0" encoding="utf-8" ?>\n' \
              '<drugs>\n'.encode('utf8')
            file_damumed.write(xml)
            SQL_DAMUMED = " select first 5 g.caption  as storename, " \
                      "w.sname as drugname, " \
                      "w.sizg as manufacturer, " \
                      "w.scountry as country, " \
                      "'' as dosage, " \
                      "'' as packaging, " \
                      "'' as registrationNumber, " \
                      "w.quant as balance, " \
                      "w.price as price " \
                      "from warebase_g w "\
                    "inner join g$profiles g on g.id = w.g$profile_id"
            result = self.DB.get_sql(SQL_DAMUMED,' where w.g$profile_id='+self.profile_id)
            xml = ''

            for s in result:
                xml = '  <drug storeName="' + valid_xml(s[0]) + '" drugName="' + valid_xml(
                s[1]) + '" manufacturer="' + valid_xml(s[2]) + '" country="' + s[3] + \
                  '" dosage="' + s[4] + '" packaging="' + s[5] + '" registrationNumber="' + s[6] + '" balance="' + str(
                s[7]) + '" price="' + str(s[8]) + '"/>\n'
                xml = xml.encode('utf8')
                file_damumed.write(xml)
            xml = '</drugs>\n'.encode('utf8')
            file_damumed.write(xml)

        Archiv(self.file_name+self.profile_id, 'xml').zip_File()
        FTP_work(self.conf).upload_FTP(self.file_name + '.zip')




