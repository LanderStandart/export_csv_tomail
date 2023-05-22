import gui
from engine import System

import datetime,os
import locale,sys
from tqdm import tqdm



section = 'BASE_CONF'

path = System.read_ini(section, 'PATH_EXPORT')

#init windows
window=gui.Form(path)
window.geometry("300x250")
window.iconbitmap(default="./export.ico")
window.title("Выгрузка данных для 1С")
window.mainloop()



#конец инициализации


