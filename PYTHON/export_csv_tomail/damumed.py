#  Autor by Lander (c) 2020. Created for Standart-N LLT
from MyUtils import FTP_work,Archiv
import MyUtils
class Damumed:
    def __init__(self, DB, file_name, profile_id):
        self.profile_id = profile_id
        self.file_name = file_name
        self.DB = DB

    def get_Data(self):
        file_damumed = open("./" + self.file_name + ".xml", "wb")
        xml = '<?xml version="1.0" encoding="utf-8" ?>\n' \
              '<drugs>\n'.encode('utf8')
        file_damumed.write(xml)

        SQL_DAMUMED = " select first 1 p.param_value as storename, " \
                      "w.sname as drugname, " \
                      "w.sizg as manufacturer, " \
                      "w.scountry as country, " \
                      "'' as dosage, " \
                      "'' as packaging, " \
                      "'' as registrationNumber, " \
                      "w.quant as balance, " \
                      "w.price as price " \
                      "from warebase_g w " \
                      "join params p on p.param_id='ORG_NAME_SHORT'"
        if self.profile_id:
            SQL_DAMUMED =SQL_DAMUMED+" and p.g$profile_id=w.g$profile_id"

        result = self.DB.get_sql(SQL_DAMUMED, self.profile_id)
        xml = ''

        for s in result:
            xml = '  <drug storeName="' + MyUtils.valid_xml(s[0]) + '" drugName="' + MyUtils.valid_xml(
                s[1]) + ' " manufacturer="' + MyUtils.valid_xml(s[2]) + '" country="' + s[3] + \
                  '" dosage="' + s[4] + '" packaging="' + s[5] + '" registrationNumber="' + s[6] + '" balance="' + str(
                s[7]) + '" price="' + str(s[8]) + '"/>\n'
            xml = xml.encode('utf8')
            file_damumed.write(xml)
        xml = '</drugs>\n'.encode('utf8')
        file_damumed.write(xml)
        file_damumed.close()

        Archiv(self.file_name, 'xml').zip_File()
        FTP_work('FTP_CONF3').upload_FTP(self.file_name + '.zip')




