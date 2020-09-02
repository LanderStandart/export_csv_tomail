import dbf
import fdb
import configparser
import query
import create_query

config = configparser.ConfigParser()
config.read('./config.ini')
section = 'DB'
host = config.get(section, 'HOST')
database = config.get(section, 'PATH')

inn = config.get('BASE','INN')

conn = fdb.connect(host=host, database=database, user='sysdba', password='masterkey')

curs = conn.cursor()

#запрос к базе
def get_sql(sql,where=None,commit=None):
    if where is None:
        sql=sql
    else:
        sql=sql+where


  #проверка корректности запроса
    try:
        query = curs.execute(sql)
    except Exception as Error:
        Err = Error.args
        Errs = Err[0].split('- ')
        print(Err)
        Flag = search(Errs, 'Table unknown\n')
        if Flag > 0:
            return False,'Таблица не найдена\n'+Errs[Flag + 1]
        else:
            Flag = search(Errs, 'Token unknown ')
            if Flag > 0:
                print('Ошибка в запросе')
                print('Вероятная ошибка - '+Errs[Flag + 2])
                return False
        return

   #------------------------------

    result = []
    if commit is None:
        for i in query:
            result.append(list(i))
        return result
    else:
        conn.commit()
        return

#создание ДБФ
def create_dbf(filename,columns,sql,values1=None):


    table = dbf.Table(filename,columns,codepage='cp866')
    table.open(mode=dbf.READ_WRITE)
    if values1 is None:
        values = get_sql(sql)
    else:
        values = get_sql(sql)
        values.extend(values1)




    i = 0
    while i < len(values):
        datum = tuple(values[i])
        table.append(datum)
        i += 1
    table.close()


def search(list, n):
    for i in range(len(list)):

        if list[i] == n:

            return i

    return False

def clear_psql(sql):
    del_id = []
    for str in range(len(sql)):
        res = sql[str].find('/**')
        res2 = sql[str].find('SET SQL')
        len_str = len(sql[str])

        if res != -1 or len_str < 4 or res2 !=-1:
            del_id.append(str)

    del_id.sort(reverse=True)
    for i in del_id:
        del sql[i]
    return sql

#Справочник товаров
# SQL='update wares w set id = id where (select p.GOODS_ID from PR_ASNA_GET_GOODS(w.id) p) is null'
# get_sql(SQL)

#create_dbf('goods.dbf','id C(250); name C(250); producer C(250); country C(250); ean C(250)',query.SQL_WARES)

#Контрагенты
# SQL_AGENTS="select cast(a.id as varchar(255)) as ID, caption as name, coalesce(INN,'') as INN from agents a " \
#            "--inner join ASNA_G$PROFILES ga on ga.id = a.g$profile_id " \
#            "where  a.id > 0 --and ga.id is not null  "
    #  #Базовые контрагенты
datum1 = []
datum1.append(list(['1','Мелкооптовый покупатель',inn]))
datum1.append(list(['2','Розничный покупатель (ККМ)',inn]))
datum1.append(list(['3','Ввод остатков',inn]))
#create_dbf('ven2.dbf','id C(250); name C(250); inn C(250)',query.SQL_AGENTS,datum1)

sql=create_query.Create_ASNA_GOODS_TABLE

#Result = get_sql(create_query.Create_ASNA_GOODS_TABLE,None,'1')

#Создаем Таблицу
# for ee in create_query.Create_ASNA_GOODS_TABLE:
#     get_sql(ee,None,'1')

f = open('CREATE_ASNA_GOODS')
sql=f.read()
sql=sql.split('\n')
devide=';'
for i in range(len(sql)):
    if sql[i] == 'SET TERM ^ ;':
        devide = '^'
    if sql[i] == 'SET TERM ; ^':
        devide = ';'
    sql[i] = sql[i].replace(devide, '\n')

for i in range(len(sql)):
    if sql[i].find(';')-12:
        sql[i] = sql[i].replace(';', '',1)

for i in range(len(sql)):
    if sql[i].find('^')>-1:
        sql[i] = sql[i].replace('^', '',1)

sql = clear_psql(sql)
sql_text = " ".join(sql)


sql = sql_text.split('SET TERM')

sql_text = " ".join(sql)
sql = sql_text.split('\n')
sql = clear_psql(sql)
# sql_text = " \n".join(sql)





print(sql_text)


