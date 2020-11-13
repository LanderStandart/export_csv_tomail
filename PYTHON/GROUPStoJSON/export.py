import declare
import fdb
import lan_fdb
import json

# init connect to database
conn = fdb.connect(host=declare.host, database=declare.db_file, user='sysdba', password='masterkey')
curs = conn.cursor()

#sql = "select id,parent_id,caption from groups g where g.grouptable containing('PARTS')and g.id<>-8 order by g.parent_id,g.id"
sql = "select id,parent_id,caption from groups g where " \
      "g.grouptable containing('PARTS') and g.parent_id=-8"
sql_cl = "select id,parent_id,caption from groups g"

def get_child(group_id=None):
    wheres = ' where g.parent_id='+group_id
    g_child = lan_fdb.get_sql(curs,sql_cl,wheres)
    return g_child


result = lan_fdb.get_sql(curs, sql)
res=[]
chld=[]
chld1=[]
chld2=[]
for line in result:
    child = get_child(str(line[0]))
    for lin in child:
        child1 = get_child(str(lin[0]))
        for lin1 in child1:
            child2 = get_child(str(lin1[0]))
            for lin2 in child2:
                chld2.append({"id": lin2[0], "name": lin2[2], "children": ''})
            chld1.append({"id": lin1[0], "name": lin1[2], "children": chld2})
            chld2=[]
        chld.append({"id":lin[0],"name":lin[2],"children":chld1})
        chld1=[]

    res.append({"id":line[0],"name":line[2],"children":chld})
    chld=[]
# print(res)
#
with open('group.json', 'w', encoding='cp1251') as f:
     json.dump(res, f, ensure_ascii=False, indent=4)
file_name ='group.json'
ftp = FTP()
ftp.connect('185.146.3.180', '21')

ftp.login('admin_integration', 'gWPz9O2X8Z')

ftp.set_pasv(True)
ftp.storlines("STOR " + file_name, open(file_name, 'rb'))
ftp.quit()


