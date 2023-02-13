import os
import logging
from flask import Flask
from gevent import pywsgi, monkey; monkey.patch_all()
from web.www.LatentHandler import latent
from encode.encode import init_main

BASE_DIR = os.path.dirname(__file__)

app = Flask(__name__, static_folder="web/static", static_url_path="")
app.register_blueprint(latent)


@app.route('/', methods=['GET', 'POST'])
def main_handler():
    return "main"


if __name__ == '__main__':
    print("server init")
    init_main()

    handler = logging.FileHandler('flask.log', encoding='UTF-8')
    handler.setFormatter(logging.Formatter('%(asctime)s %(filename)s %(lineno)s: %(message)s'))
    app.logger.addHandler(handler)

    print("server starting...")
    server = pywsgi.WSGIServer(('0.0.0.0', 8800), app)
    server.serve_forever()
