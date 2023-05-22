from  engine import System

class Export(System):
    def __init__(self):
        self.logger = System.get_logger(__name__)

    def PressKey(self,date_start,date_end,path):
        self.sql_name = 'move'
        self.val = {'doc_type':'1','date_start':date_start,'date_end':date_end}
        self.path=path
        self.createFile(self.sql_name,self.val,'button1')


    def PressKey2(self,date_start,date_end,path):
        self.sql_name = 'move'
        self.val = {'doc_type': '3,4,5,6,10,17,63', 'date_start': date_start, 'date_end': date_end}
        self.path = path
        self.createFile(self.sql_name, self.val,'button2')

    def PressKey3(self,date_start,date_end,path):
        self.sql_name = 'parts'
        self.val = {'doc_type': '3', 'date_start': date_start, 'date_end': date_end}
        self.path = path
        self.createFile(self.sql_name, self.val,'button3')

    def createFile(self, sql_name, val,filename):
        self.logger.info(f'{sql_name}_{val}')

        self.data = self.DB.get_from_base(__name__, sql_name, val)
        head = self.get_File(f'./head/', sql_name).split('\n')

        System.create_dbf(self,f'{self.path}{filename}.dbf', head, self.data)


