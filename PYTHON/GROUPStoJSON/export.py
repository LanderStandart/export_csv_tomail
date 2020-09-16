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
result = lan_fdb.get_sql(curs, sql)
res=[]
chld=[]
for line in result:
    where = ' where g.parent_id='+str(line[0])
    child = lan_fdb.get_sql(curs,sql_cl,where)
    for lin in child:
        chld.append({"id":lin[0],"name":lin[2]})
    res.append({"id":line[0],"name":line[2],"children":chld})
    chld=[]
#print(res)

with open('app.json', 'w', encoding='utf-8') as f:
     json.dump(res, f, ensure_ascii=False, indent=4)

