from flask import Flask
import socket
import os
import requests


hostname = os.uname()[1]
ips = socket.gethostbyname_ex(hostname)[2]


app = Flask(__name__)


@app.route('/')
def index():

    backend_response = requests.get("http://backend:80").text
    # backend_response = "Backend is coming later!"
    # backend_response = ips
    return f'<html style="background:green;">Hello World V1: IP: {ips}, The backend said: {backend_response} </html>'
    # return f'<html style="background:yellow;">Hello World V1 from {ips}</html>'


app.run(host='0.0.0.0', port=80, debug=False)
