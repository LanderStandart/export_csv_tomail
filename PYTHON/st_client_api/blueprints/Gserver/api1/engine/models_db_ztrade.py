from sqlalchemy import create_engine, MetaData, Table, Integer, String, \
    Column, DateTime, ForeignKey, Numeric,LargeBinary
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
from marshmallow import Schema, fields
Base = declarative_base()

class Agents(Base):
    __tablename__='agents'
    ID= Column(Integer,primary_key=True)
    PARENT_ID = Column(Integer,nullable=False)
    CAPTION = Column(String(250))

class Profiles(Base):
    __tablename__='g$profiles'
    ID = Column(Integer, primary_key=True)
    PARENT_ID = Column(Integer, nullable=False,default=0)
    CAPTION = Column(String(250))
    DESCRIPTION = Column(String(250))
    DBSECUREKEY =Column(String(32))
    STATUS =Column(Integer,default=0)
    DATA = Column(LargeBinary)


class Shema_Profiles(Schema):
    ID = fields.Integer()
    PARENT_ID = fields.Integer()
    CAPTION = fields.String()
    DESCRIPTION =fields.String()
    DBSECUREKEY =fields.String()
    STATUS= fields.Integer()







