#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,os,LogIt,existPath,read_ini,get_File,put_file
from XMLcreate import XML
import datetime

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



    def create_export(self,gl_root,root,element,data,head_file,sql,date_start=None,date_end=None):
        self.doc_dates=[]
        if self.type:
            attrib = {"type": root,  "map_pharmacy_ids": self.dep_code}
        else:
            attrib={"type":root,"datestart":self.date_start.strftime("%Y-%m-%dT%H:%M:%S"),"dateend":self.date_end.strftime("%Y-%m-%dT23:59:59"),"map_pharmacy_ids":self.dep_code}

        rt=XML().add_element(root=gl_root,element='action',attrib=attrib)
        el=XML().add_element(root,rt)
        sql = get_File(path='./modules/sozvezdie/sql/', file=sql)
        for pid in data:
            sql1 = sql.replace(':pid', str(pid))
            sql1 = sql1.replace(':date_start',"'"+self.date_start.strftime('%d.%m.%Y:00:00:00')+"'")
            sql1 = sql1.replace(':date_end', "'"+self.date_end.strftime('%d.%m.%Y:23:59:59')+"'")
            p = self.DB.get_sql(sql1)

            # el1=XML().add_element(element,el)
            heads = get_File('./modules/sozvezdie/head/', head_file)
            heads = heads.split('\n')

            if 'move' in head_file:
                self.doc_dates.append([p[0][18],p[0][2]])
            for row in p:
                el1 = XML().add_element(element, el)

                y = 0
                for head in heads:
                    exp_data= row[y]

                    if head != 'nomenclature_codes':
                        XML().add_subelement(subelem=head,elem=el1,data=exp_data)
                    else:
                        el2 = XML().add_element(head,el1)
                        XML().add_subelement(subelem='code', elem=el2, data=exp_data,attrib={"owner":"map"})
                    y += 1
        return rt

    def get_Data(self):
        self.get_Date()
        file_name = self.get_Filename()
        part_id=[]
        part_id1=[]
        sql = 'SELECT first 200 part_id from docs d left join doc_detail dd on dd.doc_id=d.id'
        if self.type:
            where = f" where d.docdate < '{self.date_start.strftime('%d.%m.%Y:00:00:00')}'and part_id is not null group by dd.part_id having (abs(sum(dd.quant))>0.001)"
            p = self.DB.get_sql(sql, where)
            for po in p:
                part_id1.append(po[0])
            part_id1 = list(set(part_id1))

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
        # for d in docs:
        #     LogIt(str(d[0])+' '+str(d[1]))


        XML().save_file(root=gl_root,filename=file_name)
        LogIt('END')
        exit()

        self.get_Date()



    def get_Date(self):
        if self.type:
            LogIt('Выбранна первичная выгрузка')
            self.date_start = datetime.datetime.strptime(read_ini(self.conf, 'DATE_START'),"%d.%m.%Y")
            self.date_end = datetime.datetime.today()#datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")#
        else:
            LogIt('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today()-datetime.timedelta(days=92)
            self.date_end =datetime.datetime.today()






