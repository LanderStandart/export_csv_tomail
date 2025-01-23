from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String

Base =declarative_base()

class Sup_code(Base):
    __tablename__ = 'SUP_CODE'
    id = Column(Integer,primary_key=True,autoincrement=True)
    BIN = Column(String(25))
    ADDRESS = Column(String(250))
    POST_ID = Column(Integer)
    CODE = Column(String(250))
    CONTRACT = Column(String(250))
    STORE = Column(String(250))

class Oz_client(Base):
    __tablename__ = 'OZ_CLIENTS'
    id = Column(Integer,primary_key=True,autoincrement=True)
    p_id = Column(Integer)
    name = Column(String(250))
    inn = Column(String(20))
    oz_client_id = Column(Integer)
