from flask import request, render_template, make_response
from flask_restx import Namespace, Resource, reqparse

namespace = Namespace(
    'jinja_page',
    'Пример использования Jinja шаблона. ВНИМАНИЕ: Данный\
    раздел не предполагает создание модели и, следовательно,\
    не отображает внешний вид документируемого сервиса')

parser = reqparse.RequestParser()
parser.add_argument('верхний колонтитул', type=str, help='Верхнее значение:')
parser.add_argument('нижний колонтитул', type=str, help='Нижнее значение:')

@namespace.route('')
class JinjaTemplate(Resource):
    @namespace.response(200, 'Render jinja template')
    @namespace.response(500, 'Internal Server error')
    @namespace.expect(parser)
    def get(self):
        '''Визуализация параметров запросов для html-странички на основе
        Jinja шаблона'''
        top = request.args.get('top') if 'top' in request.args else ''
        bottom = request.args.get('bottom') if 'bottom' in request.args else ''
        return make_response(render_template('primer.html', top=top,
                                              bottom=bottom), 200)