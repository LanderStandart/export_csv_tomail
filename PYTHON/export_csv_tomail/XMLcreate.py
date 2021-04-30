#  Autor by Lander (c) 2021. Created for Standart-N LLT
# Создание XML
# содание основной ветви <root name="attrib">
# add_root(root='root' attrib=["name":"attrib"])
# создание ветви <elem name="attrib">
# add_element(element,root,attrib=["name":"attrib"])
# переменная root указыает узел в который добавляем ветвь
# Создаем подветвь
# add_subelement(subelem='subelem', elem=element, data=date,attrib={"name":"attrib"})

import xml.etree.ElementTree as xml
class XML:
    def __init__(self):
        pass
    #Красивое форматирование с отступами
    def pretty(self,elem, level=0):
        i = "\n" + level * "  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                self.pretty(elem, level + 1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i


    def add_root(self,root,attrib=None):
        self.root = xml.Element(root,attrib) if attrib else xml.Element(root)
        return self.root

    def add_element(self,element,root=None,attrib=None,data=None):
        appt = xml.Element(element,attrib)if attrib else xml.Element(element)
        root.append(appt)
        data = '' if data is None or len(str(data))<1 else data
        appt.text = data
        return appt

    def add_subelement(self,subelem,data,elem=None,attrib=None):
        sub = xml.SubElement(elem, subelem,attrib) if attrib else xml.SubElement(elem, subelem)
        data = str(data)
        if len(data) < 1 or data is None:
            data = ''
        sub.text = data
        return sub

    def save_file(self,root,filename):
        self.pretty(root)

        xml.ElementTree.write(xml.ElementTree(root), filename, encoding='utf-8', method='xml',xml_declaration=True)
