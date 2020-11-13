

#запрос к базе
def get_sql(curs,sql,where=None,commit=None):
    """

    :param sql: Запрос
    :param where: Условие
    :param commit: требуется ли коммит
    :return: Список результатов
    """
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

def search(list, n):
    for i in range(len(list)):

        if list[i] == n:

            return i

    return False