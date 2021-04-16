#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,os,LogIt,existPath,read_ini,get_File,put_file
from XMLcreate import XML
import datetime
import itertools

class Sozvezdie(Db):
    def __init__(self,profile_id=None):
        self.DB = Db()
        self.profile_id = profile_id
        self.conf = 'SOZVEZDIE'
        self.path = read_ini(self.conf, 'PATH_EXPORT')
        #CLIENT_ID пока получаем из ini но думаю для сети нужно привязку к профиль ИД
        self.client_id = read_ini(self.conf, 'CLIENT_ID')
        #Тип выгрузки 1- первичная 0-текущая
        self.type = int(read_ini(self.conf, 'TYPE'))
        existPath(self.path)
        #список файлов выгрузки
        self.expfile = read_ini(self.conf, 'FILE_LIST').split(',')
        self.dep_code =read_ini(self.conf, 'DEP_CODE')



    def get_Filename(self):#формируем имя файла
        filename = '_'+self.client_id+'_bat'
        self.filename=self.date_end.strftime('%Y')+self.date_end.strftime('%m')+self.date_end.strftime('%d')+\
                      self.date_end.strftime('%H')+self.date_end.strftime('%M')+self.date_end.strftime('%S')+ filename
        return self.path +self.filename + '.tmp'



    def create_export(self,root,element,data,head_file,sql,date_start=None,date_end=None,gl_root=None):
        self.doc_dates=[]
        if self.type:
            attrib = {"type": root,  "map_pharmacy_ids": self.dep_code}
        else:
            attrib={"type":root,"datestart":self.date_start.strftime("%Y-%m-%dT%H:%M:%S"),"dateend":self.date_end.strftime("%Y-%m-%dT23:59:59"),"map_pharmacy_ids":self.dep_code}

        if gl_root is not None:
            self.rt=XML().add_element(root=gl_root,element='action',attrib=attrib)
            self.el=XML().add_element(root,self.rt)
        sql = get_File(path='./modules/sozvezdie/sql/', file=sql)
        #data = data if type(data) ==int else list(set(data))
        x = 0
        for pid in data:

            da_strt = self.date_start if type(pid)==int else pid[1]
            da_end = self.date_end if type(pid)==int  else pid[1]
            da_end = self.date_start if date_end else da_end
            pid = str(pid) if type(pid) == int else pid[0]
            sql1 = sql.replace(':pid', str(pid))
            sql1 = sql1.replace(':date_start',"'"+da_strt.strftime('%d.%m.%Y:00:00:00')+"'")
            sql1 = sql1.replace(':date_end', "'"+da_end.strftime('%d.%m.%Y:23:59:59')+"'")
            p = self.DB.get_sql(sql1)

            # el1=XML().add_element(element,el)
            heads = get_File('./modules/sozvezdie/head/', head_file)
            heads = heads.split('\n')

            if date_start and da_strt.strftime('%d.%m.%Y:00:00:00') == date_start.strftime('%d.%m.%Y:00:00:00'):
                print(head_file, da_strt, da_end, date_start)
                continue

            for row in p:

                el1 = XML().add_element(element, self.el)
                if 'move' in head_file :
                    self.doc_dates.append([row[2], row[18]])

                y = 0
                for head in heads:
                    exp_data = row[y]
                    # if 'base' in head_file and x==0 and y in (3,5,7):
                    #     exp_data='0.0'
                    if head != 'nomenclature_codes':
                        XML().add_subelement(subelem=head,elem=el1,data=exp_data)
                    else:
                        el2 = XML().add_element(head,el1)
                        XML().add_subelement(subelem='code', elem=el2, data=exp_data,attrib={"owner":"map"})
                    y += 1
            x += 1
        return self.rt

    def get_Data(self):
        self.get_Date()
        file_name = self.get_Filename()
        part_id=[]
        part_id1=[]
        sql = 'SELECT part_id from docs d left join doc_detail dd on dd.doc_id=d.id'
        if self.type:
            where = f" where d.docdate < '{self.date_start.strftime('%d.%m.%Y:00:00:00')}'and part_id is not null group by dd.part_id having (abs(sum(dd.quant))>0.001)"
            #where = f" where d.docdate < '{self.date_start.strftime('%d.%m.%Y:00:00:00')}'and part_id =126608 group by dd.part_id having (abs(sum(dd.quant))>0.001)"
            p = self.DB.get_sql(sql, where)
            for po in p:
                part_id1.append(po[0])
            part_id1 = list(set(part_id1))
        #where = f" where d.docdate between '{self.date_start.strftime('%d.%m.%Y:00:00:00')}' and '{self.date_end.strftime('%d.%m.%Y:23:59:59')}' and part_id =126608"
        where = f" where d.docdate between '{self.date_start.strftime('%d.%m.%Y:00:00:00')}' and '{self.date_end.strftime('%d.%m.%Y:23:59:59')}' and part_id is not null"
        p = self.DB.get_sql(sql, where)
        for po in p:
            part_id.append(po[0])
        part_id = list(set(part_id))
        parts = list(set(part_id+part_id1))
        LogIt(str(len(parts)))
        #Create XML
        gl_root=XML().add_root(root='map-actions',attrib={"client_id":"13110"})

        self.create_export(gl_root=gl_root,root='batches',element='batch',data=parts,head_file='goods',sql='action_batch')

        if self.type:
            self.create_export(gl_root=gl_root,root='distributions', element='distribution', data=parts, head_file='move', sql='action_move_first')
        else:
            self.create_export(gl_root=gl_root,root='distributions', element='distribution', data=part_id, head_file='move', sql='action_move')

        docs = self.doc_dates
        docs.sort()
        docs = list(docs for docs,_ in itertools.groupby(docs) )

        if self.type:

            self.create_export(gl_root=gl_root, root='remnants', element='remnant', data=part_id1, head_file='base', sql='action_remnant_first',date_end='1')


            self.create_export(gl_root=None,root='remnants',element='remnant', data=docs, head_file='base', sql='action_remnant',date_start=self.date_start)
        else:
            self.create_export(gl_root=gl_root, root='remnants', element='remnant', data=docs, head_file='base', sql='action_remnant')



        XML().save_file(root=gl_root,filename=file_name)
        LogIt('END')
 



    def get_Date(self):
        if self.type:
            LogIt('Выбранна первичная выгрузка')
            self.date_start = datetime.datetime.strptime(read_ini(self.conf, 'DATE_START'),"%d.%m.%Y")
            self.date_end = datetime.datetime.today()#datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")#
        else:
            LogIt('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today()-datetime.timedelta(days=92)
            self.date_end =datetime.datetime.today()






