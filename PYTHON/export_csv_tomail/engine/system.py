#  Autor by Lander (c) 2021. Created for Standart-N LLT
import time
import datetime
import os
import configparser
import pathlib
import my_log
logger = my_log.get_logger(__name__)

def read_ini(sections,params,modules=None,save=None,values=None):
    config = configparser.ConfigParser()
    path ='.' if not modules else './modules/'+modules
    try:
        config.read(path+'/config.ini')
        if not save:
            return config.get(sections, params)
        else:
            #config[sections][params]=str(values)
            config.set(sections, params, str(values))
            with open(path+'/config.ini', 'w') as configfile:
                config.write(configfile)

    except:
        logger.error(f'Нет параметра - {params} в настройках - {sections} модуля {modules} - {path}/config.ini')

def list_file_in_path(path,ext):
    curDir=pathlib.Path(path)
    curPatt="*."+ext
    fList = []
    for curFile in curDir.glob(curPatt):
        fList.append(str(curFile))
    return fList

def get_File(path,file):
    try:
        with open(path+file)as file:
            p = file.read()
            # p = p.split('\n')
    except FileNotFoundError:
        logger.error ('Файл:' + path+file + '- недоступен для загрузки')
        sys.exit()
    return p

def clear_export_path(path):
    #Чистим логи чтобы выгрузка была только свежая
    logger.info(f'Удаляем старые выгрузки в - {path}')
    now=datetime.datetime.now()
    i=0
    if not path:return logger.error('Не указан путь для удаления выгрузок')
    try:
        with os.scandir(path) as files:
            for file in files:
                time_file = time.ctime(os.path.getctime(path+file.name))
                time_file= datetime.datetime.strptime(time_file,'%c')
                if now-time_file>datetime.timedelta(days=1):
                    print('Удален - '+file.name)
                    i +=1
                    os.remove(path+file.name)
        logger.info('Удаленно ' + str(i) + ' файлов')
    except FileNotFoundError:
        logger.info('Удалять нечего')

def existPath(path):
    if not path:return logger.error('Не указан путь для  выгрузок')
    if os.path.exists(path):
        logger.info('Каталог -'+path+' найден')

    else:
        logger.info('Каталог -' + path + ' ненайден, создаем...')

        os.mkdir(path)

def put_file(filen,data):
    type_f = 'ab' if type(data)==bytes else 'a'
    with open(filen, type_f)as file:
        file.write(data)





