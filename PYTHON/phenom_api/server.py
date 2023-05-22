import uptime,time,os,glob,json

def last_modified_file2(folder):
    result = None
    date = None
    for name in glob.iglob(folder + "/*"):
        if os.path.isfile(name):
            if not result:
                result = name
                date = os.path.getmtime(name)
            else:
                date2 = os.path.getmtime(name)
                if date2 > date:
                    result = name
                    date = date2
    return result
path = r'E:\TMS\export_csv_tomail\PYTHON\export_csv_tomail\export\damumed'



def read_all():
    LF = time.strftime("%d-%m-%Y  %H:%M:%S", time.localtime(os.path.getctime(last_modified_file2(path))))
    ServerUptime = time.strftime("%d days  %H:%M:%S", time.gmtime(uptime.uptime()))
    PEOPLE = {
        "ServerInfo": {
            "PhenomUptime": ServerUptime,
            "LastBackUpDate": LF,
            "CurrentTime": time.strftime("%d-%m-%Y  %H:%M:%S", time.localtime(time.time()))

        },

    }
    return PEOPLE