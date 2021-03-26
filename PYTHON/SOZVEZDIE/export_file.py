class Goods:
    def __init__(self,map_batch_id,map_pharmacy_id,map_pharmacy_name,nomenclature_id,map_nomenclature_name,map_product_code,map_product_name,producer_id,
                 map_producer_code,map_producer_name,producer_country_id,map_producer_country_code,map_producer_country_name,map_supplier_code,map_supplier_tin,
                 supplier_name,batch_doc_date,batch_doc_number,purchase_price_nds,purchase_nds,retail_price_nds,retail_nds,barcode,sign_comission,nomenclature_codes):
        self.map_batch_id =map_batch_id
        self.map_pharmacy_id =map_pharmacy_id
        self.map_pharmacy_name =map_pharmacy_name
        self.nomenclature_id =nomenclature_id
        self.map_nomenclature_name =map_nomenclature_name
        self.map_product_code =map_product_code
        self.map_product_name =map_product_name
        self.producer_id = producer_id
        self.map_producer_code = map_producer_code
        self.map_producer_name = map_producer_name
        self.producer_country_id = producer_country_id
        self.map_producer_country_code = map_producer_country_code
        self.map_producer_country_name = map_producer_country_name
        self.map_supplier_code = map_supplier_code
        self.map_supplier_tin = map_supplier_tin
        self.supplier_name = supplier_name
        self.batch_doc_date = batch_doc_date
        self.batch_doc_number = batch_doc_number
        self.purchase_price_nds = purchase_price_nds
        self.purchase_nds = purchase_nds
        self.retail_price_nds = retail_price_nds
        self.retail_nds = retail_nds
        self.barcode = barcode
        self.sign_comission = sign_comission
        self.nomenclature_codes = nomenclature_codes

class Moves:
    def __init__(self,map_pharmacy_id,distribution_id,batch_id,doc_date,doc_type,doc_number,pos_number,check_number,check_unique_number,quantity,purchase_sum_nds,
                 retail_sum_nds,discount_sum,cashier_id,cashier_full_name,cashier_tin,resale_sign):
        self.map_pharmacy_id = map_pharmacy_id
        self.distribution_id = distribution_id
        self.batch_id = batch_id
        self.doc_date = doc_date
        self.doc_type = doc_type
        self.doc_number = doc_number
        self.pos_number = pos_number
        self.check_number = check_number
        self.check_unique_number = check_unique_number
        self.quantity = quantity
        self.purchase_sum_nds = purchase_sum_nds
        self.retail_sum_nds = retail_sum_nds
        self.discount_sum = discount_sum
        self.cashier_id = cashier_id
        self.cashier_full_name = cashier_full_name
        self.cashier_tin = cashier_tin
        self.resale_sign = resale_sign

class Bases:
    def __init__(self,map_pharmacy_id,batch_id,dates,opening_balance,closing_balance,input_purchasing_price_balance,output_purchasing_price_balance,input_retail_price_balance,
                 output_retail_price_balance):
        self.map_pharmacy_id = map_pharmacy_id
        self.batch_id = batch_id
        self.dates = dates
        self.opening_balance = opening_balance
        self.closing_balance = closing_balance
        self.input_purchasing_price_balance = input_purchasing_price_balance
        self.output_purchasing_price_balance = output_purchasing_price_balance
        self.input_retail_price_balance = input_retail_price_balance
        self.output_retail_price_balance = output_retail_price_balance

        
