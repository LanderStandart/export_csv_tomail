#from read_db_configs import read_db_config
#print(read_db_config(section='mysql-sinhro'))
#print(read_db_config(section='mysql-udm-oz'))

from mysql.connector import MySQLConnection, Error
from read_db_configs import read_db_config

def query_with_fetchone(db,sql):
    try:
        dbconfig = read_db_config(section=db)
        conn = MySQLConnection(**dbconfig)
        cursor = conn.cursor()
        cursor.execute(sql)
        agents = dict()
        row = cursor.fetchone()

        while row is not None:
            #print(row[1])
            agents[row[0]]=row[1]
            row = cursor.fetchone()

    except Error as e:
        print(e)

    finally:
        return(agents)
        cursor.close()
        conn.close()

if __name__ == '__main__':
    query_with_fetchone()
    
