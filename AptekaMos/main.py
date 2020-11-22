import json
import os
class Assort_item:
    def __init__(self,org_id,org_chenum,qtty,item_id,item_name,price,remark,drug_id=0,
                 delivery=0,reserv=0,preorder=0,payonline=0,limited=0,action=0,bycard=0):
        self.org_id = org_id # код аптеки aptekamos
        self.org_chenum = org_chenum # внутренний код аптеки если не заполнено будет org_id
        self.drug_id = drug_id #код ЕГК
        self.price = price
        self.delivery = delivery #признак доставки
        self.reserv = reserv
        self.preorder = preorder
        self.payonline = payonline
        self.limited = limited
        self.action = action
        self.bycard = bycard
        self.qtty = qtty
        self.item_id = item_id #Внутренний код упаковки скорее карточки товара
        self.item_name = item_name #Наименование товара
        self.remark = remark
    def writeJson(self):
        self.json_str = {"org_id":self.org_id,"org_chenum":self.org_chenum,"drug_id":self.drug_id,
                         "price":self.price,"delivery":self.delivery,"reserv":self.reserv,
                         "preorder":self.preorder,"payonline":self.payonline,"limited":self.limited,
                         "action":self.action,"bycard":self.bycard,"qtty":self.qtty,"item_id":self.item_id,
                         "item_name":self.item_name,"remark":self.remark}
        with open("data_file.json","a") as write_file:
            json.dump(self.json_str,write_file)

os.unlink('data_file.json')

G = Assort_item(1,2,4,'11234','Парацетамол',1300,'').writeJson()
G = Assort_item(1,2,4,'11234','Витамины',2300,'').writeJson()


