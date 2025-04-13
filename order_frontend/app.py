#
# Copyright 2021 The Dapr Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from flask import Flask, jsonify
import requests
import urllib3
import json
import random
import os

app = Flask(__name__)

daprPort = os.getenv("DAPR_HTTP_PORT", 3500)

@app.route('/')
def index():
    with urllib3.PoolManager() as http:
        r = http.request('GET', f'http://localhost:{daprPort}/order', headers={"dapr-app-id": "backendapi"})
        return jsonify(json.loads(r.data.decode('utf-8')))

@app.route('/neworder')
def neworder():
    with urllib3.PoolManager() as http:
        r = http.request(
            'POST',
            f'http://localhost:{daprPort}/neworder',
            headers={'Content-Type': 'application/json', "dapr-app-id": "backendapi"},
            body=json.dumps({"data": {"orderId": str(random.randrange(100))}})
        )
        return jsonify({"status": "Order submitted"})

@app.route('/ports')
def ports():
    return jsonify({"DAPR_HTTP_PORT": daprPort})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)