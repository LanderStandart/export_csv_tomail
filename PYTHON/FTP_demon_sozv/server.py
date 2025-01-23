import uptime,time,os,glob,json,sys
sys.path.insert(0, "./engine")
from system import System






def read_all():
    system=System()
    log=system.Log(__name__)
    path=system.read_ini('BASE', 'PATH_EXPORT')

    # LF = time.strftime("%d-%m-%Y  %H:%M:%S", time.localtime(os.path.getctime(last_modified_file2(path))))
    # ServerUptime = time.strftime("%d days  %H:%M:%S", time.gmtime(uptime.uptime()))
    PEOPLE = {
        "ServerInfo": {
            "PhenomUptime": path,


        },

    }
    return PEOPLE