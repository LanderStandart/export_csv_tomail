from system import System
import fdb, sys
import csv


class Db(System):
    def __init__(self, host=None, database=None):
        section = 'BASE_CONF'
        self.logger = self.Logs(__name__)
        self.host = System().read_ini(section, 'HOST') if not host else host
        self.database = System().read_ini(section, 'PATH') if not database else database
        self.conn = fdb.connect(host=self.host, database=self.database, user='sysdba', password='masterkey')
        self.curs = self.conn.cursor()

    def create_sql(self, string, module):
        s = System().get_File('./modules/' + module + '/scripts/', string)
        sq = s.split('^')
        for se in sq:
            self.get_sql(sql=se, commit=1)
            # print('se')

        self.logger.info('CREATE ->' + string[5])

        return

    def cheak_db(self, name1, type):
        return
        frm = inspect.stack()[1]
        mod = inspect.getmodule(frm[0])
        if not name1: return self.logger.error(f'Нет параметров для проверки - {type}')
        names = name1.split(',')
        for name in names:
            if type == 'TABLE':
                sql = f"select r.rdb$FIELD_id from RDB$RELATIONS r where r.rdb$relation_name='{name}'"
            elif type == 'PROCEDURE':
                sql = f"select r.rdb$procedure_id from RDB$PROCEDURES r where r.rdb$procedure_name='{name}'"
            elif type == 'TRIGGER':
                sql = f"select r.rdb$trigger_name from RDB$TRIGGERS r where r.rdb$trigger_name='{name}'"
            print(name)
            result = self.get_sql(sql)
            if result:
                print(result)
            else:
                print('Создаем' + name)
                self.create_sql(name, mod.__name__)

    # Запрос к базе с условием
    # Добавлена возможность выбрать результат будет списком или словарем с именами колонок
    def get_sql(self, sql, where=None, commit=None,res_dict=None):
        self.sql = sql
        self.commit = commit
        self.where = where
        if self.where:
            self.sql = self.sql + ' ' + self.where
        # query = self.curs.execute(self.sql)
        # self.logger.info('Запрос-\n'+self.sql)
        # проверка корректности запроса
        try:
            query = self.curs.execute(self.sql)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')
            self.logger.error(''.join(str(Err)))

            if Errs:
                if self.search(Errs, 'Table unknown\n'):
                    msg = 'Таблица не найдена\n'
                    sql_err = 'errTable'
                elif self.search(Errs, 'Procedure unknown\n'):
                    msg = 'Процедура не найдена\n'
                    sql_err = 'errProcedure'
                else:
                    self.logger.error('Ошибка в запросе')
                    self.logger.error('Вероятная ошибка - ' + Errs[2] + self.sql)
                    sql_err = 'errSql'
                # logger.error(msg)
                if 'errTable' in sql_err or 'errProcedure' in sql_err:
                    self.create_sql(Errs)
                    return self.get_sql(sql, where, commit)
                else:
                    sys.exit(sql_err)

        # Вывод результатов или проведение
        result = []
        names=[]
        if self.commit:
            self.conn.commit()
            return
        else:
            #  Get Name Fields
            for name in query.description:
                names.append(name[0])

            for i in query:
                #print(type(i))

                dict_value={obj : state for obj, state in zip(names, i)} if res_dict else list(i)
                #result.append(list(i))
                result.append(dict_value)
            #print(result)
            # LogIt(self.sql + 'Содержит ' + str(len(result)))
            self.conn.commit()
            if result:
                return result
            else:
                # logger.error(f' {self.sql }- Запрос вернул Пустоту')
                return result

    def search(self, list, n):
        for i in range(len(list)):

            if list[i] == n:
                return i
        return False

    def get_from_base(self, module, sql_file, val=None, profile='', sql_q=None,res_dict=None):
        path = f'./modules/{module}/sql{profile}/'
        self.SQL = System().get_File(path=path, file=sql_file) if sql_file else sql_q
        # self.SQL = System().get_File(path=path, file=sql_file)
        self.SQL = self.prepare_sql(self.SQL, values=val)
        data = self.get_sql(self.SQL, None, None,res_dict)
        return data

    def prepare_sql(self, sql, values=None):
        try:
            res = sql.format(**values) if values else sql

        except KeyError as Key:
            sys.exit(self.logger.error(f'Не задан параметр - {Key} \n в запросе \n {sql}'))

        return res

    def getsqltocsv(self, filename, module, sql_file, val=None, profile=None, header=None, profile_code=None,
                    delimeter=';', encoding='cp1251', quotechar="'", ext='.csv'
                    , dialect='excel', quota=None, commit=None):
        profile_q = 'sql_q' if profile else 'sql'
        path = f'./modules/{module}/{profile_q}/'

        self.filename = filename
        self.header = header
        self.profile_code = profile_code
        self.delimeter = delimeter
        self.quotechar = quotechar
        self.encoding = encoding
        self.ext = ext
        self.dialect = dialect

        res_row = []
        self.quota = quota
        self.logger.info('Create File:' + self.filename + self.ext)

        self.SQL = System().get_File(path=path, file=sql_file) if sql_file else sql_q
        self.SQL = self.prepare_sql(self.SQL, values=val)
        # query = self.curs.execute(self.sql)
        # проверка корректности запроса

        try:
            query = self.curs.execute(self.SQL)
        except Exception as Error:
            Err = Error.args
            Errs = Err[0].split('- ')
            self.logger.error(''.join(str(Err)))

            if Errs:
                if self.search(Errs, 'Table unknown\n'):
                    msg = 'Таблица не найдена\n'
                    sql_err = 'errTable'
                elif self.search(Errs, 'Procedure unknown\n'):
                    msg = 'Процедура не найдена\n'
                    sql_err = 'errProcedure'
                else:
                    self.logger.error('Ошибка в запросе')
                    self.logger.error('Вероятная ошибка - ' + Errs[2] + self.sql)
                    sql_err = 'errSql'
                # logger.error(msg)
                if 'errTable' in sql_err or 'errProcedure' in sql_err:
                    self.create_sql(Errs)
                    return self.get_sql(sql, where, commit)
                else:
                    sys.exit(sql_err)
        # Вывод результатов или проведение
        result = []

        try:
            with open(self.filename + self.ext, 'w', newline='', encoding=self.encoding) as f:
                writer = csv.writer(f, dialect=self.dialect, delimiter=self.delimeter, escapechar='~',
                                    quotechar=self.quotechar)
                if self.header is not None:
                    writer.writerow(self.header)
                for res_row in query:
                    writer.writerow(res_row)

            self.conn.commit()
        except:
            return 0
        else:
            return 1
