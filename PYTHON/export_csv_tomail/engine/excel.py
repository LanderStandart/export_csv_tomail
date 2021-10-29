#  Autor by Lander (c) 2021. Created for Standart-N LLT
import pandas as pd

class Excel:
    def __init__(self,filename,sheets):
        self.filename=filename
        self.sheets = sheets

    def create_frame(self,colname,data):

        frame[colname]=data
        return frame

    def save(self):
        writer = pd.ExcelWriter(self.filename,engine='xlsxwritter')