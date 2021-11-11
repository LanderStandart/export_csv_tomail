#  Autor by Lander (c) 2021. Created for Standart-N LLT
from engine import FTP_work,Archiv,Db,os,existPath,read_ini,get_File,put_file,my_log,XML
import datetime
import itertools
from pathlib import Path
import sys
import os
logger = my_log.get_logger(__name__)
class Sozvezdie(Db):
    def __init__(self,profile_id=None):
        self.DB = Db()
        self.path_ini=__name__
        self.profile_id = profile_id
        self.conf = 'SOZVEZDIE'
        self.alone = str(read_ini('BASE_CONF', 'ALONE'))
        self.path = read_ini(self.conf, 'PATH_EXPORT',self.path_ini)
        #CLIENT_ID пока получаем из ini но думаю для сети нужно привязку к профиль ИД
        self.client_id = read_ini(self.conf, 'CLIENT_ID',self.path_ini)
        #Тип выгрузки 1- первичная 0-текущая
        self.type = int(read_ini(self.conf, 'TYPE',self.path_ini))
        existPath(self.path)

        if int(read_ini('BASE_CONF', 'ALONE'))==1:
            self.dep_code =read_ini(self.conf, 'DEP_CODE',self.path_ini)
        else:
            self.dep_code = profile_id




    def get_Filename(self):#формируем имя файла
        #{datetime}_{code_client}_{dep_code}_bat.xml  = 2021061110315_1_bat.xml
        self.filename=f"{self.path}{self.date_end.strftime('%Y%m%d%H%M%S')}_{self.client_id}_{self.dep_code}_bat.xml"
        logger.info('Формируем файл - '+self.filename)
        return self.filename

    def prepare_sql(self,sql,pid,da_strt,da_end,header=None):
        sql1 = sql.replace(':pid', str(pid))
        sql1 = sql1.replace(':date_start', "'" + da_strt.strftime('%d.%m.%Y:00:00:00') + "'")

        sql1 = sql1.replace(':datestart1', "'" + (da_strt + datetime.timedelta(days=1)).strftime('%d.%m.%Y:00:00:00') + "'") if self.type else sql1.replace(':datestart1', "'" + da_strt.strftime('%d.%m.%Y:00:00:00') + "'")
        sql1 = sql1.replace(':datestart2', "'" + da_strt.strftime('%d.%m.%Y:23:59:59') + "'")
        sql1 = sql1.replace(':date_end', "'" + da_end.strftime('%d.%m.%Y:23:59:59') + "'")
        sql1 = sql1.replace(':departmentcode',  str(self.dep_code) )
        #Если сеть
        if self.alone !='1':
            sql1 = sql1.replace('--', '')

            sql1 = sql1.replace(':profile_id', str(self.profile_id))
            sql1 = sql1.replace("(select p.param_value  from params p where p.param_id='ORG_NAME_SHORT')as map_pharmacy_name,",f"(select caption from g$profiles g where g.id={str(self.profile_id)})as map_pharmacy_name,")
