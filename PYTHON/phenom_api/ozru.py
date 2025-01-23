import uptime,datetime,os,glob,json,sys
sys.path.insert(0, "./engine")
from MySQL import Mysql
from system import System

MYSQL = Mysql()


def last_send_zakaz():
    task = 'ozru'
    val = {}
    data = MYSQL.get_from_base(__name__, task, val)
    return str(data[0][0])

def last_price_update():
    task = 'last_price_upd'
    val = {}
    data = MYSQL.get_from_base(__name__, task, val)
    return str(data[0][0])

def last_enakl_send():
    task = 'last_enakl_send'
    val = {}
    data = MYSQL.get_from_base(__name__, task, val)
    return str(data[0][0])

def count_error():
    task = 'counterror'
    val = {}
    data = MYSQL.get_from_base(__name__, task, val)
    return str(data[0][0])


def read_all():
    LAST_ZAKAZ = datetime.datetime.strptime(last_send_zakaz(),"%Y-%m-%d %H:%M:%S").strftime("%d-%m-%Y  %H:%M:%S")
    PERIOD_ZAKAZ = datetime.datetime.now()-datetime.datetime.strptime(last_send_zakaz(),"%Y-%m-%d %H:%M:%S")
    #print(f'  {PERIOD_ZAKAZ.seconds//60} минут')
    LAST_PRICE = datetime.datetime.strptime(last_price_update(), "%Y-%m-%d %H:%M:%S").strftime("%d-%m-%Y  %H:%M:%S")
    PERIOD_PRICE = datetime.datetime.now() - datetime.datetime.strptime(last_price_update(), "%Y-%m-%d %H:%M:%S")

    LAST_ENAKL = datetime.datetime.strptime(last_enakl_send(), "%Y-%m-%d %H:%M:%S").strftime("%d-%m-%Y  %H:%M:%S")
    PERIOD_ENAKL = datetime.datetime.now() - datetime.datetime.strptime(last_enakl_send(), "%Y-%m-%d %H:%M:%S")

    COUNT_ERROR = count_error()

    PEOPLE = {
        "OZRUInfo": {
            "LastZakaz": LAST_ZAKAZ,
            "TimeFROMsend":PERIOD_ZAKAZ.seconds//60,
            "LastPrice": LAST_PRICE,
            "TimeFROMupdate": PERIOD_PRICE.seconds // 60,
            "LastEnakl": LAST_ENAKL,
            "TimeFROMEnakl": PERIOD_ENAKL.seconds // 60,
            "COUNT_Error":COUNT_ERROR

        },

    }
    return PEOPLE