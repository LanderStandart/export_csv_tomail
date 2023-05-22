import sys,datetime,os
import smtplib
from email import encoders
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from calendar import monthrange
sys.path.insert(0, "./engine")
from MySQL import Mysql
from system import System
from matplotlib import pyplot as plt




section = 'BASE_CONF'
path = System().read_ini(section, 'PATH_EXPORT')
toemail =System().read_ini(section,'toemail').split(',')
MYSQL = Mysql()

def getData():
    # data_start = datetime.datetime.now() - datetime.timedelta(days=30)
    # data_end = datetime.datetime.now()
    period = getDate()
    task = 'ratio'
    val = {'datestart': period['date_start'].strftime('%Y-%m-%d'),'dateend': period['date_end'].strftime('%Y-%m-%d')}
    data = MYSQL.get_from_base(__name__, task, val)
    return data

def getDate():
    month = System().read_ini(section, 'MONTH') if System().read_ini(section, 'MONTH') else datetime.datetime.today().month - 1
    year =   datetime.datetime.today().year
    last_day = str(monthrange(int(year), int(month))[1])
    date_start = datetime.datetime.strptime(f'01.{month}.{year}', '%d.%m.%Y')
    date_end = datetime.datetime.strptime(f'{last_day}.{month}.{year}', '%d.%m.%Y')
    period = {'date_start':date_start,'date_end':date_end}
    return period

def MailTo(filename):
  #  Archiv(filename, 'xls').zip_File()
    basename = os.path.basename(filename)
    from_addr ="fs@standart-n.ru"
    file_to_attach = filename
    to_emails = toemail
    msg = MIMEMultipart()
    msg["From"] = "fs@standart-n.ru"
    msg["Subject"] = 'Доли заказов по поставщикам'
    msg["To"] = ", ".join(to_emails)
    #msg.attach(MIMEText('text'))

    try:
        with open(file_to_attach, "rb") as fil:
            part = MIMEApplication(
                fil.read(),
                Name=basename
            )
        # After the file is closed
        part['Content-Disposition'] = 'attachment; filename="%s"' % basename
        msg.attach(part)
    except IOError:
        print(f"Ошибка при открытии файла вложения {file_to_attach}")

    try:
        smtp = smtplib.SMTP('192.168.67.235')
     #   smtp.starttls()
        smtp.ehlo()
        smtp.login('fs', 'teric0ls1')
        smtp.sendmail(from_addr, to_emails, msg.as_string())
    except smtplib.SMTPException as err:
        print('Что - то пошло не так...')
        raise err
    finally:
        smtp.quit()


if System().planner() == 0:
    exit()

data = getData()
Supplier=[]
Summ = []
for row in data:
    print(row)
    Supplier.append(row[0])
    Summ.append((row[1]))

# # Creating plot
period = getDate()
date_start = period['date_start'].strftime('%Y-%m-%d')
date_end = period['date_end'].strftime('%Y-%m-%d')
fig = plt.figure(figsize=(10, 7))
patches=plt.pie(Summ, labels=Supplier, autopct='%1.1f%%',counterclock=True, pctdistance=1,textprops={'fontsize': 8})
plt.title(f'Доли поставщиков в заказах {date_start} - {date_end}')
plt.legend(Supplier,fontsize=8,loc=2,bbox_to_anchor=(-0.4, 1.14))

#
# # show plot
#plt.show()
plt.savefig(f'{path}ratio_supplier_chart.png')
MailTo(f'{path}ratio_supplier_chart.png')