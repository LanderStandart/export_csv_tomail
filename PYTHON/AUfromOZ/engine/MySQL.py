import pymysql
from system import read_ini,my_log,get_File

logger = my_log.get_logger(__name__)
class Mysql:
    def __init__(self):
        section = 'MYSQL'
        self.host =read_ini(section, 'HOST')
        self.base = read_ini(section, 'BASE')
        self.user = read_ini(section, 'USER')
        self.passw = read_ini(section, 'PASS')

        self.conn = pymysql.connect(host=self.host, user=self.user, password=self.passw, db=self.base,charset='cp1251')
        self.curs = self.conn.cursor()

#Запрос к базе с условием
    def get_sql(self,sql,where=None,commit=None):
        self.sql=sql
        self.commit = commit
        self.where = where
        if self.where:
            self.sql = self.sql + ' '+self.where
        # query = self.curs.execute(self.sql)
        #logger.info('Запрос-'+self.sql)
     # проверка корректности запроса
        try:
            query = self.curs.execute(self.sql)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')
            logger.error(''.join(str(Err)))

            if Errs:
                if self.search(Errs, 'Table unknown\n'):
                    msg='Таблица не найдена\n'
                    sql_err='errTable'
                elif self.search(Errs, 'Procedure unknown\n'):
                    msg='Процедура не найдена\n'
                    sql_err='errProcedure'
                else:
                    logger.error('Ошибка в запросе')
                    logger.error('Вероятная ошибка - ' + Errs[2]+self.sql)
                    sql_err='errSql'
                #logger.error(msg)
                if 'errTable' in sql_err or 'errProcedure' in sql_err:
                    self.create_sql(Errs)
                    return self.get_sql(sql,where,commit)
                else:
                    sys.exit(sql_err)

        # Вывод результатов или проведение
        result = []
        if self.commit:
            self.conn.commit()
            return
        else:

            data = self.curs.fetchall()

            for i in data:

                result.append(list(i))

            #LogIt(self.sql + 'Содержит ' + str(len(result)))
            self.conn.commit()
            return result

    def get_from_base(self, module,sql_file:str,val=None,profile=''):
        path=f'./sql{profile}/'
        SQL = get_File(path=path, file=sql_file)
        SQL=self.prepare_sql(SQL,values=val)
        #logger.info(SQL)
        data=self.get_sql(SQL,None,None)
        return data

    def prepare_sql(self, sql, values=None):
        try:
            res = sql.format(**values) if values else sql

        except KeyError as Key:
            sys.exit(logger.error(f'Не задан параметр - {Key} \n в запросе \n {sql}'))

        return res
