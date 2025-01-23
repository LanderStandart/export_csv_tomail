from flask import request
from flask_restx import Namespace, Resource, fields

namespace = Namespace('pages1',
                      'Статическая страничка с приветственным текстом')

welcome_text_model = namespace.model('WelcomeText', {
    'message': fields.String(
        readonly=True,
        description='<h1>Мне кажется, или я реально уже в браузере?!</h1>'
    )
})

welcome_text_primer = {'message': 'Мне кажется, или я реально уже в браузере?!'}

@namespace.route('')
class WelcomeText(Resource):
    @namespace.marshal_list_with(welcome_text_model)
    @namespace.response(500, 'Internal Server error')
    def get(self):
        '''Статическая страничка с приветственным текстом'''
        return welcome_text_primer