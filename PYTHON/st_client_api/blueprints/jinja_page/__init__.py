from flask import Blueprint, request, render_template

blueprint = Blueprint('jinja_primer', __name__, url_prefix='/jinja_primer')

@blueprint.route('')
def get_template():
    top = request.args.get('top') if 'top' in request.args else ''
    bottom = request.args.get('bottom') if 'bottom' in request.args else ''

    return render_template('primer.html', top=top, bottom=bottom)