#        LogIt(sql1)
        return sql1


    def create_export(self,root,element,data,head_file,sql,date_start=None,date_end=None,gl_root=None,first=None):
        #LogIt(sql)
        if self.type:
            attrib = {"type": root,  "map_pharmacy_ids": self.dep_code}
        else:
            attrib={"type":root,"datestart":self.date_start.strftime("%Y-%m-%dT%H:%M:%S"),"dateend":self.date_end.strftime("%Y-%m-%dT23:59:59"),"map_pharmacy_ids":self.dep_code}

        if gl_root is not None:
            self.rt=XML().add_element(root=gl_root,element='action',attrib=attrib)
            self.el=XML().add_element(root,self.rt)
        sql1 = get_File(path='./modules/sozvezdie/sql/', file=sql)


        x = 0
        for pid in data:

            da_strt = self.date_start if type(pid)==int else pid[1]
            da_end = self.date_end if type(pid)==int  else pid[1]
            #da_end = self.date_start if date_end else da_end
            pid = str(pid) if type(pid) == int else pid[0]
            #LogIt(sql1)
            sql2 = self.prepare_sql(sql1, pid, da_strt,da_end,header=head_file)
            #LogIt(sql2)
            p = self.DB.get_sql(sql2)

            heads = get_File('./modules/sozvezdie/head/', head_file)
            heads = heads.split('\n')
            # if date_start and da_strt.strftime('%d.%m.%Y:00:00:00') == date_start.strftime('%d.%m.%Y:00:00:00'):
            #     print(head_file, da_strt, da_end, date_start)
            #     continue

            distr_id=[]
            distr_id1=[]
            for row in p:

                el1 = XML().add_element(element, self.el)

                if 'move_first' in sql :
 #                   print (row[2], row[21])
                    self.doc_dates1.append([row[2], datetime.datetime.strptime(read_ini(self.conf, 'DATE_START',self.path_ini),"%d.%m.%Y")])
                    if row[1] in distr_id1:
                        logger.error('Дубль в первичке- ' + str(row))
                        continue
                    distr_id1.append(row[1])
                elif 'move' in sql:
                    move_data= datetime.datetime.strptime(row[21].strftime("%d.%m.%Y"),"%d.%m.%Y")
                    if self.type and row[21]==datetime.datetime.strptime(read_ini(self.conf, 'DATE_START',self.path_ini),"%d.%m.%Y"):
                        #print(row[21],move_data,'eee',row[2])
                        continue
                    if row[1] in distr_id:
                        logger.error('Дубль - '+str(row))
                        continue
                    distr_id.append(row[1])
                    move_data= datetime.datetime.strptime(row[21].strftime("%d.%m.%Y"),"%d.%m.%Y")
                    #print(type(row[21]),row[21],type(self.date_start.strftime('%Y-%m-%d')),type(move_data),row[2])
                    self.doc_dates.append([row[2], move_data])
                if 'batch' in sql:
                    self.batch_id.append(row[0])


                y = 0
                for head in heads:
 #помещаем значение из строки запроса по колонкам в переменную
                    exp_data = row[y]
                    if row[y]==None:
                        row[y]=''
                    if 'base' in head_file and y==4 and row[4]<0:
                        logger.info(str(row))

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
        self.get_Filename()
       # raise SystemExit('nnn'+self.filename)
        part_id=[]
        part_id1=[]
        self.batch_id=[]

        #Если первичная выгрузкв
        if self.type:
            #Одиночная точка
            if self.alone =='1':
                sql = f"select  part_id from warebase_d w where w.doc_commitdate='{self.date_start.strftime('01.%m.%Y')}' and w.quant>0.01 " \
                      f" union all " \
                      f"SELECT   part_id from docs d left join doc_detail dd on dd.doc_id=d.id where d.docdate " \
                      f"between '{self.date_start.strftime('01.%m.%Y:00:00:00')}' and '{self.date_start.strftime('01.%m.%Y:23:59:00')}' and part_id is not null  "

                where=''
               # where = f" where d.docdate <= '{self.date_start.strftime('%d.%m.%Y:23:59:00')}'and part_id is not null   group by dd.part_id having (abs(sum(dd.quant))>0.001)"
            else:
             # Сеть аптек
                sql = f"select part_id from warebase_d w where w.doc_commitdate='{self.date_start.strftime('01.%m.%Y')}' and w.quant>0.01 and w.g$profile_id= {self.profile_id} " \
                f" union all " \
                f"SELECT  part_id from docs d left join doc_detail dd on dd.doc_id=d.id and dd.g$profile_id= d.g$profile_id where d.docdate " \
                f"between '{self.date_start.strftime('01.%m.%Y:00:00:00')}' and '{self.date_start.strftime('01.%m.%Y:23:59:00')}' and part_id is not null and d.g$profile_id= {self.profile_id} "
                where =''
               # where = f" where w.doc_commitdate='{self.date_start.strftime('01.%m.%Y')}' and w.quant>0.01 and w.g$profile_id= {self.profile_id} "
               #where =  f" where d.docdate < '{self.date_start.strftime('%d.%m.%Y:00:00:00')}'and part_id is not null and d.g$profile_id= {self.profile_id}  group by dd.part_id having (abs(sum(dd.quant))>0.001)"
            print(sql,where)
            p = self.DB.get_sql(sql, where)
            for po in p:
                part_id1.append(po[0])
            part_id1 = list(set(part_id1))
            self.date_start=self.date_start + datetime.timedelta(days=1)	
        #Регулярная выгрузка
        if self.alone =='1':
        # Одиночная точка
            sql = 'SELECT  part_id from docs d left join doc_detail dd on dd.doc_id=d.id'
            where = f" where d.docdate between '{self.date_start.strftime('%d.%m.%Y:00:00:00')}' and '{self.date_end.strftime('%d.%m.%Y:23:59:59')}' and part_id is not null "
        # Сеть аптек
        else:
            sql = 'SELECT distinct part_id from docs d left join doc_detail dd on dd.doc_id=d.id and dd.g$profile_id= d.g$profile_id'
            where = f" where d.docdate between '{self.date_start.strftime('%d.%m.%Y:00:00:00')}' and '{self.date_end.strftime('%d.%m.%Y:23:59:59')}' and part_id is not null  and d.g$profile_id= {self.profile_id} "
        print(sql,where)
        p = self.DB.get_sql(sql, where)
        for po in p:
            part_id.append(po[0])
        part_id = list(set(part_id))
        parts = list(set(part_id+part_id1))
        logger.info(str(len(parts)))
        #Create XML
        if self.type:
            self.date_start=self.date_start - datetime.timedelta(days=1)
        gl_root=XML().add_root(root='map-actions',attrib={"client_id":read_ini(self.conf, 'CLIENT_ID',self.path_ini)})
        XML().add_element(element='data_version',root=gl_root,data='6')

        self.create_export(gl_root=gl_root,root='batches',element='batch',data=parts,head_file='goods',sql='action_batch')
        logger.info('distr')
        self.doc_dates=[]
        self.doc_dates1 = []
   
        if self.type:
            logger.info('Собираю первичные движения')
            self.create_export(gl_root=gl_root,root='distributions', element='distribution', data=parts, head_file='move', sql='action_move_first')
            self.create_export(root='distributions', element='distribution', data=part_id,head_file='move', sql='action_move')
        else:
            self.create_export(gl_root=gl_root,root='distributions', element='distribution', data=part_id, head_file='move', sql='action_move')

        docs = self.doc_dates
        docs.sort()
        docs2 = list(docs for docs,_ in itertools.groupby(docs) )
        docs1= self.doc_dates1
        docs1 = list(docs1 for docs1, _ in itertools.groupby(docs1))
        self.check_move(part_id1,docs1)
        #LogIt(str(docs2))
        logger.info('remnant')
        if self.type:

            self.create_export(gl_root=gl_root, root='remnants', element='remnant', data=docs1, head_file='base', sql='action_remnant_first',date_end='1')
            self.create_export(gl_root=None,root='remnants',element='remnant', data=docs2, head_file='base', sql='action_remnant',date_start=self.date_start)
        else:
            self.create_export(gl_root=gl_root, root='remnants', element='remnant', data=docs2, head_file='base', sql='action_remnant')

        self.check_batch(self.batch_id,parts)
        XML().save_file(root=gl_root,filename=self.filename)

        fn  = self.filename.replace('./', '')
        fn = fn.replace('/',"\\")
        fn1=fn.split('.')
        pf = Path(os.path.abspath(os.curdir) +'/'+ fn1[0]+'.zip')

        Archiv(fn1[0] ,fn1[1]).zip_File()

        pf.rename(Path(pf.parent,"{}.{}".format(pf.stem,'tmp')))
    #    FTP_work(self.conf).upload_FTP(self.filename+'.tmp',extpath=str(read_ini(self.conf, 'FTP_PATH')),isbynary=True,rename=True)
        FTP_work(self.conf).upload_FTP('./'+fn1[0]+'.tmp',extpath=str(read_ini(self.conf, 'FTP_PATH',self.path_ini)),isbynary=True,rename=True)
#,extpath=str(read_ini(self.conf, 'FTP_PATH'))
        logger.info('END')




    def get_Date(self):
        if self.type:
            logger.info('Выбранна первичная выгрузка')
            self.date_start = datetime.datetime.strptime(read_ini(self.conf, 'DATE_START',self.path_ini),"%d.%m.%Y")
            self.date_end =datetime.datetime.today()-datetime.timedelta(days=1)
#datetime.datetime.strptime(read_ini(self.conf, 'DATE_END'),"%d.%m.%Y")#
        else:
            logger.info('Выбрана текущая выгрузка')
            self.date_start = datetime.date.today()-datetime.timedelta(days=92)
            self.date_end =datetime.datetime.today()-datetime.timedelta(days=1)


    def check_move(self,parts,docs):
        for part in parts:
            # if part not in docs: print(part)
                good = 0
                for doc in docs:
                    good = good+ doc.count(part)
                if not good:
                    logger.info(str(part)+'- нет выгрузки')
             

    def check_batch(self,batch,parts):
        #batch_clear = list(batch for batch, _ in itertools.groupby(batch))
        result = [x for x in parts if x not in set(batch)]
        if result:
            logger.error(str(result)+' - нет партий')





