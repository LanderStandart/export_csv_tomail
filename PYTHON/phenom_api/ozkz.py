import uptime,datetime,os,glob,json,sys
sys.path.insert(0, "./engine")
from MySQL import Mysql
from system import System

MYSQL = Mysql('MYSQL_KZ')


def last_send_zakaz():
    task = 'ozru'
    val = {}
    data = MYSQL.get_from_base(__name__, task, val)
    return str(data[0][0])

path = r'E:\TMS\export_csv_tomail\PYTHON\export_csv_tomail\export\damumed'



def read_all():
    LAST_ZAKAZ = datetime.datetime.strptime(last_send_zakaz(),"%Y-%m-%d %H:%M:%S").strftime("%d-%m-%Y  %H:%M:%S")
    PERIOD_ZAKAZ = datetime.datetime.now()-datetime.datetime.strptime(last_send_zakaz(),"%Y-%m-%d %H:%M:%S")
    print(f'  {PERIOD_ZAKAZ.seconds//60} минут')

    PEOPLE = {
        "OZKZInfo": {
            "LastZakaz": LAST_ZAKAZ,
            "TimeFROMsend":PERIOD_ZAKAZ.seconds//60

        },

    }
    return PEOPLE