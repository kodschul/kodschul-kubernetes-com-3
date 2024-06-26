from flask import Flask
import socket
import os
import requests
from datetime import datetime
from dotenv import load_dotenv

hostname = os.uname()[1]
ips = socket.gethostbyname_ex(hostname)[2]


load_dotenv()
app = Flask(__name__)


@app.route('/')
def index():

    try:
        os.mkdir("/data")
    except:
        pass

    with open("/data/access.log", "a+") as file:

        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        file.write(f"\n Processed by {ips} at {now}")

    secret_pass = os.getenv("DB_SECRET")

    backend_response = requests.get("http://backend:80").text
    backend_response = "Backend is coming later!"
    backend_response = ips
    return f'<html style="background:aqua;">Hello World V3, DB_SECRET: {secret_pass},  The backend said: {backend_response} </html>'
    # return f'<html style="background:orange;">Hello World V1 </html>'


app.run(host='0.0.0.0', port=80, debug=True)
