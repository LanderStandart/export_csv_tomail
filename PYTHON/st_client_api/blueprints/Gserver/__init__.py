from flask import Blueprint
from flask_restx import Api
from .pages import namespace as page_primer_ns
#from .api1 import namespace as sushchnosti_ns
from .jinja_page import namespace as jinja_page_ns

blueprint = Blueprint('swagger', __name__, url_prefix='/swagger')

api_extension = Api(
    blueprint,
    title='Демонстрация возможностей Flask-RESTX',
    version='1.0',
    description='Инструкция к приложению для <b>статьи по Flask REST API\
    </b>, демонстрирующему возможности <b>пакета RESTX</b>, позволяющему\
    создавать масштабируемые сервисы и генерировать API документацию по ним',
    doc='/doc'
)

api_extension.add_namespace(page_primer_ns)

api_extension.add_namespace(jinja_page_ns)