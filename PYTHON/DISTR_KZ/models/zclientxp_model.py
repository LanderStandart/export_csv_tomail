from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String,DateTime

Base =declarative_base()

class Zclient(Base):
    __tablename__ = 'ZCLIENTS'
    id = Column(Integer,primary_key=True,autoincrement=True)
    client_type = Column(Integer)
    client_name = Column(String(255))
    insertdt = Column(DateTime)
    insertby = Column(String(64))
    status = Column(Integer)
    inn = Column(String(20))