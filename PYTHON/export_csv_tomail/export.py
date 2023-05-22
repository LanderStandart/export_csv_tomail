#  Autor by Lander (c) 2020. Created for Standart-N LLT
from  engine import ExportData
import configparser
import sys
sys.path.insert(0, "./engine")
from system import System


EXP=ExportData()
logger =EXP.Logs(__name__)
config = configparser.ConfigParser()
config.read('./config.ini')
params = config.items('PARAMS')


if len(sys.argv)>1:
    EXP.create('file',firm=sys.argv[1],queue=EXP.read_ini(sys.argv[1],'QUEUE',sys.argv[1]))
for i in params:
    if int(i[1]) != 0:
        firm = i[0].title()
        logger.info('Формируем:'+ firm)
        path = EXP.read_ini(firm.upper(),'PATH_EXPORT',firm)
        EXP.clear_export_path(path)
        queue = EXP.read_ini(firm.upper(),'QUEUE',firm)
        path = './log/'
        EXP.clear_export_path(path)
        #Проверка переодичности запуска если 1 то запускаем если 0 то пропускаем
        if EXP.planner(firm) == 1:
            logger.info(f'Формируем: {firm}  QUEUE = {queue}')
            EXP.create('file',firm=firm,queue=queue)
            data = {"exportname": firm,
                    "pointid": 12,
                    "pointname": "ScriptTest",
                    "status": "string_ok"
                    }

          #  s_request('POST', data=json.dumps(data), header=None, auth=None, url='http://192.168.67.62:8000/api/point')








