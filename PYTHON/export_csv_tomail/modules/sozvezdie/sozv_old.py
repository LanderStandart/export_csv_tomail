#  Autor by Lander (c) 2021. Created for Standart-N LLT
# формируем заголовок файла
self.put_file(self.file_name, self.XMLtemplates(client_id=self.client_id, openclose=0))
# формируем Партии товара
if self.type:
    sql = "execute procedure PR_SOZVEZDIE_ACTION_BATCH('" + self.dep_code + "','" + self.date_start.strftime(
        '%d.%m.%Y:00:00:00') + "','" + \
          self.date_end.strftime('%d.%m.%Y:23:59:59') + "',1)"
    # self.DB.get_sql(sql,commit=1)

sql = "execute procedure PR_SOZVEZDIE_ACTION_BATCH('" + self.dep_code + "','" + self.date_start.strftime(
    '%d.%m.%Y:00:00:00') + "','" + \
      self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
# self.DB.get_sql(sql, commit=1)
sql = "select XML from SOZVEZDIE_ACTION_BATCH1 group by xml"
self.put_ex_file(types='batch', sql=sql)

# формируем Движение товара
if self.type:
    sql = "execute procedure PR_SOZVEZDIE_ACTION_MOVE('" + self.dep_code + "','" + self.date_start.strftime(
        '%d.%m.%Y:00:00:00') + "','" + \
          self.date_start.strftime('%d.%m.%Y:00:00:10') + ",'" + self.date_start.strftime('%d.%m.%Y:00:00:10') + "',1)"
    # self.DB.get_sql(sql,commit=1)
sql = "execute procedure PR_SOZVEZDIE_ACTION_MOVE('" + self.dep_code + "','" + self.date_start.strftime(
    '%d.%m.%Y:00:00:11') + "','" + \
      self.date_end.strftime('%d.%m.%Y:23:59:59') + ",'" + self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
# self.DB.get_sql(sql, commit=1)
sql = "SELECT XML FROM SOZVEZDIE_ACTION_MOVE   group by insertdt, xml"
self.put_ex_file(types='distribution', sql=sql)

# формируем Остатки
if self.type:
    sql = "execute procedure PR_SOZVEZDIE_ACTION_REMHANT('" + self.dep_code + "','" + self.date_start.strftime(
        '%d.%m.%Y:00:00:00') + "','" + \
          self.date_start.strftime('%d.%m.%Y:23:59:59') + "',1)"
    # self.DB.get_sql(sql,commit=1)
    self.date_start = self.date_start + datetime.timedelta(days=1)
sql = "execute procedure PR_SOZVEZDIE_ACTION_REMHANT('" + self.dep_code + "','" + self.date_start.strftime(
    '%d.%m.%Y:00:00:00') + "','" + \
      self.date_end.strftime('%d.%m.%Y:23:59:59') + "',0)"
# self.DB.get_sql(sql, commit=1)
sql = "select XML from SOZVEZDIE_ACTION_REMHANT group by xml"
self.put_ex_file(types='remnant', sql=sql)
self.put_file(self.file_name, self.XMLtemplates(client_id=self.client_id, openclose=1))


def put_ex_file(self, types, sql):
    put_file(self.file_name, self.XMLtemplates(types=types, client_id=self.client_id, openclose=0))
    rez = self.DB.get_sql(sql)
    for i in rez:
        for y in i:
            put_file(self.file_name, str(y))
    put_file(self.file_name, self.XMLtemplates(types=types, client_id=self.client_id, openclose=1))


def XMLtemplates(self, client_id, openclose, types=None):
    if types is None:
        OP_tags = '<?xml version="1.0" encoding="WINDOWS-1251"?>\n <map-actions client_id="' + client_id + '"> \n <data_version>4</data_version> '
        CL_tags = '\n </map-actions>\n'
    else:
        if types == 'batch':
            types = types + 'es'
        else:
            types = types + 's'
        if self.type:
            OP_tags = '<action type="' + types + '" map_pharmacy_ids="' + self.dep_code + '"> \n<' + types + '>\n'
        else:
            OP_tags = '<action type="' + types + '" datestart="' + self.date_start.strftime(
                "%Y-%m-%dT%H:%M:%S") + '" dateend="' + self.date_end.strftime(
                "%Y-%m-%dT23:59:59") + '" map_pharmacy_ids="' + self.dep_code + '"> \n<' + types + '> \n'
        CL_tags = '</' + types + '> \n</action> \n'
    if openclose == 0:
        return OP_tags
    else:
        return CL_tags

