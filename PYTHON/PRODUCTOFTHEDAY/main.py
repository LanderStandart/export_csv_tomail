import sys
from lxml import etree
import datetime
sys.path.insert(0, "./engine")
from firebirdsql import Db
from system import System
from ftp import FTP_work
section ='BASE_CONF'
system=System()
FTP=FTP_work()
logger = system.Logs(__name__)
DB = Db()
ftp_path=system.read_ini(section, 'FTP_PATH')
profiles=system.read_ini(section, 'PROFILE_ON').split(',')
i_path='./import/DISCOUNTCOMPENSATION'
FTP.Download_FTP(i_path,ftp_path,maska="^\d+_102582_\d+_DISCOUNTCOMPENSATION")
exit
#FTP.Download_FTP(i_path,ftp_path,maska="^\d+_102581_")
filelist=system.list_file_in_path(i_path,'xml')
for file in filelist:
    logger.info(file)
    tree = etree.parse(file)
    root = tree.getroot()
    data_row = {}
    data_list=[]
    for data in root:
        if data.tag=='{portal-mapintegration}marketing_actions':
            for marketing_action in data.getchildren():

                #print(marketing_action.tag)

                for mark in marketing_action.getchildren():

                    if mark.tag =='{portal-mapintegration}marketing_action_id':
                        #print(mark.text)
                        marketing_action_id=mark.text
                    if mark.tag =='{portal-mapintegration}marketing_action_name':
                        #print(mark.text)
                        marketing_action_name=mark.text

                    if mark.tag =='{portal-mapintegration}date_start':
                        #print(mark.text)
                        date_start=datetime.datetime.strptime(mark.text,'%Y-%m-%d')
                    if mark.tag =='{portal-mapintegration}date_end':
                        #print(mark.text)
                        date_end=datetime.datetime.strptime(mark.text,'%Y-%m-%d')
                    if mark.tag =='{portal-mapintegration}map_pharmacy_ids':
                        for map_pharmacy_ids in mark.getchildren():
                            #print(map_pharmacy_ids.text)
                            map_pharmacy_ids_text=map_pharmacy_ids.text
                    if mark.tag =='{portal-mapintegration}products':

                        for products in mark.getchildren():
                            for product in products.getchildren():
                                if product.tag == '{portal-mapintegration}product_id':
                                    data_row = {}
                                    data_row['marketing_action_id'] = marketing_action_id
                                    data_row['marketing_action_name'] = marketing_action_name
                                    data_row['date_start'] = date_start
                                    data_row['date_end'] = date_end
                                    data_row['map_pharmacy_ids'] = map_pharmacy_ids_text
                                if product.tag == '{portal-mapintegration}product_name':
                                    data_row['product_name_text'] =product.text
                                if product.tag == '{portal-mapintegration}product_data':
                                    for product_data in product.getchildren():
                                        data_row['product_data']=product_data.text
                                if product.tag == '{portal-mapintegration}nomenclatures':
                                    for nomenclatures in product.getchildren():
                                        for nomenclature in nomenclatures.getchildren():
                                            if nomenclature.tag == '{portal-mapintegration}map_nomenclature_code':
                                                data_row['map_nomenclature_code']=nomenclature.text
                                            elif nomenclature.tag == '{portal-mapintegration}nomenclature_barcodes':
                                                        data_row['nomenclature_barcodes']=nomenclature.text
                            data_list.append(data_row)


                                #

    #                                 else:
    #                                     if product.tag == '{portal-mapintegration}product_data':
    #                                         for product_data in product.getchildren():
    #                                             data_row['product_data']=product_data.text

    #

    #
    #
    #
    # Получаем значение генератора акций select gen_id(GEN_DSC_RULES_ID,1) from rdb$database
    #
    sql='select gen_id(GEN_DSC_RULES_ID,1) from rdb$database'
    ID=DB.get_sql(sql)[0][0]


    # for f in data_list:
    #     print(f)

    for f in data_list:
        if 'ТД' in f['marketing_action_name']:
            logger.info(f"Инициатива {f['marketing_action_name']} Загружается")
            if f['map_nomenclature_code']:
                sql = f"select id from DSC_RULES where SNAME1 containing((Select first 1 SNAME from WARES where name_id='{f['map_nomenclature_code']}')) and" \
                      f" DATE_BEG='{datetime.datetime.strftime(f['date_start'], '%d.%m.%Y')}' --and comments containing('{f['marketing_action_id']}')"
                IDold = DB.get_sql(sql)

                if not IDold:
                    SNAMES=[]
                    barcodes =f['nomenclature_barcodes'].split(',')
                    print(barcodes)
                    for barcode in barcodes:
                        print(barcode)
                        sql = f"select sname from wares w where w.barcode containing('{barcode}') group by sname"
                        SNAMES=SNAMES+DB.get_sql(sql)
                    print(SNAMES)
                    try:

                        for sname in SNAMES:
                            print(sname)
                            sql = 'select gen_id(GEN_DSC_RULES_ID,1) from rdb$database'
                            ID = DB.get_sql(sql)[0][0]
                            sql = f"INSERT INTO DSC_RULES(ID,DATE_BEG,DATE_END,SNAME1,SUM_DSC,STATUS,COMMENTS) VALUES ({ID},'{datetime.datetime.strftime(f['date_start'], '%d.%m.%Y')}'" \
                                  f",'{datetime.datetime.strftime(f['date_end'], '%d.%m.%Y')}'," \
                                  f"'{sname[0]}',{float(f['product_data'])},1,'{f['marketing_action_name']}({f['marketing_action_id']})')"

                            DB.get_sql(sql=sql, commit=1)
                            logger.info(f"Товар  {f['product_name_text']} ШК:{f['nomenclature_barcodes']}  загружен как  {sname[0]}")
                            for prof in profiles:
                                sql = f"INSERT INTO DSC_RULES_GPROFILES(DSC_RULES_ID,PROFILE_ID,ALLOW) VALUES ({ID},{int(prof)},1)"
                                print(sql)
                                DB.get_sql(sql=sql, commit=1)
                    except:
                        logger.error(f"Нет кода наименования - {f['product_name_text']}")

                else:
                    logger.error(f"Инициатива - {f['marketing_action_id']} c товаром {f['product_name_text']} загружена")
                    # exit(f"Инициатива - {f['marketing_action_id']} загружена")
            else:
                logger.error(f'Нет кода наименования - {f}')
        else:
            logger.info(f"Инициатива {f['marketing_action_name']} не используется")