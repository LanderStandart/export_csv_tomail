#  Autor by Lander (c) 2020. Created for Standart-N LLT
from MyUtils import Db,CSV_File,Archiv,FTP_work
class Iteka():
    def __init__(self):
        self.DB = Db()
        self.SQL = "select w.sname,w.price, w.scountry, w.sizg, w.quant, w.ware_id from warebase w " \
                     "inner join doc_detail dd on dd.part_id=w.part_id " \
                     "inner join docs d on d.id=dd.doc_id and d.commitdate between '$datestart' and current_timestamp"
        

