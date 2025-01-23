import datetime
import calendar
import sys
sys.path.insert(0, "./engine")
from firebirdsql import Db
from system import System
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

DB = Db()
users = {'38':'Андрей','61':'Дима','75':'Саша М'}
programmers = {'69':'Игорь','15':'Коля','13':'Леша','1':'Слава'}
task_status = {'1':'Закрыта','0':'Открыта'}
task_project = {'6':'Автоматизация','7':'Доработка'}




def Get_Periods():
    today = datetime.datetime.today()
    current_year = today.year
    period = list()
    #month=1
    for month in range(1,today.month+1):
        mon = str(month) if len(str(month))==2 else f'0{month}'
        date_start_month = datetime.datetime.strptime(f'01.{mon}.{today.year}','%d.%m.%Y')
        date_end_month= datetime.datetime.strptime(f'{calendar.monthrange(today.year, month)[1]}.{mon}.{today.year}','%d.%m.%Y')
        period.append([date_start_month,date_end_month])
    return period

def Get_Count_Task(date_start,date_end,user_id,task_time='',task_project_id='',task='count_task'):
    sql=task
    val={'task_time':task_time,'date_start':date_start,'date_end':date_end,'user_id':user_id,'task_project_id':task_project_id}
    data1 = DB.get_from_base( sql, val)
    return data1

def Get_User_Task(user_id,task_time='',task_project_id='',task='count_task'):
    count =[]
    period = Get_Periods()
    for per in period:
        count.append(Get_Count_Task(date_start=datetime.datetime.strftime(per[0],'%d.%m.%Y'),
                       date_end=datetime.datetime.strftime(per[1],'%d.%m.%Y'),
                       user_id=user_id,
                       task_time=task_time,
                       task_project_id = task_project_id,
                       task=task             )[0][0])
    return count

# for user in users.keys():
#     us_count=Get_User_Task(user)
#     print(users[user])
#     print(us_count)


index = np.arange(6)
bw = 0.3

# plt.bar(index,Get_User_Task(61),bw,color='b')
# plt.bar(index+bw,Get_User_Task(38),bw,color='g')
# plt.bar(index+2*bw,Get_User_Task(75),bw,color='r')
# plt.xticks(index+bw,['Январь','Февраль','Март','Апрель','Май','Июнь'])
# plt.plot(Get_User_Task(61))
# plt.plot(Get_User_Task(38))
# plt.plot(Get_User_Task(75))
# data = {'Игорь': Get_User_Task(69,task='sum_time'),
#          'Коля': Get_User_Task(15,task='sum_time'),
#          'Леша': Get_User_Task(13,task='sum_time'),
#         'Слава': Get_User_Task(1,task='sum_time')}
data = {'Диана': Get_User_Task(54,task='sum_time'),
         'Наташа': Get_User_Task(59,task='sum_time'),
         'Новакова': Get_User_Task(63,task='sum_time'),
'Баженова': Get_User_Task(70,task='sum_time'),
'Олеся': Get_User_Task(76,task='sum_time'),
'Головизнина': Get_User_Task(79,task='sum_time'),
'Загребина': Get_User_Task(85,task='sum_time'),
        'Елена': Get_User_Task(67,task='sum_time')}

# data = {'Андрей': Get_User_Task(38,task='sum_time',task_time='and task.l_time>5'),
#         'Дима': Get_User_Task(61,task='sum_time',task_time='and task.l_time>5'),
#         'Саша': Get_User_Task(75,task='sum_time',task_time='and task.l_time>5')}

df = pd.DataFrame(data,index=['Январь','Февраль','Март','Апрель','Май','Июнь'])
df.plot(kind='bar')
plt.show()
#print(Get_Count_Task('01.06.2023','30.06.2023','61',task_project_id='and task.project_id=6'))




