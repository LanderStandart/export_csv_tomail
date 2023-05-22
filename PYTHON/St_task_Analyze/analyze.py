from engine import Db,my_log
import pymorphy2
import re
from string import punctuation
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer


logger = my_log.get_logger(__name__)

def f_tokenizer(s):
    morph = pymorphy2.MorphAnalyzer()

    s = ''.join(c for c in s if c not in punctuation)
    text=s
    words=[]
    for word in text.split(u' '):
        word = re.sub("[\\r|\\n]",' ',word)
        if re.match('([А-Яа-я]+)', word):
            word = morph.parse(word)[0].normal_form
            words.append(word)
    return words


def get_task():
    sql_name = 'gettask'
    txt = []
    data = Db().get_from_base(sql_file=sql_name)
    for ee in data:
        str1 = ' '.join([str(e) for e in ee])
        txt.append(str1)
        str1=''
    return txt# (''.join(txt))

text =get_task()

for word in text:
    # print(word)
    print(f_tokenizer(word))



