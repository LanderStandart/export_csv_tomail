from get_oz_client import query_with_fetchone
import engine

sql = 'SELECT id, upper(client_name)as client_name from zclients where status=0 and client_type=0'
sql_city = 'select c.ID, upper(c.CAPTION)  from CITIES c'
db_main = 'mysql-sinhro' #основная база SINHRO
db = 'mysql-udm-oz' #база общего заказа Удмуртия
res = query_with_fetchone(db, sql)
cities_db = query_with_fetchone(db_main, sql_city)
pat_str = r"\s(?:УЛ|ПЕР)\s+\w+\s(\w+\s\w+\s|\w+)(?:\s\d|\w+|\s|)"
pat_city = r'(?:\s|^)(?:П|Г|С|ПОС|ПГТ|Д)\s+\w{2,}'
pat_apteka = r'(?:АПТ\w+\s+|АПТ(?:\w+\s|\s)\ПУН\w+\s|А/П\s)(?:\№\d{1,3}|\d{1,3})'
clrs = r'\sГ\s|^Г\s|(\s(?:УЛ|ПЕР)\s)|^ГУП\sУР\s|ООО\sМНВП'
agents = ['АПТЕКИ','УДМУРТИИ','АЙБОЛИТ', 'СТАНДАРТ М','АСПЭК']


for key in res:
    str2 = res[key]
    city = ''
    street = ''
    str1 = engine.clear_str(str2)
    print('------------------')
    print(str1)
    apteka = engine.search(str1, pat_apteka)
    street = engine.search(str1, pat_str)
    city =   engine.search(str1, pat_city)

    if city is None:
        city = engine.check_from_base(str1, cities_db)
    str1 = engine.cl_str(str1, city)
    str1 = engine.cl_str(str1, street)
    str1 = engine.cl_str(str1, apteka)
    #чистим лишние символы оставшиеся от предыдущего поиска
    str1 = engine.cl_str(str1,clrs)

    agent = engine.ch_agent(str1, agents)

    str1 = engine.cl_str(str1, agent)

    print(str1)

    print(city, ';', street, ';', apteka,';', agent)
    print('------------------')

