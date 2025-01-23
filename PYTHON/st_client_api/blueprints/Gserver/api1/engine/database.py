from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from ..config import settings

class db_ztrade():
    def __init__(self):
        # host = 'localhost'  # или IP-адрес сервера
        # database = 'E:\Standart-N\Clients\Gemedji\ZTRADE.FDB'  # путь к файлу базы данных
        # user = 'SYSDBA'  # имя пользователя
        # password = 'masterkey'  # пароль
        # port = '3050'  # порт (по умолчанию 3050)
        # charset = 'WIN1251'  # кодировка
        # #Строка подключения
        # connection_string = f"firebird+fdb://{user}:{password}@{host}:{port}/{database}?charset={charset}"

        # Создание движка
        print(settings.DATABASE_URL_ZTRADE)
        self.ztrade_engine = create_engine(settings.DATABASE_URL_ZTRADE, echo=True, implicit_returning=False)
        # Создание базового класса для моделей

        # Создание сессии
        self.Session = sessionmaker(bind=self.ztrade_engine)
        self.session = self.Session()
