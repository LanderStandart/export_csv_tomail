import configparser
config = configparser.ConfigParser()
config.read('./config.ini')
org_code = config.get('BASE', 'ORG_CODE')

#Запрос списка контрагентов
SQL_AGENTS="select cast(a.id as varchar(255)) as ID, caption as name, coalesce(INN,'') as INN from agents a " \
           "--inner join ASNA_G$PROFILES ga on ga.id = a.g$profile_id " \
           "where  a.id > 0 --and ga.id is not null  "

#Запрос товаров
SQL_WARES='select id, MGN_NAME as name, PRODUCER, COUNTRY, EAN from ASNA_GOODS where ACTUAL = 1 order by MGN_NAME'
#SQL_WARES="select w.id,w.mgn_name,w.izg_id,w.country_id,w.barcode from wares w where sname is not null and sname <>'' order by MGN_NAME "

#Запрос Движения
SQL_MOVE="select "+org_code+"||'_'||'ga.asna_code'||'_'||replace(cast(current_date as varchar(255)),'-','')||'T'" \
         "||replace(left(cast(current_time as varchar(255)),5),':','')||'.txt' as filename,"\
         "cast(dd.id as varchar(255))||'_'||cast(dd.g$profile_id as varchar(255)) as ID,"\
         "cast(d.id as varchar(255))||'_'||cast(d.g$profile_id as varchar(255)) as DOC_ID"\
         " from doc_detail dd " \
         "inner join docs d on dd.doc_id = d.id and dd.g$profile_id = d.g$profile_id"