import pandas as pd
import csv
import xlrd
import os

def csv_writer(data, path):
    """
    Write data to a CSV file path
    """
    with open(path, "w", newline='') as csv_file:
        writer = csv.writer(csv_file, quoting=csv.QUOTE_NONE, escapechar=' ', delimiter='\t')
        for line in data:
            writer.writerow(line)

# Assign spreadsheet filename to `file`
def xls_to_zao(file):
    #file = 'a17-1.xlsx'
    file = './export/'+file
    xl = pd.ExcelFile(file)
    print(file)
    excel_data_df = pd.read_excel(file, sheet_name=xl.sheet_names[0],header=0)


# столбцы  1- '№'  2- 'Наименование / Изготовитель' 3-'заказ'

    i = 0

    data=[]
    while i< len(excel_data_df):
    #print(excel_data_df['Наименование / Изготовитель'][i])
   # datum1.append(list(['3', 'Ввод остатков', inn]))
        pos = str(excel_data_df['№'][i])+'\t'
        name = str(excel_data_df['Наименование / Изготовитель'][i]).strip(' ')
        zakaz = str(excel_data_df['Кол-во'][i])
        data.append(list([name.rstrip('')+'\t\t\t',zakaz+'\t\t',zakaz+'\t','0'+'\t',name+';'+name+';'+name+';\t'+' ' ]))
        i=i+1

    path = './zao/'+file.replace('./export','')+'.zao'
    print(data)
    #csv_writer(data,path)

    f = open(path,"w")
    for item in data:

        f.write("".join(item)+'\n')



directory='./export';
files = os.listdir(directory)
xsls = filter(lambda x: x.endswith('.xlsx'),files)
print(files)
for file in files:
    xls_to_zao(file.replace('~$',''))