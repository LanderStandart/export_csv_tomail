from engine import Engine
Eng = Engine()

def get_from_file(filename):
    with open(filename) as file:
        result = file.read()
    return result


f = open('CREATE_ASNA_GOODS')
sql=f.read()
sql=sql.split('\n')
# devide=';'
# for i in range(len(sql)):
#     if sql[i] == 'SET TERM ^ ;':
#         devide = '^'
#     if sql[i] == 'SET TERM ; ^':
#         devide = ';'
#     sql[i] = sql[i].replace(devide, '\n')
# #
# for i in range(len(sql)):
#     if sql[i].find(';')-12:
#         sql[i] = sql[i].replace(';', '',1)
#
# for i in range(len(sql)):
#     if sql[i].find('^')>-1:
#         sql[i] = sql[i].replace('^', '',1)
#
# sql = Eng.clear_psql(sql)
# sql_text = " ".join(sql)
# sql = sql_text.split('SET TERM')
# sql_text = " ".join(sql)
# sql = sql_text.split('\n')
sql = Eng.clear_psql(sql)
sql_text = " \n".join(sql)
sql_text = sql_text.split(';')
print(sql_text)
# with open('query.txt','w') as file:
#     file.write(sql_text)
