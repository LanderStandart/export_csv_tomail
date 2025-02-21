#  Autor by Lander (c) 2021. Created for Standart-N LLT
import zipfile
import os
from system import System

#Архивирование файла
class Archiv(System):
    def __init__(self,fn,ext):
        self.logger = System.get_logger(__name__)
        self.fn = fn
        self.ext = ext
    def zip_File(self):
        fname= self.fn
        if '\\' in fname:
            i=fname.rfind('\\')
            fname = self.fn[i+1:len(self.fn)]
        # if '.' in fname:
        #     i=fname.rfind('.')
        #     fname = self.fn[1:i-1]
        ext_filename = os.path.basename(r'' + self.fn)
        with zipfile.ZipFile(os.path.abspath(os.curdir)+'\\'+self.fn + '.zip', 'w') as ZIPP:
            ZIPP.write(os.path.abspath(os.curdir)+'\\'+self.fn + '.'+self.ext,arcname=ext_filename+ '.'+ self.ext, compress_type=zipfile.ZIP_DEFLATED)
        ZIPP.close()