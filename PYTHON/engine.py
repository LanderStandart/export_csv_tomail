import re


def clear_str(str):
    pattern = r'\||\«|\»|\,|\.|\s|\"'
    str1 = re.sub(pattern, ' ', str)
    str1 = str1.replace('  ', ' ')
    str1 = str1.replace('№ ', '№')
    return str1


def search(input, regex):
    test_str = ''.join(input)
    matches = re.finditer(regex, test_str, re.MULTILINE)
    for matchNum, match in enumerate(matches, start=1):
        result = ("{match}".format(matchNum=matchNum, start=match.start(), end=match.end(), match=match.group()))
        result = result.lstrip()
        result = result.rstrip()
        return result


# чистим мусор
def cl_str(input_string, pattern):
    """Очищаем входную строку от вхождения переменной pattern
    :param pattern: Содержит значения которые будем удалять из строки
    :param input_string: входная строка
    """
    if pattern is not None:
        if isinstance(pattern, str):
            pattern = re.compile(pattern)
            r = re.sub(pattern, '', input_string)
            return r
    else:  # если не нашли мусора
        return input_string


def ch_agent(input_string, pattern):
    test_str = ''.join(input_string)
    test_str1 = test_str.split()
    pattern = ' '.join(pattern)
    pattern = pattern.split()
    result = list(set(test_str1) & set(pattern))
    #result.reverse()
    result = ' '.join(result)
    return result

def check_from_base(input_string, data_db):
    for key in data_db:
       res = search(input_string,data_db[key]+'\s')
       if res is not None:
           return  data_db[key]
    return
