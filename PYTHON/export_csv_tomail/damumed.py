#  Autor by Lander (c) 2020. Created for Standart-N LLT
from MyUtils import FTP_work,Archiv,Db,valid_xml

class Damumed(Db):
    def __init__(self, profile_id=None):
        self.DB = Db()
        self.profile_id = profile_id
        self.file_name = self.DB.config.get('FTP_CONF3', 'ID_CLIENT')
        print(self.profile_id)

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
                s[1]) + ' " manufacturer="' + valid_xml(s[2]) + '" country="' + s[3] + \
                  '" dosage="' + s[4] + '" packaging="' + s[5] + '" registrationNumber="' + s[6] + '" balance="' + str(
                s[7]) + '" price="' + str(s[8]) + '"/>\n'
                xml = xml.encode('utf8')
                file_damumed.write(xml)
            xml = '</drugs>\n'.encode('utf8')
            file_damumed.write(xml)


        Archiv(self.file_name+self.profile_id, 'xml').zip_File()
        FTP_work('FTP_CONF3').upload_FTP(self.file_name+self.profile_id + '.zip')




