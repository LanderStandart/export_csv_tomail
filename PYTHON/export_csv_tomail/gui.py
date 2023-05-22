import tkinter as tk
from tkinter import ttk
from  engine import ExportData,Db,read_ini,oldmy_log,clear_export_path
import configparser

def action(vars,firms):
    each_var = vars.get()
    print ("var is %s", str(each_var))
    print(firms)
    if vars.get():
        cb.deselect()

    else:

        cb.select()

root = tk.Tk()
root.title("Tab Widget")
tabControl = ttk.Notebook(root)
tab = {}
config = configparser.ConfigParser()
config.read('./config.ini')
params = config.items('PARAMS')
tab1=ttk.Frame(tabControl)
tabControl.add(tab1, text='main')
index=0
for i in params:
    index=+1
    if int(i[1]) != 2:
        firm = i[0].title()
        tab[index]=ttk.Frame(tabControl)
        tabControl.add(tab[index], text=firm)


tabControl.pack(expand=1, fill="both")
var2 = tk.BooleanVar()
var={}

c={}
index=0
for i in params:
    index+=1
    firm = i[0].title()
    var[index]= tk.IntVar()
    var[index].set(int(i[1]))
    cb = tk.Checkbutton(tab1, text=firm, variable=var[index],
             onvalue=1, offvalue=0,
             command= lambda i=firm: action(var[index],i))

    cb.pack()






root.mainloop()