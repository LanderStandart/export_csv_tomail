from ftplib import FTP
import configparser

config = configparser.ConfigParser()
config.read('./config.ini')
section = 'FTP_CONF'
host = config.get(section, 'FTP_HOST')
ftp_user = config.get(section, 'FTP_USER')
ftp_password = config.get(section, 'FTP_PASSWORD')
print(host)

ftp = FTP()
ftp.connect (host)
ftp.login(ftp_user,ftp_password)
ftp.set_pasv(False)
file_name = 'a-filename.txt'
ftp.storlines("STOR " + file_name, open(file_name, 'rb'))
ftp.quit()


