from flask import Flask,current_app
#from blueprints.Helpdesk.pages import blueprint as pages
from blueprints.Gserver.api1 import blueprint as final_api
from flask_api_key import APIKeyManager

app = Flask(__name__)
#app.register_blueprint(pages)
app.register_blueprint(final_api)
app.secret_key='2D0F6484-D970-40DB-A76C-ED3B2612739E'



app.config['JSON_AS_ASCII'] = False
app.config['JSON_SORT_KEYS'] = False

if __name__ == "__main__":
    app.run(debug=True)