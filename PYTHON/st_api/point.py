import fdb
from flask import abort
# Подключение к БД
class Db:
    def __init__(self):
        self.host = 'LOCALHOST'
        self.database = 'E:/TMS/export_csv_tomail/PYTHON/st_api/db/base.fdb'
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()

    # Запрос к базе с условием
    def get_sql(self, sql, where=None, commit=None):
        self.sql = sql
        self.commit = commit
        self.where = where
        if self.where:
            self.sql = self.sql + ' ' + self.where
        # query = self.curs.execute(self.sql)
        # logger.info('Запрос-'+self.sql)
        # проверка корректности запроса
        try:
            query = self.curs.execute(self.sql)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')


            if Errs:
                if self.search(Errs, 'Table unknown\n'):
                    msg = 'Таблица не найдена\n'
                    sql_err = 'errTable'
                elif self.search(Errs, 'Procedure unknown\n'):
                    msg = 'Процедура не найдена\n'
                    sql_err = 'errProcedure'
                else:

                    sql_err = 'errSql'
                # logger.error(msg)
                if 'errTable' in sql_err or 'errProcedure' in sql_err:
                    self.create_sql(Errs)
                    return self.get_sql(sql, where, commit)
                else:
                    sys.exit(sql_err)

        # Вывод результатов или проведение
        result = []
        if self.commit:
            self.conn.commit()
            return
        else:

            for i in query:
                result.append(list(i))

            # LogIt(self.sql + 'Содержит ' + str(len(result)))
            self.conn.commit()
            if result:
                return result
            else:
                logger.error(f' - Запрос вернул Пустоту')
                return result

    def get_from_base(self, module, sql_file: str, val=None, profile=''):
        path = f'./sql/'
        SQL = get_File(path=path, file=sql_file)
        SQL = self.prepare_sql(SQL, values=val)
        # logger.info(SQL)
        data = self.get_sql(SQL, None, None)
        return data

    def prepare_sql(self, sql, values=None):
        try:
            res = sql.format(**values) if values else sql

        except KeyError as Key:
            sys.exit(logger.error(f'Не задан параметр - {Key} \n в запросе \n {sql}'))

        return res

def read_all():
    DB=Db()
    points = DB.get_sql('select * from EX_POINT_LOG')
    return points

def create(point):
    pointid = point.get("pointid")
    pointname = point.get("pointname")
    exportname = point.get("exportname")
    status = point.get("status")
    DB = Db()
    DB.get_sql(f"INSERT INTO EX_POINT_LOG (POINT_ID,POINT_NAME,EXPORT_NAME,STATUS) values ({pointid},'{pointname}','{exportname}','{status}')",commit=True)



