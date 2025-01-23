import json
import zipfile,io
import zlib
import ydbf
from sqlalchemy import create_engine,update
from sqlalchemy.orm import sessionmaker,Query

#from sqlalchemy.ext.declarative import declarative_base
#from sqlalchemy import Column, Integer, String
from config import settings,settings1
import requests
from bs4 import BeautifulSoup
from dbfread import DBF
from models.sinhro_model import Sup_code



class db_sinhro():
    def __init__(self):
        # Создание движка
        print(settings.DATABASE_URL_ZTRADE)
        self.sinhro_engine = create_engine(settings.DATABASE_URL_ZTRADE, echo=True, implicit_returning=False)
        # Создание базового класса для моделей

        # Создание сессии
        self.Session = sessionmaker(bind=self.sinhro_engine)
        self.session = self.Session()

class db_zclients():
    def __init__(self):
        # Создание движка
        print(settings1.DATABASE_ZCLIENTS)
        self.zclient_engine = create_engine(settings1.DATABASE_ZCLIENTS, echo=True, implicit_returning=False)
        # Создание базового класса для моделей

        # Создание сессии
        self.Session = sessionmaker(bind=self.zclient_engine)
        self.session = self.Session()

class Record(object):
    def __init__(self, items):
        for (name, value) in items:
            setattr(self, name, value)

def get_Atamiras(bin):
    print(bin)
    contract_id = ''
    store_id = ''
    zclients = []
    response = requests.get('http://wiki.standart-n.ru/images/0/05/Adress.zip')
    with response, zipfile.ZipFile(io.BytesIO(response.content)) as archive:
        archive.extractall('import')

    for record in DBF('./import/adress.dbf', recfactory=Record, lowernames=True):
        if record.client_cod in bin:
            put_in_base(record.client_cod, record.adress, 15, record.guid, contract_id, store_id)
            # zclients.append(
            # {'BIN': record.client_cod, 'ADDRESS': record.adress,
            #  'POST_ID': 15, 'CODE': record.guid,
            #  'CONTRACT': contract_id, 'STORE': store_id})

    return zclients

def put_in_base(client_bin, client_address,id_sup,  client_id, contract_id, store_id):
    DB = db_sinhro()

    newsupp = Sup_code(
        BIN=client_bin,
        ADDRESS=client_address,
        POST_ID=id_sup,
        CODE=client_id,
        CONTRACT=contract_id,
        STORE=store_id
    )
    SUP = {'BIN': client_bin,
         'ADDRESS': client_address,
         'POST_ID':id_sup,
         'CODE':client_id,
         'CONTRACT': contract_id,
         'STORE':store_id}
    qry_object = DB.session.query(Sup_code).filter(Sup_code.CODE == newsupp.CODE,
                                                   Sup_code.POST_ID == newsupp.POST_ID)
    if qry_object.first() is None:
        DB.session.add(newsupp)
    else:

        update_vals = update(Sup_code).where((Sup_code.CODE == newsupp.CODE) &(Sup_code.POST_ID == newsupp.POST_ID)).values(SUP)
        DB.session.execute(update_vals)

    DB.session.commit()



def proc_responce_sup(response, id_sup, response1=None, bin=None):
    DB=db_sinhro()
    contract_id = ''
    store_id = ''
    zclients = []

    try:

        if int(id_sup) != 56 and id_sup!=736 and id_sup!=1016 and id_sup!=19:

            soup = BeautifulSoup(response.text, 'lxml')
            root = soup.find_all('client')
            for client in root:
                client_id = client.find("id").text
                client_bin = client.find("bin").text
                client_address = client.find("address").text
                if response1:
                    if id_sup != 153:
                        soup = BeautifulSoup(response1.text, 'lxml')
                        root = soup.find_all('contract')
                        for contract in root:
                            if contract.find("main").text == '1':
                                contract_id = contract.find("id").text
                    else:
                        soup = BeautifulSoup(response1.text, 'lxml')
                        root = soup.find_all('i')
                        for stat in root:
                            if stat['town'].lower() in client_address.lower():
                                contract_id = stat['id']
                                store_id = stat['store']
                put_in_base(client_bin, client_address,id_sup,  client_id, contract_id, store_id)

        else:

            clients = json.loads((response.text)) if response!='' else ''

            if id_sup ==56:
                put_in_base(clients['bin'], clients['address'], id_sup, clients['id'], contract_id, store_id)

            elif id_sup == 736:
                for clients in clients['body']:
                    put_in_base(clients['Counterparty_BIN'], clients['Counterparty']+clients['name'], id_sup, clients['uid'], contract_id, store_id)

            elif id_sup == 1016:
                for client in clients['addresses']:
                    put_in_base(clients['bin'], client['name'], id_sup, client['id'], contract_id, store_id)

            elif id_sup == 15:
                get_Atamiras(bin)

    except:
        print('Чтото пошло не так !!!')



def get_CODE_SUP(id_sup, bin, sklad):
    response1 = None
    auth=None
    result = db_sinhro().session.execute(f"select * from SUPPLIERS where id={id_sup}").fetchone()
    if result['auth']:
        auth = {'Authorization': result['auth']}

    if result['url1']:
        url1 = result['url1'].format(bin)
        response1 = requests.get(url1, verify=False)
        print(url1)

    if id_sup == 46:
        url = result['url'].format(sklad, bin)
    else:  # id_sup == 55:
        url = result['url'].format(bin)
    print(auth)
    response =requests.get(url, verify=False,headers=auth) if result['url'] else ''
    # print(response.text)

    return proc_responce_sup(response, id_sup, response1,bin)


bin = '960340001047'
#bin = '700620401745'
sklad = '1020'
# print(get_CODE_SUP(46,bin,sklad))
# medservice=result['url'].format(sklad,bin)

# response=requests.get(medservice,verify=False)
# print(response.text)
# result = db_sinhro().session.execute(f"select id from SUPPLIERS")
# for id in result:
#     print(id[0])
#     get_CODE_SUP(id[0], bin, sklad)
#answer = get_CODE_SUP(153, bin, sklad)
#
# for stroka in answer:
#     print(stroka)
result = db_zclients().session.execute(f"select client_name,inn from zclients z where z.client_type=0").fetchall()

for row in result:
    print(row)








