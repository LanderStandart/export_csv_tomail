#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,valid_xml,os,LogIt,existPath,read_ini,get_File,put_file
from XMLcreate import XML
import time
import datetime
import xml.etree.ElementTree as xml

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
        return self.path +self.filename


    def put_ex_file(self,types,sql):
        put_file(self.file_name, self.XMLtemplates(types=types, client_id=self.client_id, openclose=0))
        rez = self.DB.get_sql(sql)
        for i in rez:
            for y in i:
                put_file(self.file_name, str(y))
        put_file(self.file_name, self.XMLtemplates(types=types, client_id=self.client_id, openclose=1))


    def create_export(self,root,element,data,head_file,sql):
        if self.type:
            attrib = {"type": root,  "map_pharmacy_ids": self.dep_code}
        else:
            attrib={"type":root,"datestart":self.date_start.strftime("%Y-%m-%dT%H:%M:%S"),"dateend":self.date_end.strftime("%Y-%m-%dT23:59:59"),"map_pharmacy_ids":self.dep_code}

        rt=XML().add_root(root='action',attrib=attrib)
        el=XML().add_element(root,rt)
        sql = get_File(path='./modules/sozvezdie/sql/', file=sql)
        for pid in data:
            sql1 = sql.replace(':pid', str(pid))
            sql1 = sql1.replace(':date_start',self.date_start.strftime('%d.%m.%Y:00:00:00'))
            sql1 = sql1.replace(':date_end', self.date_end.strftime('%d.%m.%Y:23:59:59'))
            p = self.DB.get_sql(sql1)
            el1=XML().add_element(element,el)
            heads = get_File('./modules/sozvezdie/head/', head_file)
            heads = heads.split('\n')
            y = 0
            head =''
            for head in heads:
                exp_data= p[0][y]
                if head != 'nomenclature_codes':
                    se=XML().add_subelement(subelem=head,elem=el1,data=exp_data)
                else:
                    el2 = XML().add_element(head,el1)
                    XML().add_subelement(subelem='code', elem=el2, data=exp_data,attrib={"owner":"map"})

                y += 1
        return rt



    def get_Data(self):
        self.get_Date()
        part_id=[]
        part_id1=[]
        sql = 'SELECT first 2 part_id from docs d left join doc_detail dd on dd.doc_id=d.id'
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

        res=self.create_export(root='batches',element='batch',data=parts,head_file='goods',sql='action_batch')

        XML().save_file(res)


        LogIt('END')
        exit()

        self.get_Date()
        self.file_name =self.get_Filename()+'.tmp'
        #формируем заголовок файла
        self.put_file(self.file_name,self.XMLtemplates(client_id=self.client_id,openclose=0))
    # формируем Партии товара
        if self.type:
            sql = "execute procedure PR_SOZVEZDIE_ACTION_BATCH('"+self.dep_code+"','"+self.date_start.strftime('%d.%m.%Y:00:00:00')+"','"+\
                  self.date_end.strftime('%d.%m.%Y:23:59:59')+"',1)"
            #self.DB.get_sql(sql,commit=1)

        sql = "execute procedure PR_SOZVEZDIE_ACTION_BATCH('" + self.dep_code + "','" + self.date_start.strftime('%d.%m.%Y:00:00:00') + "','" + \
                  self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
        #self.DB.get_sql(sql, commit=1)
        sql = "select XML from SOZVEZDIE_ACTION_BATCH1 group by xml"
        self.put_ex_file(types='batch',sql=sql)


    # формируем Движение товара
        if self.type:
            sql = "execute procedure PR_SOZVEZDIE_ACTION_MOVE('" + self.dep_code + "','" + self.date_start.strftime('%d.%m.%Y:00:00:00') + "','" +\
                  self.date_start.strftime('%d.%m.%Y:00:00:10') +",'"+self.date_start.strftime('%d.%m.%Y:00:00:10')+ "',1)"
            # self.DB.get_sql(sql,commit=1)
        sql = "execute procedure PR_SOZVEZDIE_ACTION_MOVE('" + self.dep_code + "','" + self.date_start.strftime('%d.%m.%Y:00:00:11') + "','" + \
              self.date_end.strftime('%d.%m.%Y:23:59:59') + ",'" + self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
        # self.DB.get_sql(sql, commit=1)
        sql = "SELECT XML FROM SOZVEZDIE_ACTION_MOVE   group by insertdt, xml"
        self.put_ex_file(types='distribution', sql=sql)

        # формируем Остатки
        if self.type:
            sql = "execute procedure PR_SOZVEZDIE_ACTION_REMHANT('" + self.dep_code + "','" + self.date_start.strftime('%d.%m.%Y:00:00:00') + "','" + \
                  self.date_start.strftime('%d.%m.%Y:23:59:59') + "',1)"
            # self.DB.get_sql(sql,commit=1)
            self.date_start = self.date_start+datetime.timedelta(days=1)
        sql = "execute procedure PR_SOZVEZDIE_ACTION_REMHANT('" + self.dep_code + "','" + self.date_start.strftime('%d.%m.%Y:00:00:00') + "','" + \
              self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
        # self.DB.get_sql(sql, commit=1)
        sql = "select XML from SOZVEZDIE_ACTION_REMHANT group by xml"
        self.put_ex_file(types='remnant', sql=sql)
        self.put_file(self.file_name, self.XMLtemplates(client_id=self.client_id, openclose=1))

    def XMLtemplates(self,client_id,openclose,types=None):
        if types is None:
            OP_tags = '<?xml version="1.0" encoding="WINDOWS-1251"?>\n <map-actions client_id="'+client_id+'"> \n <data_version>4</data_version> '
            CL_tags = '\n </map-actions>\n'
        else:
            if types == 'batch':
                types=types+'es'
            else:
                types = types+'s'
            if self.type:
                OP_tags = '<action type="'+types+'" map_pharmacy_ids="'+self.dep_code+'"> \n<'+types+'>\n'
            else:
                OP_tags = '<action type="'+types+'" datestart="'+self.date_start.strftime("%Y-%m-%dT%H:%M:%S")+ '" dateend="'+self.date_end.strftime("%Y-%m-%dT23:59:59")+'" map_pharmacy_ids="'+self.dep_code+'"> \n<'+types+'> \n'
            CL_tags ='</'+types+'> \n</action> \n'
        if openclose == 0:
            return OP_tags
        else:
            return CL_tags

    def get_Date(self):
        if self.type:
            LogIt('Выбранна первичная выгрузка')
            self.date_start = datetime.datetime.strptime(read_ini(self.conf, 'DATE_START'),"%d.%m.%Y")
            self.date_end = datetime.datetime.today()#datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")
        else:
            LogIt('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today()-datetime.timedelta(days=92)
            self.date_end =datetime.datetime.today()






