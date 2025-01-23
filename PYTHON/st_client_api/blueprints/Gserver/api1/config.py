from pydantic_settings import BaseSettings, SettingsConfigDict
import os


class Settings(BaseSettings):
    DB_HOST: str
    db_path: str
    db_user: str
    db_password: str
    db_port: int
    db_charset: str

    @property
    def DATABASE_URL_ZTRADE(self):
        return f"firebird+fdb://{self.db_user}:{self.db_password}@{self.DB_HOST}:{self.db_port}/{self.db_path}" \
               f"?charset={self.db_charset}"


    model_config = SettingsConfigDict(env_file=os.path.join(os.path.dirname(__file__),'.env'))


settings = Settings()
