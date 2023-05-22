import tkinter as tk
from tkcalendar import DateEntry
from export import Export
from  engine import Db,System

class Form(tk.Tk,Export,Db,System):
    def __init__(self,path):
        super().__init__()
        self.DB = Db()
        self.path = path
        self.logger = System.get_logger(self,__name__)
        lbl_header = tk.Label(text='Выберите период:').place(x=0, y=0)

        lbl_start = tk.Label(width=3, height=1, text="c:").place(x=4, y=25)
        self.cal_start =  DateEntry(width=10, height=1, selectmode='day', date_pattern='dd.MM.YYYY', locale='ru_ru')
        self.cal_start.place(x=25, y=25)
        # Frm_end=Frame().pack(side=RIGHT)
        lbl_end = tk.Label(width=3, height=1, text="по:").place(x=120, y=25)
        self.cal_end =DateEntry(width=10, height=1, selectmode='day', date_pattern='dd.MM.YYYY', locale='ru_ru')
        self.cal_end.place(x=145, y=25)

        lbl_path_header = tk.Label(text='Путь Выгрузки').place(x=0, y=60)
        self.lbl_path = tk.Entry(width=35)
        self.lbl_path.place(x=10, y=80)
        # lbl_path.grid(column=2,row=5)
        self.lbl_path.insert(0, path)

        self.key1 = tk.Button(text='КНОПКА №1',command=self.PressKey1)
        self.key1.place(x=5, y=120)

        self.key2 = tk.Button(text='КНОПКА №2',command=self.PressKey2)
        self.key2.place(x=105, y=120)

        self.key3 = tk.Button(text='КНОПКА №3',command=self.PressKey3)
        self.key3.place(x=205, y=120)

    def PressKey1(self):
        Export.PressKey(self,self.cal_start.get(), self.cal_end.get(),self.lbl_path.get())
        return



    def PressKey2(self):
        Export.PressKey2(self,self.cal_start.get(), self.cal_end.get(),self.lbl_path.get())

    def PressKey3(self):
        Export.PressKey3(self,self.cal_start.get(), self.cal_end.get(),self.lbl_path.get())




