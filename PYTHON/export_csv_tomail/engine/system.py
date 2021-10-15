#  Autor by Lander (c) 2021. Created for Standart-N LLT
import time
import configparser
import pathlib
import my_log
def LogIt(text,status=None):
   # Log(text)
    with open('./log.txt', 'a')as log:
        log_string = time.strftime("%d.%m_%H:%M:%S")
        log_string = log_string +' '+ text + "\n"
        log.write(log_string)
    print(log_string)

def read_ini(sections,params,modules=None):
    config = configparser.ConfigParser()
    path ='.' if not modules else './modules/'+modules
    config.read(path+'/config.ini')
    return config.get(sections, params)

def list_file_in_path(path,ext):
    curDir=pathlib.Path(path)
    curPatt="*."+ext
    fList = []
    for curFile in curDir.glob(curPatt):
        fList.append(str(curFile))
    return fList





